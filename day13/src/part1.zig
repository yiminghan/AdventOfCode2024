const std = @import("std");

const Button = struct { x: i64, y: i64 };

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024000]u8 = undefined;

    var lineType: usize = 0;
    var totalCost: u64 = 0;
    var buttonA = Button{ .x = 0, .y = 0 };
    var buttonB = Button{ .x = 0, .y = 0 };
    var goal = Button{ .x = 0, .y = 0 };

    outer: while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split1 = std.mem.split(u8, line, ",");

        if (lineType == 0) {
            const xString = split1.next().?;
            // try stdout.writer().print("x: |{s}|", .{xString});
            const x = try std.fmt.parseInt(i64, xString, 10);
            const y = try std.fmt.parseInt(i64, split1.next().?, 10);
            buttonA.x = x;
            buttonA.y = y;
            lineType += 1;
        } else if (lineType == 1) {
            const x = try std.fmt.parseInt(i64, split1.next().?, 10);
            const y = try std.fmt.parseInt(i64, split1.next().?, 10);
            buttonB.x = x;
            buttonB.y = y;
            lineType += 1;
        } else if (lineType == 2) {
            const x = try std.fmt.parseInt(i64, split1.next().?, 10);
            const y = try std.fmt.parseInt(i64, split1.next().?, 10);
            goal.x = x + 10000000000000;
            goal.y = y + 10000000000000;
            // let's try to solve this
            try stdout.writer().print("\ntry problem Button A |{} {}|, ButtonB |{} {}| Goal |{} {}|\n", .{
                buttonA.x,
                buttonA.y,
                buttonB.x,
                buttonB.y,
                goal.x,
                goal.y,
            });

            const d = buttonA.x * buttonB.y - buttonA.y * buttonB.x;
            if (d == 0) {
                lineType += 1;
                continue :outer;
            }

            const buttonApress = @divFloor(goal.x * buttonB.y - goal.y * buttonB.x, d);
            const buttonBPress = @divFloor(goal.y * buttonA.x - goal.x * buttonA.y, d);

            try stdout.writer().print("{}, {}\n", .{ buttonApress, buttonBPress });

            if ((buttonBPress * buttonB.x + buttonApress * buttonA.x) == goal.x and (buttonBPress * buttonB.y + buttonApress * buttonA.y == goal.y)) {
                try stdout.writer().print("Found sol {}, {}\n", .{ buttonApress, buttonBPress });

                totalCost += @intCast(buttonApress * 3 + buttonBPress);
                lineType += 1;
                continue;
            }

            lineType += 1;
        } else {
            lineType = 0;
            continue :outer;
        }
    }

    try stdout.writer().print("total cost {}", .{totalCost});
}
