const tty = @import("tty");

pub fn kernel_main() void {
    try tty.terminal_initialize();
    tty.terminal_write_string("SneebleOS");
}
