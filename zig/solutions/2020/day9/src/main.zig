const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.debug.info;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    const Self = @This();

    nums: []i64,
    allocator: Allocator,
    raw_data: []const u8,
    Answer: usize = 0,

    pub fn deinit(self: *Self) void {
        defer self.allocator.free(self.nums);
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var nums: std.ArrayList(i64) = .empty;
    errdefer nums.deinit(allocator);

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) continue;
        const num = try std.fmt.parseInt(i64, line, 10);
        try nums.append(allocator, num);
    }

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .nums = try nums.toOwnedSlice(allocator),
    };
}

fn findInvalid(nums: []i64, range: usize) !i64 {
    var check_idx: usize = range;
    while (check_idx < nums.len) : (check_idx += 1) {
        const num = nums[check_idx];
        const low: usize = check_idx - range;
        const high: usize = check_idx;
        var found: bool = false;
        for (low..high) |i| {
            for (low..high) |j| {
                const a = nums[i];
                const b = nums[j];
                if (a + b == num) {
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            return num;
        }
    }
    return error.NotFound;
}

fn findContiguousSet(nums: []i64, target: i64) !i64 {
    var check_idx: usize = 0;
    while (check_idx < nums.len) : (check_idx += 1) {
        var sum: i64 = 0;
        var min: i64 = std.math.maxInt(i64);
        var max: i64 = std.math.minInt(i64);
        for (check_idx..nums.len) |i| {
            if (nums[i] < min) min = nums[i];
            if (nums[i] > max) max = nums[i];
            sum += nums[i];
            if (sum == target) {
                return min + max;
            }
        }
    }
    return error.NotFound;
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const res1 = try part1(input.nums, 25);
    print("part1: {}\n", .{res1});
    const res2 = try part2(input.nums, res1);
    print("part2: {}\n", .{res2});
}

fn part1(nums: []i64, range: usize) !i64 {
    return findInvalid(nums, range);
}

fn part2(nums: []i64, target: i64) !i64 {
    return findContiguousSet(nums, target);
}
