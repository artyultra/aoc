const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Child = struct {
    count: usize,
    color: []const u8,
};

const Bag = struct {
    children: []Child,
};

const Bags = std.StringHashMap(Bag);

const Input = struct {
    const Self = @This();

    bags: Bags,
    allocator: Allocator,
    raw_data: []const u8,
    lines: [][]const u8,

    pub fn deinit(self: *Self) void {
        var bags_it = self.bags.iterator();
        while (bags_it.next()) |kv| {
            const key = kv.key_ptr.*;
            const bag = kv.value_ptr.*;
            for (bag.children) |child| {
                self.allocator.free(child.color);
            }
            self.allocator.free(bag.children);
            self.allocator.free(key);
        }
        self.bags.deinit();
        self.allocator.free(self.lines);
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var lines: std.ArrayList([]const u8) = .{};
    errdefer lines.deinit(allocator);

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    while (line_it.next()) |line| {
        try lines.append(allocator, line);
    }

    var bags = Bags.init(allocator);
    errdefer bags.deinit();
    var children: std.ArrayList(Child) = .{};
    errdefer children.deinit(allocator);

    for (lines.items) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const outer1 = it.next().?;
        const outer2 = it.next().?;
        const outer = try std.fmt.allocPrint(allocator, "{s}_{s}", .{ outer1, outer2 });

        // skip "bag/s and contain"
        _ = it.next().?;
        _ = it.next().?;

        const remaining = it.rest();

        var inner_entries = std.mem.tokenizeAny(u8, remaining, ",.");
        while (inner_entries.next()) |entry| {
            var e_it = std.mem.tokenizeScalar(u8, entry, ' ');

            const num_str = e_it.next().?;
            if (std.mem.eql(u8, num_str, "no")) continue;

            const num = try std.fmt.parseInt(usize, num_str, 10);
            const inner1 = e_it.next().?;
            const inner2 = e_it.next().?;
            const inner = try std.fmt.allocPrint(allocator, "{s}_{s}", .{ inner1, inner2 });
            try children.append(allocator, Child{
                .count = num,
                .color = inner,
            });
        }

        try bags.put(outer, Bag{
            .children = try children.toOwnedSlice(allocator),
        });
    }

    return Input{
        .bags = bags,
        .allocator = allocator,
        .raw_data = raw_data,
        .lines = try lines.toOwnedSlice(allocator),
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    // const res1 = try part1(input, "shiny_gold");
    // print("part1: {}\n", .{res1});
    const res2 = try part2(input, "shiny_gold");
    print("part2: {}\n", .{res2});
}

fn canFind(bags: *const Bags, color: []const u8, target: []const u8) bool {
    const bag = bags.get(color) orelse return false;

    for (bag.children) |child| {
        if (std.mem.eql(u8, child.color, target)) return true;

        if (canFind(bags, child.color, target)) return true;
    }
    return false;
}

fn part1(input: Input, target: []const u8) !usize {
    const bags = input.bags;
    var res: usize = 0;
    var kv_it = input.bags.iterator();
    while (kv_it.next()) |kv| {
        const color = kv.key_ptr.*;
        if (std.mem.eql(u8, color, target)) continue;
        const found = canFind(&bags, color, target);
        if (found) res += 1;
        // info("{s}: {}", .{ color, found });
    }
    return res;
}

fn countBagsRecursive(
    bags: *const Bags,
    color: []const u8,
) usize {
    const bag = bags.get(color) orelse return 0;

    var sum: usize = 0;
    for (bag.children) |child| {
        const nested = countBagsRecursive(bags, child.color);
        sum += child.count * (nested + 1);
    }
    return sum;
}

fn part2(input: Input, target: []const u8) !usize {
    return countBagsRecursive(&input.bags, target);
}
