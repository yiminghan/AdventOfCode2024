const std = @import("std");

const size: usize = 141;

var maze: [size][size]u8 = [_][size]u8{[_]u8{0} ** size} ** size;

const XY = struct { x: i64, y: i64 };
const PATH = struct { x: i64, y: i64, dir: usize };

var startX: usize = 0;
var startY: usize = 0;
var endX: usize = 0;
var endY: usize = 0;
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
var path = std.ArrayList(Path).init(std.heap.page_allocator);

var paths = std.AutoHashMap(PATH, usize).init(std.heap.page_allocator);
var walkedPaths = std.AutoHashMap(PATH, void).init(std.heap.page_allocator);
var walkMazeCache = std.AutoHashMap(PATH, usize).init(std.heap.page_allocator);
var minScore: usize = 99999999999999;

var openSet = std.AutoHashMap(PATH, void).init(std.heap.page_allocator);
// records previous direction
var cameFrom = std.AutoHashMap(PATH, PATH).init(std.heap.page_allocator);
// actual score
var scores = std.AutoHashMap(PATH, usize).init(std.heap.page_allocator);

fn getRotation(a: XY, b: XY) usize {
    if (a.x == b.x) {
        if (a.y == b.y) return 0 else return 2;
    } else {
        if (@abs(a.x) == @abs(b.y) and @abs(a.y) == @abs(b.x)) {
            return 1;
        } else {
            return 2;
        }
    }
}

fn walkMaze(sx: usize, sy: usize, dir: usize) usize {
    const cachepath = PATH{ .x = @intCast(sx), .y = @intCast(sy), .dir = dir };
    if (walkMazeCache.get(cachepath) != null) {
        return walkMazeCache.get(cachepath).?;
    }

    const start = PATH{ .x = @intCast(sx), .y = @intCast(sy), .dir = dir };
    openSet.put(start, {}) catch {};
    cameFrom.put(start, start) catch {};
    scores.put(start, 0) catch {};

    while (openSet.count() > 0) {
        var current: PATH = PATH{ .x = 0, .y = 0, .dir = 0 };
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

        for (DIR, 0..) |d, i| {
            var next = PATH{ .x = current.x + d.x, .y = current.y + d.y, .dir = i };
            if (i == current.dir) {
                next = PATH{ .x = current.x + d.x, .y = current.y + d.y, .dir = i };
            } else next = PATH{ .x = current.x, .y = current.y, .dir = i };

            if (maze[@intCast(next.y)][@intCast(next.x)] != '#' and (getRotation(DIR[current.dir], d) != 2)) {
                var nextScore: usize = 1;
                if (i != current.dir) nextScore = 1000;

                const tentativeScore = scores.get(current).? + nextScore;
                const currentScore = scores.get(next) orelse 99999999;

                if (tentativeScore < currentScore) {
                    cameFrom.put(next, current) catch {};
                    scores.put(next, tentativeScore) catch {};
                    openSet.put(next, {}) catch {};
                }
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

    walkMazeCache.put(cachepath, ms) catch {};

    // stdout.writer().print("walkMazeCache: {}\n", .{walkMazeCache.count()}) catch {};
    var current = PATH{ .x = @intCast(endX), .y = @intCast(endY), .dir = 3 };
    while (cameFrom.get(current) != null and !(current.x == startX and current.y == startY)) {
        current = cameFrom.get(current).?;

        if (walkMazeCache.get(current) == null and scores.get(current) != null) {
            // stdout.writer().print("walkPath: {} {} {} val {}\n", .{ current.x, current.y, current.dir, ms - scores.get(current).? }) catch {};
            walkMazeCache.put(current, ms - scores.get(current).?) catch {};
        } else {
            break;
        }
    }

    return ms;
}

fn reverseWalk() void {
    var visited = std.AutoHashMap(PATH, void).init(std.heap.page_allocator);
    var visitedDup = std.AutoHashMap(PATH, void).init(std.heap.page_allocator);
    var minScores = std.AutoHashMap(PATH, usize).init(std.heap.page_allocator);

    const start = PATH{ .x = @intCast(endX), .y = @intCast(endY), .dir = 3 };
    visited.put(start, {}) catch {};
    visitedDup.put(start, {}) catch {};
    minScores.put(start, 0) catch {};

    while (visited.count() > 0) {
        var current: PATH = PATH{ .x = 0, .y = 0, .dir = 0 };
        var iter = visited.iterator();
        current = iter.next().?.key_ptr.*;

        _ = visited.remove(current);

        for (DIR, 0..) |d, i| {
            const r = getRotation(d, DIR[current.dir]);
            var next = PATH{ .x = current.x - d.x, .y = current.y - d.y, .dir = i };

            if (i == current.dir) {
                next = PATH{ .x = current.x - d.x, .y = current.y - d.y, .dir = i };
            } else next = PATH{ .x = current.x, .y = current.y, .dir = i };

            if (scores.get(next) != null and minScores.get(current) != null) {
                var cost: usize = 1;
                if (i != current.dir) cost = r * 1000;

                const minS = minScores.get(current) orelse 9999999;

                if (minScore == minS + cost + scores.get(next).?) {
                    stdout.writer().print("put next: {} {} {}, \n", .{ next.x, next.y, next.dir }) catch {};
                    visited.put(next, {}) catch {};
                    visitedDup.put(next, {}) catch {};
                    minScores.put(next, cost + minS) catch {};
                }
            }
        }
    }

    var ii = visitedDup.iterator();
    var bestPaths = std.AutoHashMap(XY, void).init(std.heap.page_allocator);

    while (ii.next()) |w| {
        const xy = XY{ .x = w.key_ptr.x, .y = w.key_ptr.y };
        if (bestPaths.get(xy) == null) bestPaths.put(xy, {}) catch {};
    }

    stdout.writer().print("best seats: {}\n", .{bestPaths.count()}) catch {};
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (0..line.len) |x| {
            maze[maxY][x] = line[x];
            if (line[x] == 'S') {
                startX = x;
                startY = maxY;
            }
            if (line[x] == 'E') {
                endX = x;
                endY = maxY;
            }
        }
        maxY += 1;
    }

    for (0..size) |y| {
        for (0..size) |x| {
            try stdout.writer().print("{c}", .{maze[y][x]});
        }

        try stdout.writer().print("\n", .{});
    }

    try stdout.writer().print("start: {} {}\n", .{ startX, startY });
    try stdout.writer().print("end: {} {}\n", .{ endX, endY });

    // part 1
    minScore = walkMaze(startX, startY, 0);

    try stdout.writer().print("minscore {} \n", .{minScore});

    //part2
    reverseWalk();
}
