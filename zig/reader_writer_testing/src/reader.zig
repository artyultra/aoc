const std = @import("std");
const t = @import("types.zig");

pub fn readFile(path: []const u8, alloc: std.mem.Allocator) ![]t.StoredMessage {
    var file = try std.fs.cwd().openFile(
        path,
        .{},
    );
    defer file.close();

    var msgs: std.ArrayList(t.StoredMessage) = .{};
    errdefer {
        for (msgs.items) |msg| msg.deinit(alloc);
        msgs.deinit(alloc);
    }

    var buf: [1024]u8 = undefined;
    var reader = std.fs.File.Reader.init(file, &buf);

    while (true) {
        const raw_line = reader.interface.takeDelimiterInclusive('\n') catch |err| switch (err) {
            error.StreamTooLong => {
                std.debug.print("Stream too long\n", .{});
                return err;
            },
            else => {
                break;
            },
        };

        const line = std.mem.trim(u8, raw_line, "\r\n\t");
        if (line.len == 0) continue;

        const parsed = std.json.parseFromSlice(
            t.StoredMessage,
            alloc,
            line,
            .{},
        ) catch |err| {
            std.debug.print("parse error: {s}\nLINE: {s}\n\n", .{ @errorName(err), line });
            continue;
        };
        defer parsed.deinit();

        const user_copy = try alloc.dupe(u8, parsed.value.user);
        errdefer alloc.free(user_copy);

        const text_copy = try alloc.dupe(u8, parsed.value.text);
        errdefer alloc.free(text_copy);

        try msgs.append(alloc, .{
            .id = parsed.value.id,
            .user = user_copy,
            .text = text_copy,
        });
    }

    return try msgs.toOwnedSlice(alloc);
}
