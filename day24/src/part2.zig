const std = @import("std");
const Gate = struct {
    id: []const u8,
    value: bool,
    child1id: []const u8,
    child1value: bool,
    child2id: []const u8,
    child2value: bool,
    logic: []const u8,
};

const Logic = struct { gate1: *const [3]u8, gate2: *const [3]u8, logic: []const u8, output: *const [3]u8 };
const FinalValue = struct { index: u32, value: bool };
const stdout = std.io.getStdOut();

var gates = std.StringHashMap(bool).init(std.heap.page_allocator);
var x: u64 = 0;
var y: u64 = 0;
var logics = std.ArrayList(Logic).init(std.heap.page_allocator);
var finalGates = std.ArrayList(Gate).init(std.heap.page_allocator);
var finalValue = std.ArrayList(FinalValue).init(std.heap.page_allocator);

fn compareStrings(_: void, lhs: Logic, rhs: Logic) bool {
    return std.mem.order(u8, lhs.gate1, rhs.gate1).compare(std.math.CompareOperator.lt);
}

fn walkGates(output: []const u8) !void {
    for (finalGates.items) |l| {
        if (std.mem.eql(u8, output, l.id)) {
            // try stdout.writer().print("compare {s} vs {s}\n ", .{ output, l.id });

            try stdout.writer().print("walk from {s} ({s}): {s} ({s}) {s} {s} ({s}), \n", .{
                l.id,
                if (l.value) "1" else "0",
                l.child1id,
                if (l.child1value) "1" else "0",
                l.logic,
                l.child2id,
                if (l.child2value) "1" else "0",
            });

            try walkGates(l.child1id);
            try walkGates(l.child2id);
        }
    }
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/input-small.txt", .{});
    defer file.close();
    var xfile = try std.fs.cwd().openFile("./src/inputx.txt", .{});
    var yfile = try std.fs.cwd().openFile("./src/inputy.txt", .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var xbuf_reader = std.io.bufferedReader(xfile.reader());
    var xin_stream = xbuf_reader.reader();

    var ybuf_reader = std.io.bufferedReader(yfile.reader());
    var yin_stream = ybuf_reader.reader();
    defer xfile.close();
    defer yfile.close();

    var buf: [1024000]u8 = undefined;

    while (try xin_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split1 = std.mem.split(u8, line, ":");
        const xid = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        const indent = try std.fmt.parseInt(u64, xid[1..], 10);
        const number = try std.fmt.parseInt(u64, std.mem.trim(u8, split1.next().?, " "), 10);
        try gates.put(xid, number == 1);
        if (number == 1) {
            x += std.math.pow(u64, 2, indent);
        }
        try stdout.writer().print(" {s}: {} \n", .{ xid, number });
    }

    while (try yin_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split1 = std.mem.split(u8, line, ":");
        const xid = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        const indent = try std.fmt.parseInt(u64, xid[1..], 10);
        const number = try std.fmt.parseInt(u64, std.mem.trim(u8, split1.next().?, " "), 10);
        try gates.put(xid, number == 1);

        try stdout.writer().print(" {s}: {} \n", .{ xid, number });
        if (number == 1) {
            y += std.math.pow(u64, 2, indent);
        }
    }

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split1 = std.mem.split(u8, line, " ");
        const id1 = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        const logic1 = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        const id2 = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        _ = split1.next();
        const idDest = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;

        try logics.append(Logic{ .gate1 = id1[0..3], .gate2 = id2[0..3], .logic = logic1, .output = idDest[0..3] });
    }

    try stdout.writer().print(" x: 0{b}\n y: 0{b} \n z: {b}\n", .{ x, y, x + y });

    std.mem.sort(Logic, logics.items, {}, compareStrings);

    // just run it 10 times XD
    for (0..1000) |_| {
        for (logics.items) |l| {
            const id1 = gates.get(l.gate1);
            const id2 = gates.get(l.gate2);
            const ouput = gates.get(l.output);
            if (id1 != null and id2 != null and ouput == null) {
                var value = false;
                if (std.mem.eql(u8, l.logic, "OR")) {
                    value = id1.? or id2.?;
                } else if (std.mem.eql(u8, l.logic, "AND")) {
                    value = id1.? and id2.?;
                } else if (std.mem.eql(u8, l.logic, "XOR")) {
                    value = id1.? != id2.?;
                } else {
                    try stdout.writer().print("bad logic {s}\n ", .{l.logic});
                }

                // try stdout.writer().print("compute id1: {s} ({}) {s} id2: {s} ({}), output: {s} ({}) \n", .{
                //     l.gate1,
                //     id1.?,
                //     l.logic,
                //     l.gate2,
                //     id2.?,
                //     l.output,
                //     value,
                // });
                try gates.put(std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.output}) catch continue, value);

                try finalGates.append(Gate{
                    .child1id = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.gate1}) catch continue,
                    .child1value = id1.?,
                    .child2id = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.gate2}) catch continue,
                    .child2value = id2.?,
                    .logic = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.logic}) catch continue,
                    .value = value,
                    .id = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.output}) catch continue,
                });
            }
        }
    }

    var g = gates.iterator();
    while (g.next()) |gg| {
        if (gg.key_ptr.*[0] == 'z') {
            // try stdout.writer().print("{s} : {}\n", .{ gg.key_ptr.*, gg.value_ptr.* });
            try finalValue.append(FinalValue{ .index = std.fmt.parseInt(u32, gg.key_ptr.*[1..3], 10) catch 0, .value = gg.value_ptr.* });
        }
    }

    var output: u64 = 0;

    for (finalValue.items) |f| {
        if (f.value) {
            output += std.math.pow(u64, 2, @intCast(f.index));
            // try stdout.writer().print("compute index: {} , output: {} \n", .{ f.index, output });
        }
    }

    try stdout.writer().print(" z: {b} \n", .{output});

    try walkGates("z03");
    try stdout.writer().print("========\n", .{});

    try walkGates("z35");
    try stdout.writer().print("========\n", .{});
}
