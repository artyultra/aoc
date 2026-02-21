const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const PartState = enum { Part1, Part2 };

const Operator = enum {
    Add,
    Multi,
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
        .state = .Part1,
    };
}

const ParseError = error{
    UnexpectedChar,
    ExpectedNumber,
    TrailingGarbage,
};

const Parser = struct {
    s: []const u8,
    i: usize = 0,
    mode: PartState,

    fn skipSpaces(self: *Parser) void {
        while (self.i < self.s.len and self.s[self.i] == ' ') self.i += 1;
    }

    fn peek(self: *Parser) ?u8 {
        self.skipSpaces();
        if (self.i >= self.s.len) return null;
        return self.s[self.i];
    }

    fn eat(self: *Parser, ch: u8) ParseError!void {
        self.skipSpaces();
        if (self.i >= self.s.len or self.s[self.i] != ch) return error.UnexpectedChar;
        self.i += 1;
    }

    fn parseNumber(self: *Parser) ParseError!i64 {
        self.skipSpaces();
        if (self.i >= self.s.len or self.s[self.i] < '0' or self.s[self.i] > '9') return error.ExpectedNumber;
        var n: i64 = 0;
        while (self.i < self.s.len) : (self.i += 1) {
            const ch = self.s[self.i];
            if (ch < '0' or ch > '9') break;
            n = n * 10 + @as(i64, ch - '0');
        }
        return n;
    }

    fn parseFactor(self: *Parser) ParseError!i64 {
        if (self.peek()) |c| {
            if (c == '(') {
                try self.eat('(');
                const v = try self.parseTop();
                try self.eat(')');
                return v;
            }
        }
        return try self.parseNumber();
    }

    fn parseTop(self: *Parser) ParseError!i64 {
        return switch (self.mode) {
            .Part1 => try self.parseExpression(),
            .Part2 => try self.parseExpression2(),
        };
    }

    // Part 1: left-to-right
    fn parseExpression(self: *Parser) ParseError!i64 {
        var acc = try self.parseFactor();
        while (true) {
            const op = self.peek() orelse break;
            if (op != '+' and op != '*') break;

            self.i += 1;
            const rhs = try self.parseFactor();

            acc = switch (op) {
                '+' => acc + rhs,
                '*' => acc * rhs,
                else => unreachable,
            };
        }
        return acc;
    }

    // Part 2: '+' before '*'
    // term := factor ( '+' factor )*
    fn parseTerm(self: *Parser) ParseError!i64 {
        var acc = try self.parseFactor();
        while (true) {
            const p = self.peek() orelse break;
            if (p != '+') break;

            self.i += 1;
            const rhs = try self.parseFactor();
            acc += rhs;
        }
        return acc;
    }

    fn parseExpression2(self: *Parser) ParseError!i64 {
        var acc = try self.parseTerm();
        while (true) {
            const p = self.peek() orelse break;
            if (p != '*') break;

            self.i += 1;
            const rhs = try self.parseTerm();
            acc *= rhs;
        }
        return acc;
    }
};

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    lines: [][]const u8,
    state: PartState,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.lines);
    }

    fn evalLine(self: *Self, line: []const u8) !i64 {
        var p = Parser{ .s = line, .mode = self.state };
        const v = try p.parseTop();
        p.skipSpaces();
        if (p.i != line.len) return error.TrailingGarbage;
        return v;
    }

    pub fn evaluate(self: *Self) !i64 {
        var sum: i64 = 0;
        for (self.lines) |line| {
            sum += try self.evalLine(line);
        }
        return sum;
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    print("\n", .{});

    input.state = .Part1;
    const part1 = try input.evaluate();
    info("Part 1: {d}", .{part1});

    print("\n", .{});

    input.state = .Part2;
    const part2 = try input.evaluate();
    info("Part 2: {d}", .{part2});
}
