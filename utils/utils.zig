const std = @import("std");

pub fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

pub fn split_number(buf: []u8, delimiter: u8) []i32 {
    var target_numbers = try std.mem.splitScalar(u8, buf, delimiter);

    var outArray = std.ArrayList(i32).init(std.heap.page_allocator);

    while (target_numbers.next()) |x| {
        const num: i32 = std.fmt.parseInt(i32, x, 10) orelse 0;
        outArray.append(num);
    }
    return outArray.items;
}
