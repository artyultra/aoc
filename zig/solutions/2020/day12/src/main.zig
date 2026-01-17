const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Facing = enum(u8) {
    north,
    east,
    south,
    west,
};

const FerryState = struct {
    facing: Facing,
    y: i32,
    x: i32,
};

const NavInstructions = struct {
    opp: u8,
    val: usize,
};

fn parseInstructions(allocator: Allocator, raw_data: []const u8) ![]NavInstructions {
    var instructions: std.ArrayList(NavInstructions) = .{};
    errdefer instructions.deinit(allocator);

    var lines_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    while (lines_it.next()) |line| {
        const opp = line[0];
        const val = line[1..];
        try instructions.append(allocator, NavInstructions{
            .opp = opp,
            .val = std.fmt.parseInt(usize, val, 10) catch return error.InvalidInput,
        });
    }

    return try instructions.toOwnedSlice(allocator);
}

fn parseInputP1(allocator: Allocator, raw_data: []const u8) !InputP1 {
    const instructions = try parseInstructions(allocator, raw_data);
    errdefer allocator.free(instructions);

    return InputP1{
        .raw_data = raw_data,
        .allocator = allocator,
        .state = FerryState{
            .facing = .east,
            .y = 0,
            .x = 0,
        },
        .instructions = instructions,
    };
}

const InputP1 = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    state: FerryState,
    instructions: []NavInstructions,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.instructions);
    }

    pub fn getManhattanDistance(self: *Self) usize {
        const dx = @abs(self.state.x + 0);
        const dy = @abs(self.state.y + 0);
        return dx + dy;
    }

    pub fn rotate(self: *Self, dir: u8, deg: usize) void {
        const i_deg: i32 = @intCast(deg);
        var num_steps = @divTrunc(i_deg, 90);
        if (dir == 'L') {
            num_steps *= -1;
        }
        self.state.facing = self.calculateNextDir(num_steps);
    }

    pub fn calculateNextDir(self: *Self, num_steps: i32) Facing {
        const i: i32 = @intFromEnum(self.state.facing);
        const n: i32 = @intCast(@typeInfo(Facing).@"enum".fields.len);

        const next_i: i32 = @mod(i + num_steps, n);

        return @enumFromInt(next_i);
    }

    pub fn move_forward(self: *Self, val: usize) void {
        const i_val: i32 = @intCast(val);
        switch (self.state.facing) {
            .north => {
                self.state.y += i_val;
            },
            .east => {
                self.state.x += i_val;
            },
            .south => {
                self.state.y -= i_val;
            },
            .west => {
                self.state.x -= i_val;
            },
        }
    }

    pub fn move_dir(self: *Self, dir: u8, val: usize) void {
        const i_val: i32 = @intCast(val);
        switch (dir) {
            'N' => {
                self.state.y += i_val;
            },
            'S' => {
                self.state.y -= i_val;
            },
            'E' => {
                self.state.x += i_val;
            },
            'W' => {
                self.state.x -= i_val;
            },
            else => {
                return;
            },
        }
    }

    pub fn simulateP1(self: *Self) !void {
        for (self.instructions) |instruction| {
            const opp = instruction.opp;
            const val = instruction.val;
            switch (opp) {
                'L', 'R' => {
                    self.rotate(opp, val);
                },
                'F' => {
                    self.move_forward(val);
                },
                'N', 'S', 'E', 'W' => {
                    self.move_dir(opp, val);
                },
                else => {
                    return error.InvalidOpp;
                },
            }
        }
        const manhattan_distance = self.getManhattanDistance();
        print("Distance: {d}\n", .{manhattan_distance});
    }
};

const Vec2 = struct { x: i32, y: i32 };

fn parseInputP2(allocator: Allocator, raw_data: []const u8) !InputP2 {
    const instructions = try parseInstructions(allocator, raw_data);
    errdefer allocator.free(instructions);

    return InputP2{
        .raw_data = raw_data,
        .allocator = allocator,
        .instructions = instructions,
        .waypoint = Vec2{ .x = 10, .y = 1 },
        .ship = Vec2{ .x = 0, .y = 0 },
    };
}

const InputP2 = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    instructions: []NavInstructions,

    ship: Vec2,
    waypoint: Vec2,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.instructions);
    }

    pub fn getManhattanDistance(self: *Self) usize {
        const dx = @abs(self.ship.x + 0);
        const dy = @abs(self.ship.y + 0);
        return dx + dy;
    }

    pub fn moveWaypoint(self: *Self, dir: u8, val: usize) void {
        const i_val: i32 = @intCast(val);
        switch (dir) {
            'N' => {
                self.waypoint.y += i_val;
            },
            'S' => {
                self.waypoint.y -= i_val;
            },
            'E' => {
                self.waypoint.x += i_val;
            },
            'W' => {
                self.waypoint.x -= i_val;
            },
            else => {},
        }
    }

    pub fn rotateWaypoint(self: *Self, dir: u8, deg: usize) void {
        var steps: i32 = @intCast(deg / 90);
        steps = @mod(steps, 4);

        if (dir == 'L') steps = @mod(4 - steps, 4);

        var x = self.waypoint.x;
        var y = self.waypoint.y;

        switch (steps) {
            0 => {},
            1 => {
                const tx = x;
                x = y;
                y = -tx;
            },
            2 => {
                x = -x;
                y = -y;
            },
            3 => {
                const tx = x;
                x = -y;
                y = tx;
            },
            else => unreachable,
        }
        self.waypoint.x = x;
        self.waypoint.y = y;
    }

    pub fn moveShipToWaypoint(self: *Self, times: usize) void {
        const t: i32 = @intCast(times);
        self.ship.x += self.waypoint.x * t;
        self.ship.y += self.waypoint.y * t;
    }

    pub fn simulateP2(self: *Self) !void {
        for (self.instructions) |ins| {
            switch (ins.opp) {
                'L', 'R' => {
                    self.rotateWaypoint(ins.opp, ins.val);
                },
                'F' => {
                    self.moveShipToWaypoint(ins.val);
                },
                'N', 'S', 'E', 'W' => {
                    self.moveWaypoint(ins.opp, ins.val);
                },
                else => return error.InvalidOpp,
            }
        }
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    // dont forget to change to var after
    // implementing input.deinit()
    // var inputP1 = try parseInputP1(alloc.allocator(), INPUT_FILE);
    // defer inputP1.deinit();
    // try inputP1.simulateP1();

    var inputP2 = try parseInputP2(alloc.allocator(), INPUT_FILE);
    defer inputP2.deinit();
    try inputP2.simulateP2();
    print("Distance: {}\n", .{inputP2.getManhattanDistance()});
}

// PART 1

test "change Rotation" {
    print("\n***change Rotation test*** ", .{});
    const alloc = std.testing.allocator;
    const example_file = @embedFile("example.txt");
    var input = try parseInputP1(alloc, example_file);
    // const input_file = @embedFile("input.txt");
    // var input = try parseInput(alloc, input_file);
    defer input.deinit();

    for (input.instructions) |instruction| {
        const opp = instruction.opp;
        const val = instruction.val;
        switch (opp) {
            'L' => {
                print("\n\nRotate Left:  -{}\n", .{val});
                print("Before: {s}", .{@tagName(input.state.facing)});
                input.rotate('L', val);
                print(" | After: {s}\n", .{@tagName(input.state.facing)});
                break;
            },
            'R' => {
                print("\n\nRotate Right:  {}\n", .{val});
                print("Before: {s}", .{@tagName(input.state.facing)});
                input.rotate('R', val);
                print(" | After: {s}\n", .{@tagName(input.state.facing)});
                break;
            },
            else => {
                continue;
            },
        }
    }
    print("\n\n", .{});
}

test "move forward" {
    print("****move forward test****: ", .{});
    const alloc = std.testing.allocator;
    const example_file = @embedFile("example.txt");
    var input = try parseInputP1(alloc, example_file);
    // const input_file = @embedFile("input.txt");
    // var input = try parseInput(alloc, input_file);
    defer input.deinit();

    for (input.instructions) |instruction| {
        const opp = instruction.opp;
        const val = instruction.val;
        switch (opp) {
            'F' => {
                print("\n\n", .{});
                print("Move Forward:  {}\n", .{val});
                print("Before:  x: {}, y: {}\n", .{ input.state.x, input.state.y });
                input.move_forward(val);
                print("After:   x: {}, y: {}\n", .{ input.state.x, input.state.y });
                print("\n", .{});
            },
            else => {
                continue;
            },
        }
    }
    print("\n\n", .{});
}

test "move dir" {
    print("******move dir test******: ", .{});
    const alloc = std.testing.allocator;
    const example_file = @embedFile("example.txt");
    var input = try parseInputP1(alloc, example_file);
    // const input_file = @embedFile("input.txt");
    // var input = try parseInput(alloc, input_file);
    defer input.deinit();

    for (input.instructions) |instruction| {
        const opp = instruction.opp;
        const val = instruction.val;
        switch (opp) {
            'N', 'S', 'E', 'W' => {
                print("\n\n", .{});
                print("Move Dir: {c}, Val: {}\n", .{ opp, val });
                print("Before:  x: {}, y: {}\n", .{ input.state.x, input.state.y });
                input.move_dir(opp, val);
                print("After:   x: {}, y: {}\n", .{ input.state.x, input.state.y });
                print("\n", .{});
            },
            else => {
                continue;
            },
        }
    }
}

// PART 2
