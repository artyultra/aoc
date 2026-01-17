const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.debug.info;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    earliest: usize,
    buses: []?usize,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.buses);
        return;
    }

    pub fn findEarliestBus(self: *Self) usize {
        var found: bool = false;
        var i: usize = self.earliest;
        var bus_id: usize = 0;
        while (!found) : (i += 1) {
            for (self.buses) |maybe_bus| {
                if (maybe_bus) |bus| {
                    if (@mod(i, bus) == 0) {
                        found = true;
                        bus_id = bus;
                        break;
                    }
                }
            }
        }
        return bus_id * (i - self.earliest - 1);
    }

    pub fn findTimestampAtConstraint(self: *Self) u128 {
        var t: u128 = 0;
        var step: u128 = 1;

        for (self.buses, 0..) |maybe_bus, offset_usize| {
            if (maybe_bus) |bus_usize| {
                const bus: u128 = @intCast(bus_usize);
                const offset: u128 = @intCast(offset_usize);

                while ((t + offset) % bus != 0) {
                    t += step;
                }

                step = lcm(step, bus);
            }
        }

        return t;
    }

    fn gcd(a0: u128, b0: u128) u128 {
        var a = a0;
        var b = b0;
        while (b != 0) {
            const r = a % b;
            a = b;
            b = r;
        }
        return a;
    }

    fn lcm(a: u128, b: u128) u128 {
        return (a / gcd(a, b)) * b;
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var lines_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    const earliest_string = lines_it.next().?;
    const earliest = try std.fmt.parseInt(usize, earliest_string, 10);
    const bus_ids = lines_it.next().?;

    var buses: std.ArrayList(?usize) = .{};
    errdefer buses.deinit(allocator);

    var bus_it = std.mem.tokenizeScalar(u8, bus_ids, ',');
    while (bus_it.next()) |bus_id| {
        if (bus_id[0] == 'x') {
            try buses.append(allocator, null);
            continue;
        }

        try buses.append(allocator, try std.fmt.parseInt(usize, bus_id, 10));
    }

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .earliest = earliest,
        .buses = try buses.toOwnedSlice(allocator),
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    // dont forget to change to var after
    // implementing input.deinit()
    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const earliest_bus = input.findEarliestBus();
    print("part 1: {}\n", .{earliest_bus});
    const timestamp_at_constraint = input.findTimestampAtConstraint();
    print("part 2: {}\n", .{timestamp_at_constraint});
}
