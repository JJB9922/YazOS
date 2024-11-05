const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .x86, .os_tag = .freestanding } });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "YazOS.elf", .root_source_file = b.path("src/kernel/arch/i386/boot.zig"), .target = target, .optimize = optimize, .code_model = .kernel });

    const tty_mod = b.addModule("tty", .{ .root_source_file = b.path("src/kernel/arch/i386/tty.zig") });
    const gdt_mod = b.addModule("gdt", .{ .root_source_file = b.path("src/kernel/arch/i386/gdt.zig") });
    const kernel_mod = b.addModule("kernel", .{ .root_source_file = b.path("src/kernel/kernel/kernel.zig"), .imports = &.{} });

    exe.setLinkerScript(b.path("src/kernel/arch/i386/linker.ld"));
    exe.root_module.addImport("kernel", kernel_mod);
    gdt_mod.addImport("tty", tty_mod);
    kernel_mod.addImport("gdt", gdt_mod);
    kernel_mod.addImport("tty", tty_mod);

    b.installArtifact(exe);

    const run_cmd = b.addSystemCommand(&.{"qemu-system-x86_64"});
    run_cmd.addArg("-kernel");
    run_cmd.addArg("./zig-out/bin/YazOS.elf");

    const run_step = b.step("run", "Run the kernel in QEMU");
    run_step.dependOn(&run_cmd.step);

    const mkdir_cmd = b.addSystemCommand(&.{"mkdir"});
    mkdir_cmd.addArg("-p");
    mkdir_cmd.addArg("isodir/boot/grub");

    const cp_kernel_cmd = b.addSystemCommand(&.{"cp"});
    cp_kernel_cmd.addArg("zig-out/bin/YazOS.elf");
    cp_kernel_cmd.addArg("isodir/boot/YazOS.elf");
    cp_kernel_cmd.step.dependOn(&mkdir_cmd.step);

    const cp_grub_cmd = b.addSystemCommand(&.{"cp"});
    cp_grub_cmd.addArg("grub.cfg");
    cp_grub_cmd.addArg("isodir/boot/grub/grub.cfg");
    cp_grub_cmd.step.dependOn(&cp_kernel_cmd.step);

    const grub_cmd = b.addSystemCommand(&.{"grub-mkrescue"});
    grub_cmd.addArg("-o");
    grub_cmd.addArg("YazOS.iso");
    grub_cmd.addArg("isodir");
    grub_cmd.step.dependOn(&cp_grub_cmd.step);

    //const qemu_cmd = b.addSystemCommand(&.{"qemu-system-i386"});
    //qemu_cmd.addArg("-cdrom");
    //qemu_cmd.addArg("YazOS.iso");
    //qemu_cmd.step.dependOn(&grub_cmd.step);

    const package_step = b.step("package", "Package an ISO of the kernel and run it from QEMU");
    package_step.dependOn(&grub_cmd.step);
}
