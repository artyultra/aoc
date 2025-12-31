const std = @import("std");

pub fn printTest(input: []const u8) void {
    std.debug.print("Input: {s}\n", .{input});
}
