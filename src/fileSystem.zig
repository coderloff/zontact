const std = @import("std");
const contactBook = @import("contactBook.zig");
const main = @import("main.zig");
const Contact = contactBook.Contact;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn saveContacts() !void {
    const file = try std.fs.cwd().createFile(
        "contacts.txt",
        .{ .read = true },
    );
    defer file.close();

    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();

    var it = contactBook.getAll();
    while (it.next()) |contact| {
        string.clearAndFree();
        try std.json.stringify(contact, .{}, string.writer());
        try file.writeAll(string.items);
        try file.writeAll("\n");
    }
}

pub fn readContacts() !void {
    const file = std.fs.cwd().openFile("contacts.txt", .{}) catch |e|
        switch (e) {
        error.FileNotFound => {
            std.log.info("You don't have any contacts\n", .{});
            return;
        },
        else => return e,
    };
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const parsed = try std.json.parseFromSlice(Contact, allocator, line, .{});
        defer parsed.deinit();

        try contactBook.put(parsed.value);
    }
}

pub fn readName() ![]u8 {
    const file = std.fs.cwd().openFile("name.txt", .{}) catch |e|
        switch (e) {
        error.FileNotFound => {
            return try main.getName();
        },
        else => return e,
    };
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    if (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const name = try allocator.dupe(u8, line);
        return name;
    } else {
        return undefined;
    }
}

pub fn saveName(name: []u8) !void {
    const file = try std.fs.cwd().createFile(
        "name.txt",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(name);
}
