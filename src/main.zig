const std = @import("std");
const contactBook = @import("contactBook.zig");
const fileSystem = @import("fileSystem.zig");
const Contact = contactBook.Contact;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("Hello, {s}!\n\n", .{try fileSystem.readName()});

    try fileSystem.readContacts();

    try getRequest();

    std.debug.print("Contacts saving...\n", .{});
    try fileSystem.saveContacts();

    quit();
}

pub fn getName() ![]u8 {
    var stdin = std.io.getStdIn().reader();
    var buf: [1024]u8 = undefined;
    var name: []u8 = undefined;

    std.debug.print("What is your name?\n└─ ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |input| {
        name = try allocator.dupe(u8, input);
    }
    try fileSystem.saveName(name);
    return name;
}

fn getRequest() !void {
    std.debug.print("Which operation do you want to do?\n", .{});
    std.debug.print("└─ 0: List Contacts\n└─ 1: Add Contact\n└─ 2: Remove Contact\n└─ 3: Quit\n\n└─ ", .{});
    var stdin = std.io.getStdIn().reader();
    var buffer: [2]u8 = undefined;
    const decision = stdin.readUntilDelimiterOrEof(buffer[0..], '\n') catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    std.debug.print("\n", .{});
    try switch (decision.?[0]) {
        '0' => contactBook.list(),
        '1' => addContact(),
        '2' => removeContact(),
        '3' => return,
        else => {
            std.debug.print("Invalid option\n", .{});
        },
    };

    if (try wantToContinue()) {
        try getRequest();
    }
}

fn wantToContinue() !bool {
    std.debug.print("Do you want to continue? (y/n)\n└─ ", .{});
    var stdin = std.io.getStdIn().reader();
    var buffer: [2]u8 = undefined;
    const decision = stdin.readUntilDelimiterOrEof(buffer[0..], '\n') catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return false;
    };
    std.debug.print("\n", .{});
    return decision.?[0] == 'y';
}

fn addContact() !void {
    var stdin = std.io.getStdIn().reader();
    var buf: [1024]u8 = undefined;
    var name: []u8 = undefined;
    var phone: []u8 = undefined;

    std.debug.print("Enter the name:\n└─ ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |input| {
        name = try allocator.dupe(u8, input);
    }

    std.debug.print("Enter the phone:\n└─ ", .{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |input| {
        phone = try allocator.dupe(u8, input);
    }
    std.debug.print("\n", .{});
    try contactBook.add(name, phone);
}

fn removeContact() !void {
    std.debug.print("Enter the id:\n└─ ", .{});
    var stdin = std.io.getStdIn().reader();
    var buffer: [2]u8 = undefined;
    const id = stdin.readUntilDelimiterOrEof(buffer[0..], '\n') catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    std.debug.print("\n", .{});
    try contactBook.remove(id.?[0] - '0');
}

fn quit() void {
    std.debug.print("Goodbye!\n", .{});
}
