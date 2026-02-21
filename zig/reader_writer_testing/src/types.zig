const std = @import("std");

pub const StoredMessage = struct {
    id: u64,
    user: []const u8,
    text: []const u8,
    pub fn deinit(self: StoredMessage, alloc: std.mem.Allocator) void {
        alloc.free(self.user);
        alloc.free(self.text);
    }
};
