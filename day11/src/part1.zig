const std = @import("std");

var lookupTable = std.AutoHashMap(u64, u64).init(std.heap.page_allocator);

fn blink(b: u64, times: usize) !u64 {
    const lookup = lookupTable.get(b * 100 + times);
    if (lookup != null) return lookup orelse 0;
    if (times == 0) return 1;
    if (b == 0) {
        return blink(1, times - 1) catch 0;
    } else if ((std.fmt.allocPrint(std.heap.page_allocator, "{}", .{b}) catch "").len % 2 == 0) {
        const s = try std.fmt.allocPrint(std.heap.page_allocator, "{}", .{b});
        const split_len = s.len / 2;
        const first_half = s[0..split_len];
        const second_half = s[split_len..];
        const leftInt = std.fmt.parseInt(u64, first_half, 10) catch 0;
        const rightInt = std.fmt.parseInt(u64, second_half, 10) catch 0;

        const left = blink(leftInt, times - 1) catch 0;
        const right = blink(rightInt, times - 1) catch 0;

        try lookupTable.put(leftInt * 100 + times - 1, left);
        try lookupTable.put(rightInt * 100 + times - 1, right);

        return left + right;
    } else {
        return blink(b * 2024, times - 1) catch 0;
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input-small.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024000]u8 = undefined;

    var blocks = std.ArrayList(u64).init(std.heap.page_allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var n = std.mem.split(u8, line, " ");

        while (n.next()) |next| {
            const number = std.fmt.parseInt(u64, next, 10) catch 0;
            try blocks.append(number);
        }
    }

    var total: u64 = 0;
    for (blocks.items) |i| {
        total += blink(i, 75) catch 0;
    }

    try stdout.writer().print("total {}", .{total});
}
