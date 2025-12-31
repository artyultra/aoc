const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn getInput(allocator: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    return content;
}

pub fn part1(allocator: Allocator, filename: []const u8) !i32 {
    const content = try getInput(allocator, filename);
    defer allocator.free(content);

    // New syntax for Zig 0.15+
    var numbers: std.ArrayList(i32) = .empty;
    defer numbers.deinit(allocator);

    var iter = std.mem.splitAny(u8, content, "\n");
    while (iter.next()) |line| {
        if (line.len > 0) {
            const num = try std.fmt.parseInt(i32, line, 10);
            try numbers.append(allocator, num);
        }
    }

    for (0..numbers.items.len) |i| {
        const num = numbers.items[i];
        for (0..numbers.items.len) |j| {
            const num2 = numbers.items[j];
            if (i != j) {
                if (num + num2 == 2020) {
                    const res = num * num2;
                    return res;
                }
            }
        }
    }
    return error.NotFound;
}

pub fn part2(allocator: Allocator, filename: []const u8) !i32 {
    const content = try getInput(allocator, filename);
    defer allocator.free(content);

    var numbers: std.ArrayList(i32) = .empty;
    defer numbers.deinit(allocator);

    var iter = std.mem.splitAny(u8, content, "\n");
    while (iter.next()) |line| {
        if (line.len > 0) {
            const num = try std.fmt.parseInt(i32, line, 10);
            try numbers.append(allocator, num);
        }
    }

    for (0..numbers.items.len) |i| {
        const num1 = numbers.items[i];
        for (0..numbers.items.len) |j| {
            const num2 = numbers.items[j];
            for (0..numbers.items.len) |k| {
                const num3 = numbers.items[k];
                if (i != j and i != k and j != k) {
                    if (num1 + num2 + num3 == 2020) {
                        return num1 * num2 * num3;
                    }
                }
            }
        }
    }

    return error.NotFound;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // const part1Res = try part1(allocator, "input.txt");
    // std.debug.print("Part 1: {}\n", .{part1Res});
    const part2Res = try part2(allocator, "input.txt");
    std.debug.print("Part 2: {}\n", .{part2Res});
}
