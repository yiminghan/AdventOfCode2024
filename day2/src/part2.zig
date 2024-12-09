const std = @import("std");
const utils = @import("../../utils/readline.zig");

fn checkArray(array: []i32) bool {
    var previousN: i32 = -1;
    var isIncreasing: ?bool = null;

    for (array) |n| {
        if (previousN == -1) {
            previousN = n;
            continue;
        }
        if (previousN == n) return false;

        const tempIncreasing = previousN < n;
        if (isIncreasing == null) isIncreasing = tempIncreasing;
        if (isIncreasing != tempIncreasing) return false;

        if (@abs(previousN - n) > 3) return false;

        previousN = n;
    }
    return true;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var nSafe: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // do something with line...
        try stdout.writer().print("new line:{s}\n", .{line});

        const trimline = std.mem.trimRight(u8, line, "\n");
        var split = std.mem.splitScalar(u8, trimline, ' ');
        var array = std.ArrayList(i32).init(std.heap.page_allocator);

        while (split.next()) |x| {
            const n = try std.fmt.parseInt(i32, x, 10);
            try array.append(n);
        }

        // brute force
        for (0..array.items.len) |i| {
            var removedArray = try array.clone();
            _ = removedArray.orderedRemove(i);

            if (checkArray(removedArray.items)) {
                nSafe += 1;
                break;
            }
        }
    }

    try stdout.writer().print("safe count : {}", .{nSafe});
}
