const std = @import("std");

pub fn build(b: *std.Build) void {
  const exec = b.addExecutable(.{
      .name = "zig-dicom",
      .root_source_file = b.path("src/main.zig"),
      .target = b.host,
  });

  b.installArtifact(exec);

  const run_exec = b.addRunArtifact(exec);

  const run_step = b.step("run", "Run the application");
  run_step.dependOn(&run_exec.step);
}
