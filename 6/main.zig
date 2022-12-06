const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

fn duplicateCharacter(stream: ArrayList(u8), numberOfDistinctCharacters: i64) bool {
    var counter: usize = 0;
    const len = stream.items.len;
    while (counter < numberOfDistinctCharacters) : (counter += 1) {
        var innerCounter = counter + 1;
        while (innerCounter < numberOfDistinctCharacters) : (innerCounter += 1) {
            if (stream.items[len - counter - 1] == stream.items[len - innerCounter - 1]) {
                return true;
            }
        }
    }
    return false;
}

pub fn main() !void {
    const data = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stream = ArrayList(u8).init(allocator);
    defer stream.deinit();

    for (data) |d| {
        try stream.append(d);
    }
    _ = stream.pop();
    std.mem.reverse(u8, stream.items);

    const numberOfDistinctCharacters: i64 = 14;

    var counter = numberOfDistinctCharacters;
    while (duplicateCharacter(stream, numberOfDistinctCharacters)) : (counter += 1) {
        _ = stream.pop();
    }
    print("{s}\n", .{stream.items});
    print("{}\n", .{counter});
}
