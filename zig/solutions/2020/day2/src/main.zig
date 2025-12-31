const std = @import("std");
const Allocator = std.mem.Allocator;

const PasswordEntry = struct {
    min: u32,
    max: u32,
    ch: u8,
    password: []const u8,
};

pub fn getInput(allocator: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    return content;
}

pub fn parseEntries(allocator: Allocator, content: []const u8) ![]const PasswordEntry {
    var plist: std.ArrayList(PasswordEntry) = .empty;
    errdefer plist.deinit(allocator);

    var it = std.mem.splitAny(u8, content, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;

        const dashIdx = std.mem.indexOfScalar(u8, line, '-') orelse
            return error.InvalidFormat;
        const spaceIdx = std.mem.indexOfScalar(u8, line, ' ') orelse
            return error.InvalidFormat;
        const colonIdx = std.mem.indexOfScalar(u8, line, ':') orelse
            return error.InvalidFormat;

        const min_str = line[0..dashIdx];
        const max_str = line[dashIdx + 1 .. spaceIdx];

        const min = try std.fmt.parseInt(u32, min_str, 10);
        const max = try std.fmt.parseInt(u32, max_str, 10);

        const ch = line[spaceIdx + 1];

        var pw_slice = line[colonIdx + 1 ..];
        pw_slice = std.mem.trim(u8, pw_slice, " ");

        try plist.append(allocator, .{
            .min = min,
            .max = max,
            .ch = ch,
            .password = pw_slice,
        });
    }

    return try plist.toOwnedSlice(allocator);
}

pub fn part1(allocator: Allocator, content: []const u8) !void {
    defer allocator.free(content);

    const passwords = try parseEntries(allocator, content);
    defer allocator.free(passwords);

    var validCount: usize = 0;
    for (passwords) |entry| {
        const count = std.mem.count(u8, entry.password, &[_]u8{entry.ch});
        if (count >= entry.min and count <= entry.max) {
            validCount += 1;
        }
    }
    std.debug.print("Part 1: {}\n", .{validCount});
}

pub fn part2(allocator: Allocator, content: []const u8) !void {
    defer allocator.free(content);

    const passwords = try parseEntries(allocator, content);
    defer allocator.free(passwords);

    var validCount: usize = 0;
    for (passwords) |entry| {
        const idxA = entry.min - 1;
        const idxB = entry.max - 1;
        const checkA: u8 = entry.password[idxA];
        const checkB: u8 = entry.password[idxB];

        if (checkA == entry.ch and checkB == entry.ch) {
            continue;
        }

        if (checkA == entry.ch or checkB == entry.ch) {
            validCount += 1;
        }
    }
    std.debug.print("Part 2: {}\n", .{validCount});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try getInput(allocator, "input.txt");

    // try part1(allocator, content);
    try part2(allocator, content);
}
