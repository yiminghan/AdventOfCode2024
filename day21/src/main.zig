const std = @import("std");

const stdout = std.io.getStdOut();

const Press = struct { press: []const u8 };
const buttonsToPress = [5][]const u8{
    "382A",
    "176A",
    "463A",
    "083A",
    "789A",
};

// manual
const bestInputLevel1 = [5][]const u8{
    "^A<^^AvvAv>A", // 382A,
    "^<<A^^Av>>AvvA", // 176A
    "^^<<A>>AvAvA", // 463A
    "<A^^^Avv>AvA", // 083A
    "^^^<<A>A>AvvvA", //789A
};

const complexity = [5]usize{
    382,
    176,
    463,
    83,
    789,
};

const config1 = [4][]const u8{ "789", "456", "123", " 0A" };
const config2 = [2][]const u8{ "X^A", "<v>" };

fn parseButtons(in: []const u8) void {
    var y: usize = 0;
    var x: usize = 2;

    for (in) |char| {
        switch (char) {
            'A' => stdout.writer().print("{c}", .{config2[y][x]}) catch {},
            '^' => y -= 1,
            'v' => y += 1,
            '<' => x -= 1,
            '>' => x += 1,
            else => {},
        }
    }
}

// you want to end with ^ or > to Press A faster
// you want to start with v or < to so you can come back
// avoid > because it's far from A

// get the best input from a to b
fn getBestInput(a: u8, b: u8) []const u8 {
    if (a == b) return "A";

    if (a == 'A') {
        switch (b) {
            '>' => return "vA",
            '<' => return "v<<A",
            'v' => return "<vA",
            '^' => return "<A",
            else => return "",
        }
    }

    if (a == '^') {
        switch (b) {
            '>' => return "v>A",
            '<' => return "v<A",
            'v' => return "vA",
            'A' => return ">A",
            else => return "",
        }
    }
    if (a == '<') {
        switch (b) {
            '>' => return ">>A",
            'A' => return ">>^A",
            'v' => return ">A",
            '^' => return ">^A",
            else => return "",
        }
    }
    if (a == 'v') {
        switch (b) {
            '>' => return ">A",
            '<' => return "<A",
            'A' => return "^>A",
            '^' => return "^A",
            else => return "",
        }
    }
    if (a == '>') {
        switch (b) {
            'A' => return "^A",
            '<' => return "<<A",
            'v' => return "<A",
            '^' => return "<^A",
            else => return "",
        }
    }
    return "";
}

fn findShortestPress1(in: []const u8) []u8 {
    var path: []u8 = "";
    var current: u8 = 'A';
    for (in) |char| {
        path = std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ path, getBestInput(current, char) }) catch "";
        current = char;
    }

    return path;
}

const seed = 0x209421;
const ShortestPress = struct { path: []const u8, depth: usize };
const ShortestPressContext = struct {
    pub fn hash(self: @This(), key: ShortestPress) u64 {
        _ = self;
        var h = std.hash.Wyhash.init(seed); // <- change the hash algo according to your needs... (WyHash...)
        h.update(key.path);
        h.update(std.fmt.allocPrint(std.heap.page_allocator, "{}", .{key.depth}) catch "");
        return h.final();
    }

    pub fn eql(self: @This(), a: ShortestPress, b: ShortestPress) bool {
        _ = self;
        return std.mem.eql(u8, a.path, b.path) and b.depth == a.depth;
    }
};

var functionCache = std.HashMap(ShortestPress, usize, ShortestPressContext, 80).init(std.heap.page_allocator);

// just returns the length
fn findShortestPress2(in: []const u8, depth: usize) usize {
    const key = ShortestPress{ .path = in, .depth = depth };
    if (functionCache.get(key) != null) return functionCache.get(key).?;

    if (depth == 0) return in.len;

    var current: u8 = 'A';
    var length: usize = 0;

    for (in) |char| {
        const bestInput = getBestInput(current, char);
        length += findShortestPress2(bestInput, depth - 1);
        current = char;
    }

    functionCache.put(key, length) catch {};
    return length;
}

pub fn main() !void {
    var level1Press = std.ArrayList(Press).init(std.heap.page_allocator);
    for (bestInputLevel1) |i| {
        const shortest = findShortestPress1(i);
        try level1Press.append(Press{ .press = shortest });
    }

    var level2Press = std.ArrayList(Press).init(std.heap.page_allocator);
    for (level1Press.items) |i| {
        const shortest = findShortestPress1(i.press);
        try level2Press.append(Press{ .press = shortest });
    }

    var total_complexity: usize = 0;

    for (level2Press.items, 0..) |l, i| {
        const c = (complexity[i]) * l.press.len;
        total_complexity += c;
    }

    try stdout.writer().print("total complexity  {} \n", .{total_complexity});

    // part2
    var part2: usize = 0;

    const depth: usize = 25;

    for (bestInputLevel1, 0..) |l, i| {
        part2 += (complexity[i]) * findShortestPress2(l, depth);
    }

    try stdout.writer().print("part2  {} \n", .{part2});
}
