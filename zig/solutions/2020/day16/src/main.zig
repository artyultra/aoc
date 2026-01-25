const std = @import("std");
const r = @import("rules.zig");
const T = @import("ticket.zig");
const parse = @import("parse.zig");

const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const test_equal = std.testing.expectEqual;

const INPUT_FILE = @embedFile("input.txt");

const FieldMap = struct {
    dep_loc: ?usize = null,
    dep_stn: ?usize = null,
    dep_plt: ?usize = null,
    dep_track: ?usize = null,
    dep_date: ?usize = null,
    dep_time: ?usize = null,

    arr_loc: ?usize = null,
    arr_stn: ?usize = null,
    arr_plt: ?usize = null,
    arr_track: ?usize = null,

    class: ?usize = null,
    duration: ?usize = null,
    price: ?usize = null,
    route: ?usize = null,
    row: ?usize = null,
    seat: ?usize = null,
    train: ?usize = null,
    tick_type: ?usize = null,
    wagon: ?usize = null,
    zone: ?usize = null,
};

fn assignRule(rules: *T.Rules, rule: T.Rule) !void {
    const rr: T.RuleRanges = .{ .a = rule.a, .b = rule.b };
    switch (rule.t) {
        .dep_loc => rules.dep_loc = rr,
        .dep_stn => rules.dep_stn = rr,
        .dep_plt => rules.dep_plt = rr,
        .dep_track => rules.dep_track = rr,
        .dep_date => rules.dep_date = rr,
        .dep_time => rules.dep_time = rr,
        .arr_loc => rules.arr_loc = rr,
        .arr_stn => rules.arr_stn = rr,
        .arr_plt => rules.arr_plt = rr,
        .arr_track => rules.arr_track = rr,
        .class => rules.class = rr,
        .duration => rules.duration = rr,
        .price => rules.price = rr,
        .route => rules.route = rr,
        .row => rules.row = rr,
        .seat => rules.seat = rr,
        .train => rules.train = rr,
        .tick_type => rules.tick_type = rr,
        .wagon => rules.wagon = rr,
        .zone => rules.zone = rr,
    }
}

fn parseInput(allocator: Allocator, raw_data: []const u8) !Input {
    var state: T.ParseState = .rules;
    var lines: std.ArrayList([]const u8) = .{};
    errdefer lines.deinit(allocator);

    var rules: T.Rules = .{};

    var my_ticket: std.ArrayList(u32) = .{};
    errdefer my_ticket.deinit(allocator);

    var nearby_tickets: std.ArrayList([]u32) = .{};
    errdefer nearby_tickets.deinit(allocator);

    var valid_idxs: std.ArrayList(usize) = .{};
    errdefer valid_idxs.deinit(allocator);

    var line_it = std.mem.tokenizeScalar(u8, raw_data, '\n');
    var idx: usize = 0;
    while (line_it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            continue;
        }

        try lines.append(allocator, line);
        if (std.mem.eql(u8, line, "your ticket:")) {
            state = .my_ticket;
            continue;
        }
        if (std.mem.eql(u8, line, "nearby tickets:")) {
            state = .nearby_tickets;
            continue;
        }
        switch (state) {
            .rules => {
                const rule = try parse.rule(line);
                try assignRule(&rules, rule);
            },
            .my_ticket => {
                const slice = try parse.ticket(allocator, line);
                defer allocator.free(slice);

                try my_ticket.appendSlice(allocator, slice);
            },
            .nearby_tickets => {
                const ticket = try parse.ticket(allocator, line);
                errdefer allocator.free(ticket);

                if (!r.isInvalid(ticket, rules)) {
                    try valid_idxs.append(allocator, idx);
                }

                try nearby_tickets.append(allocator, ticket);
                idx += 1;
            },
        }
    }

    return Input{
        .allocator = allocator,
        .raw_lines = try lines.toOwnedSlice(allocator),
        .rules = rules,
        .my_ticket = try my_ticket.toOwnedSlice(allocator),
        .nearby_tickets = try nearby_tickets.toOwnedSlice(allocator),
        .valid_idxs = try valid_idxs.toOwnedSlice(allocator),
        .field_map = null,
    };
}

const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_lines: [][]const u8,
    rules: T.Rules,
    my_ticket: []u32,
    nearby_tickets: [][]u32,
    valid_idxs: []usize,
    field_map: ?FieldMap,

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.raw_lines);

        for (self.nearby_tickets) |ticket| self.allocator.free(ticket);
        self.allocator.free(self.nearby_tickets);

        self.allocator.free(self.valid_idxs);

        self.allocator.free(self.my_ticket);
    }

    pub fn getErrorRate(self: *Self) u32 {
        var error_count: u32 = 0;
        for (self.nearby_tickets) |ticket| {
            for (ticket) |val| {
                if (!r.checkRules(val, self.rules)) {
                    error_count += val;
                }
            }
        }

        return error_count;
    }

    fn createFieldMatrix(self: *Self) ![][]bool {
        const rule_count = std.meta.fields(T.Rules).len;
        const field_count = self.nearby_tickets[self.valid_idxs[0]].len;

        var matrix = try self.allocator.alloc([]bool, field_count);
        errdefer {
            for (matrix) |row| self.allocator.free(row);
            self.allocator.free(matrix);
        }
        for (matrix) |*row| {
            row.* = try self.allocator.alloc(bool, rule_count);
            @memset(row.*, true);
        }

        for (self.valid_idxs) |ticket_idx| {
            const ticket = self.nearby_tickets[ticket_idx];
            for (ticket, 0..) |val, pos| {
                for (0..rule_count) |rule_j| {
                    if (!r.checkRuleByTypeIdx(self.rules, val, rule_j)) {
                        matrix[pos][rule_j] = false;
                    }
                }
            }
        }
        return matrix;
    }

    fn solveMatrixConstraints(_: *Self, matrix: [][]bool) ![20]?usize {
        var solution = [_]?usize{null} ** 20;
        var assigned_rules = [_]bool{false} ** 20;

        var changed = true;
        while (changed) {
            changed = false;

            for (matrix, 0..) |row, field_idx| {
                if (solution[field_idx] != null) continue;

                var count: usize = 0;
                var rule_idx: usize = 0;
                for (row, 0..) |possible, r_idx| {
                    if (possible and !assigned_rules[r_idx]) {
                        count += 1;
                        rule_idx = r_idx;
                    }
                }

                if (count == 1) {
                    solution[field_idx] = rule_idx;
                    assigned_rules[rule_idx] = true;
                    changed = true;
                }
            }
        }
        return solution;
    }

    fn part2(self: *Self) !u64 {
        const matrix = try self.createFieldMatrix();
        defer {
            for (matrix) |row| self.allocator.free(row);
            self.allocator.free(matrix);
        }

        var total: u64 = 1;
        const solution = try self.solveMatrixConstraints(matrix);
        for (solution, 0..) |maybe_rule_idx, field_pos| {
            const rule_idx = maybe_rule_idx.?;

            if (rule_idx < 6) { // Check if rule is departure (0-5)
                const field_val = self.my_ticket[field_pos]; // Use field_pos to index ticket
                total *= field_val;
            }
        }

        return total;
    }
};

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try parseInput(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    // const part1 = input.getErrorRate();
    // print("part1: {}\n", .{part1});

    const part2 = try input.part2();
    print("part2: {}\n", .{part2});
}

test "parseRange" {
    const test_ranges = [_]struct {
        str: []const u8,
        expected: T.Range,
    }{
        .{ .str = " 1-3", .expected = .{ .low = 1, .high = 3 } },
        .{ .str = "1-3 ", .expected = .{ .low = 1, .high = 3 } },
        .{ .str = "13-57", .expected = .{ .low = 13, .high = 57 } },
        .{ .str = "3599-112222", .expected = .{ .low = 3599, .high = 112222 } },
    };

    for (test_ranges) |entry| {
        const range = try parse.range(entry.str);
        try test_equal(entry.expected.low, range.low);
        try test_equal(entry.expected.high, range.high);
    }
}

test "parseRuleType" {
    const cases = [_]struct {
        str: []const u8,
        expected: T.RuleType,
    }{
        .{ .str = "departure location", .expected = .dep_loc },
        .{ .str = " departure location", .expected = .dep_loc },
        .{ .str = " departure location ", .expected = .dep_loc },
        .{ .str = "departure station", .expected = .dep_stn },
        .{ .str = "train", .expected = .train }, // intentionally wrong input
        .{ .str = "arrival location", .expected = .arr_loc },
    };

    for (cases, 0..) |case, i| {
        const actual = parse.ruleType(case.str) catch |err| {
            // error failure
            std.debug.print(
                "case {} FAILED (threw error)\n  input: '{s}'\n  expected: {any}\n  got error: {any}\n",
                .{ i, case.str, case.expected, err },
            );
            return err; // fail test with the real error
        };

        // wrong value failure
        if (actual != case.expected) {
            std.debug.print(
                "case {} FAILED (wrong value)\n  input: '{s}'\n  expected: {any}\n  got: {any}\n",
                .{ i, case.str, case.expected, actual },
            );
            return error.TestFailure;
        }

        // Optional: still use expectEqual if you want, but it's redundant now:
        // try std.testing.expectEqual(case.expected, actual);
    }
}

test "parseRule" {
    const cases = [_]struct {
        line: []const u8,
        expected: T.Rule,
    }{
        .{ .line = "departure location: 33-430 or 456-967", .expected = .{
            .t = .dep_loc,
            .a = .{ .low = 33, .high = 430 },
            .b = .{ .low = 456, .high = 967 },
        } },
        .{ .line = "departure platform: 42-805 or 821-968", .expected = .{
            .t = .dep_plt,
            .a = .{ .low = 42, .high = 805 },
            .b = .{ .low = 821, .high = 968 },
        } },
        .{ .line = "class: 49-524 or 543-951", .expected = .{
            .t = .class,
            .a = .{ .low = 49, .high = 524 },
            .b = .{ .low = 543, .high = 951 },
        } },
        .{ .line = "zone: 34-188 or 212-959", .expected = .{
            .t = .zone,
            .a = .{ .low = 34, .high = 188 },
            .b = .{ .low = 212, .high = 959 },
        } },
    };

    for (cases, 0..) |case, i| {
        const result = parse.rule(case.line) catch |err| {
            // error failure
            std.debug.print(
                "case {} FAILED (threw error)\n  input: '{s}'\n  expected: {any}\n  got error: {any}\n",
                .{ i, case.line, case.expected, err },
            );
            return err; // fail test with the real error
        };

        // wrong value failure
        std.testing.expectEqualDeep(case.expected, result) catch |err| {
            std.debug.print(
                "case {} FAILED (wrong value)\n  input: '{s}'\n  expected: {any}\n  got: {any}\n",
                .{ i, case.line, case.expected, result },
            );
            return err; // fail test with the real error
        };
    }
}

test "assignRule" {
    const cases = [_]struct {
        rule: T.Rule,
        expected: T.Rules,
    }{
        .{
            .rule = .{
                .t = .dep_loc,
                .a = .{ .low = 33, .high = 430 },
                .b = .{ .low = 456, .high = 967 },
            },
            .expected = .{
                .dep_loc = T.RuleRanges{
                    .a = .{ .low = 33, .high = 430 },
                    .b = .{ .low = 456, .high = 967 },
                },
            },
        },
    };

    for (cases, 0..) |case, i| {
        var rules: T.Rules = .{};
        assignRule(&rules, case.rule) catch |err| {
            // error failure
            print("FAILED: case {}\n", .{i});
            return err;
        };

        std.testing.expectEqualDeep(case.expected, rules) catch |err| {
            print("FAILED: case {}\n", .{i});
            return err;
        };
    }
}

test "parseTicket" {
    var alloc = std.testing.allocator;

    const cases = [_]struct {
        line: []const u8,
        expected: []const u32,
    }{
        .{
            .line = "122,945,480,667,824,475,800,224,297,602,673,513,641,524,835,981,54,184,60,721",
            .expected = &[_]u32{ 122, 945, 480, 667, 824, 475, 800, 224, 297, 602, 673, 513, 641, 524, 835, 981, 54, 184, 60, 721 },
        },
        .{
            .line = "692,125,595,331,803,765,721,249,729,162,226,523,821,137,297,588,296,299,720,318",
            .expected = &[_]u32{ 692, 125, 595, 331, 803, 765, 721, 249, 729, 162, 226, 523, 821, 137, 297, 588, 296, 299, 720, 318 },
        },
        .{
            .line = "137,173,167,139,73,67,61,179,103,113,163,71,97,101,109,59,131,127,107,53",
            .expected = &[_]u32{ 137, 173, 167, 139, 73, 67, 61, 179, 103, 113, 163, 71, 97, 101, 109, 59, 131, 127, 107, 53 },
        },
    };

    for (cases, 0..) |case, i| {
        const result = parse.ticket(alloc, case.line) catch |err| {
            print("FAILTED: case {}\n", .{i});
            return err;
        };

        std.testing.expectEqualSlices(u32, case.expected, result) catch |err| {
            print("FAILTED: case {}\n", .{i});
            return err;
        };
        defer alloc.free(result);
    }
}
