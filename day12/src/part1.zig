const std = @import("std");

const Pair = struct { x: usize, y: usize };
const Fence = struct { area: usize, permiter: usize, numSides: usize };
const stdout = std.io.getStdOut();

fn walkTerritory(current: u8, x: usize, y: usize, matrix: [][]u8, reached: *std.AutoHashMap(Pair, void)) Fence {
    stdout.writer().print("walk Terrioty {c}: {} {} {} \n", .{ current, matrix[y][x], y, x }) catch {};

    if (reached.*.get(Pair{ .x = @intCast(x), .y = @intCast(y) }) != null) return Fence{ .area = 0, .permiter = 0 };
    reached.*.put(Pair{ .x = @intCast(x), .y = @intCast(y) }, {}) catch {};

    var runningFence = Fence{ .area = 0, .permiter = 0 };
    runningFence.area += 1;

    if (y == 0 or matrix[y - 1][x] != current) {
        runningFence.permiter += 1;
    } else {
        const left = walkTerritory(current, x, y - 1, matrix, reached);
        runningFence.area += left.area;
        runningFence.permiter += left.permiter;
    }

    if (y == matrix.len - 1 or matrix[y + 1][x] != current) {
        runningFence.permiter += 1;
    } else {
        const right = walkTerritory(current, x, y + 1, matrix, reached);
        runningFence.area += right.area;
        runningFence.permiter += right.permiter;
    }
    if (x == 0 or matrix[y][x - 1] != current) {
        runningFence.permiter += 1;
    } else {
        const up = walkTerritory(current, x - 1, y, matrix, reached);
        runningFence.area += up.area;
        runningFence.permiter += up.permiter;
    }
    if (x == matrix[0].len - 1 or matrix[y][x + 1] != current) {
        runningFence.permiter += 1;
    } else {
        const down = walkTerritory(current, x + 1, y, matrix, reached);
        runningFence.area += down.area;
        runningFence.permiter += down.permiter;
    }

    return runningFence;
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

    var reached = std.AutoHashMap(Pair, void).init(std.heap.page_allocator);
    var cost: u32 = 0;
    for (0..matrix.items.len) |y| {
        for (0..matrix.items[0].len) |x| {
            if (reached.get(Pair{ .x = x, .y = y }) == null) {
                const runningFence = walkTerritory(matrix.items[y][x], x, y, matrix.items, &reached);
                try stdout.writer().print("fence {c}: {} \n", .{ matrix.items[y][x], runningFence.area * runningFence.numSides });

                cost += @intCast(runningFence.area * runningFence.numSides);
            }
        }
    }

    try stdout.writer().print("total: {} \n", .{cost});
}
