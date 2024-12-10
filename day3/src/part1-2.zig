const std = @import("std");
const utils = @import("../../utils/readline.zig");

fn reset(a: bool, b: bool, c: bool, d: bool, e: bool) void {
    a = false;
    b = false;
    c = false;
    d = false;
    e = false;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var total: i32 = 0;
    var step: i32 = 0;
    var do_step: i32 = 0;
    var dont_step: i32 = 0;
    var do = true;
    var firstNumber: i32 = -1;
    var secondNumber: i32 = -1;
    var eof = false;

    while (!eof) {
        const x = in_stream.readByte() catch |err| switch (err) {
            error.EndOfStream => {
                eof = true;
                break;
            },
            else => |e| return e,
        };

        if (x == 'd') {
            do_step = 1;
            dont_step = 1;
            continue;
        }

        if (do_step > 0) {
            if (do_step == 1 and x == 'o') {
                do_step = 2;
            } else if (do_step == 2 and x == '(') {
                do_step = 3;
            } else if (do_step == 3 and x == ')') {
                do_step = 0;
                do = true;
            } else {
                do_step = 0;
            }
        }

        if (dont_step > 0) {
            if (dont_step == 1 and x == 'o') {
                dont_step = 2;
            } else if (dont_step == 2 and x == 'n') {
                dont_step += 1;
            } else if (dont_step == 3 and x == '\'') {
                dont_step += 1;
            } else if (dont_step == 4 and x == 't') {
                dont_step += 1;
            } else if (dont_step == 5 and x == '(') {
                dont_step += 1;
            } else if (dont_step == 6 and x == ')') {
                dont_step = 0;
                do = false;
            } else {
                dont_step = 0;
            }
        }

        // try stdout.writer().print("{s} {}, {}\n", .{ [1]u8{x}, dont_step, do_step });

        if (!do) continue;

        if (x == '\n') continue;

        if (x == 'm') {
            step = 1;
            continue;
        }

        if (step == 1) {
            if (x == 'u') {
                step = 2;
                continue;
            } else step = 0;
        }
        if (step == 2) {
            if (x == 'l') {
                step = 3;
                continue;
            } else step = 0;
        }

        if (step == 3) {
            if (x == '(') {
                step = 4;
                continue;
            } else step = 0;
        }

        if (step == 4) {
            if (firstNumber > 0 and x == ',') {
                step = 5;
                continue;
            } else if (std.ascii.isDigit(x)) {
                const number = try std.fmt.parseInt(i32, &[1]u8{x}, 10);
                if (firstNumber == -1) firstNumber = number else firstNumber = firstNumber * 10 + number;
                continue;
            } else {
                firstNumber = -1;
                secondNumber = -1;
                step = 0;
            }
        }

        if (step == 5) {
            if (firstNumber > 0 and secondNumber > 0 and x == ')') {
                total += firstNumber * secondNumber;
                firstNumber = -1;
                secondNumber = -1;
                continue;
            } else if (std.ascii.isDigit(x)) {
                const number = try std.fmt.parseInt(i32, &[1]u8{x}, 10);
                if (secondNumber == -1) secondNumber = number else secondNumber = secondNumber * 10 + number;
                continue;
            } else {
                firstNumber = -1;
                secondNumber = -1;
                step = 0;
            }
        }
    }

    try stdout.writer().print("total: {}", .{total});
}
