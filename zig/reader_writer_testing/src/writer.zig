const std = @import("std");
const t = @import("types.zig");

const StoredMessage = t.StoredMessage;

pub fn writeFile(alloc: std.mem.Allocator, path: []const u8, msg: StoredMessage) !void {
    var file = std.fs.cwd().openFile(
        path,
        .{ .mode = .write_only },
    ) catch |err| switch (err) {
        error.FileNotFound => try std.fs.cwd().createFile(path, .{ .truncate = false }),
        else => return err,
    };
    defer file.close();

    const end = try file.getEndPos();

    var buf: [1024]u8 = undefined;
    var writer = std.fs.File.Writer.init(file, &buf);

    writer.pos = end;

    const json = try std.json.Stringify.valueAlloc(alloc, msg, .{});
    defer alloc.free(json);

    try writer.interface.writeAll(json);
    try writer.interface.writeAll("\n");

    try writer.interface.flush();
}
