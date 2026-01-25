const std = @import("std");

pub const Range = struct {
    low: u32,
    high: u32,
};

pub const RuleType = enum {
    dep_loc,
    dep_stn,
    dep_plt,
    dep_track,
    dep_date,
    dep_time,

    arr_loc,
    arr_stn,
    arr_plt,
    arr_track,

    class,
    duration,
    price,
    route,
    row,
    seat,
    train,
    tick_type,
    wagon,
    zone,
};

pub const Rule = struct {
    t: RuleType,
    a: Range,
    b: Range,
};

pub const RuleRanges = struct {
    a: Range,
    b: Range,
};

pub const Rules = struct {
    dep_loc: ?RuleRanges = null,
    dep_stn: ?RuleRanges = null,
    dep_plt: ?RuleRanges = null,
    dep_track: ?RuleRanges = null,
    dep_date: ?RuleRanges = null,
    dep_time: ?RuleRanges = null,
    arr_loc: ?RuleRanges = null,
    arr_stn: ?RuleRanges = null,
    arr_plt: ?RuleRanges = null,
    arr_track: ?RuleRanges = null,
    class: ?RuleRanges = null,
    duration: ?RuleRanges = null,
    price: ?RuleRanges = null,
    route: ?RuleRanges = null,
    row: ?RuleRanges = null,
    seat: ?RuleRanges = null,
    train: ?RuleRanges = null,
    tick_type: ?RuleRanges = null,
    wagon: ?RuleRanges = null,
    zone: ?RuleRanges = null,
};

pub const ParseState = enum {
    rules,
    my_ticket,
    nearby_tickets,
};
