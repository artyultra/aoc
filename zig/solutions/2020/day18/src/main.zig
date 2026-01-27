const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const Operator = enum {
    Add,
    Multi,
};

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    lines: [][]const u8,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.lines);
    }

    fn findMatchingClosParenthesis(s: []const u8, open_idx: usize) !usize {
        if (open_idx >= s.len or s[open_idx] != '(') return error.NotOpenParen;

        var depth: usize = 0;
        var i = open_idx;
        while (i < s.len) : (i += 1) {
            switch (s[i]) {
                '(' => depth += 1,
                ')' => {
                    depth -= 1;
                    if (depth == 0) return i;
                    if (depth < 0) return error.UnbalancedParens;
                },
                else => {},
            }
        }
        return error.UnbalancedParens;
    }

    fn multiply(a: i64, b: i64) i64 {
        return a * b;
    }

    fn add(a: i64, b: i64) i64 {
        return a + b;
    }

    fn handleOperation(op: Operator, a: i64, b: i64) !i64 {
        switch (op) {
            .Add => return add(a, b),
            .Multi => return multiply(a, b),
        }
    }

    fn parseExpression(s: []const u8) !i64 {
        return parseExpressionImpl(s, 0);
    }

    fn parseExpressionImpl(s: []const u8, acc_in: i64) !i64 {
        var acc: i64 = acc_in;
        var op: Operator = undefined;
        var current_num: i64 = 0;
        var have_num: bool = false;

        var i: usize = 0;
        while (i < s.len) : (i += 1) {
            switch (s[i]) {
                ' ' => {
                    if (have_num) {
                        acc = try handleOperation(op, acc, current_num);
                        current_num = 0;
                        have_num = false;
                    }
                },
                '+' => op = .Add,
                '*' => op = .Multi,

                '(' => {
                    const end_idx = try findMatchingClosParenthesis(s, i);
                    const sub_expr = s[i + 1 .. end_idx];

                    const sub_val = try parseExpressionImpl(sub_expr, 0);

                    if (have_num) {
                        acc = try handleOperation(op, acc, current_num);
                        current_num = 0;
                        have_num = false;
                    }

                    acc = try handleOperation(op, acc, sub_val);

                    // skip ahead to the ')'
                    i = end_idx;
                },
                '0'...'9' => {
                    have_num = true;
                    current_num = current_num * 10 + @as(i64, s[i] - '0');
                },
                else => return error.UnexpectedChar,
            }
        }

        // flush trailing number at the end
        if (have_num) {
            acc = try handleOperation(op, acc, current_num);
        }

        return acc;
    }

    pub fn evaluate(self: *Self) !i64 {
        var acc: i64 = 0;
        for (self.lines) |line| {
            acc += try parseExpression(line);
        }

        return acc;
    }
};

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var lines: std.ArrayList([]const u8) = .{};
    errdefer lines.deinit(allocator);

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    while (line_it.next()) |line| {
        try lines.append(allocator, line);
    }

    return Input{
        .allocator = allocator,
        .lines = try lines.toOwnedSlice(allocator),
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    const part1 = try input.evaluate();
    info("Part 1: {d}", .{part1});
}
