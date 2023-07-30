const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const io = std.io;

const File = std.fs.File;
const Case = fmt.Case;

const path = "samples/IM-0001-0001.dcm";
const MAGIC_WORD = "DICM";

// error set for the DICOM parser
const DICOMError = error{
    NoMagicWord,
};

// See Chapter 7 on Data Set, Data Elements and Data Element Fields
// https://dicom.nema.org/medical/dicom/current/output/html/part05.html#chapter_7
const DataSet = struct { elements: []DataElement };
const DataElement = struct { tag: Tag, vr: [2]u8, vl: u16, value: u32 };
const Tag = struct { group: [2]u8, element: [2]u8 };

// TODO pass CLI flags and stuff
pub fn main() !void {
    std.debug.print("⚡︎ Zig DICOM v{s}\n\n", .{"0.1.0"});

    // 1. open file, read some metadata and get a file reader
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_meta = try file.metadata();

    const file_size = file_meta.size();
    const file_reader = file.reader();

    std.debug.print("file\t\t{s}\n", .{path});
    std.debug.print("size\t\t{s}\n", .{fmt.fmtIntSizeDec(file_size)});

    try verifyPreamble(file_reader);

    // now we must read a tag + value (collectively called an element)

    // Must read metadata as LittleEndian explicit VR, BigEndian has been retired (see PS3.5 2016b)
    // Read the length of the metadata elements: (0002,0000) MetaElementGroupLength
    const element = try readElement(file_reader);
    const tag = element.tag;

    std.debug.print("\n", .{});
    std.debug.print("╔═══════ PREAMBLE ══════╗\n", .{});
    std.debug.print("║  0x00(×128)         \t║\n", .{});
    std.debug.print("║  MAGIC_WORD   yes   \t║\n", .{});
    std.debug.print("╠═══════ ELEMENT ═══════╣\n", .{});
    std.debug.print("║                       ║\n", .{});
    std.debug.print("╟───────── TAG ─────────╢\n", .{});
    std.debug.print("║ group         {s}   \t║\n", .{fmt.fmtSliceHexLower(&tag.group)});
    std.debug.print("║ element       {s}   \t║\n", .{fmt.fmtSliceHexLower(&tag.element)});
    std.debug.print("╟─────── VR / VL ───────╢\n", .{});
    std.debug.print("║ VR            {s}   \t║\n", .{&element.vr});
    std.debug.print("║ VL            {d}   \t║\n", .{element.vl});
    std.debug.print("╟──────── VALUE ────────╢\n", .{});
    std.debug.print("║ value         {any} \t║\n", .{element.value});
    std.debug.print("╚═══════════════════════╝\n", .{});
}

// check the preamble
// (first 132 bytes, 128 empty bytes + 4 byte magic word, DICM)
fn verifyPreamble(reader: File.Reader) !void {
    try reader.skipBytes(128, .{}); // skip 128 bytes

    // check for the DICM magic string
    const magic_word = try reader.readBytesNoEof(4);
    if (!mem.eql(u8, &magic_word, MAGIC_WORD)) {
        return DICOMError.NoMagicWord;
    }
}

fn readElement(reader: File.Reader) !DataElement {
    const tag = try readTag(reader);

    // Explicit Transfer Syntax, read 2 byte VR:
    const vr = try reader.readBytesNoEof(2);
    // Now read the VL based on the VR (UL) (16-bit unsigned integer)
    const vl = try reader.readIntLittle(u16);
    // now read the value based on the VR and VL
    const value = try reader.readIntLittle(u32);

    return DataElement{ .tag = tag, .vr = vr, .vl = vl, .value = value };
}

fn readTag(reader: File.Reader) !Tag {
    const group = try reader.readBytesNoEof(2);
    const element = try reader.readBytesNoEof(2);

    return Tag{ .group = group, .element = element };
}
