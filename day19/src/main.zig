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
var cache = std.StringHashMap(bool).init(allocator);
var cachelimit: usize = 2;

fn tryPart(in: []const u8, depth: usize) bool {
    if (cache.get(in) != null) {
        return cache.get(in) orelse false;
    }

    if (in.len == 0) {
        if (in.len > cachelimit) cache.put(in, true) catch {};
        return true;
    }

    if (depth > 60) {
        if (in.len > cachelimit) cache.put(in, true) catch {};
        return false;
    }

    var partsIterator = parts.iterator();

    while (partsIterator.next()) |x| {
        if (std.mem.startsWith(u8, in, x.key_ptr.*)) {
            if (tryPart(in[x.key_ptr.*.len..], depth + 1)) {
                if (in.len > cachelimit) cache.put(in, true) catch {};
                return true;
            }
        }
    }

    if (in.len > cachelimit) cache.put(in, false) catch {};
    return false;
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

        if (tryPart(line, 0)) {
            counter += 1;
        }
    }

    try stdout.writer().print("counter {}", .{counter});
}

pub fn main() !void {
    try readParts();
    try readcombos();
}
