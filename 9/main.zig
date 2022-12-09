const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Point = struct { x: i64, y: i64 };

fn GetDistanceSquare(a: Point, b: Point) i64 {
    const xSquare = std.math.pow(i64, a.x - b.x, 2);
    const ySquare = std.math.pow(i64, a.y - b.y, 2);
    return xSquare + ySquare;
}

pub fn main() !void {
    const ropeLength = 10;

    const data = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tailHistory = std.AutoHashMap(Point, bool).init(allocator);
    defer tailHistory.deinit();

    var rope = try std.ArrayList(Point).initCapacity(allocator, ropeLength);
    defer rope.deinit();

    var counter: i64 = 0;
    while (counter < ropeLength) : (counter += 1) {
        const poi64: Point = .{ .x = 0, .y = 0 };
        try rope.append(poi64);
    }

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |i| {
        var line = std.mem.tokenize(u8, i, " ");
        const direction = line.next().?;
        const stepsString = line.next().?;
        const steps = try std.fmt.parseInt(u8, stepsString, 10);
        var step: i64 = 0;
        while (step < steps) : (step += 1) {
            if (std.mem.eql(u8, direction, "R")) {
                rope.items[0].x += 1;
            } else if (std.mem.eql(u8, direction, "L")) {
                rope.items[0].x -= 1;
            } else if (std.mem.eql(u8, direction, "U")) {
                rope.items[0].y += 1;
            } else if (std.mem.eql(u8, direction, "D")) {
                rope.items[0].y -= 1;
            }

            var ropeSegment: usize = 1;
            while (ropeSegment < ropeLength) : (ropeSegment += 1) {
                const distanceSquare = GetDistanceSquare(rope.items[ropeSegment - 1], rope.items[ropeSegment]);
                if (distanceSquare >= 4) {
                    const deltaX = std.math.clamp(rope.items[ropeSegment - 1].x - rope.items[ropeSegment].x, -1, 1);
                    const deltaY = std.math.clamp(rope.items[ropeSegment - 1].y - rope.items[ropeSegment].y, -1, 1);
                    rope.items[ropeSegment].x += deltaX;
                    rope.items[ropeSegment].y += deltaY;
                }
            }

            try tailHistory.put(rope.items[rope.items.len - 1], true);
        }
    }

    print("{any}\n", .{tailHistory.count()});
}
