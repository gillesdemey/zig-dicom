const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

const Endian = std.builtin.Endian;
const Case = fmt.Case;

const path = "samples/IM-0001-0001.dcm";
const MAGIC_WORD = "DICM";

// error set for the DICOM parser
const DICOMError = error{
    NoMagicWord,
};

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

    // 2. skip 128 bytes, this is the preamble
    try file.seekTo(128);

    // 3. check for the DICM magic string
    const magic_word = try file_reader.readBytesNoEof(4);
    if (!mem.eql(u8, &magic_word, MAGIC_WORD)) {
        return DICOMError.NoMagicWord;
    }

    // now we must read a tag + value (collectively called an element)

    // Must read metadata as LittleEndian explicit VR
    // Read the length of the metadata elements: (0002,0000) MetaElementGroupLength
    const group = try file_reader.readBytesNoEof(2);
    const element = try file_reader.readBytesNoEof(2);

    // Explicit Transfer Syntax, read 2 byte VR:
    const vr = try file_reader.readBytesNoEof(2);
    // Now read the VL based on the VR (UL) (16-bit unsigned integer)
    const vl = try file_reader.readIntLittle(u16);
    // now read the value based on the VR and VL
    const value = try file_reader.readIntLittle(u32);

    std.debug.print("\n", .{});
    std.debug.print("╔═══════ PREAMBLE ══════╗\n", .{});
    std.debug.print("║  0x00(×128)         \t║\n", .{});
    std.debug.print("║  MAGIC_WORD   {s}   \t║\n", .{&magic_word});
    std.debug.print("╠═══════ ELEMENT ═══════╣\n", .{});
    std.debug.print("║                       ║\n", .{});
    std.debug.print("╟───────── TAG ─────────╢\n", .{});
    std.debug.print("║ group         {s}   \t║\n", .{fmt.bytesToHex(group, Case.lower)});
    std.debug.print("║ element       {s}   \t║\n", .{fmt.bytesToHex(element, Case.lower)});
    std.debug.print("╟─────── VR / VL ───────╢\n", .{});
    std.debug.print("║ VR            {s}   \t║\n", .{&vr});
    std.debug.print("║ VL            {d}   \t║\n", .{vl});
    std.debug.print("╟──────── VALUE ────────╢\n", .{});
    std.debug.print("║ value         {any} \t║\n", .{value});
    std.debug.print("╚═══════════════════════╝\n", .{});
}
