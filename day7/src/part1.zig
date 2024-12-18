const std = @import("std");

fn split_number(buf: []const u8, delimiter: u8) ![]u64 {
    var splits = std.mem.splitScalar(u8, buf, delimiter);

    var outArray = std.ArrayList(u64).init(std.heap.page_allocator);

    while (splits.next()) |x| {
        const num: u64 = try std.fmt.parseInt(u64, x, 10);
        try outArray.append(num);
    }
    return outArray.items;
}

fn concat(comptime T: type, x: T, y: T) T {
    const string = std.fmt.allocPrint(
        std.heap.page_allocator,
        "{d}{d}",
        .{ x, y },
    ) catch "0";
    defer std.heap.page_allocator.free(string);

    return std.fmt.parseInt(T, string, 10) catch 0;
}

fn try_math(currentNumber: u64, target: u64, leftNumber: []u64) !bool {
    if (currentNumber == target and leftNumber.len == 0) return true;
    if (leftNumber.len == 0) return false;
    if (currentNumber > target) return false;

    const plus = try_math(currentNumber + leftNumber[0], target, leftNumber[1..]) catch false;
    const mul = try_math(currentNumber * leftNumber[0], target, leftNumber[1..]) catch false;
    const cc = try_math(concat(u64, currentNumber, leftNumber[0]), target, leftNumber[1..]) catch false;

    return (plus or mul or cc);
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    // var total: i32 = 0;
    var buf: [1024]u8 = undefined;
    var total: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, ": ");

        const f = split.next() orelse &[1]u8{'0'};

        const split_sum: u64 = try std.fmt.parseInt(u64, f, 10);
        const target_numbers = try split_number(std.mem.trim(u8, split.next().?, " "), ' ');

        if (try_math(target_numbers[0], split_sum, target_numbers[1..]) catch false) {
            for (target_numbers) |x| {
                try stdout.writer().print("num {} ", .{x});
            }

            try stdout.writer().print("\ntotal {} ", .{total});

            total += split_sum;
        }
    }

    try stdout.writer().print("\ntotal {} ", .{total});
}
