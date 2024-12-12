const std = @import("std");
const utils = @import("../../utils/readline.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var rules = std.ArrayList([2]i32).init(std.heap.page_allocator);
    var buf: [1024]u8 = undefined;

    var secondPortion = false;
    var result: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (!secondPortion) {
            if (line.len < 2) {
                secondPortion = true;
                continue;
            }
            var split = std.mem.splitScalar(u8, line, '|');
            const f = split.next() orelse &[1]u8{'0'};
            const firstNumber = try std.fmt.parseInt(i32, f, 10);
            const s = split.next() orelse &[1]u8{'0'};

            const second = try std.fmt.parseInt(i32, s, 10);
            try rules.append([2]i32{ firstNumber, second });
        } else {
            var numbers = std.mem.splitScalar(u8, line, ',');
            var numbersList = std.ArrayList(i32).init(std.heap.page_allocator);

            while (numbers.next()) |x| {
                const parsedNumber = try std.fmt.parseInt(i32, x, 10);
                try numbersList.append(parsedNumber);
            }

            var ruleSet = true;
            for (0..(numbersList.items.len - 1)) |i| {
                var numberPair = false;
                for (rules.items) |rule| {
                    if (rule[0] == numbersList.items[i] and rule[1] == numbersList.items[i + 1]) {
                        numberPair = true;
                    }
                }

                if (!numberPair) {
                    ruleSet = false;
                    break;
                }
            }

            if (!ruleSet) {
                for (numbersList.items) |x| {
                    try stdout.writer().print("{},", .{x});
                }
                try stdout.writer().print("\n", .{});

                // bubble sort
                for (0..(numbersList.items.len - 1)) |_| {
                    for (0..(numbersList.items.len - 1)) |i| {
                        for (rules.items) |rule| {
                            // indicate they should be swapped
                            if (rule[1] == numbersList.items[i] and rule[0] == numbersList.items[i + 1]) {
                                const temp = numbersList.items[i];
                                numbersList.items[i] = numbersList.items[i + 1];
                                numbersList.items[i + 1] = temp;
                            }
                        }
                    }
                }

                for (numbersList.items) |x| {
                    try stdout.writer().print("{},", .{x});
                }
                try stdout.writer().print("\n", .{});

                result += numbersList.items[numbersList.items.len / 2];
            }
        }
    }

    try stdout.writer().print("result: {}\n", .{result});
}
