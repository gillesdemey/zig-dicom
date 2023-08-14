const std = @import("std");
const mem = @import("std").mem;
const ArrayList = @import("std").ArrayList;
const dicom_types = @import("types.zig");

const fixedBufferStream = std.io.fixedBufferStream;

const DataSet = dicom_types.DataSet;
const DataElement = dicom_types.DataElement;
const Tag = dicom_types.Tag;

const MAGIC_WORD = "DICM";

// error set for the DICOM parser
const DICOMError = error{
    NoMagicWord,
};

// check the preamble
// (first 132 bytes, 128 empty bytes + 4 byte magic word, DICM)
fn verifyPreamble(reader: anytype) !void {
    try reader.skipBytes(128, .{}); // skip 128 bytes

    // check for the DICM magic string
    const magic_word = try reader.readBytesNoEof(4);
    if (!mem.eql(u8, &magic_word, MAGIC_WORD)) {
        return DICOMError.NoMagicWord;
    }
}

// this function will read the DICOM file header
// TODO maybe we want a faster allocator than std.heap.page_allocator
pub fn readHeader(reader: anytype) !DataSet {
    // start by verifying the preamble to see if we're dealing with a valid DICOM file
    try verifyPreamble(reader);

    // now we must read a tag + value (collectively called an element)

    // Must read metadata as LittleEndian explicit VR, BigEndian has been retired (see PS3.5 2016b)
    // Read the length of the metadata elements: (0002,0000) MetaElementGroupLength
    const groupLengthElement = try readElement(reader);

    // now we know how many bytes we need to read the entire header; allocate memory for it
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, groupLengthElement.value);
    defer allocator.free(buffer);

    // push elements on to the ArrayList
    var headerElements = ArrayList(DataElement).init(allocator);
    defer headerElements.deinit();
    try headerElements.append(groupLengthElement);

    // now we just have to read x bytes in to memory and parse them as elements
    var fbs = fixedBufferStream(buffer);

    // we'll keep reading until we get a EndOFStream, which indicates our buffer stream is
    // empty and we've exhausted our header elements
    while (readElement(fbs.reader())) |element| {
        try headerElements.append(element);
    } else |err| {
        // we'll return all of the elements we've reached the end of the stream
        if (err == error.EndOfStream) {
            return try headerElements.toOwnedSlice();
        }
        // any other error is just returned and should be handled
        return err;
    }
}

pub fn readElement(reader: anytype) !DataElement {
    return DataElement{
        .tag = try readTag(reader),
        // Explicit Transfer Syntax, read 2 byte VR
        .vr = try reader.readBytesNoEof(2),
        // Now read the VL based on the VR (UL) (16-bit unsigned integer)
        .vl = try reader.readIntLittle(u16),
        // now read value based on vr and vl
        .value = try reader.readIntLittle(u32),
    };
}

fn readTag(reader: anytype) !Tag {
    return Tag{
        // Group Number
        .group = try reader.readIntLittle(u16),
        // Element Number
        .element = try reader.readIntLittle(u16),
    };
}
