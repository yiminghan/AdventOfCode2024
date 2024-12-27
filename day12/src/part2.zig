const std = @import("std");

const Pair = struct { x: usize, y: usize };
const Fence = struct { area: usize, permiter: usize, corners: usize };
const stdout = std.io.getStdOut();

fn getKey(x: usize, y: usize, direction: usize) usize {
    return x * 100 + y * 100_000 + direction;
}

fn walkTerritory(current: u8, x: usize, y: usize, matrix: [][]u8, reached: *std.AutoHashMap(Pair, void)) Fence {
    if (reached.*.get(Pair{ .x = @intCast(x), .y = @intCast(y) }) != null) return Fence{ .area = 0, .permiter = 0, .corners = 0 };
    reached.*.put(Pair{ .x = @intCast(x), .y = @intCast(y) }, {}) catch {};

    var runningFence = Fence{ .area = 0, .permiter = 0, .corners = 0 };
    runningFence.area += 1;

    if (y == 0 or matrix[y - 1][x] != current) {
        runningFence.permiter += 1;
        if (x == 0 or matrix[y][x - 1] != current) runningFence.corners += 1;
        if (x == matrix[0].len - 1 or matrix[y][x + 1] != current) runningFence.corners += 1;
        if (y > 0 and x > 0 and matrix[y - 1][x - 1] == current and matrix[y][x - 1] == current) runningFence.corners += 1;
        if (y > 0 and x < matrix.len - 1 and matrix[y - 1][x + 1] == current and matrix[y][x + 1] == current) runningFence.corners += 1;
    } else {
        const left = walkTerritory(current, x, y - 1, matrix, reached);
        runningFence.area += left.area;
        runningFence.permiter += left.permiter;
        runningFence.corners += left.corners;
    }

    if (y == matrix.len - 1 or matrix[y + 1][x] != current) {
        runningFence.permiter += 1;
        if (x == 0 or matrix[y][x - 1] != current) runningFence.corners += 1;
        if (x == matrix[0].len - 1 or matrix[y][x + 1] != current) runningFence.corners += 1;
        if (y < matrix.len - 1 and x > 0 and matrix[y + 1][x - 1] == current and matrix[y][x - 1] == current) runningFence.corners += 1;
        if (y < matrix.len - 1 and x < matrix.len - 1 and matrix[y + 1][x + 1] == current and matrix[y][x + 1] == current) runningFence.corners += 1;
    } else {
        const right = walkTerritory(current, x, y + 1, matrix, reached);
        runningFence.area += right.area;
        runningFence.permiter += right.permiter;
        runningFence.corners += right.corners;
    }

    if (x == 0 or matrix[y][x - 1] != current) {
        runningFence.permiter += 1;
        if (y == 0 or matrix[y - 1][x] != current) runningFence.corners += 1;
        if (y == matrix[0].len - 1 or matrix[y + 1][x] != current) runningFence.corners += 1;
        if (y > 0 and x > 0 and matrix[y - 1][x - 1] == current and matrix[y - 1][x] == current) runningFence.corners += 1;
        if (y < matrix.len - 1 and x > 0 and matrix[y + 1][x - 1] == current and matrix[y + 1][x] == current) runningFence.corners += 1;
    } else {
        const up = walkTerritory(current, x - 1, y, matrix, reached);
        runningFence.area += up.area;
        runningFence.permiter += up.permiter;
        runningFence.corners += up.corners;
    }

    if (x == matrix[0].len - 1 or matrix[y][x + 1] != current) {
        runningFence.permiter += 1;
        if (y == 0 or matrix[y - 1][x] != current) runningFence.corners += 1;
        if (y == matrix[0].len - 1 or matrix[y + 1][x] != current) runningFence.corners += 1;
        if (y > 0 and x < matrix.len - 1 and matrix[y - 1][x + 1] == current and matrix[y - 1][x] == current) runningFence.corners += 1;
        if (y < matrix.len - 1 and x < matrix.len - 1 and matrix[y + 1][x + 1] == current and matrix[y + 1][x] == current) runningFence.corners += 1;
    } else {
        const down = walkTerritory(current, x + 1, y, matrix, reached);
        runningFence.area += down.area;
        runningFence.permiter += down.permiter;
        runningFence.corners += down.corners;
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

    var areaReached = std.AutoHashMap(Pair, void).init(std.heap.page_allocator);

    var cost: u32 = 0;
    for (0..matrix.items.len) |y| {
        for (0..matrix.items[0].len) |x| {
            if (areaReached.get(Pair{ .x = x, .y = y }) == null) {
                const t = walkTerritory(matrix.items[y][x], x, y, matrix.items, &areaReached);

                try stdout.writer().print("fence {c}: area {} sides {} total  {} \n", .{ matrix.items[y][x], t.area, t.corners / 2, t.area * t.corners / 2 });
                cost += @intCast(t.area * t.corners / 2);
            }
        }
    }

    try stdout.writer().print("total: {} \n", .{cost});
}
