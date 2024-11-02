// This kernel uses the VGA text mode buffer (located at 0xB8000) as the output device.
// It sets up a simple driver that remembers the location of the next character in this buffer and provides a primitive for adding a new character.

const std = @import("std");

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
const VGA_SIZE: usize = VGA_WIDTH * VGA_HEIGHT;
var terminal_row: usize = 0;
var terminal_column: usize = 0;
var terminal_color: Color = Color.VGA_COLOR_BLACK;
var terminal_buffer: [*]volatile u16 = @ptrFromInt(0xB8000);

fn vga_build_color_base(fg: Color, bg: Color) Color {
    const colorByte = @intFromEnum(fg) | std.math.shl(u8, @intFromEnum(bg), 4);
    return @enumFromInt(colorByte);
}

fn vga_build_colored_character(character: u8, color: Color) u16 {
    return character | std.math.shl(u8, @intFromEnum(color), 8);
}

pub fn terminal_initialize() !void {
    try clear();
}

fn clear() !void {
    @memset(terminal_buffer[0..VGA_SIZE], vga_build_colored_character(' ', vga_build_color_base(Color.VGA_COLOR_WHITE, Color.VGA_COLOR_BLACK)));
}

fn terminal_set_color(c: Color) !void {
    terminal_color = c;
}

fn terminal_put_char_at(char: u8, color: Color, x: usize, y: usize) !void {
    const idx = y * VGA_WIDTH + x;
    terminal_buffer[idx] = vga_build_colored_character(char, color);
}

fn terminal_put_char(char: u8) !void {
    try terminal_put_char_at(char, terminal_color, terminal_column, terminal_row);
    if (terminal_column + 1 == VGA_WIDTH) {
        terminal_column = 0;
        if (terminal_row + 1 == VGA_HEIGHT) {
            terminal_row = 0;
        }
    }
}

fn terminal_write(data: []const u8, size: usize) !void {
    for (0..size) |i| {
        try terminal_put_char(data[i]);
    }
}

pub fn terminal_write_string(data: []const u8) !void {
    try terminal_write(data, data.len);
}
