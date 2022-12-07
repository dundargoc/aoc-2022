const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const List = std.ArrayList;
const size_limit = 100000;
const total_disk_space = 70000000;
const required_unused_space = 30000000;
const ENABLE_DEBUG = false;

const File = struct {
    name: []const u8 = undefined,
    size: i32,
};

const Directory = struct {
    name: []const u8 = undefined,
    parent: ?*Directory = null,
    children: List(*Directory) = undefined,
    files: List(File) = undefined,
};

fn gotoRootDir(current_directory: **Directory) void {
    while (current_directory.*.parent != null) {
        current_directory.* = current_directory.*.parent.?;
    }
}

fn printIndent(depth: i32) void {
    var i: i32 = 0;
    while (i < depth) : (i += 1) {
        debug.print("  ", .{});
    }
}

fn pprint(comptime fmt: []const u8, args: anytype, depth: i32) void {
    printIndent(depth);
    debug.print(fmt, args);
}

fn printFilesystem(current_directory: *Directory, depth: i32) void {
    pprint("- {s} (dir)\n", .{current_directory.name}, depth);
    for (current_directory.children.items) |child| {
        printFilesystem(child, depth + 1);
    }
    for (current_directory.files.items) |file| {
        pprint("- {s} (file, size={})\n", .{ file.name, file.size }, depth + 1);
    }
}

fn getDirSize(current_directory: *Directory) i32 {
    var sum: i32 = 0;

    for (current_directory.children.items) |child| {
        sum += getDirSize(child);
    }
    for (current_directory.files.items) |file| {
        sum += file.size;
    }
    return sum;
}

fn findSmallDirs(current_directory: *Directory) i32 {
    var sum: i32 = 0;

    for (current_directory.children.items) |child| {
        sum += findSmallDirs(child);
    }

    for (current_directory.children.items) |child| {
        const dir_size = getDirSize(child);
        if (dir_size <= size_limit) {
            sum += dir_size;
            if (ENABLE_DEBUG) {
                debug.print("Including {s} - (size={})\n", .{ child.name, dir_size });
            }
        }
    }

    return sum;
}

fn findSmallDirsPart2(current_directory: *Directory, required_delete_size: i32) i32 {
    var dir_size: i32 = total_disk_space;

    for (current_directory.children.items) |child| {
        const current_dir_size = findSmallDirsPart2(child, required_delete_size);
        if (current_dir_size >= required_delete_size) {
            dir_size = @min(dir_size, current_dir_size);
        }
    }

    for (current_directory.children.items) |child| {
        const current_dir_size = getDirSize(child);
        if (current_dir_size >= required_delete_size) {
            dir_size = @min(dir_size, current_dir_size);
        }
    }

    return dir_size;
}

pub fn main() !void {
    const data = @embedFile("input");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var lines = mem.tokenize(u8, data, "\n");
    _ = lines.next();

    var l = List(*Directory).init(allocator);
    var f = List(File).init(allocator);
    var current_directory = try allocator.create(Directory);
    current_directory.* = .{ .name = "/", .children = l, .files = f };

    while (lines.next()) |line| {
        if (line[0] == '$') {
            var command_split = mem.tokenize(u8, line, " ");
            _ = command_split.next().?;
            const command = command_split.next().?;
            if (mem.eql(u8, command, "cd")) {
                const destination = command_split.next().?;
                if (mem.eql(u8, destination, "..")) {
                    current_directory = current_directory.parent.?;
                } else {
                    l = List(*Directory).init(allocator);
                    f = List(File).init(allocator);
                    const child_directory = try allocator.create(Directory);
                    child_directory.* = .{ .name = destination, .parent = current_directory, .children = l, .files = f };
                    try current_directory.children.append(child_directory);
                    current_directory = child_directory;
                }
            }
        } else if (line[0] == 'd' and line[1] == 'i' and line[2] == 'r') {
            continue;
        } else {
            var split = mem.tokenize(u8, line, " ");
            const size = split.next().?;
            const name = split.next().?;
            const file: File = .{ .name = name, .size = try std.fmt.parseInt(i32, size, 10) };
            try current_directory.files.append(file);
        }
    }

    gotoRootDir(&current_directory);

    if (ENABLE_DEBUG) {
        printFilesystem(current_directory, 0);
        debug.print("\n", .{});
    }

    const size = findSmallDirs(current_directory);

    if (ENABLE_DEBUG) {
        debug.print("\n", .{});
    }

    const total_used_size = getDirSize(current_directory);
    const current_unused_space = total_disk_space - total_used_size;
    const required_delete_size = required_unused_space - current_unused_space;
    const part2size = findSmallDirsPart2(current_directory, required_delete_size);
    debug.print("P1: {}, P2: {}\n", .{ size, part2size });
}
