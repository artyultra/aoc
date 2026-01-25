const std = @import("std");
const T = @import("ticket.zig");
const print = std.debug.print;

fn isInRange(val: u32, ranges: T.RuleRanges) bool {
    const range_a = ranges.a;
    const range_b = ranges.b;

    if (val >= range_a.low and val <= range_a.high) {
        return true;
    }
    if (val >= range_b.low and val <= range_b.high) {
        return true;
    }
    return false;
}

pub fn checkRules(val: u32, rules: T.Rules) bool {
    inline for (std.meta.fields(T.Rules)) |f| {
        if (@field(rules, f.name)) |rr| {
            if (isInRange(val, rr)) {
                return true;
            }
        }
    }

    return false;
}

pub fn isInvalid(ticket: []const u32, rules: T.Rules) bool {
    for (ticket) |val| {
        if (!checkRules(val, rules)) {
            return true;
        }
    }
    return false;
}

pub fn checkRuleByTypeIdx(r: T.Rules, val: u32, rule_idx: usize) bool {
    inline for (std.meta.fields(T.Rules), 0..) |f, i| {
        if (i == rule_idx) {
            const rr = @field(r, f.name).?;
            return isInRange(val, rr);
        }
    }
    unreachable;
}
