// This kernel uses the VGA text mode buffer (located at 0xB8000) as the output device.
// It sets up a simple driver that remembers the location of the next character in this buffer and provides a primitive for adding a new character.

const Color = enum(u8) {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};

const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;
var terminal_row: usize = 0;
var terminal_column: usize = 0;
var terminal_color: u8 = 0;
var terminal_buffer: *u16 = 0;

pub fn terminal_initialize() !void {
    terminal_buffer = 0xB8000;
    for (0..VGA_HEIGHT) |y| {
        for (0..VGA_WIDTH) |x| {
            const index: usize = y * VGA_WIDTH + x;
            terminal_buffer[index] = 0;
        }
    }
}
