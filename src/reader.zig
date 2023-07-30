const File = @import("std").fs.File;
const mem = @import("std").mem;
const dicom_types = @import("types.zig");

const DataElement = dicom_types.DataElement;
const Tag = dicom_types.Tag;

const MAGIC_WORD = "DICM";

// error set for the DICOM parser
const DICOMError = error{
    NoMagicWord,
};

// check the preamble
// (first 132 bytes, 128 empty bytes + 4 byte magic word, DICM)
pub fn verifyPreamble(reader: File.Reader) !void {
    try reader.skipBytes(128, .{}); // skip 128 bytes

    // check for the DICM magic string
    const magic_word = try reader.readBytesNoEof(4);
    if (!mem.eql(u8, &magic_word, MAGIC_WORD)) {
        return DICOMError.NoMagicWord;
    }
}

pub fn readElement(reader: File.Reader) !DataElement {
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

fn readTag(reader: File.Reader) !Tag {
    return Tag{
        // Group Number
        .group = try reader.readIntLittle(u16),
        // Element Number
        .element = try reader.readIntLittle(u16),
    };
}
