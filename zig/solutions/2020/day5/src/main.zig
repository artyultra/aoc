const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const INPUT_FILE = @embedFile("input.txt");

const Input = struct {
    row_data: []const u8,
    seat_data: []const u8,
};

fn parseInput(alloc: Allocator, input: []const u8) ![]Input {
    var data_sets: std.ArrayList(Input) = .empty;
    errdefer data_sets.deinit(alloc);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const l = std.mem.trim(u8, line, " ");
        const row_data = l[0 .. l.len - 3];
        const seat_data = l[l.len - 3 ..];
        const input_item = Input{
            .row_data = row_data,
            .seat_data = seat_data,
        };
        try data_sets.append(alloc, input_item);
    }
    return data_sets.toOwnedSlice(alloc);
}

fn decodeRow(code: []const u8) usize {
    var low: usize = 0;
    var high: usize = 127;
    for (code) |c| {
        const mid = (low + high) / 2;
        if (c == 'F') {
            high = mid;
        } else if (c == 'B') {
            low = mid + 1;
        } else {
            @panic("invalid char in bordering pass string");
        }
    }
    return low;
}

fn decodeSeat(code: []const u8) usize {
    var low: usize = 0;
    var high: usize = 7;
    for (code) |c| {
        print("c: {c}\n", .{c});
        const mid = (low + high) / 2;
        if (c == 'L') {
            high = mid;
        } else if (c == 'R') {
            low = mid + 1;
        } else {
            @panic("invalid char in seat string");
        }
    }
    return low;
}

fn seatId(row_data: []const u8, seat_data: []const u8) usize {
    const row = decodeRow(row_data);
    const seat = decodeSeat(seat_data);
    return (row * 8) + seat;
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    const data_sets = try parseInput(alloc.allocator(), INPUT_FILE);
    defer alloc.allocator().free(data_sets);

    const highest_seat_id = try part1(data_sets);
    print("highest seat id: {}\n", .{highest_seat_id});
}

fn part1(data_sets: []Input) !usize {
    var highest_seat_id: usize = 0;
    for (data_sets) |data_set| {
        var row_data = data_set.row_data;
        row_data = std.mem.trim(u8, row_data, " ");
        var seat_data = data_set.seat_data;
        seat_data = std.mem.trim(u8, seat_data, " ");

        const seat_id = seatId(row_data, seat_data);
        if (seat_id > highest_seat_id) {
            highest_seat_id = seat_id;
        }
    }
    return highest_seat_id;
}
