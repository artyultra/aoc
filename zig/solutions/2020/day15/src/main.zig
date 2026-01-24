const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const TARGET = 30_000_000;

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    const data = std.mem.trim(u8, raw_data, "\n");
    var nums: [2022]u32 = [_]u32{0} ** 2022;
    var last_seen = try allocator.alloc(u32, TARGET + 1);
    errdefer allocator.free(last_seen);
    @memset(last_seen, 0);

    var num_it = std.mem.tokenizeScalar(u8, data, ',');
    var last_spoken: u32 = 0;
    var i: usize = 0;
    while (num_it.next()) |num| {
        const num_u = try std.fmt.parseInt(u32, num, 10);
        nums[i] = num_u;
        last_spoken = num_u;
        i += 1;
    }

    var t: u32 = 1;
    while (t < @as(u32, @intCast(i))) : (t += 1) {
        const n = nums[t - 1];
        last_seen[n] = t;
    }

    return Input{
        .allocator = allocator,
        .nums = nums,
        .cur_idx = i,
        .last_seen = last_seen,
        .last_spoken = last_spoken,
    };
}

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    nums: [2022]u32,
    last_seen: []u32,
    cur_idx: usize,
    last_spoken: u32,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.last_seen);
    }

    fn checkForPrevInstances(self: *Self, num: u32, idx: usize) ?usize {
        var i: usize = idx - 1;
        while (i > 0) {
            i -= 1; // decrement first so we start at idx-1
            if (self.nums[i] == num) return i;
        }
        return null;
    }

    pub fn part1(self: *Self) u32 {
        for (self.cur_idx..2022) |i| {
            const prev = self.nums[i - 1];
            const prev_pos = self.checkForPrevInstances(prev, i);
            if (prev_pos) |pos| {
                const new_num: u32 = @intCast((i - 1) - pos);
                self.nums[i] = new_num;
            } else {
                self.nums[i] = 0;
            }
        }
        return self.nums[2019];
    }

    fn part2(self: *Self) !u32 {
        var last: u32 = self.last_spoken;

        // turn is 1 based
        // next turn after the start list is curr idx + 1
        var turn: u32 = @intCast(self.cur_idx + 1);

        while (turn <= TARGET) : (turn += 1) {
            const prev_turn: u32 = self.last_seen[last]; // 0 if unseen

            const next: u32 =
                if (prev_turn == 0) 0 else (turn - 1) - prev_turn;

            // update last_seen for number just spoken (next)
            self.last_seen[last] = turn - 1;

            last = next;
        }

        return last;
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    // defer input.deinit();

    const part1 = (&input).part1();
    info("part1: {d}\n", .{part1});
    const part2 = try (&input).part2();
    info("part2: {d}\n", .{part2});
}
