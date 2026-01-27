const std = @import("std");
const Allocator = std.mem.Allocator;
const f = @import("funcs.zig");
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var raw_lines: std.ArrayList([]const u8) = .{};
    errdefer raw_lines.deinit(allocator);

    var active = std.AutoHashMap(u64, void).init(allocator);
    errdefer active.deinit();

    var active_p2 = std.AutoHashMap(u64, void).init(allocator);
    errdefer active_p2.deinit();

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    const w: i32 = 0;
    const z: i32 = 0;
    var y: i32 = 0;
    while (line_it.next()) |line| : (y += 1) {
        try raw_lines.append(allocator, line);
        for (line, 0..) |c, x| {
            if (c == '#') {
                const xi: i32 = @intCast(x);
                const key = f.pack(xi, y, z);
                try active.put(key, {});

                const key_p2 = f.pack2(xi, y, z, w);
                try active_p2.put(key_p2, {});
            }
        }
    }

    return Input{
        .allocator = allocator,
        .raw_lines = try raw_lines.toOwnedSlice(allocator),
        .active = active,
        .active_p2 = active_p2,
        .state = .part1,
    };
}

const PartState = enum { part1, part2 };

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_lines: [][]const u8,
    active: std.AutoHashMap(u64, void),
    active_p2: std.AutoHashMap(u64, void),
    state: PartState,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.raw_lines);
        self.active.deinit();
        self.active_p2.deinit();
    }

    fn updateNeighborsCount(key: u64, neighbors_count: *std.AutoHashMap(u64, usize)) !void {
        const active_cell = f.unpack(key);
        var dx: i32 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i32 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i32 = -1;
                while (dz <= 1) : (dz += 1) {
                    // skip self
                    if (dx == 0 and dy == 0 and dz == 0) continue;
                    const nx = active_cell.x + dx;
                    const ny = active_cell.y + dy;
                    const nz = active_cell.z + dz;

                    const nkey = f.pack(nx, ny, nz);
                    if (neighbors_count.contains(nkey)) {
                        const current_count = neighbors_count.get(nkey).?;
                        try neighbors_count.put(nkey, current_count + 1);
                    } else {
                        try neighbors_count.put(nkey, 1);
                    }
                }
            }
        }
    }

    fn updateNeighborsCount2(key: u64, neighbors_count: *std.AutoHashMap(u64, usize)) !void {
        const active_cell = f.unpack2(key);
        var dx: i32 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i32 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i32 = -1;
                while (dz <= 1) : (dz += 1) {
                    var dw: i32 = -1;
                    while (dw <= 1) : (dw += 1) {
                        // skip self
                        if (dx == 0 and dy == 0 and dz == 0 and dw == 0) continue;
                        const nx = active_cell.x + dx;
                        const ny = active_cell.y + dy;
                        const nz = active_cell.z + dz;
                        const nw = active_cell.w + dw;

                        const nkey = f.pack2(nx, ny, nz, nw);
                        if (neighbors_count.contains(nkey)) {
                            const current_count = neighbors_count.get(nkey).?;
                            try neighbors_count.put(nkey, current_count + 1);
                        } else {
                            try neighbors_count.put(nkey, 1);
                        }
                    }
                }
            }
        }
    }

    fn handleInactive(count: usize, n_key: u64, next_active: *std.AutoHashMap(u64, void)) !void {
        if (count == 3) {
            try next_active.put(n_key, {});
        }
    }

    fn handleActive(count: usize, n_key: u64, next_active: *std.AutoHashMap(u64, void)) !void {
        if (count == 2 or count == 3) {
            try next_active.put(n_key, {});
        }
    }

    fn runSimCycle(self: *Self) !void {
        var next_active = std.AutoHashMap(u64, void).init(self.allocator);
        errdefer next_active.deinit();

        var neighbors_count = std.AutoHashMap(u64, usize).init(self.allocator);
        defer neighbors_count.deinit();

        var current_active: *std.AutoHashMap(u64, void) = undefined;

        var update_neighbors_count_fn: *const fn (u64, *std.AutoHashMap(u64, usize)) Allocator.Error!void = undefined;

        switch (self.state) {
            .part1 => {
                current_active = &self.active;
                update_neighbors_count_fn = updateNeighborsCount;
            },
            .part2 => {
                current_active = &self.active_p2;
                update_neighbors_count_fn = updateNeighborsCount2;
            },
        }

        var active_it = current_active.iterator();
        while (active_it.next()) |entry| {
            const a_key = entry.key_ptr.*;

            try update_neighbors_count_fn(a_key, &neighbors_count);
        }

        var neighbors_it = neighbors_count.iterator();
        while (neighbors_it.next()) |entry2| {
            const n_key = entry2.key_ptr.*;
            const n_count = entry2.value_ptr.*;
            if (current_active.contains(n_key)) {
                try handleActive(n_count, n_key, &next_active);
            } else {
                try handleInactive(n_count, n_key, &next_active);
            }
        }

        switch (self.state) {
            .part1 => {
                self.active.deinit();
                self.active = next_active;
            },
            .part2 => {
                self.active_p2.deinit();
                self.active_p2 = next_active;
            },
        }
    }

    pub fn runFullSimulation(self: *Self, num_cycles: usize) !usize {
        var i: usize = 0;
        while (i < num_cycles) : (i += 1) {
            try self.runSimCycle();
        }

        switch (self.state) {
            .part1 => return self.active.count(),
            .part2 => return self.active_p2.count(),
        }
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const num_cycles = 6;

    const part1_num_active_cells = try input.runFullSimulation(num_cycles);
    print("Part 1: {}\n", .{part1_num_active_cells});

    input.state = .part2;
    const part2_num_active_cells = try input.runFullSimulation(num_cycles);
    print("Part 2: {}\n", .{part2_num_active_cells});
}
