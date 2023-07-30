const std = @import("std");
const dicom_reader = @import("reader.zig");
const dicom_types = @import("types.zig");

const DataElement = dicom_types;

const fmt = std.fmt;
const mem = std.mem;
const io = std.io;

const File = std.fs.File;
const Case = fmt.Case;

const path = "samples/IM-0001-0001.dcm";

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

    try dicom_reader.verifyPreamble(file_reader);

    // now we must read a tag + value (collectively called an element)

    // Must read metadata as LittleEndian explicit VR, BigEndian has been retired (see PS3.5 2016b)
    // Read the length of the metadata elements: (0002,0000) MetaElementGroupLength
    const element = try dicom_reader.readElement(file_reader);
    const tag = element.tag;

    std.debug.print("\n", .{});
    std.debug.print("╔═══════ PREAMBLE ══════╗\n", .{});
    std.debug.print("║  0x00(×128)         \t║\n", .{});
    std.debug.print("║  MAGIC_WORD   yes   \t║\n", .{});
    std.debug.print("╠═══════ ELEMENT ═══════╣\n", .{});
    std.debug.print("║                       ║\n", .{});
    std.debug.print("╟───────── TAG ─────────╢\n", .{});
    std.debug.print("║ group    \t0x{x:0>4}  ║\n", .{tag.group});
    std.debug.print("║ element  \t0x{x:0>4}  ║\n", .{tag.element});
    std.debug.print("╟─────── VR / VL ───────╢\n", .{});
    std.debug.print("║ VR            {s}   \t║\n", .{&element.vr});
    std.debug.print("║ VL            {d}   \t║\n", .{element.vl});
    std.debug.print("╟──────── VALUE ────────╢\n", .{});
    std.debug.print("║ value         {any} \t║\n", .{element.value});
    std.debug.print("╚═══════════════════════╝\n", .{});
}
