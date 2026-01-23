const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    lines: [][]const u8,

    pub fn deinit(self: *Self) void {
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

    return Input{
        .allocator = allocator,
        .lines = try lines.toOwnedSlice(allocator),
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    info("input lines:\n", .{});
    for (input.lines) |line| {
        print("    {s}\n", .{line});
    }
}
