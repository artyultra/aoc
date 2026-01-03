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

fn runSim(nums: []i64, range: usize) !i64 {
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

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const res1 = try part1(input.nums, 25);
    print("part1: {}", .{res1});
}

fn part1(nums: []i64, range: usize) !i64 {
    return runSim(nums, range);
}
