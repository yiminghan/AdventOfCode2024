const std = @import("std");

const Coord = struct { x: i32, y: i32 };

const Antenna = struct { symbol: u8, coords: *std.ArrayList(Coord) };

const stdout = std.io.getStdOut();

fn contains(comptime T: type, array: []T, item: T) bool {
    for (array) |x| if (x == item) return true;

    return false;
}

pub fn main() !void {
    var y: i32 = 0;
    const maxX: i32 = 50;

    // x * 10000 + y
    var affected = std.ArrayList(u32).init(std.heap.page_allocator);

    for ("1234567890asdfghjklqwertyuiopzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM") |c| {
        var file = try std.fs.cwd().openFile("./src/input.txt", .{});
        defer file.close();
        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024]u8 = undefined;
        var a0 = std.ArrayList(Coord).init(std.heap.page_allocator);
        y = 0;

        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            var x: i32 = -1;

            for (line) |char| {
                x += 1;
                if (char != c) continue;
                const coord = Coord{ .x = y, .y = x };

                try stdout.writer().print("Add {c}, {} {} \n", .{ c, x, y });
                try a0.append(coord);
                continue;
            }

            y += 1;
        }

        for (0..a0.items.len) |i| {
            for (i + 1..a0.items.len) |j| {
                const coord_a: Coord = a0.items[i];
                const coord_b: Coord = a0.items[j];

                const x_distance = coord_a.x - coord_b.x;
                const y_distance = coord_a.y - coord_b.y;

                var coord_x = coord_a.x;
                var coord_y = coord_a.y;

                // go to the var end of line
                while (coord_x - x_distance >= 0 and coord_y - y_distance >= 0 and coord_x - x_distance < maxX and coord_y - y_distance < y) {
                    coord_x = coord_x - x_distance;
                    coord_y = coord_y - y_distance;
                }

                // walk the line
                while (coord_x >= 0 and coord_y >= 0 and coord_x < maxX and coord_y < y) {
                    if (!contains(u32, affected.items, @intCast(coord_x * 10000 + coord_y))) {
                        try affected.append(@intCast(coord_x * 10000 + coord_y));
                    }

                    coord_x = coord_x + x_distance;
                    coord_y = coord_y + y_distance;
                }
            }
        }
    }

    const count = affected.items.len;

    try stdout.writer().print("maxy: {}, max x {}", .{ y, maxX });

    try stdout.writer().print("totol: {}", .{count});
}
