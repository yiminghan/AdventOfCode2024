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
        try stdout.writer().print("{s}\n", .{line});

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

    var total_similarity: i32 = 0;

    for (0..(leftArray.items.len)) |i| {
        const l = leftArray.items[i];

        var count: i32 = 0;
        // let's just double loop since input is small, no binary search
        for (0..(rightArray.items.len)) |j| {
            if (rightArray.items[j] == l) {
                count = count + 1;
            }
        }

        total_similarity += l * count;
    }

    try stdout.writer().print("total similarity: {}\n", .{total_similarity});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
