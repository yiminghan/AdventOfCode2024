const std = @import("std");
const Gate = struct { id: *const [3]u8, value: i32 };
const Logic = struct { gate1: *const [3]u8, gate2: *const [3]u8, logic: []const u8, output: *const [3]u8 };
const FinalValue = struct { index: u32, value: bool };

var gates = std.StringHashMap(bool).init(std.heap.page_allocator);
var logics = std.ArrayList(Logic).init(std.heap.page_allocator);
var finalValue = std.ArrayList(FinalValue).init(std.heap.page_allocator);

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input-small.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024000]u8 = undefined;

    try gates.put("x00", 1 == 1);
    try gates.put("x01", 0 == 1);
    try gates.put("x02", 0 == 1);
    try gates.put("x03", 1 == 1);
    try gates.put("x04", 1 == 1);
    try gates.put("x05", 1 == 1);
    try gates.put("x06", 0 == 1);
    try gates.put("x07", 0 == 1);
    try gates.put("x08", 1 == 1);
    try gates.put("x09", 1 == 1);
    try gates.put("x10", 0 == 1);
    try gates.put("x11", 1 == 1);
    try gates.put("x12", 0 == 1);
    try gates.put("x13", 1 == 1);
    try gates.put("x14", 0 == 1);
    try gates.put("x15", 1 == 1);
    try gates.put("x16", 0 == 1);
    try gates.put("x17", 0 == 1);
    try gates.put("x18", 1 == 1);
    try gates.put("x19", 1 == 1);
    try gates.put("x20", 0 == 1);
    try gates.put("x21", 0 == 1);
    try gates.put("x22", 0 == 1);
    try gates.put("x23", 1 == 1);
    try gates.put("x24", 1 == 1);
    try gates.put("x25", 1 == 1);
    try gates.put("x26", 0 == 1);
    try gates.put("x27", 0 == 1);
    try gates.put("x28", 1 == 1);
    try gates.put("x29", 0 == 1);
    try gates.put("x30", 0 == 1);
    try gates.put("x31", 0 == 1);
    try gates.put("x32", 1 == 1);
    try gates.put("x33", 0 == 1);
    try gates.put("x34", 1 == 1);
    try gates.put("x35", 0 == 1);
    try gates.put("x36", 1 == 1);
    try gates.put("x37", 0 == 1);
    try gates.put("x38", 1 == 1);
    try gates.put("x39", 1 == 1);
    try gates.put("x40", 1 == 1);
    try gates.put("x41", 0 == 1);
    try gates.put("x42", 0 == 1);
    try gates.put("x43", 0 == 1);
    try gates.put("x44", 1 == 1);

    try gates.put("y00", 1 == 1);
    try gates.put("y01", 1 == 1);
    try gates.put("y02", 1 == 1);
    try gates.put("y03", 1 == 1);
    try gates.put("y04", 0 == 1);
    try gates.put("y05", 0 == 1);
    try gates.put("y06", 0 == 1);
    try gates.put("y07", 0 == 1);
    try gates.put("y08", 0 == 1);
    try gates.put("y09", 1 == 1);
    try gates.put("y10", 0 == 1);
    try gates.put("y11", 1 == 1);
    try gates.put("y12", 0 == 1);
    try gates.put("y13", 1 == 1);
    try gates.put("y14", 0 == 1);
    try gates.put("y15", 1 == 1);
    try gates.put("y16", 1 == 1);
    try gates.put("y17", 1 == 1);
    try gates.put("y18", 1 == 1);
    try gates.put("y19", 1 == 1);
    try gates.put("y20", 0 == 1);
    try gates.put("y21", 0 == 1);
    try gates.put("y22", 1 == 1);
    try gates.put("y23", 1 == 1);
    try gates.put("y24", 1 == 1);
    try gates.put("y25", 1 == 1);
    try gates.put("y26", 0 == 1);
    try gates.put("y27", 1 == 1);
    try gates.put("y28", 0 == 1);
    try gates.put("y29", 0 == 1);
    try gates.put("y30", 0 == 1);
    try gates.put("y31", 0 == 1);
    try gates.put("y32", 1 == 1);
    try gates.put("y33", 0 == 1);
    try gates.put("y34", 1 == 1);
    try gates.put("y35", 1 == 1);
    try gates.put("y36", 0 == 1);
    try gates.put("y37", 0 == 1);
    try gates.put("y38", 0 == 1);
    try gates.put("y39", 1 == 1);
    try gates.put("y40", 1 == 1);
    try gates.put("y41", 0 == 1);
    try gates.put("y42", 0 == 1);
    try gates.put("y43", 0 == 1);
    try gates.put("y44", 1 == 1);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split1 = std.mem.split(u8, line, ":");
        const id1 = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        const logic1 = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        const id2 = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;
        _ = split1.next();
        const idDest = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{split1.next() orelse continue}) catch continue;

        try logics.append(Logic{ .gate1 = id1[0..3], .gate2 = id2[0..3], .logic = logic1, .output = idDest[0..3] });
    }

    // just run it 10 times XD
    for (0..1000) |_| {
        for (logics.items) |l| {
            const id1 = gates.get(l.gate1);
            const id2 = gates.get(l.gate2);
            const ouput = gates.get(l.output);
            if (id1 != null and id2 != null and ouput == null) {
                if (std.mem.eql(u8, l.logic, "OR")) {
                    try gates.put(std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.output}) catch continue, id1 orelse continue or id2 orelse continue);
                } else if (std.mem.eql(u8, l.logic, "AND")) {
                    try gates.put(std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.output}) catch continue, id1 orelse continue and id2 orelse continue);
                } else if (std.mem.eql(u8, l.logic, "XOR")) {
                    try gates.put(std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{l.output}) catch continue, id1 orelse continue != id2 orelse continue);
                }
            }
        }
    }

    var g = gates.iterator();
    while (g.next()) |x| {
        if (x.key_ptr.*[0] == 'z') {
            try stdout.writer().print("{s} : {}\n", .{ x.key_ptr.*, x.value_ptr.* });
            try finalValue.append(FinalValue{ .index = std.fmt.parseInt(u32, x.key_ptr.*[1..3], 10) catch 0, .value = x.value_ptr.* });
        }
    }

    var output: u64 = 0;

    for (finalValue.items) |f| {
        if (f.value) {
            output += std.math.pow(u64, 2, @intCast(f.index));
            try stdout.writer().print("compute index: {} , output: {} \n", .{ f.index, output });
        }
    }

    try stdout.writer().print("output: {} \n", .{output});
}
