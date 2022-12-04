const std = @import("std");

pub fn main() !void {
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
    std.debug.print("{} \n", .{total});
}
