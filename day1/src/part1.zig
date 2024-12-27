const std = @import("std");
const utils = @import("../../utils/readline.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var leftArray = std.ArrayList(i32).init(std.heap.page_allocator);
    var rightArray = std.ArrayList(i32).init(std.heap.page_allocator);

    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // do something with line...
        // try stdout.writer().print("{s}\n", .{line});

        const trimline = std.mem.trimRight(u8, line, "\n");
        var split = std.mem.splitScalar(u8, trimline, ' ');

        const left = split.next() orelse &[1]u8{'0'};
        try leftArray.append(try std.fmt.parseInt(i32, left, 10));

        _ = split.next();
        _ = split.next();

        const right = split.next() orelse &[1]u8{'0'};
        try rightArray.append(try std.fmt.parseInt(i32, right, 10));
    }

    std.mem.sort(i32, leftArray.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, rightArray.items, {}, comptime std.sort.asc(i32));

    var total_distance: i32 = 0;

    for (0..(leftArray.items.len)) |i| {
        const l = leftArray.items[i];
        const r = rightArray.items[i];

        const distance = @abs(l - r);
        total_distance += @intCast(distance);
    }

    try stdout.writer().print("total distance: {}\n", .{total_distance});
}
