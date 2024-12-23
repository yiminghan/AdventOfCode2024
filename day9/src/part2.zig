const std = @import("std");

const Block = struct {
    size: usize,
    // negative if free
    id: i32,
};

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024000]u8 = undefined;

    var isFree = false;
    // -1 if free block
    var blocks = std.ArrayList(Block).init(std.heap.page_allocator);
    var fileId: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |char| {
            const number = std.fmt.parseInt(u32, &[1]u8{char}, 10) catch 0;
            try blocks.append(Block{ .size = number, .id = if (isFree) -1 else fileId });
            if (!isFree) fileId += 1;
            isFree = !isFree;
        }
    }

    // move Blocks
    var newblocks = std.ArrayList(Block).init(std.heap.page_allocator);
    var addedBlocks = std.AutoHashMap(i32, void).init(std.heap.page_allocator);
    try newblocks.ensureTotalCapacity(blocks.capacity);
    try addedBlocks.ensureTotalCapacity(@intCast(blocks.capacity));

    for (blocks.items, 0..) |b, index| {
        try stdout.writer().print("checking: {}/ {}\n", .{ index, blocks.items.len });

        if (b.id != -1 and addedBlocks.get(b.id) == null) {
            try newblocks.append(b);
            try addedBlocks.put(b.id, {});
        } else {
            var free_space = b.size;
            var endIndex = blocks.items.len - 1;

            while (endIndex > 0 and free_space > 0) {
                const blockToAdd = blocks.items[endIndex];
                if (blockToAdd.id != -1 and blockToAdd.size <= free_space) {
                    if (addedBlocks.get(blockToAdd.id) == null) {
                        try newblocks.append(blockToAdd);
                        try addedBlocks.put(blockToAdd.id, {});
                        free_space -= blockToAdd.size;
                    }
                }

                endIndex -= 1;
            }

            if (free_space > 0) {
                try newblocks.append(Block{ .id = -1, .size = free_space });
            }
        }
    }

    var checksum: u64 = 0;
    var currentIndex: usize = 0;

    for (newblocks.items) |block| {
        if (block.id == -1) {
            currentIndex += block.size;
            continue;
        }
        for (0..block.size) |_| {
            checksum += @intCast((std.math.cast(i32, currentIndex) orelse 0) * block.id);
            currentIndex += 1;
        }
    }

    try stdout.writer().print("checksum: {}", .{checksum});
}
