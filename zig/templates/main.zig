const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,

    fn deinit(self: *Self) void {
        defer self.allocator.free(self.raw_data);
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    const input = try parseInput(alloc.allocator(), INPUT_FILE);
    // defer input.deinit();

    print("input: {s}", .{input.raw_data});
}
