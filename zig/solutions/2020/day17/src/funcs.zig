const std = @import("std");

// =======================
// Part 1 (3D)
// =======================

const SHIFT_P1 = 21;
const OFFSET_P1 = 1 << 20;

pub fn pack(x: i32, y: i32, z: i32) u64 {
    const ux = @as(u64, @intCast(x + OFFSET_P1));
    const uy = @as(u64, @intCast(y + OFFSET_P1));
    const uz = @as(u64, @intCast(z + OFFSET_P1));

    return (ux << (SHIFT_P1 * 2)) |
        (uy << SHIFT_P1) |
        uz;
}

pub fn unpack(p: u64) struct { x: i32, y: i32, z: i32 } {
    const mask = (@as(u64, 1) << SHIFT_P1) - 1;

    const ux = (p >> (SHIFT_P1 * 2)) & mask;
    const uy = (p >> SHIFT_P1) & mask;
    const uz = p & mask;

    return .{
        .x = @as(i32, @intCast(ux)) - OFFSET_P1,
        .y = @as(i32, @intCast(uy)) - OFFSET_P1,
        .z = @as(i32, @intCast(uz)) - OFFSET_P1,
    };
}

// =======================
// Part 2 (4D)
// =======================

const SHIFT_P2 = 16;
const OFFSET_P2 = 1 << 15;

pub fn pack2(x: i32, y: i32, z: i32, w: i32) u64 {
    const ux = @as(u64, @intCast(x + OFFSET_P2));
    const uy = @as(u64, @intCast(y + OFFSET_P2));
    const uz = @as(u64, @intCast(z + OFFSET_P2));
    const uw = @as(u64, @intCast(w + OFFSET_P2));

    return (ux << (SHIFT_P2 * 3)) |
        (uy << (SHIFT_P2 * 2)) |
        (uz << SHIFT_P2) |
        uw;
}

pub fn unpack2(p: u64) struct { x: i32, y: i32, z: i32, w: i32 } {
    const mask = (@as(u64, 1) << SHIFT_P2) - 1;

    const ux = (p >> (SHIFT_P2 * 3)) & mask;
    const uy = (p >> (SHIFT_P2 * 2)) & mask;
    const uz = (p >> SHIFT_P2) & mask;
    const uw = p & mask;

    return .{
        .x = @as(i32, @intCast(ux)) - OFFSET_P2,
        .y = @as(i32, @intCast(uy)) - OFFSET_P2,
        .z = @as(i32, @intCast(uz)) - OFFSET_P2,
        .w = @as(i32, @intCast(uw)) - OFFSET_P2,
    };
}
