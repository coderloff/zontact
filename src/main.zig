const std = @import("std");
const contactBook = @import("contactBook.zig");
const fileSystem = @import("fileSystem.zig");
const Contact = contactBook.Contact;

pub fn main() !void {
    const contact = Contact{
        .name = "John Doe",
        .phone = "123-456-7890",
    };

    try contactBook.put(contact);
    contactBook.list();
    try fileSystem.save();
}
