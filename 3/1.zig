const std = @import("std");

fn findDuplicateLetter(line: []const u8) u8 {
    var seen_items = [1]bool{false} ** 256;
    var first = line[0 .. line.len / 2];
    for (first) |a| {
        seen_items[a] = true;
    }
    var second = line[line.len / 2 ..];

    for (second) |b| {
        if (seen_items[b]) {
            return b;
        }
    }

    unreachable;
}

fn convertItemToPriority(item: u8) u8 {
    var result = item;
    if (std.ascii.isLower(item)) {
        result -= 'a';
    } else {
        result -= 'A';
        result += 26;
    }

    return result + 1;
}

pub fn main() void {
    const data = @embedFile("input");
    var lines = std.mem.tokenize(u8, data, "\n");
    var sum: i64 = 0;

    while (lines.next()) |line| {
        var duplicate = findDuplicateLetter(line);
        sum += convertItemToPriority(duplicate);
    }
    std.debug.print("{} \n", .{sum});
}
