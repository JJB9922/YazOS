const tty = @import("tty");

pub fn kernel_main() void {
    try tty.terminal_initialize();
    try tty.terminal_write_string("SneebleOS");
}
