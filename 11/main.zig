const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;
const int = i64;
const split = std.mem.split;
const tokenize = std.mem.tokenize;

const Operation = enum { add, mul };

const Monkey = struct {
    items: List(int),
    operation: Operation,
    element2: ?int,
    divisor: int,
    trueMonkey: int,
    falseMonkey: int,
    inspected: int = 0,
};

fn parseMonkeyData(monkeys: *List(Monkey), data: []const u8, allocator: std.mem.Allocator) !void {
    var monkeysData = split(u8, data, "\n\n");
    while (monkeysData.next()) |monkeyData| {
        var behaviours = tokenize(u8, monkeyData, "\n");

        _ = behaviours.next().?;

        var startingItemsData = split(u8, behaviours.next().?, ":");
        _ = startingItemsData.next().?;
        startingItemsData = split(u8, startingItemsData.next().?, ",");
        var items = List(int).init(allocator);
        while (startingItemsData.next()) |startingItemData| {
            const startingItem = std.mem.trim(u8, startingItemData, " ");
            const item = try std.fmt.parseInt(int, startingItem, 10);
            try items.append(item);
        }

        var operationDataSplit = split(u8, behaviours.next().?, "=");
        _ = operationDataSplit.next().?;
        var operationData = tokenize(u8, operationDataSplit.next().?, " ");
        _ = operationData.next().?;
        const operationString = operationData.next().?;
        const operation = if (std.mem.eql(u8, operationString, "*")) Operation.mul else Operation.add;
        const element2String = operationData.next().?;
        const element2 = if (std.mem.eql(u8, element2String, "old"))
            null
        else
            try std.fmt.parseInt(int, element2String, 10);

        var testdata = tokenize(u8, behaviours.next().?, " ");
        var divisorslice: []const u8 = undefined;
        while (testdata.next()) |d| {
            divisorslice = d;
        }
        const divisor = try std.fmt.parseInt(int, divisorslice, 10);

        var throwData = tokenize(u8, behaviours.next().?, " ");
        var throwSlice: []const u8 = undefined;
        while (throwData.next()) |d| {
            throwSlice = d;
        }
        const trueMonkey = try std.fmt.parseInt(int, throwSlice, 10);

        throwData = tokenize(u8, behaviours.next().?, " ");
        while (throwData.next()) |d| {
            throwSlice = d;
        }
        const falseMonkey = try std.fmt.parseInt(int, throwSlice, 10);

        const monkey: Monkey = .{ .items = items, .operation = operation, .element2 = element2, .divisor = divisor, .trueMonkey = trueMonkey, .falseMonkey = falseMonkey };
        try monkeys.append(monkey);
    }
}

fn monkeyInspect(item: int, monkey: Monkey, worryDivisor: int, largeDivisor: int) !int {
    const element2 = monkey.element2 orelse item;
    var result = switch (monkey.operation) {
        Operation.add => item + element2,
        Operation.mul => item * element2,
    };

    result = @divFloor(result, worryDivisor);
    return @mod(result, largeDivisor);
}

fn solve(part2: bool, allocator: std.mem.Allocator) !int {
    const worryDivisor: i64 = if (part2) 1 else 3;
    const numberOfRounds: i64 = if (part2) 10000 else 20;
    const data = @embedFile("input");

    var monkeys = List(Monkey).init(allocator);
    var inspections = List(int).init(allocator);

    try parseMonkeyData(&monkeys, data, allocator);

    var largeDivisor: int = 1;
    for (monkeys.items) |monkey| {
        largeDivisor *= monkey.divisor;
    }

    var round: int = 0;
    while (round < numberOfRounds) : (round += 1) {
        var monkeyCounter: usize = 0;
        while (monkeyCounter < monkeys.items.len) : (monkeyCounter += 1) {
            while (monkeys.items[monkeyCounter].items.items.len != 0) {
                const item = monkeys.items[monkeyCounter].items.orderedRemove(0);
                const newItem = try monkeyInspect(item, monkeys.items[monkeyCounter], worryDivisor, largeDivisor);
                monkeys.items[monkeyCounter].inspected += 1;
                if (@rem(newItem, monkeys.items[monkeyCounter].divisor) == 0) {
                    try monkeys.items[@intCast(monkeys.items[monkeyCounter].trueMonkey)].items.append(newItem);
                } else {
                    try monkeys.items[@intCast(monkeys.items[monkeyCounter].falseMonkey)].items.append(newItem);
                }
            }
        }
    }

    for (monkeys.items) |monkey| {
        try inspections.append(monkey.inspected);
    }
    std.mem.sort(int, inspections.items, {}, comptime std.sort.desc(int));
    return inspections.items[0] * inspections.items[1];
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    print("P1: {}, P2: {}\n", .{ try solve(false, allocator), try solve(true, allocator) });
}
