const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Input = struct {
    const Self = @This();

    allocator: Allocator,
    lines: [][]const u8,

    pub fn init(allocator: Allocator, raw_data: []const u8) !Self {
        return .{
            .allocator = allocator,
            .lines = try parseLines(allocator, raw_data),
        };
    }

    fn parseLines(allocator: Allocator, raw_data: []const u8) ![][]const u8 {
        var lines: std.ArrayList([]const u8) = .{};
        errdefer lines.deinit(allocator);

        var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
        while (line_it.next()) |line| {
            try lines.append(allocator, line);
        }

        return lines.toOwnedSlice(allocator);
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.lines);
    }
};
