const std = @import("std");

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

fn resetItems(seen_items: *[256]bool) void {
    std.mem.set(bool, seen_items, false);
}

pub fn main() void {
    const data = @embedFile("input");
    var lines = std.mem.tokenize(u8, data, "\n");
    var sum: i64 = 0;
    var counter: u64 = 0;

    var seen_items1 = [1]bool{false} ** 256;
    var seen_items2 = [1]bool{false} ** 256;
    var seen_items3 = [1]bool{false} ** 256;
    while (lines.next()) |line| : (counter += 1) {
        counter %= 3;
        if (counter == 0) {
            resetItems(&seen_items1);
            for (line) |l| {
                seen_items1[l] = true;
            }
        }
        if (counter == 1) {
            resetItems(&seen_items2);
            for (line) |l| {
                seen_items2[l] = true;
            }
        }
        if (counter == 2) {
            resetItems(&seen_items3);
            for (line) |l| {
                seen_items3[l] = true;
            }

            var i: u8 = 0;
            while (i < seen_items3.len - 1) : (i += 1) {
                if (seen_items1[i] and seen_items2[i] and seen_items3[i]) {
                    sum += convertItemToPriority(i);
                }
            }
        }
    }
    std.debug.print("{any} \n", .{sum});
}
