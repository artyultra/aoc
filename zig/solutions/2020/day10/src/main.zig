const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.debug.info;

const INPUT_FILE = @embedFile("input.txt");

const Diffs = struct {
    one: i32,
    three: i32,
};

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    nums: []i32,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.nums);
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var nums: std.ArrayList(i32) = .empty;
    defer nums.deinit(allocator);
    try nums.append(allocator, 0);

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    var max: i32 = 0;
    while (line_it.next()) |line| {
        const num = try std.fmt.parseInt(i32, line, 10);
        if (num > max) {
            max = num;
        }
        try nums.append(allocator, num);
    }
    const device: i32 = max + 3;
    try nums.append(allocator, device);

    const slice = nums.items[0..nums.items.len];
    std.sort.block(i32, slice, {}, comptime std.sort.asc(i32));

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .nums = try nums.toOwnedSlice(allocator),
    };
}

fn getJoltDiffs(nums: []i32) !Diffs {
    var diff_of_one: i32 = 0;
    var diff_of_three: i32 = 0;
    var i: usize = 0;
    while (i < nums.len - 1) : (i += 1) {
        if (i == 0) {
            const num = nums[i];
            if (num == 1) {
                diff_of_one += 1;
            } else if (num == 3) {
                diff_of_three += 1;
            }
        }
        const num = nums[i];
        const plug = nums[i + 1];
        const diff = @abs(num - plug);
        if (diff == 1) {
            diff_of_one += 1;
        } else if (diff == 3) {
            diff_of_three += 1;
        }
    }
    return Diffs{
        .one = diff_of_one,
        .three = diff_of_three,
    };
}

fn getPossAdapterCombos(alloc: Allocator, nums: []i32) !i64 {
    var ways = try alloc.alloc(i64, nums.len);
    defer alloc.free(ways);
    ways[0] = 1;

    var i: usize = 1;
    while (i < nums.len) : (i += 1) {
        var total: i64 = 0;

        var j = i;
        while (j > 0) {
            j -= 1;

            const diff = @abs(nums[i] - nums[j]);
            if (diff <= 3) {
                total += ways[j];
            } else {
                break;
            }
        }
        ways[i] = total;
    }
    return ways[nums.len - 1];
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const res1 = try part1(input.nums);
    print("Part 1: {}\n", .{res1.one * res1.three});
    const res2 = try part2(input);
    print("Part 2: {}\n", .{res2});
}

fn part1(nums: []i32) !Diffs {
    return getJoltDiffs(nums);
}

fn part2(input: Input) !i64 {
    const nums = input.nums;
    const alloc = input.allocator;
    return getPossAdapterCombos(alloc, nums);
}
