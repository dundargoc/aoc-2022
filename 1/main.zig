const std = @import("std");
const print = std.debug.print;

fn getTotalCalories(input: []const u8) !i32 {
    var lines = std.mem.tokenize(u8, input, "\n");
    var sum: i32 = 0;
    while (lines.next()) |line| {
        const cal = try std.fmt.parseInt(i32, line, 10);
        sum += cal;
    }
    return sum;
}

pub fn main() !void {
    const data = @embedFile("input");

    var max_sums = [_]i32{ 0, 0, 0 };

    var lines = std.mem.split(u8, data, "\n\n");
    while (lines.next()) |line| {
        const sum = try getTotalCalories(line);
        if (sum > max_sums[2]) {
            max_sums[2] = sum;
            std.mem.sort(i32, &max_sums, {}, comptime std.sort.desc(i32));
        }
    }

    const total = max_sums[0] + max_sums[1] + max_sums[2];
    print("P1: {}, P2: {}\n", .{ max_sums[0], total });
}
