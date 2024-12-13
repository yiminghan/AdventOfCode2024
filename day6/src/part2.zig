const std = @import("std");
const utils = @import("../../utils/readline.zig");

fn checkCanLoop(items: [][]u8, blockCordX: usize, blockCordY: usize, cordX: usize, cordY: usize, currentDirection: usize) !bool {
    var itemCopyList = std.ArrayList([]u8).init(std.heap.page_allocator);
    var currentDirectionCopy = currentDirection;
    var cordXCopy = cordX;
    var cordYCopy = cordY;
    for (items) |line| {
        var copyBuffer: []u8 = try std.heap.page_allocator.alloc(u8, 1024);
        const mutableSlice: []u8 = copyBuffer[0..line.len];
        @memcpy(mutableSlice, line);
        try itemCopyList.append(mutableSlice);
    }

    var itemCopy = itemCopyList.items;
    itemCopy[blockCordX][blockCordY] = '#';

    while ((cordXCopy > 0 and cordXCopy < itemCopy.len) or (cordYCopy > 0 and cordYCopy < itemCopy[0].len)) {
        switch (currentDirectionCopy) {
            0 => {
                if (cordXCopy == 0) break;

                if (itemCopy[cordXCopy - 1][cordYCopy] == 'U') return true;
                if (itemCopy[cordXCopy - 1][cordYCopy] == '#') {
                    currentDirectionCopy += 1;
                } else {
                    cordXCopy -= 1;
                    itemCopy[cordXCopy][cordYCopy] = 'U';
                }
            },
            1 => {
                if (cordYCopy + 1 == itemCopy.len) break;
                if (itemCopy[cordXCopy][cordYCopy + 1] == 'R') return true;
                if (itemCopy[cordXCopy][cordYCopy + 1] == '#') {
                    currentDirectionCopy += 1;
                } else {
                    cordYCopy += 1;
                    itemCopy[cordXCopy][cordYCopy] = 'R';
                }
            },
            2 => {
                if (cordXCopy + 1 == itemCopy[0].len) break;

                if (itemCopy[cordXCopy + 1][cordYCopy] == 'D') return true;
                if (itemCopy[cordXCopy + 1][cordYCopy] == '#') {
                    currentDirectionCopy += 1;
                } else {
                    cordXCopy += 1;
                    itemCopy[cordXCopy][cordYCopy] = 'D';
                }
            },
            3 => {
                if (cordYCopy == 0) break;

                if (itemCopy[cordXCopy][cordYCopy - 1] == 'L') return true;
                if (itemCopy[cordXCopy][cordYCopy - 1] == '#') {
                    currentDirectionCopy = 0;
                } else {
                    cordYCopy -= 1;
                    itemCopy[cordXCopy][cordYCopy] = 'L';
                }
            },
            else => {},
        }
    }

    return false;
}
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
    const currentDirection: usize = 0;
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

    var loopCount: i32 = 0;

    var positions = std.ArrayList(i32).init(std.heap.page_allocator);

    for (0..items.len) |y| {
        for (0..items[0].len) |x| {

            // try stdout.writer().print("check loop {}, {}\n", .{ y, x });

            if (x == cordX and y == cordY) continue;
            if (try checkCanLoop(items, x, y, cordX, cordY, currentDirection)) {
                var hasPos: bool = false;
                // try stdout.writer().print("has loop {}, {}\n", .{ y, x });

                for (positions.items) |p| {
                    if (p == x * 1000 + y) hasPos = true;
                }
                if (!hasPos) {
                    loopCount += 1;
                    try positions.append(@intCast(x * 1000 + y));
                }
            }
        }
    }

    try stdout.writer().print("count {}", .{loopCount});
}
