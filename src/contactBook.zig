const std = @import("std");

pub const Contact = struct {
    name: []const u8,
    phone: []const u8,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var contactBook = std.AutoHashMap(u32, Contact).init(allocator);

pub fn list() void {
    std.debug.print("========== Contact Book ==========\n", .{});
    var it = contactBook.keyIterator();
    while (it.next()) |key| {
        std.debug.print("|| ID: {d}\n", .{key.*});
        std.debug.print("|| Name: {s}\n", .{contactBook.get(key.*).?.name});
        std.debug.print("|| Phone: {s}\n", .{contactBook.get(key.*).?.phone});
        std.debug.print("==================================\n", .{});
    }
}

pub fn add(name: []const u8, phone: []const u8) !void {
    const contact = Contact{ .name = name, .phone = phone };
    try contactBook.put(contactBook.count(), contact);
    std.debug.print("Contact added succesfully!\n", .{});
}

pub fn put(contact: Contact) !void {
    const name = try allocator.dupe(u8, contact.name);
    const phone = try allocator.dupe(u8, contact.phone);
    const newContact = Contact{ .name = name, .phone = phone };
    try contactBook.put(contactBook.count(), newContact);
}

pub fn remove(id: u8) !void {
    if (contactBook.remove(id)) {
        std.debug.print("Contact removed succesfully!\n", .{});
    } else {
        std.debug.print("Contact not found!\n", .{});
    }
}

pub fn get(key: u32) ?Contact {
    return contactBook.get(key);
}

pub fn getAll() std.AutoHashMap(u32, Contact).ValueIterator {
    return contactBook.valueIterator();
}
