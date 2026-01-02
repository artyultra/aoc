const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Op = struct {
    op: []const u8,
    val: i32,
};

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    ops: []Op,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.ops);
    }

    pub fn printOps(self: *const Self) void {
        for (self.ops) |op| {
            print("{s} {d}\n", .{ op.op, op.val });
        }
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var ops: std.ArrayList(Op) = .empty;
    errdefer ops.deinit(allocator);

    var op_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    while (op_it.next()) |op| {
        const space_idx = std.mem.indexOfScalar(u8, op, ' ').?;
        const op_type = op[0..space_idx];
        const op_value = op[space_idx + 1 ..];
        const sign_char = op_value[0];
        const digits = op_value[1..];
        var val = try std.fmt.parseInt(i32, digits, 10);
        if (sign_char == '-') {
            val = -val;
        }

        try ops.append(allocator, Op{
            .op = op_type,
            .val = val,
        });
    }

    return Input{
        .raw_data = raw_data,
        .allocator = allocator,
        .ops = try ops.toOwnedSlice(allocator),
    };
}

fn runOps(input: Input) !i32 {
    const ops = input.ops;

    var visited = try input.allocator.alloc(bool, ops.len);
    @memset(visited, false);
    var acc: i32 = 0;
    var repeated: bool = false;
    var ip: isize = 0;
    while (!repeated) {
        const idx: usize = @intCast(ip);
        if (visited[idx]) {
            repeated = true;
            continue;
        } else {
            visited[idx] = true;
        }

        const opt = ops[idx];
        const op = opt.op;
        const val = opt.val;
        print("Op: {s} {d}\n", .{ op, val });
        if (std.mem.eql(u8, op, "nop")) {
            ip += 1;
            continue;
        } else if (std.mem.eql(u8, op, "acc")) {
            acc += val;
            ip += 1;
            continue;
        } else if (std.mem.eql(u8, op, "jmp")) {
            ip += val;
            continue;
        }
    }
    return acc;
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();
    const res1 = try part1(input);
    print("part1: {}\n", .{res1});
}

fn part1(input: Input) !i32 {
    return try runOps(input);
}
