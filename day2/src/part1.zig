const std = @import("std");
const utils = @import("../../utils/readline.zig");

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

        var previousN: i32 = -1;
        var isIncreasing: ?bool = null;
        var isSafe = true;

        while (split.next()) |x| {
            try stdout.writer().print("split: {s}\n", .{x});

            const n = try std.fmt.parseInt(i32, x, 10);
            if (previousN == -1) {
                previousN = n;
                continue;
            }
            if (previousN == n) {
                isSafe = false;
                break;
            }

            const tempIncreasing = previousN < n;
            if (isIncreasing == null) isIncreasing = tempIncreasing;
            if (isIncreasing != tempIncreasing) {
                isSafe = false;
                break;
            }
            if (@abs(previousN - n) > 3) {
                isSafe = false;
                try stdout.writer().print("too far apart : {} {}\n", .{ previousN, n });

                break;
            }

            previousN = n;
        }

        try stdout.writer().print("safe : {}\n", .{isSafe});

        if (isSafe) nSafe += 1;
    }

    try stdout.writer().print("safe count : {}", .{nSafe});
}
