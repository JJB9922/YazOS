const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .x86, .os_tag = .freestanding } });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "YazOS.ELF", .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize, .code_model = .kernel });

    exe.setLinkerScript(b.path("src/linker.ld"));

    b.installArtifact(exe);

    const run_cmd = b.addSystemCommand(&.{"qemu-system-x86_64"});
    run_cmd.addArg("-kernel");
    run_cmd.addArg("./zig-out/bin/YazOS.ELF");

    const run_step = b.step("run", "Run the kernel in QEMU");
    run_step.dependOn(&run_cmd.step);
}
