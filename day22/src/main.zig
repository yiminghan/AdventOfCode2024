const std = @import("std");

const stdout = std.io.getStdOut();

fn mix(a: u64, b: u64) u64 {
    return a ^ b;
}
fn prune(a: u64) u64 {
    return @mod(a, 16777216);
}

const PriceCombo = struct {
    a: i64,
    b: i64,
    c: i64,
    d: i64,
};

var pricecombos = std.AutoHashMap(PriceCombo, u64).init(std.heap.page_allocator);
const Price = struct { priceChanges: [2000]i64 };

var localChangesSet = std.AutoHashMap(PriceCombo, void).init(std.heap.page_allocator);

fn calcPriceCombo(start: u64) u64 {
    var priceChanges = [_]i64{0} ** 2000;
    localChangesSet.clearRetainingCapacity();
    var s: u64 = start;
    var next: u64 = 0;
    for (0..2000) |i| {
        const step1 = prune(mix(s * 64, s));
        const step2 = prune(mix(@divTrunc(step1, 32), step1));
        next = prune(mix(step2, step2 * 2048));

        const priceA = s % 10;
        const priceB = next % 10;
        const priceChange = @as(i64, @intCast(priceB)) - @as(i64, @intCast(priceA));
        priceChanges[i] = priceChange;
        s = next;

        if (i >= 3) {
            const a = priceChanges[i - 3];
            const b = priceChanges[i - 2];
            const c = priceChanges[i - 1];
            const d = priceChanges[i];
            const combo = PriceCombo{ .a = a, .b = b, .c = c, .d = d };
            if (localChangesSet.get(combo) == null) {
                const existingCount = pricecombos.get(combo) orelse 0;
                pricecombos.put(combo, existingCount + priceB) catch {};
                localChangesSet.put(combo, {}) catch {};
            }
        }
    }

    return next;
}

pub fn main() !void {
    const path: []const u8 = "./src/input.txt";
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024000]u8 = undefined;

    // part 1
    var counter: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const number = std.fmt.parseInt(u64, line, 10) catch continue;
        counter += calcPriceCombo(number);
    }
    try stdout.writer().print("part1 counter {} \n", .{counter});

    var bestCombo = PriceCombo{ .a = 0, .b = 0, .c = 0, .d = 0 };
    var bestScore: u64 = 0;
    var iter = pricecombos.iterator();

    while (iter.next()) |x| {
        if (x.value_ptr.* > bestScore) {
            bestScore = x.value_ptr.*;
            bestCombo = x.key_ptr.*;
        }
    }

    try stdout.writer().print("bestScore {}", .{bestScore});
}
