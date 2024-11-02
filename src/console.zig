// This kernel uses the VGA text mode buffer (located at 0xB8000) as the output device.
// It sets up a simple driver that remembers the location of the next character in this buffer and provides a primitive for adding a new character.

const std = @import("std");
const fmt = @import("std").fmt;
const Writer = @import("std").io.Writer;

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
var terminal_color: u8 = vga_build_color_base(Color.VGA_COLOR_WHITE, Color.VGA_COLOR_BLUE);
var terminal_buffer: [*]volatile u16 = @ptrFromInt(0xB8000);

fn vga_build_color_base(fg: Color, bg: Color) u8 {
    return (@intFromEnum(fg) | std.math.shl(u8, @intFromEnum(bg), 4));
}

fn vga_build_colored_character(character: u8, color: u8) u16 {
    return character | std.math.shl(u16, color, 8);
}

pub fn terminal_initialize() !void {
    try clear();
}

fn clear() !void {
    @memset(terminal_buffer[0..VGA_SIZE], vga_build_colored_character(' ', terminal_color));
    terminal_column = 0;
    terminal_row = 0;
}

fn terminal_set_color(c: Color) !void {
    terminal_color = c;
}

fn terminal_put_char_at(char: u8, color: u8, x: usize, y: usize) !void {
    const idx = y * VGA_WIDTH + x;
    terminal_buffer[idx] = vga_build_colored_character(char, color);
}

fn terminal_new_line() !void {
    terminal_row += 1;
    terminal_column = 0;
}

fn terminal_push_content_up() !void {
    for (1..VGA_HEIGHT) |row_idx| {
        for (0..VGA_WIDTH) |col_idx| {
            try terminal_put_char_at(@truncate(terminal_buffer[(row_idx * VGA_WIDTH) + col_idx]), terminal_color, col_idx, row_idx - 1);
        }
    }
}

fn terminal_put_char(char: u8) !void {
    if (char == '\n') {
        try terminal_new_line();
    } else {
        try terminal_put_char_at(char, terminal_color, terminal_column, terminal_row);
        terminal_column += 1;
    }

    if (terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        terminal_row += 1;
    }

    if (terminal_row == VGA_HEIGHT) {
        try terminal_push_content_up();
        terminal_row = VGA_HEIGHT - 1;
    }
}

pub fn terminal_write_string(data: []const u8) !void {
    for (data) |c| {
        try terminal_put_char(c);
    }
}
