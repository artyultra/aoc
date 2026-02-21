const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const ParseState = enum {
    rules,
    messages,
};

const RuleId = u16;

const Alt = struct {
    ids: [2]RuleId = .{ 0, 0 },
    len: u8 = 0,
};

const NonTerm = struct {
    alts: [2]Alt = .{ .{}, .{} },
    alt_len: u8 = 0,
};

pub const Rule = union(enum) {
    term: u8,
    nonterm: NonTerm,
};

pub const Input = struct {
    const Self = @This();

    allocator: Allocator,
    raw_data: []const u8,
    state: ParseState = .rules,
    messages: [][]const u8,

    rules: std.AutoHashMap(u16, Rule),

    pub fn init(allocator: Allocator, raw_data: []const u8) !Input {
        var self: Input = .{
            .allocator = allocator,
            .raw_data = raw_data,
            .messages = &[_][]const u8{},
            .rules = std.AutoHashMap(u16, Rule).init(allocator),
        };
        try self.parseLines();
        return self;
    }

    fn parseRuleIds(line: []const u8) !Alt {
        var alt: Alt = .{};
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while (it.next()) |num_str| {
            if (alt.len >= 2) return error.TooManyRuleIds;

            const id = try std.fmt.parseInt(RuleId, num_str, 10);
            alt.ids[@as(usize, alt.len)] = id;
            alt.len += 1;
        }

        if (alt.len == 0) return error.MissingRuleId;
        return alt;
    }

    fn parseAlts(line: []const u8) !NonTerm {
        var res: NonTerm = .{};

        var it = std.mem.tokenizeScalar(u8, line, '|');
        while (it.next()) |alt_str| {
            if (res.alt_len >= 2) return error.TooManyAlts;
            const alt = try parseRuleIds(std.mem.trim(u8, alt_str, " "));
            res.alts[@as(usize, res.alt_len)] = alt;
            res.alt_len += 1;
        }
        if (res.alt_len == 0) return error.MissingAlt;
        return res;
    }

    fn parseRuleLine(self: *Self, line: []const u8) !void {
        info("parsing rule line: '{s}'\n", .{line});
        const col = std.mem.indexOfScalar(u8, line, ':') orelse return error.MissingColon;
        const id = try std.fmt.parseInt(RuleId, line[0..col], 10);
        const body = std.mem.trim(u8, line[col + 1 ..], " ");

        var rule: Rule = undefined;

        if (body.len >= 3 and body[0] == '"' and body[2] == '"') {
            rule = Rule{ .term = body[1] };
        } else {
            rule = Rule{ .nonterm = try parseAlts(body) };
        }

        try self.rules.put(id, rule);
    }

    fn parseLines(self: *Self) !void {
        const alloc = self.allocator;

        var messages: std.ArrayList([]const u8) = .{};
        errdefer messages.deinit(alloc);

        var line_it = std.mem.tokenizeScalar(u8, self.raw_data, '\n');

        while (line_it.next()) |line| {
            if (line[0] == 'a' or line[0] == 'b') {
                self.state = .messages;
            }

            switch (self.state) {
                .rules => try self.parseRuleLine(line),
                .messages => {
                    try messages.append(line);
                },
            }
        }

        self.messages = try messages.toOwnedSlice(alloc);
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.messages);
        self.rules.deinit();
    }

    pub fn hashTraverse(self: *Self, id: RuleId) void {}
};
