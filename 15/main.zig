const std = @import("std");
const debug = std.debug;
const fmt = std.fmt;
const math = std.math;
const mem = std.mem;
const ENABLE_DEBUG = true;

const Sensor = struct {
    x: i32,
    y: i32,
    distance: i32,
};

const Beacon = struct {
    x: i32,
    y: i32,
};

fn manhattanDistance(x1: i32, y1: i32, x2: i32, y2: i32) !i32 {
    return try math.absInt(x1 - x2) + try math.absInt(y1 - y2);
}

fn canBeaconExist(sensors: std.ArrayList(Sensor), x: i32, y: i32) !bool {
    for (sensors.items) |sensor| {
        const distance = try manhattanDistance(sensor.x, sensor.y, x, y);
        // debug.print("{} {} {}\n", .{ distance, sensor.distance, distance <= sensor.distance });
        if (distance <= sensor.distance) {
            return false;
        }
    }

    return true;
}

fn solve(allocator: mem.Allocator, data: []const u8, part2: bool) !i32 {
    var sensors = std.ArrayList(Sensor).init(allocator);
    var beacons = std.AutoHashMap(Beacon, bool).init(allocator);

    var lines = mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        var split = mem.split(u8, line, " ");
        _ = split.next();
        _ = split.next();

        var x_string = split.next().?;
        x_string = mem.trimLeft(u8, x_string, "x=");
        x_string = mem.trimRight(u8, x_string, ",");
        const x = try fmt.parseInt(i32, x_string, 10);

        var y_string = split.next().?;
        y_string = mem.trimLeft(u8, y_string, "y=");
        y_string = mem.trimRight(u8, y_string, ":");
        const y = try fmt.parseInt(i32, y_string, 10);

        _ = split.next();
        _ = split.next();
        _ = split.next();
        _ = split.next();

        x_string = split.next().?;
        x_string = mem.trimLeft(u8, x_string, "x=");
        x_string = mem.trimRight(u8, x_string, ",");
        const x_beacon = try fmt.parseInt(i32, x_string, 10);

        y_string = split.next().?;
        y_string = mem.trimLeft(u8, y_string, "y=");
        y_string = mem.trimRight(u8, y_string, ":");
        const y_beacon = try fmt.parseInt(i32, y_string, 10);

        const beacon: Beacon = .{ .x = x_beacon, .y = y_beacon };
        try beacons.put(beacon, true);

        const distance = try manhattanDistance(x, y, x_beacon, y_beacon);
        const sensor: Sensor = .{ .x = x, .y = y, .distance = distance };
        try sensors.append(sensor);
    }

    if (!part2) {
        const y: i32 = 2_000_000;
        var x: i32 = -1_000_000;
        var counter: i32 = 0;
        while (x < 5_000_000) : (x += 1) {
            if (beacons.contains(.{ .x = x, .y = y })) {
                continue;
            }
            if (!try canBeaconExist(sensors, x, y)) {
                counter += 1;
            }
        }
        return counter;
    }

    var x: i32 = 0;
    const max = 4_000_000;
    while (x <= max) : (x += 1) {
        if (@rem(x, 100) == 0) {
            debug.print("x={}\n", .{x});
        }
        var y: i32 = 0;
        while (y <= max) : (y += 1) {
            if (try canBeaconExist(sensors, x, y)) {
                return x * 4000000 + y;
            }
        }
    }

    return -1;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = @embedFile("input");

    debug.print("P2: {}\n", .{try solve(allocator, data, true)});
    // debug.print("P1: {}, P2: {}\n", .{ try solve(data, false), try solve(data, true) });
    // _ = try solve(allocator, data, false);
}
