const std = @import("std");

const small = false;
const stdout = std.io.getStdOut();

const Path = struct { x: usize, y: usize, dir: u8 };
var parts = std.StringHashMap(void).init(std.heap.page_allocator);

fn readParts() !void {
    var path: []const u8 = "./src/parts.txt";
    if (small) path = "./src/parts-small.txt";
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024000]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, ",");
        while (split.next()) |x| {
            try parts.put(try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{std.mem.trim(u8, x, " ")}), {});
        }
    }
}

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var cache = std.StringHashMap(usize).init(allocator);
var cachelimit: usize = 2;

fn tryPart(in: []const u8, depth: usize) usize {
    if (cache.get(in) != null) {
        return cache.get(in) orelse 0;
    }

    if (in.len == 0) {
        if (in.len > cachelimit) cache.put(in, 1) catch {};
        return 1;
    }

    if (depth > 60) {
        if (in.len > cachelimit) cache.put(in, 0) catch {};
        return 0;
    }

    var partsIterator = parts.iterator();
    var counter: usize = 0;

    while (partsIterator.next()) |x| {
        if (std.mem.startsWith(u8, in, x.key_ptr.*)) {
            counter += tryPart(in[x.key_ptr.*.len..], depth + 1);
        }
    }

    if (in.len > cachelimit) cache.put(in, counter) catch {};
    return counter;
}

fn readcombos() !void {
    try cache.ensureTotalCapacity(1_000_000);

    var path: []const u8 = "./src/combos.txt";
    if (small) path = "./src/combos-small.txt";

    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024000]u8 = undefined;

    var counter: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        stdout.writer().print("read {s} \n", .{line}) catch {};

        counter += tryPart(line, 0);
    }

    try stdout.writer().print("counter {}", .{counter});
}

pub fn main() !void {
    try readParts();
    try readcombos();
}
