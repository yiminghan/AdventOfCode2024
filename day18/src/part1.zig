const std = @import("std");

const size: usize = 141;

var maze: [size][size]u8 = [_][size]u8{[_]u8{0} ** size} ** size;

const XY = struct { x: i64, y: i64 };

const mapSize: usize = 71;
// const mapSize: usize = 7;
var startX: usize = 0;
var startY: usize = 0;
var endX: usize = mapSize - 1;
var endY: usize = mapSize - 1;

var maxY: usize = 0;

const DIR = [4]XY{
    // EAST
    XY{ .x = 1, .y = 0 },
    // SOUTH
    XY{ .x = 0, .y = 1 },
    // WEST
    XY{ .x = -1, .y = 0 },
    // NORTH
    XY{ .x = 0, .y = -1 },
};
const stdout = std.io.getStdOut();

const Path = struct { x: usize, y: usize, dir: u8 };

var bytes = std.AutoHashMap(XY, void).init(std.heap.page_allocator);
var optimalPath = std.AutoHashMap(XY, void).init(std.heap.page_allocator);
var openSet = std.AutoHashMap(XY, void).init(std.heap.page_allocator);
// records previous direction
var cameFrom = std.AutoHashMap(XY, XY).init(std.heap.page_allocator);
// actual score
var scores = std.AutoHashMap(XY, usize).init(std.heap.page_allocator);
var minScore: usize = 999999999;

fn walkMaze(sx: usize, sy: usize) usize {
    const start = XY{ .x = @intCast(sx), .y = @intCast(sy) };
    openSet.put(start, {}) catch {};
    // cameFrom.put(start,) catch {};
    scores.put(start, 0) catch {};

    while (openSet.count() > 0) {
        var current: XY = XY{ .x = 0, .y = 0 };
        var minF: usize = 999999999999;
        var iter = openSet.iterator();
        while (iter.next()) |i| {
            const f = scores.get(i.key_ptr.*) orelse 99999999;
            if (f < minF) {
                minF = f;
                current = i.key_ptr.*;
            }
        }

        _ = openSet.remove(current);

        for (DIR) |d| {
            const next = XY{ .x = current.x + d.x, .y = current.y + d.y };

            if (next.x < 0 or next.y < 0 or next.x >= mapSize or next.y >= mapSize) continue;
            if (bytes.get(next) != null) continue;

            const tentativeScore = scores.get(current).? + 1;
            const currentScore = scores.get(next) orelse 99999999;

            if (tentativeScore < currentScore) {
                cameFrom.put(next, current) catch {};
                scores.put(next, tentativeScore) catch {};
                openSet.put(next, {}) catch {};
            }
        }
    }

    var ms: usize = 999999999999;
    var si = scores.iterator();

    while (si.next()) |s| {
        if (s.key_ptr.*.x == endX and s.key_ptr.*.y == endY) {
            if (s.value_ptr.* < ms) ms = s.value_ptr.*;
        }
    }

    return ms;
}

fn reverseWalk() void {
    var visited = std.AutoHashMap(XY, void).init(std.heap.page_allocator);

    var current: ?XY = XY{ .x = @intCast(endX), .y = @intCast(endY) };
    while (current != null) {
        _ = visited.remove(current.?);

        visited.put(current.?, {}) catch {};

        current = cameFrom.get(current.?);
    }

    var ii = visited.iterator();

    while (ii.next()) |w| {
        const xy = XY{ .x = w.key_ptr.x, .y = w.key_ptr.y };
        if (optimalPath.get(xy) == null) optimalPath.put(xy, {}) catch {};
    }
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    const maxByteSize: usize = 1024;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, ",");
        if (bytes.count() < maxByteSize) {
            const x = try std.fmt.parseInt(i64, split.next() orelse &[1]u8{'0'}, 10);
            const y = try std.fmt.parseInt(i64, split.next() orelse &[1]u8{'0'}, 10);
            try bytes.put(XY{ .x = x, .y = y }, {});
        }
        maxY += 1;
    }

    minScore = walkMaze(startX, startY);
    reverseWalk();

    for (0..mapSize) |y| {
        for (0..mapSize) |x| {
            if (bytes.get(XY{ .x = @intCast(x), .y = @intCast(y) }) != null) {
                try stdout.writer().print("#", .{});
            } else if (optimalPath.get(XY{ .x = @intCast(x), .y = @intCast(y) }) != null) {
                try stdout.writer().print("0", .{});
            } else {
                try stdout.writer().print(".", .{});
            }
        }
        try stdout.writer().print("\n", .{});
    }

    try stdout.writer().print("minscore {} \n", .{minScore});
}
