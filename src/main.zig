const console = @import("console.zig");

const ALIGNMENT_FLAG = 1 << 0;
const MEMORY_FLAG = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGNMENT_FLAG | MEMORY_FLAG;

const MultiBoot = packed struct { magic: i32 = MAGIC, flags: i32, checksum: i32, _: u32 = 0 };

export var multiboot align(4) linksection(".multiboot") = MultiBoot{ .flags = FLAGS, .checksum = -(MAGIC + FLAGS) };

var stack: [4096]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ movl %[stk], %esp
        \\ movl %esp, %ebp
        \\ call main
        :
        : [stk] "{ecx}" (@intFromPtr(&stack) + @sizeOf(@TypeOf(stack))),
    );
    while (true) {}
}

export fn main() void {
    try console.terminal_initialize();
    try console.terminal_write_string("Hello");
}
