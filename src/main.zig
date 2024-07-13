const std = @import("std");
const dicom_reader = @import("reader.zig");
const dicom_types = @import("types.zig");
const decoder = @import("decoder.zig");

const DataElement = dicom_types;

const fmt = std.fmt;
const mem = std.mem;
const io = std.io;

const File = std.fs.File;
const Case = fmt.Case;

const TEST_PATH = "samples/IM-0001-0001.dcm";

// TODO pass CLI flags and stuff
pub fn main() !void {
    std.debug.print("⚡︎ Zig DICOM v{s}\n\n", .{"0.1.0"});

    std.debug.print("file\t\t{s}\n", .{TEST_PATH});

    const dataset = try decoder.decode(TEST_PATH);

    std.debug.print("\n", .{});
    std.debug.print("╔═══════ PREAMBLE ══════╗\n", .{});
    std.debug.print("║  0x00(×128)         \t║\n", .{});
    std.debug.print("║  MAGIC_WORD   yes   \t║\n", .{});
    for (dataset) |element| {
        std.debug.print("╠═══════ ELEMENT ═══════╣\n", .{});
        std.debug.print("║                       ║\n", .{});
        std.debug.print("╟───────── TAG ─────────╢\n", .{});
        std.debug.print("║ group    \t0x{x:0>4}  ║\n", .{element.tag.group});
        std.debug.print("║ element  \t0x{x:0>4}  ║\n", .{element.tag.element});
        std.debug.print("╟─────── VR / VL ───────╢\n", .{});
        std.debug.print("║ VR            {s}   \t║\n", .{&element.vr});
        std.debug.print("║ VL            {d}   \t║\n", .{element.vl});
        std.debug.print("╟──────── VALUE ────────╢\n", .{});
        std.debug.print("║ value         {any} \t║\n", .{element.value});
    }
    std.debug.print("╚═══════════════════════╝\n", .{});
}
