const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn getInput(allocator: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    return content;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try getInput(allocator, "input.txt");
    defer allocator.free(content);

    std.debug.print("Part 1: {s}\n", .{content});
}
