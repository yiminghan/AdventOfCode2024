const std = @import("std");

const Pair = struct { x: usize, y: usize };
const stdout = std.io.getStdOut();

fn walkMatrix(current: usize, x: isize, y: isize, matrix: [][]u8, reachedTrialHeads: *std.ArrayList(Pair)) u32 {
    if (x < 0 or y < 0) return 0;
    if (y >= matrix.len or x >= matrix[0].len) return 0;

    const c = (std.fmt.parseInt(isize, &[1]u8{matrix[@intCast(x)][@intCast(y)]}, 10)) catch 99;
    if (c == 9 and current == 9) {
        // for (reachedTrialHeads.*.items) |i| {
        // if (i.x == x and i.y == y) return 0;
        // }
        reachedTrialHeads.*.append(Pair{ .x = @intCast(x), .y = @intCast(y) }) catch {};
        return 1;
    }

    if (current != 0 and (c != current)) return 0;

    return walkMatrix(current + 1, x + 1, y, matrix, reachedTrialHeads) + walkMatrix(current + 1, x - 1, y, matrix, reachedTrialHeads) + walkMatrix(current + 1, x, y + 1, matrix, reachedTrialHeads) + walkMatrix(current + 1, x, y - 1, matrix, reachedTrialHeads);
}

pub fn main() !void {
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

    var zeros = std.ArrayList(Pair).init(std.heap.page_allocator);

    for (0..matrix.items.len) |y| {
        for (0..matrix.items[0].len) |x| {
            if (matrix.items[x][y] == '0') {
                try zeros.append(Pair{ .x = x, .y = y });
            }
        }
    }

    for (zeros.items) |z| {
        try stdout.writer().print("zero: {} {}\n", .{ z.x, z.y });
    }

    var total: u32 = 0;
    // look for top
    for (zeros.items) |z| {
        try stdout.writer().print("walk  ===== (total: {}) \n", .{total});
        var reachedTrialHeads = std.ArrayList(Pair).init(std.heap.page_allocator);
        total += walkMatrix(0, @intCast(z.x), @intCast(z.y), matrix.items, &reachedTrialHeads);
    }

    try stdout.writer().print("total: {} \n", .{total});
}
