const std = @import("std");
const debug = std.debug;
const maxRows = 200;
const maxColumns = 700;
const sandStart = .{ 500, 0 };
const ENABLE_DEBUG = false;

const Border = struct { xMin: usize, xMax: usize, yMin: usize, yMax: usize };
const Wall = struct { x1: usize, y1: usize, x2: usize, y2: usize };

fn printCave(cave: [maxRows][maxColumns]u8, borders: Border) void {
    var row = borders.yMin;
    while (row <= borders.yMax) : (row += 1) {
        var column = borders.xMin;
        while (column <= borders.xMax) : (column += 1) {
            debug.print("{c}", .{cave[row][column]});
        }
        debug.print("\n", .{});
    }
    debug.print("\n", .{});
}

fn addWalls(cave: *[maxRows][maxColumns]u8, wall: Wall) void {
    if (wall.x1 == 0 and wall.y1 == 0) {
        return;
    }

    var x = @min(wall.x1, wall.x2);
    while (x <= @max(wall.x1, wall.x2)) : (x += 1) {
        var y = @min(wall.y1, wall.y2);
        while (y <= @max(wall.y1, wall.y2)) : (y += 1) {
            cave[y][x] = '#';
        }
    }
}

fn addSand(cave: *[maxRows][maxColumns]u8, borders: *Border, part2: bool) bool {
    var sandX: usize = sandStart[0];
    var sandY: usize = sandStart[1];

    while (cave[sandY + 1][sandX] == '.' or
        cave[sandY + 1][sandX - 1] == '.' or
        cave[sandY + 1][sandX + 1] == '.')
    {
        if (sandY + 2 >= maxRows) {
            return false;
        }

        if (cave[sandY + 1][sandX] == '.') {
            sandY += 1;
            continue;
        }

        if (cave[sandY + 1][sandX - 1] == '.') {
            sandY += 1;
            sandX -= 1;
            continue;
        }

        if (cave[sandY + 1][sandX + 1] == '.') {
            sandY += 1;
            sandX += 1;
            continue;
        }
    }

    cave[sandY][sandX] = 'o';

    if (part2) {
        updateBorders(borders, sandX, sandY);
    }

    if (ENABLE_DEBUG) {
        std.time.sleep(100000000);
        debug.print("\x1B[2J\x1B[H", .{});
        printCave(cave.*, borders.*);
    }

    if (part2) {
        if (cave[sandStart[1]][sandStart[0]] == 'o') {
            return false;
        }
    }

    return true;
}

fn updateBorders(borders: *Border, x: usize, y: usize) void {
    borders.xMin = @min(borders.xMin, x);
    borders.xMax = @max(borders.xMax, x);
    borders.yMin = @min(borders.yMin, y);
    borders.yMax = @max(borders.yMax, y);
}

fn solve(data: []const u8, part2: bool) !i32 {
    const array = [_]u8{'.'} ** maxColumns;
    var cave = [_][array.len]u8{array} ** maxRows;
    var lines = std.mem.tokenize(u8, data, "\n");
    var borders: Border = .{ .xMin = 1000, .xMax = 0, .yMin = 1000, .yMax = 0 };
    while (lines.next()) |line| {
        var xPrevious: usize = 0;
        var yPrevious: usize = 0;
        var coordinates = std.mem.split(u8, line, " -> ");
        while (coordinates.next()) |coordinate| {
            var coordinateSplit = std.mem.split(u8, coordinate, ",");
            const x = try std.fmt.parseInt(usize, coordinateSplit.next().?, 10);
            const y = try std.fmt.parseInt(usize, coordinateSplit.next().?, 10);
            updateBorders(&borders, x, y);

            const wall: Wall = .{ .x1 = xPrevious, .y1 = yPrevious, .x2 = x, .y2 = y };
            addWalls(&cave, wall);

            xPrevious = x;
            yPrevious = y;
        }
    }

    cave[sandStart[1]][sandStart[0]] = '+';
    updateBorders(&borders, sandStart[0], sandStart[1]);

    if (part2) {
        borders.yMax += 2;
        @memset(&cave[borders.yMax], '#');
    }

    var unitsOfSand: i32 = if (part2) 1 else 0;
    while (addSand(&cave, &borders, part2)) {
        unitsOfSand += 1;
    }
    return unitsOfSand;
}

pub fn main() !void {
    const data = @embedFile("input");

    debug.print("P1: {}, P2: {}\n", .{ try solve(data, false), try solve(data, true) });
}
