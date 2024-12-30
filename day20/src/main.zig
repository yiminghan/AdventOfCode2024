const std = @import("std");

const size: usize = 141;

var maze: [size][size]u8 = [_][size]u8{[_]u8{0} ** size} ** size;

const XY = struct { x: i64, y: i64 };

var startX: usize = 0;
var startY: usize = 0;
var endX: usize = 0;
var endY: usize = 0;

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

var optimalPath = std.AutoHashMap(XY, void).init(std.heap.page_allocator);
var openSet = std.AutoHashMap(XY, void).init(std.heap.page_allocator);
// records previous direction
var cameFrom = std.AutoHashMap(XY, XY).init(std.heap.page_allocator);
// actual score
var scores = std.AutoHashMap(XY, i64).init(std.heap.page_allocator);
var path = std.ArrayList(XY).init(std.heap.page_allocator);

const Cheat = struct { s: XY, e: XY };
// var cheatScores = std.AutoHashMap(Cheat, usize).init(std.heap.page_allocator);

const MAX = 999999999999;

fn walkMaze(start: XY, end: XY) usize {
    openSet.put(start, {}) catch {};
    scores.put(start, 0) catch {};

    while (openSet.count() > 0) {
        var current: XY = XY{ .x = 0, .y = 0 };
        var minF: i64 = MAX;
        var iter = openSet.iterator();
        while (iter.next()) |i| {
            const f = scores.get(i.key_ptr.*) orelse 99999999;
            if (f < minF) {
                minF = f;
                current = i.key_ptr.*;
            }
        }

        _ = openSet.remove(current);
        if (current.x == end.x and current.y == end.y) {
            return @intCast(scores.get(end).?);
        }

        for (DIR) |d| {
            const next = XY{ .x = current.x + d.x, .y = current.y + d.y };

            if (next.x < 0 or next.y < 0 or next.x >= size or next.y >= size) continue;

            if (maze[@intCast(next.y)][@intCast(next.x)] != '#') {
                const tentativeScore = scores.get(current).? + 1;
                const currentScore = scores.get(next) orelse 99999999;

                if (tentativeScore < currentScore) {
                    cameFrom.put(next, current) catch {};
                    scores.put(next, tentativeScore) catch {};
                    openSet.put(next, {}) catch {};
                }
            }
        }
    }
    return MAX;
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

fn calculateCheat(start: XY, steps: usize, threshold: usize) usize {
    var cheatSize: usize = 0;

    var i = optimalPath.iterator();
    while (i.next()) |node| {
        const next = node.key_ptr.*;
        const distance_from_start = @abs(next.x - start.x) + @abs(next.y - start.y);
        if (distance_from_start <= steps) {
            const cheatScore = @abs(scores.get(start).? - scores.get(next).?);

            if (cheatScore > distance_from_start and cheatScore - distance_from_start >= threshold and cheatScore != MAX) {
                cheatSize += 1;
            }
        }
    }

    return cheatSize;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var varY: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (0..line.len) |x| {
            maze[varY][x] = line[x];
            if (line[x] == 'S') {
                startX = x;
                startY = varY;
            }
            if (line[x] == 'E') {
                endX = x;
                endY = varY;
            }
        }
        varY += 1;
    }

    const start = XY{ .x = @intCast(startX), .y = @intCast(startY) };
    const end = XY{ .x = @intCast(endX), .y = @intCast(endY) };

    _ = walkMaze(start, end);
    reverseWalk();

    // part 1
    var cheatScore: usize = 0;

    var i = optimalPath.iterator();
    while (i.next()) |node| {
        cheatScore += calculateCheat(node.key_ptr.*, 20, 100);
    }

    try stdout.writer().print("cheatSize {} \n", .{cheatScore / 2});
}
