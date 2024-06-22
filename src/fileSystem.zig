const std = @import("std");
const contactBook = @import("contactBook.zig");

pub fn save() !void {
    const file = try std.fs.cwd().createFile(
        "contacts.txt",
        .{ .read = true },
    );
    defer file.close();

    var it = contactBook.getAll();
    while (it.next()) |contact| {
        try file.writeAll(contact.*.name);
        try file.writeAll("\n");
        try file.writeAll(contact.*.phone);
        try file.writeAll("\n");
    }
}

pub fn read() !void {
    const file = try std.fs.cwd().openFile("contacts.txt", .{});
    defer file.close();
    // TODO: Read file and put values in contactBook
}
