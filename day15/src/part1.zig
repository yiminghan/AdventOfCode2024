const std = @import("std");

const Box = struct {
    x: u64,
    y: u64,
};

var boxes = std.ArrayList(?*Box).init(std.heap.page_allocator);
var walls = std.ArrayList(?*Box).init(std.heap.page_allocator);
var selfx: usize = 0;
var selfy: usize = 0;
var maxy: usize = 0;

fn pushBox(dir: u8, x: usize, y: usize) bool {
    if (dir == '>') {
        if (x + 1 < maxy) {
            for (walls.items) |w| {
                if (w.?.x == x + 1 and w.?.y == y) {
                    return false;
                }
            }

            for (boxes.items) |w| {
                if (w.?.x == x + 1 and w.?.y == y) {
                    if (pushBox(dir, x + 1, y)) {
                        w.?.x += 1;
                        return true;
                    } else {
                        return false;
                    }
                }
            }

            return true;
        }
    }
    if (dir == '<') {
        if (x - 1 >= 0) {
            for (walls.items) |w| {
                if (w.?.x == x - 1 and w.?.y == y) {
                    return false;
                }
            }

            for (boxes.items) |w| {
                if (w.?.x == x - 1 and w.?.y == y) {
                    if (pushBox(dir, x - 1, y)) {
                        w.?.x -= 1;
                        return true;
                    } else {
                        return false;
                    }
                }
            }

            return true;
        }
    }
    if (dir == 'v') {
        if (y + 1 < maxy) {
            for (walls.items) |w| {
                if (w.?.x == x and w.?.y == y + 1) {
                    return false;
                }
            }

            for (boxes.items) |w| {
                if (w.?.x == x and w.?.y == y + 1) {
                    if (pushBox(dir, x, y + 1)) {
                        w.?.y += 1;
                        return true;
                    } else {
                        return false;
                    }
                }
            }

            return true;
        }
    }
    if (dir == '^') {
        if (y - 1 >= 0) {
            for (walls.items) |w| {
                if (w.?.x == x and w.?.y == y - 1) {
                    return false;
                }
            }

            for (boxes.items) |w| {
                if (w.?.x == x and w.?.y == y - 1) {
                    if (pushBox(dir, x, y - 1)) {
                        w.?.y -= 1;
                        return true;
                    } else {
                        return false;
                    }
                }
            }

            return true;
        }
    }
    return false;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = &gpa.allocator();

    var file = try std.fs.cwd().openFile("./src/map.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (0..line.len) |x| {
            if (line[x] == 'O') {
                const newBox = try allocator.create(Box);
                newBox.* = Box{
                    .x = x,
                    .y = maxy,
                };
                try boxes.append(newBox);
            } else if (line[x] == '#') {
                const newBox = try allocator.create(Box);
                newBox.* = Box{
                    .x = x,
                    .y = maxy,
                };
                try walls.append(newBox);
            } else if (line[x] == '@') {
                selfx = x;
                selfy = maxy;
            }
        }
        maxy += 1;
    }

    var movefile = try std.fs.cwd().openFile("./src/moves.txt", .{});
    defer movefile.close();

    var mvbuf_reader = std.io.bufferedReader(movefile.reader());
    var mvin_stream = mvbuf_reader.reader();

    while (try mvin_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |dir| {
            // try stdout.writer().print("move: {c} - ", .{dir});

            if (pushBox(dir, selfx, selfy)) {
                if (dir == '>') {
                    selfx += 1;
                } else if (dir == '<') {
                    selfx -= 1;
                } else if (dir == 'v') {
                    selfy += 1;
                } else if (dir == '^') {
                    selfy -= 1;
                }
            }

            // try stdout.writer().print("after move: {} {} \n", .{ selfx, selfy });

            // for (0..maxy) |y| {
            //     outer: for (0..maxy) |x| {
            //         for (boxes.items) |b| {
            //             if (b.?.x == x and b.?.y == y) {
            //                 try stdout.writer().print("O", .{});
            //                 continue :outer;
            //             }
            //         }

            //         for (walls.items) |b| {
            //             if (b.?.x == x and b.?.y == y) {
            //                 try stdout.writer().print("#", .{});
            //                 continue :outer;
            //             }
            //         }

            //         if (selfx == x and selfy == y) {
            //             try stdout.writer().print("@", .{});
            //         } else {
            //             try stdout.writer().print(".", .{});
            //         }
            //     }
            //     try stdout.writer().print("\n", .{});
            // }
            // try stdout.writer().print("\n", .{});
            // try stdout.writer().print("\n", .{});
        }
    }

    for (0..maxy) |y| {
        outer: for (0..maxy) |x| {
            for (boxes.items) |b| {
                if (b.?.x == x and b.?.y == y) {
                    try stdout.writer().print("O", .{});
                    continue :outer;
                }
            }

            for (walls.items) |b| {
                if (b.?.x == x and b.?.y == y) {
                    try stdout.writer().print("#", .{});
                    continue :outer;
                }
            }

            if (selfx == x and selfy == y) {
                try stdout.writer().print("@", .{});
            } else {
                try stdout.writer().print(".", .{});
            }
        }
        try stdout.writer().print("\n", .{});
    }
    var gps_sum: u64 = 0;
    for (boxes.items) |b| {
        gps_sum += (100 * b.?.y + b.?.x);
    }

    try stdout.writer().print("sum {}", .{gps_sum});
}
