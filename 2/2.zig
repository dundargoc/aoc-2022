const std = @import("std");

pub fn main() void {
    const data = @embedFile("input");
    var lines = std.mem.tokenize(u8, data, "\n");
    var score: i64 = 0;

    while (lines.next()) |line| {
        const opponent = line[0];
        const me = line[2];

        score += switch (me) {
            'X' => 0,
            'Y' => 3,
            'Z' => 6,
            else => 0,
        };

        score += switch (me) {
            'X' => switch (opponent) {
                'A' => 3,
                'B' => 1,
                'C' => 2,
                else => 0,
            },
            'Y' => switch (opponent) {
                'A' => 1,
                'B' => 2,
                'C' => 3,
                else => 0,
            },
            'Z' => switch (opponent) {
                'A' => 2,
                'B' => 3,
                'C' => 1,
                else => 0,
            },
            else => 0,
        };
    }

    std.debug.print("{}\n", .{score});
}
