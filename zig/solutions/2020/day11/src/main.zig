const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

pub const DIRECTIONS = [_][2]i32{
    .{ 0, -1 },
    .{ -1, -1 },
    .{ -1, 0 },
    .{ -1, 1 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 1, 0 },
    .{ 1, -1 },
};

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    grid: []u8,
    width: i32,
    height: i32,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.grid);
    }

    pub fn countOccupied(self: *Self) usize {
        var count: usize = 0;
        for (self.grid) |c| {
            if (c == '#') count += 1;
        }
        return count;
    }

    pub fn getChar(self: *const Self, dir_y: i32, dir_x: i32, cur_idx: usize) u8 {
        const w: i32 = self.width;
        const h: i32 = self.height;

        const idx_i = @as(i32, @intCast(cur_idx));

        const x: i32 = @mod(idx_i, w);
        const y: i32 = @divTrunc(idx_i, w);

        const nx = x + dir_x;
        const ny = y + dir_y;

        if (nx < 0 or nx >= w or ny < 0 or ny >= h) return '_';

        const nidx: usize = @intCast(ny * w + nx);
        return self.grid[nidx];
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var grid: std.ArrayList(u8) = .{};
    errdefer grid.deinit(allocator);

    var width: i32 = 0;
    var height: i32 = 0;
    var cur: i32 = 0;
    for (raw_data) |c| switch (c) {
        '\n' => {
            if (cur == 0) continue;
            if (width == 0) width = cur else if (cur != width) return error.NonRectangularGrid;
            height += 1;
            cur = 0;
        },
        else => {
            try grid.append(allocator, c);
            cur += 1;
        },
    };

    if (cur != 0) {
        if (width == 0) width = cur else if (cur != width) return error.NonRectangularGrid;
        height += 1;
    }

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .grid = try grid.toOwnedSlice(allocator),
        .width = width,
        .height = height,
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    // dont forget to change to var after
    // implementing input.deinit()
    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    // // part1
    // try sim(&input, 4, checkSurroundingSeatsP1);
    // const res1 = input.countOccupied();
    // info("part1: {d}\n", .{res1});
    // part2
    try sim(&input, 5, checkSurroundingSeatsP2);
    const res1 = input.countOccupied();
    info("part2: {d}\n", .{res1});
}

fn sim(input: *Input, limit: usize, check_fn: fn (usize, *const Input) usize) !void {
    var next_grid = try input.allocator.alloc(u8, input.grid.len);
    defer input.allocator.free(next_grid);
    while (true) {
        var changed = false;
        for (input.grid, 0..) |c, i| {
            const occ = check_fn(i, input);
            next_grid[i] = c;
            switch (c) {
                'L' => if (occ == 0) {
                    next_grid[i] = '#';
                    changed = true;
                },
                '#' => {
                    if (occ >= limit) {
                        next_grid[i] = 'L';
                        changed = true;
                    }
                },
                '.' => {},
                else => unreachable,
            }
        }

        // printGrid(input.width, next_grid);

        // swap buf
        const tmp = input.grid;
        input.grid = next_grid;
        next_grid = tmp;

        if (!changed) break;
    }

    printGrid(input.width, input.grid);
}

fn checkSurroundingSeatsP1(idx: usize, input: *const Input) usize {
    var count: usize = 0;
    for (DIRECTIONS) |dir| {
        const c = input.getChar(dir[0], dir[1], idx);
        if (c == '#') count += 1;
    }

    return count;
}

fn part2(input: *Input, limit: usize) !void {
    const idx_u = 3 * input.width + 3;
    const idx: usize = @intCast(idx_u);
    const surrounding = checkSurroundingSeatsP2(idx, input);
    if (input.grid.len != 0 and limit == 5) {
        print("surrounding: {d}\n", .{surrounding});
    }
}

fn checkSurroundingSeatsP2(idx: usize, input: *const Input) usize {
    var count: usize = 0;
    for (DIRECTIONS) |dir| {
        var y = dir[0];
        var x = dir[1];
        while (true) {
            const c = input.getChar(y, x, idx);
            if (c == '_' or c == 'L') break;
            if (c == '#') {
                count += 1;
                break;
            }
            y += dir[0];
            x += dir[1];
        }
    }

    return count;
}

fn printGrid(width: i32, grid: []const u8) void {
    print(" 0123456789", .{});
    var i: i32 = 0;
    for (grid) |c| {
        if (@mod(i, width) == 0) print("\n{}", .{@divTrunc(i, width)});
        if (i == 33) {
            print("*", .{});
            i += 1;
            continue;
        }
        print("{c}", .{c});
        i += 1;
    }
    print("\n", .{});
}
