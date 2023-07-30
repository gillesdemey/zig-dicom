const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

const Case = fmt.Case;

const path = "samples/IM-0001-0001.dcm";
const MAGIC_WORD = "DICM";

// error set for the DICOM parser
const DICOMError = error{
    NoMagicWord,
};

pub fn main() !void {
    std.debug.print("⚡︎ Zig DICOM v{s}\n", .{"0.1.0"});
    std.debug.print("\nfile\t\t{s}\n", .{path});

    // 1. buffer entire file
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_meta = try file.metadata();
    const file_size = file_meta.size();
    std.debug.print("size\t\t{s}\n", .{fmt.fmtIntSizeDec(file_size)});

    // 2. skip 128 bytes, this is the preamble
    try file.seekTo(128);

    // 3. check for the DICM magic string
    var magic_word: [4]u8 = undefined;
    _ = try file.read(&magic_word);
    if (!mem.eql(u8, &magic_word, MAGIC_WORD)) {
        return DICOMError.NoMagicWord;
    }

    std.debug.print("MAGIC_WORD\t{}\n", .{true});

    // Must read metadata as LittleEndian explicit VR
    // Read the length of the metadata elements: (0002,0000) MetaElementGroupLength
    var group: [2]u8 = undefined;
    var element: [2]u8 = undefined;

    _ = try file.read(&group);
    _ = try file.read(&element);

    std.debug.print("\n--- METADATA ---\n", .{});
    std.debug.print("group\t\t{s}\n", .{fmt.bytesToHex(group, Case.lower)});
    std.debug.print("element\t\t{s}\n", .{fmt.bytesToHex(element, Case.lower)});
}
