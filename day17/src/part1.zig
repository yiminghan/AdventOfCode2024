const std = @import("std");

var registerA: u64 = 156985331242235;
var registerB: u64 = 0;
var registerC: u64 = 0;

fn getCombo(num: u64) u64 {
    return switch (num) {
        0...3 => num,
        4 => registerA,
        5 => registerB,
        6 => registerC,
        else => 0,
    };
}

pub fn main() !void {
    var stdout = std.io.getStdOut();
    var file = try std.fs.cwd().openFile("./src/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var instructionPointer: usize = 0;
        while (instructionPointer < line.len - 2 and instructionPointer >= 0) {
            const op = line[instructionPointer];

            var num: u64 = 0;

            if (instructionPointer < line.len - 2) {
                num = try std.fmt.parseInt(u64, &[1]u8{line[instructionPointer + 2]}, 10);
            }

            // try stdout.writer().print("run {c} with {} at {} \n", .{ op, num, instructionPointer });

            switch (op) {
                '0' => {
                    registerA = registerA >> @intCast(getCombo(num));
                    instructionPointer += 2 * 2;
                },
                '1' => {
                    registerB = registerB ^ num;
                    instructionPointer += 2 * 2;
                },
                '2' => {
                    registerB = @mod(getCombo(num), 8);
                    instructionPointer += 2 * 2;
                },
                '3' => {
                    if (registerA != 0) {
                        instructionPointer = @as(usize, @intCast(num * 2));
                    } else {
                        instructionPointer += 2 * 2;
                    }
                },
                '4' => {
                    registerB = registerB ^ registerC;
                    instructionPointer += 2 * 2;
                },
                '5' => {
                    try stdout.writer().print("{},", .{@mod(getCombo(num), 8)});
                    instructionPointer += 2 * 2;
                },
                '6' => {
                    registerB = registerA >> @intCast(getCombo(num));
                    instructionPointer += 2 * 2;
                },
                '7' => {
                    registerC = registerA >> @intCast(getCombo(num));
                    instructionPointer += 2 * 2;
                },
                else => {},
            }

            // try stdout.writer().print("run op {c} with {}===\nA {b}\nB {b} \nC {b} \n", .{ op, num, registerA, registerB, registerC });
        }
    }
}
