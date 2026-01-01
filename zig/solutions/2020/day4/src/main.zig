const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const print = std.log.info;

const INPUT_FILE = @embedFile("input.txt");

const VALID_EYE_COLORS = [_][]const u8{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };

const Answer = usize;

const Height = struct {
    unit: []const u8,
    height: usize,
};

const Passport = struct {
    birth_year: ?usize,
    issue_year: ?usize,
    exp_year: ?usize,
    height: ?Height,
    hair_color: ?[]const u8,
    eye_color: ?[]const u8,
    passport_id: ?[]const u8,
    country_id: ?[]const u8,
};

fn parseInput(allocator: Allocator, input: []const u8) ![]Passport {
    var passports: std.ArrayList(Passport) = .empty;
    errdefer passports.deinit(allocator);

    var raw_passports = std.mem.splitSequence(u8, input, "\n\n");
    while (raw_passports.next()) |raw_passport| {
        const passport = try parseLine(raw_passport);
        try passports.append(allocator, passport);
    }

    return passports.toOwnedSlice(allocator);
}

fn parseLine(line: []const u8) !Passport {
    var birth_year: ?usize = null;
    var issue_year: ?usize = null;
    var exp_year: ?usize = null;
    var height: ?Height = null;
    var hair_color: ?[]const u8 = null;
    var eye_color: ?[]const u8 = null;
    var passport_id: ?[]const u8 = null;
    var country_id: ?[]const u8 = null;

    var parts = std.mem.tokenizeAny(u8, line, " \n");
    while (parts.next()) |part| {
        var field_and_value = std.mem.splitAny(u8, part, ":");
        const field = field_and_value.next().?;
        const value = field_and_value.next().?;

        if (std.mem.eql(u8, field, "byr")) {
            birth_year = std.fmt.parseInt(usize, value, 10) catch unreachable;
        } else if (std.mem.eql(u8, field, "iyr")) {
            issue_year = std.fmt.parseInt(usize, value, 10) catch unreachable;
        } else if (std.mem.eql(u8, field, "eyr")) {
            exp_year = std.fmt.parseInt(usize, value, 10) catch unreachable;
        } else if (std.mem.eql(u8, field, "hgt")) {
            const unit = value[value.len - 2 ..];
            const amount = std.fmt.parseInt(usize, value[0 .. value.len - 2], 10) catch 0;
            height = Height{
                .unit = unit,
                .height = amount,
            };
        } else if (std.mem.eql(u8, field, "hcl")) {
            hair_color = value;
        } else if (std.mem.eql(u8, field, "ecl")) {
            eye_color = value;
        } else if (std.mem.eql(u8, field, "pid")) {
            passport_id = value;
        } else if (std.mem.eql(u8, field, "cid")) {
            country_id = value;
        }
    }

    return Passport{
        .birth_year = birth_year,
        .issue_year = issue_year,
        .exp_year = exp_year,
        .height = height,
        .hair_color = hair_color,
        .eye_color = eye_color,
        .passport_id = passport_id,
        .country_id = country_id,
    };
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    const passports = try parseInput(alloc.allocator(), INPUT_FILE);
    defer alloc.allocator().free(passports);

    // const answer = part1(passports);
    // print("Answer: {d}\n", .{answer});
    const answer = part2(passports);
    print("Answer: {d}\n", .{answer});
}

fn part1(passports: []Passport) Answer {
    var count: usize = 0;
    for (passports) |p| {
        if (isValidPart1(p)) {
            count += 1;
        }
    }
    return count;
}

fn isValidPart1(p: Passport) bool {
    return p.birth_year != null and
        p.issue_year != null and
        p.exp_year != null and
        p.height != null and
        p.hair_color != null and
        p.eye_color != null and
        p.passport_id != null;
}

fn part2(passports: []Passport) Answer {
    var count: usize = 0;
    for (passports) |p| {
        if (isValidPart2(p)) {
            count += 1;
        }
    }
    return count;
}

fn isValidPart2(p: Passport) bool {
    if (validateBirthYear(p.birth_year) and
        validateIssueYear(p.issue_year) and
        validateExpYear(p.exp_year) and
        validateHeight(p.height) and
        validateHairColor(p.hair_color) and
        validateEyeColor(p.eye_color) and
        validatePassportId(p.passport_id))
    {
        return true;
    }
    return false;
}

fn validateBirthYear(birth_year: ?usize) bool {
    if (birth_year) |y| {
        if (y < 1920 or y > 2002) return false;
    } else {
        return false;
    }
    return true;
}

fn validateIssueYear(issue_year: ?usize) bool {
    if (issue_year) |y| {
        if (y < 2010 or y > 2020) return false;
    } else {
        return false;
    }
    return true;
}

fn validateExpYear(exp_year: ?usize) bool {
    if (exp_year) |y| {
        if (y < 2020 or y > 2030) return false;
    } else {
        return false;
    }
    return true;
}

const HeightUnits = enum {
    cm,
    in,
    invalid,
};

fn parseHeightUnit(v: []const u8) HeightUnits {
    if (v.len != 2) return .invalid;
    if (std.mem.eql(u8, v, "cm")) return .cm;
    if (std.mem.eql(u8, v, "in")) return .in;
    return .invalid;
}

fn validateHeight(height: ?Height) bool {
    const h = height orelse return false;

    const unit = parseHeightUnit(h.unit);
    switch (unit) {
        .cm => {
            if (h.height < 150 or h.height > 193) {
                return false;
            }
            return true;
        },
        .in => {
            if (h.height < 59 or h.height > 76) {
                return false;
            }
            return true;
        },
        .invalid => {
            return false;
        },
    }
}

fn isHex(c: []const u8) bool {
    for (c) |ch| {
        if (!(std.ascii.isDigit(ch) or (ch >= 'a' and ch <= 'f'))) {
            return false;
        }
    }
    return true;
}

fn validateHairColor(hair_color: ?[]const u8) bool {
    const h = hair_color orelse return false;
    if (h.len != 7) return false;
    if (h[0] != '#') return false;
    if (!isHex(h[1..])) return false;

    return true;
}

fn validateEyeColor(eye_color: ?[]const u8) bool {
    const e = eye_color orelse return false;
    for (VALID_EYE_COLORS) |valid_color| {
        if (std.mem.eql(u8, e, valid_color)) {
            return true;
        }
    }
    return false;
}

fn validatePassportId(p_id: ?[]const u8) bool {
    const p = p_id orelse return false;
    if (p.len != 9) {
        return false;
    }
    for (p[0..9]) |ch| {
        if (!std.ascii.isDigit(ch)) {
            return false;
        }
    }

    return true;
}

test "examples" {
    const input = @embedFile("example.txt");
    try expect(part1(input) == 2);
}
