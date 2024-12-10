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
    for (0..items.len) |x| {
        for (0..items[0].len) |y| {
            if (y + 3 < items[0].len and items[x][y] == 'X' and items[x][y + 1] == 'M' and items[x][y + 2] == 'A' and items[x][y + 3] == 'S') {
                count += 1;
            }
            if (y >= 3 and items[x][y] == 'X' and items[x][y - 1] == 'M' and items[x][y - 2] == 'A' and items[x][y - 3] == 'S') {
                count += 1;
            }
            if (x + 3 < items[0].len and items[x][y] == 'X' and items[x + 1][y] == 'M' and items[x + 2][y] == 'A' and items[x + 3][y] == 'S') {
                count += 1;
            }
            if (x >= 3 and items[x][y] == 'X' and items[x - 1][y] == 'M' and items[x - 2][y] == 'A' and items[x - 3][y] == 'S') {
                count += 1;
            }

            if (y + 3 < items[0].len and x + 3 < items.len and items[x][y] == 'X' and items[x + 1][y + 1] == 'M' and items[x + 2][y + 2] == 'A' and items[x + 3][y + 3] == 'S') {
                count += 1;
            }
            if (y >= 3 and x + 3 < items.len and items[x][y] == 'X' and items[x + 1][y - 1] == 'M' and items[x + 2][y - 2] == 'A' and items[x + 3][y - 3] == 'S') {
                count += 1;
            }
            if (x >= 3 and y + 3 < items[0].len and items[x][y] == 'X' and items[x - 1][y + 1] == 'M' and items[x - 2][y + 2] == 'A' and items[x - 3][y + 3] == 'S') {
                count += 1;
            }
            if (x >= 3 and y >= 3 and items[x][y] == 'X' and items[x - 1][y - 1] == 'M' and items[x - 2][y - 2] == 'A' and items[x - 3][y - 3] == 'S') {
                count += 1;
            }
        }
    }

    try stdout.writer().print("count: {}\n", .{count});
}
