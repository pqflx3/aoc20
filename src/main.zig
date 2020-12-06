const std = @import("std");
const aoc = @import("./aoc.zig");

pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
    try aoc.day1();
    try aoc.day2();
    try aoc.day3();
}

