const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const expectEq = std.testing.expectEqual;
const expect = std.testing.expect;

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

fn seatId(input: Input) usize {
    const row_data = input.row_data;
    const seat_data = input.seat_data;
    const row = decodeRow(row_data);
    const seat = decodeSeat(seat_data);
    return (row * 8) + seat;
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    const data_sets = try parseInput(alloc.allocator(), INPUT_FILE);
    defer alloc.allocator().free(data_sets);

    // const highest_seat_id = try part1(data_sets);
    // print("highest seat id: {}\n", .{highest_seat_id});
    const my_set = try part2(data_sets);
    print("my seat: {}\n", .{my_set});
}

fn part1(data_sets: []Input) !usize {
    var highest_seat_id: usize = 0;
    for (data_sets) |data_set| {
        const seat_id = seatId(data_set);
        if (seat_id > highest_seat_id) {
            highest_seat_id = seat_id;
        }
    }
    return highest_seat_id;
}

fn part2(data_sets: []Input) !usize {
    var taken = [_]bool{false} ** (128 * 8);

    for (data_sets) |data_set| {
        const seat_id = seatId(data_set);
        taken[seat_id] = true;
    }

    var idx: usize = 1;
    while (idx < taken.len - 1) : (idx += 1) {
        const right = taken[idx - 1];
        const possible = taken[idx];
        const left = taken[idx + 1];

        if (right and !possible and left) {
            return idx;
        }
    }
    return error.NoSeatFound;
}

test "part1" {
    const test_alloc = std.testing.allocator;

    const input = @embedFile("input.txt");
    const input_data_sets = try parseInput(test_alloc, input);
    defer test_alloc.free(input_data_sets);

    const high_seat_id = try part1(input_data_sets);

    try expectEq(842, high_seat_id);
}

test "part2" {
    const test_alloc = std.testing.allocator;

    const input = @embedFile("input.txt");
    const input_data_sets = try parseInput(test_alloc, input);
    defer test_alloc.free(input_data_sets);

    const my_seat = try part2(input_data_sets);

    try expectEq(617, my_seat);
}
