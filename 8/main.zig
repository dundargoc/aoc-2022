const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

fn leftToRight(grid: ArrayList(ArrayList(u8)), visibilityGrid: *ArrayList(ArrayList(bool))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var row: usize = 0;
    while (row < numberOfRows) : (row += 1) {
        var column: usize = 0;
        var max: i64 = 0;
        while (column < numberOfColumns) : (column += 1) {
            var height = grid.items[row].items[column];
            if (height > max) {
                max = height;
                visibilityGrid.items[row].items[column] = true;
            }
        }
    }
}

fn rightToLeft(grid: ArrayList(ArrayList(u8)), visibilityGrid: *ArrayList(ArrayList(bool))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var row: usize = 0;
    while (row < numberOfRows) : (row += 1) {
        var column: usize = numberOfColumns - 1;
        var max: i64 = 0;
        while (column > 0) : (column -= 1) {
            var height = grid.items[row].items[column];
            if (height > max) {
                max = height;
                visibilityGrid.items[row].items[column] = true;
            }
        }
    }
}

fn topToBottom(grid: ArrayList(ArrayList(u8)), visibilityGrid: *ArrayList(ArrayList(bool))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var column: usize = 0;
    while (column < numberOfColumns) : (column += 1) {
        var row: usize = 0;
        var max: i64 = 0;
        while (row < numberOfRows) : (row += 1) {
            var height = grid.items[row].items[column];
            if (height > max) {
                max = height;
                visibilityGrid.items[row].items[column] = true;
            }
        }
    }
}

fn bottomToTop(grid: ArrayList(ArrayList(u8)), visibilityGrid: *ArrayList(ArrayList(bool))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var column: usize = 0;
    while (column < numberOfColumns) : (column += 1) {
        var row: usize = numberOfRows - 1;
        var max: i64 = 0;
        while (row > 0) : (row -= 1) {
            var height = grid.items[row].items[column];
            if (height > max) {
                max = height;
                visibilityGrid.items[row].items[column] = true;
            }
        }
    }
}

fn countVisibleTrees(grid: ArrayList(ArrayList(bool))) i64 {
    var numberOfVisible: i64 = 0;
    for (grid.items) |v| {
        for (v.items) |i| {
            if (i) {
                numberOfVisible += 1;
            }
        }
    }
    return numberOfVisible;
}

fn scenicLeft(grid: ArrayList(ArrayList(u8)), scenicGrid: *ArrayList(ArrayList(i64))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var row: usize = 0;
    while (row < numberOfRows) : (row += 1) {
        var startColumn: usize = 0;
        while (startColumn < numberOfColumns) : (startColumn += 1) {
            if (startColumn == 0) {
                scenicGrid.items[row].items[startColumn] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            var startHeight = grid.items[row].items[startColumn];
            var column: i64 = @intCast(i64, startColumn) - 1;
            while (column >= 0) : (column -= 1) {
                var height = grid.items[row].items[@intCast(usize, column)];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[row].items[startColumn] *= numberOfVisibleTrees;
        }
    }
}

fn scenicRight(grid: ArrayList(ArrayList(u8)), scenicGrid: *ArrayList(ArrayList(i64))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var row: usize = 0;
    while (row < numberOfRows) : (row += 1) {
        var startColumn: usize = 0;
        while (startColumn < numberOfColumns) : (startColumn += 1) {
            if (startColumn == numberOfColumns - 1) {
                scenicGrid.items[row].items[startColumn] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            var startHeight = grid.items[row].items[startColumn];
            var column: usize = startColumn + 1;
            while (column < numberOfColumns) : (column += 1) {
                var height = grid.items[row].items[column];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[row].items[startColumn] *= numberOfVisibleTrees;
        }
    }
}

fn scenicBottom(grid: ArrayList(ArrayList(u8)), scenicGrid: *ArrayList(ArrayList(i64))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var startRow: usize = 0;
    while (startRow < numberOfRows) : (startRow += 1) {
        var column: usize = 0;
        while (column < numberOfColumns) : (column += 1) {
            if (startRow == numberOfRows - 1) {
                scenicGrid.items[startRow].items[column] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            var startHeight = grid.items[startRow].items[column];
            var row: usize = startRow + 1;
            while (row < numberOfRows) : (row += 1) {
                var height = grid.items[row].items[column];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[startRow].items[column] *= numberOfVisibleTrees;
        }
    }
}

fn scenicTop(grid: ArrayList(ArrayList(u8)), scenicGrid: *ArrayList(ArrayList(i64))) void {
    var numberOfRows = grid.items.len;
    var numberOfColumns = grid.items[0].items.len;
    var startRow: usize = 0;
    while (startRow < numberOfRows) : (startRow += 1) {
        var column: usize = 0;
        while (column < numberOfColumns) : (column += 1) {
            if (startRow == 0) {
                scenicGrid.items[startRow].items[column] *= 0;
                continue;
            }
            var numberOfVisibleTrees: i64 = 0;
            var startHeight = grid.items[startRow].items[column];
            var row: i64 = @intCast(i64, startRow) - 1;
            while (row >= 0) : (row -= 1) {
                var height = grid.items[@intCast(usize, row)].items[column];
                numberOfVisibleTrees += 1;
                if (startHeight <= height) {
                    break;
                }
            }
            scenicGrid.items[startRow].items[column] *= numberOfVisibleTrees;
        }
    }
}

fn getMaxScenic(grid: ArrayList(ArrayList(i64))) i64 {
    var maxScenicScore: i64 = 0;
    for (grid.items) |g| {
        maxScenicScore = std.math.max(maxScenicScore, std.mem.max(i64, g.items));
    }

    return maxScenicScore;
}

pub fn main() !void {
    const data = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var grid = ArrayList(ArrayList(u8)).init(allocator);
    defer grid.deinit();
    defer {
        for (grid.items) |i| {
            i.deinit();
        }
    }

    var visibilityGrid = ArrayList(ArrayList(bool)).init(allocator);
    defer visibilityGrid.deinit();
    defer {
        for (visibilityGrid.items) |i| {
            i.deinit();
        }
    }

    var scenicGrid = ArrayList(ArrayList(i64)).init(allocator);
    defer scenicGrid.deinit();
    defer {
        for (scenicGrid.items) |i| {
            i.deinit();
        }
    }

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        var row = ArrayList(u8).init(allocator);
        for (line) |l| {
            try row.append(l);
        }
        try grid.append(row);
    }

    for (grid.items) |g| {
        var v = ArrayList(bool).init(allocator);
        for (g.items) |_| {
            try v.append(false);
        }
        try visibilityGrid.append(v);
    }

    for (grid.items) |g| {
        var a = ArrayList(i64).init(allocator);
        for (g.items) |_| {
            try a.append(1);
        }
        try scenicGrid.append(a);
    }

    leftToRight(grid, &visibilityGrid);
    rightToLeft(grid, &visibilityGrid);
    topToBottom(grid, &visibilityGrid);
    bottomToTop(grid, &visibilityGrid);

    var numberOfVisible = countVisibleTrees(visibilityGrid);
    print("{}\n", .{numberOfVisible});

    scenicLeft(grid, &scenicGrid);
    scenicRight(grid, &scenicGrid);
    scenicBottom(grid, &scenicGrid);
    scenicTop(grid, &scenicGrid);
    var maxScenicScore = getMaxScenic(scenicGrid);
    print("{}\n", .{maxScenicScore});
}
