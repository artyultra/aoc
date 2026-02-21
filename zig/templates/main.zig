const std = @import("std");
const inp = @import("input.zig");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try inp.Input.init(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    info("input lines:\n", .{});
    for (input.lines) |line| {
        print("{s}\n", .{line});
    }
}
