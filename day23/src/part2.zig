const std = @import("std");
const stdout = std.io.getStdOut();

pub const Connection = struct {
    // contains a string of computers, must be all connected to each other
    map: *std.StringHashMap(void),
};

var doubleConnections = std.StringHashMap(void).init(std.heap.page_allocator);
var inputConnections = std.StringHashMap(void).init(std.heap.page_allocator);
var parties = std.ArrayList(Connection).init(std.heap.page_allocator);

fn checkConnection(a: []const u8, b: []const u8) bool {
    if (std.mem.eql(u8, a, b)) return true;
    const s = std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ a, b }) catch "";
    return doubleConnections.get(s) != null;
}

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

fn connectionContains(a: []const u8, c: Connection) void {
    var iter = c.map.iterator();
    while (iter.next()) |x| {
        if (std.mem.eql(u8, x.key_ptr.*, a)) {
            return true;
        }
    }

    return false;
}

pub fn main() !void {
    const path: []const u8 = "./src/input.txt";
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024000]u8 = undefined;

    // part 1
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, "-");
        var a: []const u8 = split.next().?;
        var b: []const u8 = split.next().?;
        a = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{a});
        b = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{b});

        // swap
        if (std.mem.order(u8, a, b) == std.math.Order.lt) {
            const c = a;
            a = b;
            b = c;
        }

        const d = try std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ a, b });
        const reverseD = try std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ b, a });

        try doubleConnections.put(d, {});
        try doubleConnections.put(reverseD, {});
        try inputConnections.put(d, {});
    }

    var ii = inputConnections.iterator();
    while (ii.next()) |x| {
        const a = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{x.key_ptr.*[0..2]});
        const b = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{x.key_ptr.*[2..]});

        // try stdout.writer().print("processed {s}-{s}\n", .{ a, b });

        for (parties.items) |coll| {
            // try stdout.writer().print("iter collection size {}\n", .{coll.map.*.count()});

            var cIter = coll.map.*.iterator();
            var allContains = true;
            // check there is a connection for all A,C and B,C
            inner: while (cIter.next()) |ci| {
                const c = ci.key_ptr.*;
                // try stdout.writer().print("check {s}-{s} and {s}-{s}\n", .{ a, c, b, c });

                if (!checkConnection(a, c) or !checkConnection(b, c)) {
                    allContains = false;
                    break :inner;
                }
            }

            // all check passed, put a and b
            if (allContains) {
                const aa = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{a});
                const bb = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{b});

                try coll.map.*.put(aa, {});
                try coll.map.*.put(bb, {});
            }
        }

        const allocator = std.heap.page_allocator;
        const map_ptr = try allocator.create(std.StringHashMap(void));
        map_ptr.* = std.StringHashMap(void).init(allocator);

        const alloc = try std.heap.page_allocator.alloc(Connection, 1);
        var newCol = alloc[0];

        newCol.map = map_ptr;
        try newCol.map.*.put(a, {});
        try newCol.map.*.put(b, {});
        try parties.append(newCol);
    }

    var biggestCol: ?Connection = null;

    for (parties.items) |p| {
        if (biggestCol == null) {
            biggestCol = p;
        } else {
            if (p.map.*.count() > biggestCol.?.map.*.count()) {
                biggestCol = p;
            }
        }
        // var iter = p.map.*.iterator();
        // var s: []u8 = "";
        // while (iter.next()) |c| {
        //     s = try std.fmt.allocPrint(std.heap.page_allocator, "{s}-{s}", .{ s, c.key_ptr.* });
        // }

        // try stdout.writer().print("party: {s}\n", .{s});
    }

    var iter = biggestCol.?.map.*.iterator();

    var ss = std.ArrayList([]u8).init(std.heap.page_allocator);

    while (iter.next()) |c| {
        try ss.append(try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{c.key_ptr.*}));
    }

    std.mem.sort([]u8, ss.items, {}, compareStrings);
    for (ss.items) |computer| {
        try stdout.writer().print("{s},", .{computer});
    }

    // try stdout.writer().print("total {}\n", .{});
}
