const std = @import("std");
const stdout = std.io.getStdOut();
const Connections = std.StringHashMap(void);

const DoubleConnection = struct {
    a: []const u8,
    b: []const u8,
};

const TripleConnection = struct {
    a: []const u8,
    b: []const u8,
    c: []const u8,
};

var doubleConnections = std.ArrayList(DoubleConnection).init(std.heap.page_allocator);

// var connections = std.AutoHashMap([2]u8, std.AutoHashMap(DoubleConnection, void).init(std.heap.page_allocator)).init(std.heap.page_allocator);

var tripleConnections = std.StringHashMap(void).init(std.heap.page_allocator);

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

        const d = DoubleConnection{ .a = a, .b = b };
        const reverseD = DoubleConnection{ .a = b, .b = a };

        try doubleConnections.append(d);
        try doubleConnections.append(reverseD);
    }

    // check triple connection
    const items = doubleConnections.items;

    for (items) |x| {
        try stdout.writer().print("process a:{s}, c:{s}\n", .{ x.a, x.b });

        if (x.a[0] != 't') continue;

        // x.a = a, x.b = c
        for (items) |y| {
            // y.a = x.b = c, y.b = b
            if (std.mem.eql(u8, y.a, x.b)) {
                // match b, a
                // try stdout.writer().print(".........process b:{s}\n", .{y.b});
                for (items) |z| {
                    // z.a == y.b = b, z.b == x.a = a
                    if (std.mem.eql(u8, z.a, y.b) and std.mem.eql(u8, z.b, x.a)) {
                        var aaa = x.a;
                        var bbb = y.b;
                        var ccc = x.b;

                        // swap sort XD
                        if (std.mem.order(u8, aaa, bbb) == std.math.Order.lt) {
                            const c = aaa;
                            aaa = bbb;
                            bbb = c;
                        }

                        if (std.mem.order(u8, bbb, ccc) == std.math.Order.lt) {
                            const c = bbb;
                            bbb = ccc;
                            ccc = c;
                        }

                        if (std.mem.order(u8, aaa, bbb) == std.math.Order.lt) {
                            const c = aaa;
                            aaa = bbb;
                            bbb = c;
                        }

                        const t = try std.fmt.allocPrint(std.heap.page_allocator, "{s}-{s}-{s}", .{ aaa, bbb, ccc });
                        try tripleConnections.put(t, {});
                    }
                }
            }
        }
    }

    var titer = tripleConnections.iterator();
    var counter: usize = 0;
    while (titer.next()) |t| {
        // const tDex = std.mem.indexOf(u8, t.key_ptr.*, "t");

        try stdout.writer().print("{s}\n", .{t.key_ptr.*});
        counter += 1;
        // }
    }

    try stdout.writer().print("total {}\n", .{counter});
}
