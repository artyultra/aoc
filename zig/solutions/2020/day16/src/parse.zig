const std = @import("std");
const print = std.debug.print;
const T = @import("ticket.zig");

pub const rule_type_map = [_]struct {
    name: []const u8,
    val: T.RuleType,
}{
    .{ .name = "departure location", .val = T.RuleType.dep_loc },
    .{ .name = "departure station", .val = T.RuleType.dep_stn },
    .{ .name = "departure platform", .val = T.RuleType.dep_plt },
    .{ .name = "departure track", .val = T.RuleType.dep_track },
    .{ .name = "departure date", .val = T.RuleType.dep_date },
    .{ .name = "departure time", .val = T.RuleType.dep_time },

    .{ .name = "arrival location", .val = T.RuleType.arr_loc },
    .{ .name = "arrival station", .val = T.RuleType.arr_stn },
    .{ .name = "arrival platform", .val = T.RuleType.arr_plt },
    .{ .name = "arrival track", .val = T.RuleType.arr_track },

    .{ .name = "class", .val = T.RuleType.class },
    .{ .name = "duration", .val = T.RuleType.duration },
    .{ .name = "price", .val = T.RuleType.price },
    .{ .name = "route", .val = T.RuleType.route },
    .{ .name = "row", .val = T.RuleType.row },
    .{ .name = "seat", .val = T.RuleType.seat },
    .{ .name = "train", .val = T.RuleType.train },
    .{ .name = "type", .val = T.RuleType.tick_type },
    .{ .name = "wagon", .val = T.RuleType.wagon },
    .{ .name = "zone", .val = T.RuleType.zone },
};

pub fn range(range_str: []const u8) !T.Range {
    var parts = std.mem.splitScalar(u8, range_str, '-');
    const low_str = parts.next().?;
    const low_clean = std.mem.trim(u8, low_str, " ");
    const low = try std.fmt.parseInt(u32, low_clean, 10);

    const high_str = parts.next().?;
    const high_clean = std.mem.trim(u8, high_str, " ");
    const high = try std.fmt.parseInt(u32, high_clean, 10);

    return T.Range{ .low = low, .high = high };
}

pub fn ruleType(title: []const u8) !T.RuleType {
    var clean_title = std.mem.trimRight(u8, title, " ");
    clean_title = std.mem.trimLeft(u8, clean_title, " ");
    for (rule_type_map) |entry| {
        if (std.mem.eql(u8, clean_title, entry.name)) {
            return entry.val;
        }
    }
    return error.UnknownRuleType;
}

pub fn rule(line: []const u8) !T.Rule {
    var parts = std.mem.splitScalar(u8, line, ':');
    const title = parts.next().?;

    const ranges_str = parts.next().?;
    var range_parts = std.mem.splitSequence(u8, ranges_str, "or");

    const a = try range(range_parts.next().?);
    const b = try range(range_parts.next().?);
    const t = try ruleType(title);

    return .{
        .t = t, // todo
        .a = a,
        .b = b,
    };
}

pub fn ticket(alloc: std.mem.Allocator, line: []const u8) ![]u32 {
    const clean_line = std.mem.trimRight(u8, line, "\n");
    var nums: std.ArrayList(u32) = .{};
    errdefer nums.deinit(alloc);

    var num_it = std.mem.tokenizeScalar(u8, clean_line, ',');
    while (num_it.next()) |num_str| {
        const num = try std.fmt.parseInt(u32, num_str, 10);
        try nums.append(alloc, num);
    }

    return try nums.toOwnedSlice(alloc);
}
