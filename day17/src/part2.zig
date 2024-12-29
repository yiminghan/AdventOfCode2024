const std = @import("std");

var registerA: u64 = 0;
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

const instructions: []const u8 = "2414754114550330";

pub fn main() !void {
    var stdout = std.io.getStdOut();

    var possibleInputs = std.AutoHashMap(u64, void).init(std.heap.page_allocator);
    var nextStepInputs = std.AutoHashMap(u64, void).init(std.heap.page_allocator);
    var testedInputs = std.AutoHashMap(u64, void).init(std.heap.page_allocator);
    try possibleInputs.put(0, {});

    var outputToMatch: []const u8 = "";
    var output: []const u8 = "";

    for (0..instructions.len) |i| {
        outputToMatch = std.fmt.allocPrint(std.heap.page_allocator, "{c}{s}", .{
            instructions[instructions.len - 1 - i],
            outputToMatch,
        }) catch "";

        while (possibleInputs.count() > 0) {
            var iter = possibleInputs.iterator();
            const nextInputToTry = iter.next().?.key_ptr.*;
            _ = possibleInputs.remove(nextInputToTry);

            for (0..8) |n| {
                const inputTotry = (nextInputToTry << 3) + n;
                registerA = inputTotry;
                registerB = 0;
                registerC = 0;

                output = "";

                var instructionPointer: usize = 0;
                while (instructionPointer < instructions.len - 1 and instructionPointer >= 0) {
                    const op = instructions[instructionPointer];

                    var num: u64 = 0;

                    if (instructionPointer < instructions.len - 1) {
                        num = try std.fmt.parseInt(u64, &[1]u8{instructions[instructionPointer + 1]}, 10);
                    }

                    // try stdout.writer().print("run {c} with {} at {} \n", .{ op, num, instructionPointer });

                    switch (op) {
                        '0' => {
                            registerA = registerA >> @intCast(getCombo(num));
                            instructionPointer += 2;
                        },
                        '1' => {
                            registerB = registerB ^ num;
                            instructionPointer += 2;
                        },
                        '2' => {
                            registerB = @mod(getCombo(num), 8);
                            instructionPointer += 2;
                        },
                        '3' => {
                            if (registerA != 0) {
                                instructionPointer = @as(usize, @intCast(num * 2));
                            } else {
                                instructionPointer += 2;
                            }
                        },
                        '4' => {
                            registerB = registerB ^ registerC;
                            instructionPointer += 2;
                        },
                        '5' => {
                            output = std.fmt.allocPrint(std.heap.page_allocator, "{s}{}", .{ output, @mod(getCombo(num), 8) }) catch "";
                            instructionPointer += 2;
                        },
                        '6' => {
                            registerB = registerA >> @intCast(getCombo(num));
                            instructionPointer += 2;
                        },
                        '7' => {
                            registerC = registerA >> @intCast(getCombo(num));
                            instructionPointer += 2;
                        },
                        else => {},
                    }
                }

                try stdout.writer().print("test a={b}, got {s} vs {s} \n", .{ inputTotry, output, outputToMatch });

                if (std.mem.eql(u8, outputToMatch, output)) {
                    if (testedInputs.get(inputTotry) == null) {
                        try testedInputs.put(inputTotry, {});
                        try nextStepInputs.put(inputTotry, {});
                    }
                }
            }
        }

        possibleInputs.clearRetainingCapacity();
        var nextiter = nextStepInputs.iterator();
        while (nextiter.next()) |next| {
            try possibleInputs.put(next.key_ptr.*, {});
        }
        nextStepInputs.clearRetainingCapacity();
    }

    var pIter = possibleInputs.iterator();
    while (pIter.next()) |p| {
        try stdout.writer().print("\n\nanswer {}", .{p.key_ptr.*});
    }
}
