const tty = @import("tty");

const GDT = struct { base: i64, limit: u32, access_byte: u8, flags: u16, offset: i64 };

fn encode_gdt_entry(target: [*]u8, source: GDT) void {
    if (source.limit > 0xFFFFF) {
        // TODO replace w a proper error
        tty.terminal_write_string("GDT cannot encode limits larger than 0xFFFFF");
    }

    // Encode limit
    target[0] = source.limit & 0xFF;
    target[1] = (source.limit >> 8) & 0xFF;
    target[6] = (source.limit >> 16) & 0x0F;

    // Encode base
    target[2] = source.base & 0xFF;
    target[3] = (source.base >> 8) & 0xFF;
    target[4] = (source.base >> 16) & 0xFF;
    target[7] = (source.base >> 24) & 0xFF;

    // Encode access byte
    target[5] = source.access_byte;

    // Encode flags
    target[6] |= (source.flags << 4);
}

pub fn set_gdt(limit: u32, base: i64) void {
    _ = limit;
    _ = base;
    asm volatile (
        \\ gdtr:
        \\ .word 0
        \\ .long 0
        \\ setGdt:
        \\ movw 4(%esp), %ax
        \\ movw %ax, (gdtr)
        \\ movl 8(%esp), %eax
        \\ movl %eax, (gdtr + 2)
        \\ lgdt gdtr
        \\ ret
    );
}

pub fn reload_segment_registers() void {
    asm volatile (
        \\ reloadSegments:
        \\  ljmp $0x08, $.reload_CS    // Long jump with segment selector
        \\ .reload_CS:
        \\  movw $0x10, %ax            // Load data segment selector
        \\  movw %ax, %ds              // Reload DS
        \\  movw %ax, %es              // Reload ES
        \\  movw %ax, %fs              // Reload FS
        \\  movw %ax, %gs              // Reload GS
        \\  movw %ax, %ss              // Reload SS
        \\  ret
    );
}
