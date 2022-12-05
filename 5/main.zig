const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Matrix = ArrayList(ArrayList(u8));
const parseInt = std.fmt.parseInt;

fn convertAsciiToInteger(input: u8) u8 {
    return input - '0';
}

fn getLastItem(list: ArrayList(u8)) u8 {
    return list.items[list.items.len - 1];
}

fn getStartingStacks(input: []const u8, allocator: Allocator) !Matrix {
    var allElements = ArrayList(u8).init(allocator);
    defer allElements.deinit();
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        for (line, 0..) |in, i| {
            if (i % 4 == 1) {
                try allElements.append(in);
            }
        }
    }

    const numberOfStacks = convertAsciiToInteger(getLastItem(allElements));
    allElements.items.len -= numberOfStacks;

    var allElements2 = Matrix.init(allocator);
    var counter: i64 = 0;
    while (counter < numberOfStacks) : (counter += 1) {
        const innerList = ArrayList(u8).init(allocator);
        try allElements2.append(innerList);
    }

    for (allElements.items, 0..) |element, i| {
        if (element != 32) {
            try allElements2.items[i % numberOfStacks].insert(0, element);
        }
    }

    return allElements2;
}

fn move1(stacks: *Matrix, numberOfMoves: i64, fromIndex: usize, toIndex: usize) !void {
    var counter: i64 = 0;
    while (counter < numberOfMoves) : (counter += 1) {
        const poppedItem = stacks.items[fromIndex].pop();
        try stacks.items[toIndex].append(poppedItem);
    }
}

fn move2(stacks: *Matrix, numberOfMoves: i64, fromIndex: usize, toIndex: usize, allocator: Allocator) !void {
    var counter: usize = 0;

    var list = ArrayList(u8).init(allocator);
    defer list.deinit();

    while (counter < numberOfMoves) : (counter += 1) {
        const poppedItem = stacks.items[fromIndex].pop();
        try list.append(poppedItem);
    }

    counter = 0;
    while (counter < numberOfMoves) : (counter += 1) {
        const poppedItem = list.pop();
        try stacks.items[toIndex].append(poppedItem);
    }
}

pub fn main() !void {
    const data = @embedFile("input");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var block = std.mem.split(u8, data, "\n\n");
    var stacks = try getStartingStacks(block.next().?, allocator);
    defer stacks.deinit();

    var instructions = std.mem.tokenize(u8, block.next().?, "\n");

    while (instructions.next()) |instruction| {
        var split = std.mem.split(u8, instruction, " ");
        _ = split.next();
        const numberOfMoves = try parseInt(u8, split.next().?, 10);
        _ = split.next();
        const fromIndex = try parseInt(u8, split.next().?, 10) - 1;
        _ = split.next();
        const toIndex = try parseInt(u8, split.next().?, 10) - 1;
        // try move1(&stacks, numberOfMoves, fromIndex, toIndex);
        try move2(&stacks, numberOfMoves, fromIndex, toIndex, allocator);
    }

    var counter: usize = 0;
    while (counter < stacks.items.len) : (counter += 1) {
        print("{c}", .{stacks.items[counter].items[stacks.items[counter].items.len - 1]});
    }

    counter = 0;
    while (counter < stacks.items.len) : (counter += 1) {
        stacks.items[counter].deinit();
    }
}
