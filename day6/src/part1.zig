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

    var cordX: usize = 0;
    var cordY: usize = 0;
    var items = matrix.items;
    // 0 Up, 1 Right, 2 Down, 3 Left
    var currentDirection: usize = 0;
    for (0..items.len) |y| {
        for (0..items[0].len) |x| {
            if (items[x][y] == '^') {
                cordX = x;
                cordY = y;
                break;
            }
        }
        if (cordX != 0 and cordY != 0) break;
    }

    items[cordX][cordY] = 'X';
    while ((cordX > 0 and cordX < items.len) or (cordY > 0 and cordY < items[0].len)) {
        switch (currentDirection) {
            0 => {
                if (cordX == 0) break;
                if (items[cordX - 1][cordY] == '#') {
                    currentDirection += 1;
                } else {
                    cordX -= 1;
                    items[cordX][cordY] = 'X';
                }
            },
            1 => {
                if (cordY + 1 == items.len) break;
                if (items[cordX][cordY + 1] == '#') {
                    currentDirection += 1;
                } else {
                    cordY += 1;
                    items[cordX][cordY] = 'X';
                }
            },
            2 => {
                if (cordX + 1 == items[0].len) break;
                if (items[cordX + 1][cordY] == '#') {
                    currentDirection += 1;
                } else {
                    cordX += 1;
                    items[cordX][cordY] = 'X';
                }
            },
            3 => {
                if (cordY == 0) break;
                if (items[cordX][cordY - 1] == '#') {
                    currentDirection = 0;
                } else {
                    cordY -= 1;
                    items[cordX][cordY] = 'X';
                }
            },
            else => {},
        }
    }

    for (0..items.len) |x| {
        // for (0..items[0].len) |y| {
        try stdout.writer().print("{s}", .{items[x]});
        // }
        try stdout.writer().print("\n", .{});
    }

    var position: i32 = 0;
    for (0..items.len) |x| {
        for (0..items[0].len) |y| {
            if (items[x][y] == 'X') {
                position += 1;
            }
        }
    }

    try stdout.writer().print("position {}", .{position});
}
