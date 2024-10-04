const fmt = @import("std").fmt;
const mem = @import("std").mem;
const Writer = @import("std").io.Writer;

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const Colours = enum(u8) { Black = 0, Blue = 1, Green = 2, Cyan = 3, Red = 4, Magenta = 5, Brown = 6, LightGray = 7, DarkGray = 8, LightBlue = 9, LightGreen = 10, LightCyan = 11, LightRed = 12, LightMagenta = 13, LightBrown = 14, White = 15 };

var row: usize = 0;
var column: usize = 0;
var colour = vgaEntryColour(Colours.LightGray, Colours.Black);
var buffer: [*]volatile u16 = @ptrFromInt(0xB8000);

fn vgaEntryColour(fg: Colours, bg: Colours) u8 {
    return @intFromEnum(fg) | (@intFromEnum(bg) << 4);
}

fn vgaEntry(uc: u8, newColour: u8) u16 {
    const c: u16 = newColour;
    return uc | (c << 8);
}

pub fn setColours(fg: Colours, bg: Colours) void {
    colour = vgaEntryColour(fg, bg);
}

pub fn setForegroundColour(fg: Colours) void {
    colour = (0xF0 & colour) | @intFromEnum(fg);
}

pub fn setBackgroundColor(bg: Colours) void {
    colour = (0x0F & colour) | (@intFromEnum(bg) << 4);
}

pub fn clear() void {
    @memset(buffer[0..VGA_SIZE], vgaEntry(' ', colour));
}

pub fn setLocation(x: u8, y: u8) void {
    row = x % VGA_WIDTH;
    column = y & VGA_HEIGHT;
}

fn putCharAt(c: u8, newColour: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    buffer[index] = vgaEntry(c, newColour);
}

pub fn putChar(c: u8) void {
    if (c == '\n') {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT) row = 0;
        return;
    }

    putCharAt(c, colour, column, row);
    column += 1;

    if (column == VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT) row = 0;
    }
}

pub fn putString(data: []const u8) void {
    for (data) |c| {
        putChar(c);
    }
}

pub const writer = Writer(void, error{}, callback){ .context = {} };

fn callback(_: void, string: []const u8) error{}!usize {
    putString(string);
    return string.len;
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    fmt.format(writer, format, args) catch unreachable;
}
