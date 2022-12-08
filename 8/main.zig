const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

fn indexConvert(row: i64, column: i64, numberOfRows: i64) usize {
    const index: usize = @intCast(row * numberOfRows + column);
    return index;
}

fn leftToRight(grid: ArrayList(u8), visibilityGrid: *ArrayList(bool), numberOfRows: i64, numberOfColumns: i64) void {
    var row: i64 = 0;
    while (row < numberOfRows) : (row += 1) {
        var column: i64 = 0;
        var max: i64 = 0;
        while (column < numberOfColumns) : (column += 1) {
            const index = indexConvert(row, column, numberOfRows);
            const height = grid.items[index];
            if (height > max) {
                max = height;
                visibilityGrid.items[index] = true;
            }
        }
    }
}

fn rightToLeft(grid: ArrayList(u8), visibilityGrid: *ArrayList(bool), numberOfRows: i64, numberOfColumns: i64) void {
    var row: i64 = 0;
    while (row < numberOfRows) : (row += 1) {
        var column = numberOfColumns - 1;
        var max: i64 = 0;
        while (column > 0) : (column -= 1) {
            const index = indexConvert(row, column, numberOfRows);
            const height = grid.items[index];
            if (height > max) {
                max = height;
                visibilityGrid.items[index] = true;
            }
        }
    }
}

fn topToBottom(grid: ArrayList(u8), visibilityGrid: *ArrayList(bool), numberOfRows: i64, numberOfColumns: i64) void {
    var column: i64 = 0;
    while (column < numberOfColumns) : (column += 1) {
        var row: i64 = 0;
        var max: i64 = 0;
        while (row < numberOfRows) : (row += 1) {
            const index = indexConvert(row, column, numberOfRows);
            const height = grid.items[index];
            if (height > max) {
                max = height;
                visibilityGrid.items[index] = true;
            }
        }
    }
}

fn bottomToTop(grid: ArrayList(u8), visibilityGrid: *ArrayList(bool), numberOfRows: i64, numberOfColumns: i64) void {
    var column: i64 = 0;
    while (column < numberOfColumns) : (column += 1) {
        var row = numberOfRows - 1;
        var max: i64 = 0;
        while (row > 0) : (row -= 1) {
            const index = indexConvert(row, column, numberOfRows);
            const height = grid.items[index];
            if (height > max) {
                max = height;
                visibilityGrid.items[index] = true;
            }
        }
    }
}

fn scenicLeft(grid: ArrayList(u8), scenicGrid: *ArrayList(i64), numberOfRows: i64, numberOfColumns: i64) void {
    var row: i64 = 0;
    while (row < numberOfRows) : (row += 1) {
        var startColumn: i64 = 0;
        while (startColumn < numberOfColumns) : (startColumn += 1) {
            const indexStart = indexConvert(row, startColumn, numberOfRows);
            if (startColumn == 0) {
                scenicGrid.items[indexStart] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            const startHeight = grid.items[indexStart];
            var column: i64 = @intCast(startColumn - 1);
            while (column >= 0) : (column -= 1) {
                const height = grid.items[indexConvert(row, column, numberOfRows)];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[indexStart] *= numberOfVisibleTrees;
        }
    }
}

fn scenicRight(grid: ArrayList(u8), scenicGrid: *ArrayList(i64), numberOfRows: i64, numberOfColumns: i64) void {
    var row: i64 = 0;
    while (row < numberOfRows) : (row += 1) {
        var startColumn: i64 = 0;
        while (startColumn < numberOfColumns) : (startColumn += 1) {
            const indexStart = indexConvert(row, startColumn, numberOfRows);
            if (startColumn == numberOfColumns - 1) {
                scenicGrid.items[indexStart] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            const startHeight = grid.items[indexStart];
            var column = startColumn + 1;
            while (column < numberOfColumns) : (column += 1) {
                const height = grid.items[indexConvert(row, column, numberOfRows)];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[indexStart] *= numberOfVisibleTrees;
        }
    }
}

fn scenicBottom(grid: ArrayList(u8), scenicGrid: *ArrayList(i64), numberOfRows: i64, numberOfColumns: i64) void {
    var startRow: i64 = 0;
    while (startRow < numberOfRows) : (startRow += 1) {
        var column: i64 = 0;
        while (column < numberOfColumns) : (column += 1) {
            const indexStart = indexConvert(startRow, column, numberOfRows);
            if (startRow == numberOfRows - 1) {
                scenicGrid.items[indexStart] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            const startHeight = grid.items[indexStart];
            var row = startRow + 1;
            while (row < numberOfRows) : (row += 1) {
                const height = grid.items[indexConvert(row, column, numberOfRows)];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[indexStart] *= numberOfVisibleTrees;
        }
    }
}

fn scenicTop(grid: ArrayList(u8), scenicGrid: *ArrayList(i64), numberOfRows: i64, numberOfColumns: i64) void {
    var startRow: i64 = 0;
    while (startRow < numberOfRows) : (startRow += 1) {
        var column: i64 = 0;
        while (column < numberOfColumns) : (column += 1) {
            const indexStart = indexConvert(startRow, column, numberOfRows);
            if (startRow == 0) {
                scenicGrid.items[indexStart] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            const startHeight = grid.items[indexStart];
            var row = startRow - 1;
            while (row >= 0) : (row -= 1) {
                const height = grid.items[indexConvert(row, column, numberOfRows)];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[indexStart] *= numberOfVisibleTrees;
        }
    }
}

pub fn main() !void {
    const data = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var grid = ArrayList(u8).init(allocator);
    defer grid.deinit();

    var visibilityGrid = ArrayList(bool).init(allocator);
    defer visibilityGrid.deinit();

    var scenicGrid = ArrayList(i64).init(allocator);
    defer scenicGrid.deinit();

    var numberOfRows: i64 = 0;
    var numberOfColumns: i64 = 0;
    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        numberOfRows += 1;
        numberOfColumns = 0;
        for (line) |l| {
            numberOfColumns += 1;
            try grid.append(l);
        }
    }

    for (grid.items) |_| {
        try visibilityGrid.append(false);
    }

    for (grid.items) |_| {
        try scenicGrid.append(1);
    }

    leftToRight(grid, &visibilityGrid, numberOfRows, numberOfColumns);
    rightToLeft(grid, &visibilityGrid, numberOfRows, numberOfColumns);
    topToBottom(grid, &visibilityGrid, numberOfRows, numberOfColumns);
    bottomToTop(grid, &visibilityGrid, numberOfRows, numberOfColumns);

    const numberOfVisible = std.mem.count(bool, visibilityGrid.items, &.{true});
    print("{}\n", .{numberOfVisible});

    scenicLeft(grid, &scenicGrid, numberOfRows, numberOfColumns);
    scenicRight(grid, &scenicGrid, numberOfRows, numberOfColumns);
    scenicBottom(grid, &scenicGrid, numberOfRows, numberOfColumns);
    scenicTop(grid, &scenicGrid, numberOfRows, numberOfColumns);
    const maxScenicScore = std.mem.max(i64, scenicGrid.items);
    print("{}\n", .{maxScenicScore});
}
