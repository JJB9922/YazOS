const IDTEntry = struct { function_pointer_low: u16, gdt_selector: u16, options: u16, function_pointer_mid: u16, function_pointer_high: u16, reserved: u32 = 0 };

const IDTRegister = struct { limit: u16, base: u64 };

pub const idt: [256]IDTEntry = undefined;
pub const idtr: IDTRegister = undefined;

pub fn exception_handler() void {
    asm volatile (
        \\ cli; hlt
    );
}
