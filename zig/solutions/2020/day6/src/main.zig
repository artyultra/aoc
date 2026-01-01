const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    const Self = @This();

    raw_data: []const u8,
    allocator: Allocator,
    groups: [][][]const u8,

    pub fn deinit(self: *Self) void {
        for (self.groups) |group| {
            self.allocator.free(group);
        }
        self.allocator.free(self.groups);
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var groups: std.ArrayList([][]const u8) = .empty;
    errdefer groups.deinit(allocator);

    var group_it = std.mem.tokenizeSequence(u8, raw_data, "\n\n");
    while (group_it.next()) |group_item| {
        var group: std.ArrayList([]const u8) = .empty;
        errdefer group.deinit(allocator);

        var line_it = std.mem.tokenizeScalar(u8, group_item, '\n');
        while (line_it.next()) |line| {
            try group.append(allocator, line);
        }
        try groups.append(allocator, try group.toOwnedSlice(allocator));
    }

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .groups = try groups.toOwnedSlice(allocator),
    };
}

fn countYes(allocator: Allocator, group: [][]const u8) !usize {
    var found: std.ArrayList(u8) = .empty;
    errdefer found.deinit(allocator);

    for (group) |line| {
        for (line) |char| {
            if (std.mem.indexOfScalar(u8, found.items, char) == null) {
                try found.append(allocator, char);
            }
        }
    }
    return found.items.len;
}

fn countSharedYes(allocator: Allocator, group: [][]const u8) !usize {
    var char_counts = std.AutoHashMap(u8, usize).init(allocator);
    errdefer char_counts.deinit();

    for (group) |line| {
        for (line) |char| {
            const gop = try char_counts.getOrPut(char);
            if (gop.found_existing) {
                gop.value_ptr.* += 1;
            } else {
                gop.value_ptr.* = 1;
            }
        }
    }

    var res: usize = 0;
    var it = char_counts.iterator();
    while (it.next()) |c_ptr| {
        if (c_ptr.value_ptr.* == group.len) {
            res += 1;
        }
    }

    return res;
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    // const res1 = try part1(input);
    // print("res1: {}\n", .{res1});
    const res2 = try part2(input);
    print("res2: {}\n", .{res2});
}

fn part1(inp: Input) !usize {
    const groups = inp.groups;
    var res: usize = 0;
    for (groups) |group| {
        res += try countYes(inp.allocator, group);
    }
    return res;
}

fn part2(inp: Input) !usize {
    const groups = inp.groups;
    var res: usize = 0;
    for (groups) |group| {
        res += try countSharedYes(inp.allocator, group);
    }
    return res;
}
