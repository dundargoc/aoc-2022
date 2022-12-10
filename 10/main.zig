const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const int = i64;

fn nextCycle(cycle: *int, register: int) int {
    cycle.* += 1;
    if (@rem(cycle.*, 40) == 20) {
        return register * cycle.*;
    } else {
        return 0;
    }
}

fn part1(data: []const u8) !void {
    var register: int = 1;
    var totalSignalStrength: int = 0;
    var cycle: int = 1;

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        var lineSplit = std.mem.tokenize(u8, line, " ");
        const command = lineSplit.next().?;

        if (std.mem.eql(u8, command, "noop")) {
            totalSignalStrength += nextCycle(&cycle, register);
            continue;
        }

        totalSignalStrength += nextCycle(&cycle, register);

        const count = try std.fmt.parseInt(int, lineSplit.next().?, 10);
        register += count;

        totalSignalStrength += nextCycle(&cycle, register);
    }

    print("{}\n", .{totalSignalStrength});
}

fn pixelInSprite(pixel: int, sprite: int) bool {
    return (sprite - 1 == pixel) or (sprite == pixel) or (sprite + 1 == pixel);
}

fn printCRT(pixel: *int, sprite: *int) void {
    if (pixelInSprite(pixel.*, sprite.*)) {
        print("#", .{});
    } else {
        print(".", .{});
    }

    pixel.* += 1;
    pixel.* = @rem(pixel.*, 40);

    if (pixel.* == 0) {
        print("\n", .{});
    }
}

fn part2(data: []const u8) !void {
    var sprite: int = 1;
    var pixel: int = 0;

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        var lineSplit = std.mem.tokenize(u8, line, " ");
        const command = lineSplit.next().?;

        if (std.mem.eql(u8, command, "noop")) {
            printCRT(&pixel, &sprite);
            continue;
        }

        printCRT(&pixel, &sprite);
        printCRT(&pixel, &sprite);

        const count = try std.fmt.parseInt(int, lineSplit.next().?, 10);
        sprite += count;
    }
}

pub fn main() !void {
    const data = @embedFile("input");

    try part1(data);
    try part2(data);
}
