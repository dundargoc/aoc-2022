const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const int = i64;

const Point = struct { x: int, y: int };

fn GetDistanceSquare(a: Point, b: Point) int {
    var xSquare = std.math.pow(int, a.x - b.x, 2);
    var ySquare = std.math.pow(int, a.y - b.y, 2);
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

    var counter: int = 0;
    while (counter < ropeLength) : (counter += 1) {
        var point: Point = .{ .x = 0, .y = 0 };
        try rope.append(point);
    }

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |i| {
        var line = std.mem.tokenize(u8, i, " ");
        var direction = line.next().?;
        var stepsString = line.next().?;
        var steps = try std.fmt.parseInt(u8, stepsString, 10);
        var step: int = 0;
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
                var distanceSquare = GetDistanceSquare(rope.items[ropeSegment - 1], rope.items[ropeSegment]);
                if (distanceSquare >= 4) {
                    var deltaX: int = std.math.clamp(rope.items[ropeSegment - 1].x - rope.items[ropeSegment].x, -1, 1);
                    var deltaY: int = std.math.clamp(rope.items[ropeSegment - 1].y - rope.items[ropeSegment].y, -1, 1);
                    rope.items[ropeSegment].x += deltaX;
                    rope.items[ropeSegment].y += deltaY;
                }
            }

            try tailHistory.put(rope.items[rope.items.len - 1], true);
        }
    }

    print("{any}\n", .{tailHistory.count()});
}
