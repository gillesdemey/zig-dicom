const std = @import("std");
const dicom_reader = @import("reader.zig");
const dicom_types = @import("types.zig");

const DataElement = dicom_types;

pub fn decode (path: anytype) !dicom_types.DataSet {
  // 1. open file, read some metadata and get a file reader
  const file = try std.fs.cwd().openFile(path, .{});
  defer file.close();

  const file_meta = try file.metadata();

  const file_size = file_meta.size();
  const file_reader = file.reader();

  std.debug.print("size\t\t{s}\n", .{std.fmt.fmtIntSizeDec(file_size)});

  return try dicom_reader.readHeader(file_reader);
}
