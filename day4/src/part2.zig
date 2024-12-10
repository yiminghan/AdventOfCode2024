const std = @import("std");
const utils = @import("../../utils/readline.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var matrix = std.ArrayList([]u8).init(std.heap.page_allocator);
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var copyBuffer: []u8 = try std.heap.page_allocator.alloc(u8, 1024);
        const mutableSlice: []u8 = copyBuffer[0..line.len];
        @memcpy(mutableSlice, line);
        try matrix.append(mutableSlice);
    }

    var count: i32 = 0;

    const items = matrix.items;
    for (1..(items.len - 1)) |x| {
        for (1..(items[0].len - 1)) |y| {
            var left = false;
            var right = false;
            if (items[x][y] == 'A' and ((items[x + 1][y + 1] == 'M' and items[x - 1][y - 1] == 'S') or (items[x + 1][y + 1] == 'S' and items[x - 1][y - 1] == 'M'))) {
                left = true;
            }

            if (items[x][y] == 'A' and ((items[x + 1][y - 1] == 'M' and items[x - 1][y + 1] == 'S') or (items[x + 1][y - 1] == 'S' and items[x - 1][y + 1] == 'M'))) {
                right = true;
            }

            if (left and right) count += 1;
        }
    }

    try stdout.writer().print("count: {}\n", .{count});
}
