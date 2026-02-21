const std = @import("std");
const inp = @import("input.zig");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const info = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var input = try inp.Input.init(alloc.allocator(), INPUT_FILE);
    defer input.deinit();

    info("hashmap:\n", .{});
    var it = input.rules.iterator();
    while (it.next()) |entry| {
        print("{} = ", .{entry.key_ptr.*});
        switch (entry.value_ptr.*) {
            .term => |term| print("{}\n", .{term}),
            .nonterm => |nonterm| {
                for (0..nonterm.alt_len) |alt_i| {
                    if (alt_i == nonterm.alt_len - 1) {
                        print("or ", .{});
                    }
                    for (0..nonterm.alts[alt_i].len) |id_i| {
                        print("{} ", .{nonterm.alts[alt_i].ids[id_i]});
                    }
                }
                print("\n", .{});
            },
        }
    }
}
