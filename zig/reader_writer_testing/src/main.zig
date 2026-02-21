const std = @import("std");
const read = @import("reader.zig");
const write = @import("writer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const msgs = try read.readFile("src/read.txt", alloc);
    defer {
        for (msgs) |msg| msg.deinit(alloc);
        alloc.free(msgs);
    }
    for (msgs, 0..) |msg, i| {
        std.debug.print("msg_id: {d}, msg_user: {s}, msg_text: {s}, loop_idx: {}\n", .{ msg.id, msg.user, msg.text, i });
        try write.writeFile(alloc, "src/write_msg.txt", msg);
    }
}
