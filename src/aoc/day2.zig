const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;

const aoc20 = @import("../aoc20.zig");

const Rule = struct {
    first: u32,
    second: u32,
    c: u8,
    password: [32]u8, // hope no passwords are larger
};

const Day2 = struct {
    const Self = @This();

    allocator: *Allocator,
    data: std.ArrayList(Rule),

    pub fn init(allocator: *Allocator) Self{
        return Self {
            .allocator = allocator,
            .data = std.ArrayList(Rule).init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        self.data.deinit();
    }

    pub fn loadDataFile(self: *Self, filename: [] const u8) !void {
        var buffer = ArrayList(u8).init(self.allocator); // readline buffer
        defer buffer.deinit();

        const file = try std.fs.cwd().openFile(filename, .{ .read = true });
        defer file.close();

        while (true) {
            file.reader().readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
                break;
            };
            const line = std.mem.trimRight(u8, buffer.items, "\r\n");
        
            const dashIdx = std.mem.indexOfPos(u8, line, 0, "-").?;
            const spaceIdx = std.mem.indexOfPos(u8, line, dashIdx, " ").?;
            const colonIdx = std.mem.indexOfPos(u8, line, spaceIdx, ":").?;

            const first = try std.fmt.parseInt(u32, line[0..dashIdx], 10);
            const second = try std.fmt.parseInt(u32, line[dashIdx+1..spaceIdx], 10);
            const char = line[spaceIdx+1];
            const password = line[colonIdx+2..]; // skip ': '

            var tmpRule: Rule = Rule {
                .first = first,
                .second = second,
                .c = char,
                .password = std.mem.zeroes([32]u8),
            };


            std.mem.copy(u8, tmpRule.password[0..], password);
            std.log.debug("rule pass: {}", .{tmpRule.password});

            try self.data.append(tmpRule);
        }
    }

    pub fn passPolicyACount(self: *Self) u32 {
        var valid: u32 = 0;
        var invalid: u32 = 0;
        for(self.data.items) | rule, i | {
            const passes = aoc20.passesPasswordPolicyA(rule.password[0..], rule.first, rule.second, rule.c);
            if(passes) {
                valid += 1;
            } else {
                invalid += 1;
            }
        }
        return valid;
    }

    pub fn passPolicyBCount(self: *Self) u32 {
        var valid: u32 = 0;
        var invalid: u32 = 0;
        for(self.data.items) | rule, i | {
            const passes = aoc20.passesPasswordPolicyB(rule.password[0..], rule.first, rule.second, rule.c);
            if(passes) {
                valid += 1;
            } else {
                invalid += 1;
            }
        }
        return valid;
    }

};

pub fn day2() !void {
    std.log.info("Day 2...", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d2 = Day2.init(&gpa.allocator);
    defer d2.deinit();
    
    const filename = "C:/code/aoc20/inputs/day2.txt";
    try d2.loadDataFile(filename);

    const answerA = d2.passPolicyACount();
    std.log.info("Day2 A: '{}'.", .{answerA});

    const answerB = d2.passPolicyBCount();
    std.log.info("Day2 B: '{}'.", .{answerB});
}

test "day2" {
    std.testing.log_level = std.log.Level.debug;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d2 = Day2.init(&gpa.allocator);
    defer d2.deinit();
    const filename = "C:/code/aoc20/inputs/day2.txt";
    
    try d2.loadDataFile(filename);
}