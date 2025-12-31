const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.log.info;
const expect = std.testing.expect;

const INPUT_FILE = @embedFile("input.txt");

const Answer = usize;

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    height: usize,
    width: usize,
    data: []bool,

    fn deinit(self: *Self) void {
        defer self.allocator.free(self.data);
    }

    fn get(self: Self, i: usize, j: usize) bool {
        const x = std.math.rem(usize, i, self.width) catch 0;
        const y = std.math.rem(usize, j, self.height) catch 0;
        return self.getBounded(x, y);
    }

    fn getBounded(self: Self, i: usize, j: usize) bool {
        const idx = i + self.width * j;
        return self.data[idx];
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    print("Part 1: {}\n", .{part1(input)});
    print("Part 2: {}\n", .{part2(input)});
}

fn parseInput(allocator: Allocator, input: []const u8) !Input {
    var res: std.ArrayList(bool) = .empty;
    errdefer res.deinit(allocator);

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var height: usize = 0;
    var width: usize = 0;
    while (lines.next()) |line| {
        width = line.len;
        height += 1;
        for (line) |char| {
            const b: bool = if (char == '#') true else false;
            try res.append(allocator, b);
        }
    }

    return Input{
        .allocator = allocator,
        .height = height,
        .width = width,
        .data = try res.toOwnedSlice(allocator),
    };
}

fn treeHit(input: Input, step_right: usize, step_down: usize) Answer {
    var i: usize = 0;
    var j: usize = 0;
    var hits: usize = 0;
    while (j < input.height) {
        if (input.get(i, j)) {
            hits += 1;
        }
        i += step_right;
        j += step_down;
    }
    return hits;
}

fn part1(input: Input) Answer {
    return treeHit(input, 3, 1);
}

fn part2(input: Input) Answer {
    return treeHit(input, 1, 1) * treeHit(input, 3, 1) * treeHit(input, 5, 1) * treeHit(input, 7, 1) * treeHit(input, 1, 2);
}

test "example" {
    const alloc = std.testing.allocator;
    const test_input = @embedFile("example.txt");
    var input = try parseInput(alloc, test_input);
    defer input.deinit();

    try expect(part1(input) == 7);
    try expect(part2(input) == 336);
}

test "answers" {
    const alloc = std.testing.allocator;
    const test_input = @embedFile("input.txt");
    var input = try parseInput(alloc, test_input);
    defer input.deinit();

    try expect(part1(input) == 171);
    // try expect(part2(input) == 1718180100);
}
