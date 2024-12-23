const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024000]u8 = undefined;

    var isFree = false;
    // -1 if free block
    var blocks = std.ArrayList(i32).init(std.heap.page_allocator);
    var fileId: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |char| {
            const number = std.fmt.parseInt(u32, &[1]u8{char}, 10) catch 0;
            for (0..number) |_| try blocks.append(if (isFree) -1 else fileId);
            if (!isFree) fileId += 1;
            isFree = !isFree;
        }
    }

    try stdout.writer().print("blocks:\n", .{});

    for (blocks.items) |b| {
        try stdout.writer().print("|{}", .{b});
    }

    try stdout.writer().print("\n", .{});

    // timeToMove
    var endIndex: u32 = @intCast(blocks.items.len - 1);

    var checksum: u64 = 0;

    for (blocks.items, 0..) |block, index| {
        if (endIndex < index) continue;

        if (block == -1) {
            var i = endIndex;
            innter: while (i > 0) {
                if (blocks.items[i] != -1) {
                    try stdout.writer().print("take block from back: {} at {}, to {}\n", .{ blocks.items[i], endIndex, index });
                    checksum += @intCast((std.math.cast(i32, index) orelse 0) * blocks.items[i]);
                    endIndex = @intCast(i - 1);
                    break :innter;
                }

                i -= 1;
            }
        } else {
            checksum += @intCast((std.math.cast(i32, index) orelse 0) * block);
        }
    }

    try stdout.writer().print("checksum: {}", .{checksum});
}
