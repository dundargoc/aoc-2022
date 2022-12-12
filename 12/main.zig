const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;
const int = i32;
const split = std.mem.split;
const tokenize = std.mem.tokenize;

const Point = struct {
    row: int = undefined,
    column: int = undefined,
};

fn getShortestDistance(start: Point, end: Point, points: std.AutoHashMap(Point, u8), allocator: std.mem.Allocator) !?int {
    var queue = List(Point).init(allocator);
    try queue.append(start);
    var distance = std.AutoHashMap(Point, int).init(allocator);
    try distance.put(start, 0);
    while (queue.items.len != 0) {
        const current = queue.orderedRemove(0);
        inline for (.{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 } }) |i| {
            const neigborRow = current.row + i[0];
            const neigborColumn = current.column + i[1];
            const neighbor = Point{ .row = neigborRow, .column = neigborColumn };
            if (points.contains(neighbor) and !distance.contains(neighbor)) {
                const height = points.get(current).?;
                const neighborHeight = points.get(neighbor).?;
                if (height + 1 >= neighborHeight) {
                    const currentDistance = distance.get(current).?;
                    try distance.put(neighbor, currentDistance + 1);
                    try queue.append(neighbor);
                }
            }
        }
    }

    return distance.get(end);
}

fn solve(allocator: std.mem.Allocator, data: []const u8, part1: bool) !int {
    var points = std.AutoHashMap(Point, u8).init(allocator);
    var startPoints = List(Point).init(allocator);
    var distances = List(int).init(allocator);
    var lines = tokenize(u8, data, "\n");

    var row: int = 0;
    var end: Point = .{};
    while (lines.next()) |line| : (row += 1) {
        var column: int = 0;
        for (line) |height| {
            const p: Point = .{ .row = row, .column = column };
            switch (height) {
                'S' => {
                    try points.put(p, 'a');
                    try startPoints.append(p);
                },
                'E' => {
                    try points.put(p, 'z');
                    end = p;
                },

                'a' => {
                    try points.put(p, height);
                    if (!part1) {
                        try startPoints.append(p);
                    }
                },
                else => {
                    try points.put(p, height);
                },
            }
            column += 1;
        }
    }

    for (startPoints.items) |start| {
        const distance = try getShortestDistance(start, end, points, allocator);
        if (distance != null) {
            try distances.append(distance.?);
        }
    }

    return std.mem.min(int, distances.items);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = @embedFile("input");

    print("P1: {}, P2: {}\n", .{ try solve(allocator, data, true), try solve(allocator, data, false) });
}
