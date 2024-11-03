// This kernel uses the VGA text mode buffer (located at 0xB8000) as the output device.
// It sets up a simple driver that remembers the location of the next character in this buffer and provides a primitive for adding a new character.

const std = @import("std");
const vga = @import("vga.zig");

const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;
const VGA_SIZE: usize = VGA_WIDTH * VGA_HEIGHT;
var terminal_row: usize = 0;
var terminal_column: usize = 0;
var terminal_color: u8 = vga.vga_build_color_base(vga.VGA_Color.VGA_COLOR_WHITE, vga.VGA_Color.VGA_COLOR_DARK_GREY);
var terminal_buffer: [*]volatile u16 = @ptrFromInt(0xB8000);

pub fn terminal_initialize() !void {
    try clear();
}

fn clear() !void {
    @memset(terminal_buffer[0..VGA_SIZE], vga.vga_build_colored_character(' ', terminal_color));
    terminal_column = 0;
    terminal_row = 0;
}

fn terminal_set_color(c: vga.VGA_Color) !void {
    terminal_color = c;
}

fn terminal_put_char_at(char: u8, color: u8, x: usize, y: usize) !void {
    const idx = y * VGA_WIDTH + x;
    terminal_buffer[idx] = vga.vga_build_colored_character(char, color);
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

fn terminal_bounds_check() !void {
    if (terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        terminal_row += 1;
    }

    if (terminal_row == VGA_HEIGHT) {
        try terminal_push_content_up();
        terminal_row = VGA_HEIGHT - 1;
    }
}

fn terminal_put_char(char: u8) !void {
    if (char == '\n') {
        try terminal_new_line();
    } else {
        try terminal_put_char_at(char, terminal_color, terminal_column, terminal_row);
        terminal_column += 1;
    }

    try terminal_bounds_check();
}

pub fn terminal_write_string(data: []const u8) !void {
    for (data) |c| {
        try terminal_put_char(c);
    }
}
