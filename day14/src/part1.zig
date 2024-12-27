const std = @import("std");

const Robot = struct { x: i64, y: i64, vx: i64, vy: i64 };

// var robots = std.ArrayList(Robot).init(std.heap.page_allocator);
const max_x: i64 = 101;
const max_y: i64 = 103;

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024000]u8 = undefined;

    var quad1: i64 = 0;
    var quad2: i64 = 0;
    var quad3: i64 = 0;
    var quad4: i64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, ",");

        const x = try std.fmt.parseInt(i64, split.next().?, 10);
        const y = try std.fmt.parseInt(i64, split.next().?, 10);
        const vx = try std.fmt.parseInt(i64, split.next().?, 10);
        const vy = try std.fmt.parseInt(i64, split.next().?, 10);

        var robot = Robot{ .x = x, .y = y, .vx = vx, .vy = vy };

        for (0..100) |_| {
            robot.x += robot.vx;
            robot.y += robot.vy;

            // try stdout.writer().print("robot: {} {}, {}, {}\n ", .{ robot.x, robot.y, robot.vx, robot.vy });

            if (robot.x < 0) {
                robot.x = max_x + robot.x;
            } else if (robot.x >= max_x) robot.x = robot.x - max_x;
            if (robot.y < 0) {
                robot.y = max_y + robot.y;
            } else if (robot.y >= max_y) robot.y = robot.y - max_y;
        }

        try stdout.writer().print("robot: {} {}\n ", .{ robot.x, robot.y });

        if (robot.x <= (max_x / 2) - 1 and robot.y <= (max_y / 2) - 1) {
            quad1 += 1;
        } else if (robot.x >= (max_x / 2) + 1 and robot.y <= (max_y / 2) - 1) {
            quad2 += 1;
        } else if (robot.x <= (max_x / 2) - 1 and robot.y >= (max_y / 2) + 1) {
            quad3 += 1;
        } else if (robot.x >= (max_x / 2) + 1 and robot.y >= (max_y / 2) + 1) {
            quad4 += 1;
        }
    }

    // try stdout.writer().print("bounds : {}, {} , {} , {} \n", .{ (max_x / 2) + 1, (max_x / 2) - 1, (max_y / 2) + 1, (max_y / 2) - 1 });

    // try stdout.writer().print("result: {}, {} , {} , {}\n", .{ quad1, quad2, quad3, quad4 });

    try stdout.writer().print("result: {}", .{quad1 * quad2 * quad3 * quad4});
}
