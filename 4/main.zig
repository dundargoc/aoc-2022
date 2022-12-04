const std = @import("std");

pub fn part1() !i64 {
    const data = @embedFile("input");
    var lines = std.mem.tokenize(u8, data, "\n");
    var total: i64 = 0;

    while (lines.next()) |line| {
        var ranges_it = std.mem.tokenize(u8, line, ",");
        const range1 = ranges_it.next().?;
        const range2 = ranges_it.next().?;

        var range1_it = std.mem.tokenize(u8, range1, "-");
        const min1 = try std.fmt.parseInt(i64, range1_it.next().?, 10);
        const max1 = try std.fmt.parseInt(i64, range1_it.next().?, 10);

        var range2_it = std.mem.tokenize(u8, range2, "-");
        const min2 = try std.fmt.parseInt(i64, range2_it.next().?, 10);
        const max2 = try std.fmt.parseInt(i64, range2_it.next().?, 10);

        if (min1 >= min2 and max1 <= max2) {
            total += 1;
        } else if (min2 >= min1 and max2 <= max1) {
            total += 1;
        }
    }
    return total;
}

fn part2() !i64 {
    const data = @embedFile("input");
    var lines = std.mem.tokenize(u8, data, "\n");
    var total: i64 = 0;

    while (lines.next()) |line| {
        var ranges_it = std.mem.tokenize(u8, line, ",");
        const range1 = ranges_it.next().?;
        const range2 = ranges_it.next().?;

        var range1_it = std.mem.tokenize(u8, range1, "-");
        const min1 = try std.fmt.parseInt(i64, range1_it.next().?, 10);
        const max1 = try std.fmt.parseInt(i64, range1_it.next().?, 10);

        var range2_it = std.mem.tokenize(u8, range2, "-");
        const min2 = try std.fmt.parseInt(i64, range2_it.next().?, 10);
        const max2 = try std.fmt.parseInt(i64, range2_it.next().?, 10);

        if (min1 <= max2 and min2 <= max1) {
            total += 1;
        }
    }
    return total;
}

pub fn main() void {
    std.debug.print("P1: {!}, P2: {!}\n", .{ part1(), part2() });
}
