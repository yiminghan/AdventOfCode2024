const std = @import("std");
const stdout = std.io.getStdOut();
const Connections = std.StringHashMap(void);

const Key = struct { numbers: [5]usize };
const Lock = struct { numbers: [5]usize };
const allocator = std.heap.page_allocator;
var keys = std.ArrayList(Key).init(allocator);
var locks = std.ArrayList(Lock).init(allocator);

fn checkFit(k: Key, l: Lock) bool {
    for (0..5) |i| {
        if (k.numbers[i] + l.numbers[i] > 7) return false;
    }

    return true;
}

pub fn main() !void {
    const path: []const u8 = "./src/input.txt";
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024000]u8 = undefined;

    var isKey = true;
    var firstLine = true;
    var numbers: [5]usize = [_]usize{0} ** 5;
    // part 1
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len < 2) { //new line, reset
            firstLine = true;
            if (isKey) {
                try keys.append(Key{ .numbers = numbers });
            } else {
                try locks.append(Lock{ .numbers = numbers });
            }
            numbers = [_]usize{0} ** 5;
        } else {
            if (firstLine) {
                if (std.mem.eql(u8, line, "#####")) {
                    isKey = true;
                } else {
                    isKey = false;
                }
                firstLine = false;
            }
            for (0..5) |i| {
                if (line[i] == '#') numbers[i] += 1;
            }
        }
    }

    try stdout.writer().print("Key size: {}  \n", .{keys.items.len});
    try stdout.writer().print("Lock size: {}  \n", .{locks.items.len});

    var counter: usize = 0;
    for (keys.items) |k| {
        for (locks.items) |l| {
            if (checkFit(k, l)) counter += 1;
        }
    }
    try stdout.writer().print("count: {} \n", .{counter});
}
