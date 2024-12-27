const std = @import("std");

const Robot = struct { x: i64, y: i64, vx: i64, vy: i64 };

var robots = std.ArrayList(Robot).init(std.heap.page_allocator);
const max_x: i64 = 101;
const max_y: i64 = 103;

pub fn main() !void {
    const stdout = std.io.getStdOut();

    for (6400..6500) |loop| {
        var file = try std.fs.cwd().openFile("./src/input.txt", .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024000]u8 = undefined;

        robots.clearRetainingCapacity();
        try stdout.writer().print("loop: {} ================= ", .{loop});

        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            var split = std.mem.split(u8, line, ",");

            const x = try std.fmt.parseInt(i64, split.next().?, 10);
            const y = try std.fmt.parseInt(i64, split.next().?, 10);
            const vx = try std.fmt.parseInt(i64, split.next().?, 10);
            const vy = try std.fmt.parseInt(i64, split.next().?, 10);

            var robot = Robot{ .x = x, .y = y, .vx = vx, .vy = vy };

            for (0..loop) |_| {
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

            try robots.append(robot);
        }

        var components: usize = 0;

        for (0..max_x) |x| {
            for (0..max_y) |y| {
                var robotSize: usize = 0;
                for (robots.items) |r| {
                    if (r.x == x and r.y == y) {
                        robotSize += 1;
                    }
                }

                if (robotSize > 0) components += 1;

                // if (robotSize == 0) {
                //     try stdout.writer().print(".", .{});
                // } else {
                //     try stdout.writer().print("#", .{});
                // }
            }
            // try stdout.writer().print("\n", .{});
        }

        try stdout.writer().print("components: {}, entropy: {} \n", .{ components, entropy_calc() });
        // could be interesting pic
        if (components < 350) {
            try stdout.writer().print("==== \n \n try loop :{} \n", .{loop});
        }
    }
}
