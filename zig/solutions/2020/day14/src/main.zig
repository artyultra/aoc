const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    lines: [][]const u8,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.lines);
    }

    fn parseMask(mask_str: []const u8) struct { and_mask: u64, or_mask: u64 } {
        var and_mask: u64 = (1 << 36) - 1;
        var or_mask: u64 = 0;

        for (mask_str, 0..) |c, i| {
            const bit_idx: u6 = @intCast(35 - i);
            const bit: u64 = (@as(u64, 1) << bit_idx);

            switch (c) {
                '1' => or_mask |= bit,
                '0' => and_mask &= ~bit,
                'X' => {},
                else => unreachable,
            }
        }
        return .{ .and_mask = and_mask, .or_mask = or_mask };
    }

    fn parseMemLine(line: []const u8) !struct { addr: u64, value: u64 } {
        // mem[0x1234567890ABCDEF] = 0xFEDCBA9876543210

        const left_br = std.mem.indexOfScalar(u8, line, '[') orelse return error.BadLine;
        const right_br = std.mem.indexOfScalar(u8, line, ']') orelse return error.BadLine;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse return error.BadLine;

        const addr_str = line[left_br + 1 .. right_br];
        const value_str = line[eq + 2 ..];

        const addr = try std.fmt.parseInt(u64, addr_str, 10);
        const value = try std.fmt.parseInt(u64, value_str, 10);

        return .{ .addr = addr, .value = value };
    }

    fn printValueToBinary(buf: []u8, value: u64) []const u8 {
        const len = std.fmt.printInt(
            buf,
            value,
            2,
            .lower,
            .{},
        );

        return buf[0..len];
    }

    pub fn part1(self: *Self) !u64 {
        var memory = std.AutoHashMap(u64, u64).init(self.allocator);
        defer memory.deinit();

        var and_mask: u64 = (1 << 36) - 1;
        var or_mask: u64 = 0;
        for (self.lines) |line| {
            const mask_or_mem = line[0..4];
            if (std.mem.eql(u8, mask_or_mem, "mask")) {
                const parsed_mask = parseMask(line[7..]);
                and_mask = parsed_mask.and_mask;
                or_mask = parsed_mask.or_mask;
            }
            if (std.mem.eql(u8, mask_or_mem, "mem[")) {
                const mem_line = try parseMemLine(line);
                const masked_value = (mem_line.value & and_mask) | or_mask;
                try memory.put(mem_line.addr, masked_value);
            }
        }

        var total: u64 = 0;
        var memory_it = memory.iterator();
        while (memory_it.next()) |kv_ptr| {
            const val = kv_ptr.value_ptr.*;
            const addr = kv_ptr.key_ptr.*;
            info("k: {}, v: {}\n", .{ addr, val });
            total += val;
        }
        return total;
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var lines: std.ArrayList([]const u8) = .{};
    errdefer lines.deinit(allocator);

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    while (line_it.next()) |line| {
        try lines.append(allocator, line);
    }

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .lines = try lines.toOwnedSlice(allocator),
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const part1 = try input.part1();
    print("Part 1: {}\n", .{part1});
}
