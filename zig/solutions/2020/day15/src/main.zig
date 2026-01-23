const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    const data = std.mem.trim(u8, raw_data, "\n");
    var nums: [2022]i32 = [_]i32{0} ** 2022;

    var num_it = std.mem.tokenizeScalar(u8, data, ',');
    var i: usize = 0;
    while (num_it.next()) |num| {
        nums[i] = try std.fmt.parseInt(i32, num, 10);
        i += 1;
    }

    return Input{
        .allocator = allocator,
        .nums = nums,
        .cur_idx = i,
    };
}

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    nums: [2022]i32,
    cur_idx: usize,

    // pub fn deinit(self: *Self) void {}

    fn checkForPrevInstances(self: *Self, num: i32, idx: usize) ?usize {
        var i: usize = idx - 1;
        while (i > 0) {
            i -= 1; // decrement first so we start at idx-1
            if (self.nums[i] == num) return i;
        }
        return null;
    }

    pub fn part1(self: *Self) i32 {
        for (self.cur_idx..2022) |i| {
            const prev = self.nums[i - 1];
            const prev_pos = self.checkForPrevInstances(prev, i);
            if (prev_pos) |pos| {
                const new_num: i32 = @intCast((i - 1) - pos);
                self.nums[i] = new_num;
            } else {
                self.nums[i] = 0;
            }
        }
        return self.nums[2019];
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    // defer input.deinit();

    const part1 = (&input).part1();
    info("part1: {d}\n", .{part1});
}
