const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;
const split = std.mem.split;
const tokenize = std.mem.tokenize;
const ENABLE_DEBUG = false;

fn packetSplit(packet: *[]const u8) []const u8 {
    if (packet.*[0] != '[') {
        const p = std.mem.sliceTo(packet.*, ',');
        const index = std.mem.indexOf(u8, packet.*, ",");
        if (index) |i| {
            packet.* = packet.*[i + 1 ..];
        } else {
            packet.* = "";
        }
        return p;
    }

    var i: usize = 1;
    var nestLevel: usize = 1;
    while (nestLevel != 0) : (i += 1) {
        switch (packet.*[i]) {
            '[' => nestLevel += 1,
            ']' => nestLevel -= 1,
            else => {},
        }
    }

    const p = packet.*[0..i];

    if (i != packet.*.len) {
        packet.* = packet.*[i + 1 ..];
    } else {
        packet.* = "";
    }

    return p;
}

fn isList(slice: []const u8) bool {
    for (slice) |s| {
        if (!std.ascii.isDigit(s)) {
            return true;
        }
    }
    return false;
}

fn convertToList(allocator: std.mem.Allocator, slice: []const u8) ![]const u8 {
    return try std.mem.join(allocator, "", &.{ "[", slice, "]" });
}

fn printNestingSpaces(level: i32) void {
    var counter: i32 = 0;
    while (counter < level) : (counter += 1) {
        print("  ", .{});
    }
}

fn pprint(comptime fmt: []const u8, args: anytype, level: i32) void {
    if (ENABLE_DEBUG) {
        printNestingSpaces(level);
        print(fmt, args);
    }
}

fn compare(allocator: std.mem.Allocator, leftWithBrackets: []const u8, rightWithBrackets: []const u8, level: i32) !?bool {
    var left = leftWithBrackets[1 .. leftWithBrackets.len - 1];
    var right = rightWithBrackets[1 .. rightWithBrackets.len - 1];

    while (left.len != 0 and right.len != 0) {
        const l = packetSplit(&left);
        const r = packetSplit(&right);

        pprint("- Compare {s} vs {s} \n", .{ l, r }, level);

        if (isList(l) and isList(r)) {
            const comparison = try compare(allocator, l, r, level + 1);
            if (comparison) |c| {
                return c;
            }
        } else if (isList(l) or isList(r)) {
            const lNext = if (!isList(l)) try convertToList(allocator, l) else l;
            const rNext = if (!isList(r)) try convertToList(allocator, r) else r;
            if (isList(l)) {
                pprint("- Mixed types; convert right to {s} and retry comparison\n", .{rNext}, level);
            } else {
                pprint("- Mixed types; convert left to {s} and retry comparison\n", .{lNext}, level);
            }
            pprint("- Compare {s} vs {s} \n", .{ lNext, rNext }, level);
            const comparison = try compare(allocator, lNext, rNext, level + 1);
            if (comparison) |c| {
                return c;
            }
        } else {
            const lInt = try std.fmt.parseInt(i32, l, 10);
            const rInt = try std.fmt.parseInt(i32, r, 10);
            const order = std.math.order(lInt, rInt);
            switch (order) {
                std.math.Order.lt => {
                    pprint("- Left side is smaller, so inputs are in the right order\n", .{}, level + 1);
                    return true;
                },
                std.math.Order.gt => {
                    pprint("- Right side is smaller, so inputs are not in the right order\n", .{}, level + 1);
                    return false;
                },
                std.math.Order.eq => {},
            }
        }
    }

    if (left.len == 0 and right.len == 0) {
        return null;
    }

    if (right.len == 0) {
        pprint("- Right side ran out of items, so input are not in the right order\n", .{}, level);
    }

    if (left.len == 0) {
        pprint("- Left side ran out of items, so input are in the right order\n", .{}, level);
    }

    return left.len == 0;
}

fn solve1(allocator: std.mem.Allocator, data: []const u8) !i32 {
    var lines = split(u8, data, "\n\n");
    var pairCounter: i32 = 1;
    var total: i32 = 0;
    while (lines.next()) |line| : (pairCounter += 1) {
        var packet = tokenize(u8, line, "\n");
        const left = packet.next().?;
        const right = packet.next().?;
        if (ENABLE_DEBUG) {
            print("== Pair {} ==\n", .{pairCounter});
            print("- Compare {s} vs {s}\n", .{ left, right });
        }
        const comparison = try compare(allocator, left, right, 1);
        if (comparison.?) {
            total += pairCounter;
        }
        if (ENABLE_DEBUG) {
            print("\n", .{});
        }
    }

    return total;
}

fn solve2(allocator: std.mem.Allocator, data: []const u8) !i32 {
    var lines = split(u8, data, "\n\n");
    var pairCounter: i32 = 1;
    var two: i32 = 1;
    var six: i32 = 2;
    while (lines.next()) |line| : (pairCounter += 1) {
        var packet = tokenize(u8, line, "\n");
        const left = packet.next().?;
        const right = packet.next().?;
        const comparison2_1 = try compare(allocator, left, "[[2]]", 1);
        const comparison2_2 = try compare(allocator, right, "[[2]]", 1);
        const comparison6_1 = try compare(allocator, left, "[[6]]", 1);
        const comparison6_2 = try compare(allocator, right, "[[6]]", 1);
        if (comparison2_1.?) {
            two += 1;
        }
        if (comparison2_2.?) {
            two += 1;
        }
        if (comparison6_1.?) {
            six += 1;
        }
        if (comparison6_2.?) {
            six += 1;
        }
    }

    return two * six;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const data = @embedFile("input");

    print("P1: {}, P2: {}\n", .{ try solve1(allocator, data), try solve2(allocator, data) });
}
