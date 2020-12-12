const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;

const aoc20 = @import("../aoc20.zig");

const Day6Error = error {
    InvalidQuestionAnswer,
};

/// Given an answer to the custom's form in 'abcf' format
/// Return a 'u32' with bits '1' for Yes and '0' for no
pub fn parseCustomsQuestions(answer: [] const u8) !u32 {
    var result: u32 = 0;
    for(answer) |c, i| {
        if(c < 'a' or 'z' < c) 
            return error.InvalidQuestionAnswer;

        const bit = (c - 'a');
        result |= (std.math.rotl(u32, 1, bit));
    }
    return result;
}

test "parseCustomsQuestions" {
    expect((try parseCustomsQuestions("abc")) == 0b0111); 
    expect((try parseCustomsQuestions("abd")) == 0b01011); 
}


const Day6 = struct {
    const Self = @This();

    allocator: *Allocator,
    data: std.ArrayList(u32), // tree topography
    data2: std.ArrayList(u32), // tree topography

    
    pub fn init(allocator: *Allocator) Self{
        return Self {
            .allocator = allocator,
            .data = std.ArrayList(u32).init(allocator),
            .data2 = std.ArrayList(u32).init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        self.data.deinit();
        self.data2.deinit();
    }

    pub fn loadDataFile(self: *Self, filename: [] const u8) !void {
        const file = try std.fs.cwd().openFile(filename, .{ .read = true });
        defer file.close();

        var reader = file.reader();
        try loadData(self, reader);
    }

    pub fn loadData(self: *Self, reader: anytype) !void {
        var buffer = ArrayList(u8).init(self.allocator); // readline buffer
        defer buffer.deinit();

        var currGroupCustoms: u32 = 0;
        var currGroupCustoms2: u32 = std.math.maxInt(u32);

        while (true) {
            reader.readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
                break;
            };
            const line = std.mem.trimRight(u8, buffer.items, "\r\n");

            if(line.len == 0) {
                std.log.debug("wrap", .{});
                try self.data.append(currGroupCustoms);
                currGroupCustoms = 0; // reset
                try self.data2.append(currGroupCustoms2);
                currGroupCustoms2 = std.math.maxInt(u32); // reset
            } else {
                std.log.debug("line: {}", .{line});
                const memberAnswer = try parseCustomsQuestions(line);
                currGroupCustoms |= memberAnswer;
                currGroupCustoms2 &= memberAnswer;
                std.log.debug("group1: {b:0>32} member: {b:0>32}", .{currGroupCustoms, memberAnswer});
                std.log.debug("group2: {b:0>32} member: {b:0>32}", .{currGroupCustoms2, memberAnswer});
            }
        }

        // remaining group doesn't have a trailing '\n'
        if(currGroupCustoms > 0) {
            try self.data.append(currGroupCustoms);
        }

        if(currGroupCustoms !=  std.math.maxInt(u32)) {
            try self.data2.append(currGroupCustoms2);
        }
    }

    // Sum the number of bits in each group
    pub fn answer1(self: Self) u32 {
        var result: u32 = 0;
        for(self.data.items) | grpAnswer | {
            result += @popCount(u32, grpAnswer);
        }
        return result;
    }

    // Sum the number of bits in each group
    pub fn answer2(self: Self) u32 {
        var result: u32 = 0;
        for(self.data2.items) | grpAnswer | {
            result += @popCount(u32, grpAnswer);
        }
        return result;
    }

};


pub fn day6() !void {
    std.log.info("Day 6...", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d6 = Day6.init(&gpa.allocator);
    defer d6.deinit();
    
    const filename = "C:/code/aoc20/inputs/day6.txt";
    try d6.loadDataFile(filename);
 
    const answer1 = d6.answer1();
    std.log.info("Day 6A: '{}'.", .{answer1});

    const answer2 = d6.answer2();
    std.log.info("Day 6B: '{}'.", .{answer2});
}

test "day6" {
    std.testing.log_level = std.log.Level.debug;
    // std.testing.log_level = std.log.Level.info;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d6 = Day6.init(&gpa.allocator);
    defer d6.deinit();
    
    const testInput = 
        \\abc
        \\
        \\a
        \\b
        \\c
        \\
        \\ab
        \\ac
        \\
        \\a
        \\a
        \\a
        \\a
        \\
        \\b
        \\
        \\aef
        \\edc
        \\aa
        ;

    var reader = std.io.fixedBufferStream(testInput[0..]).reader();
    try d6.loadData(reader);

    for(d6.data.items) | x |  {
        std.log.info("group answer: {b:0>8}", .{x});
    }

    expect(d6.answer1() == (3 + 3 + 3 + 1 + 1 + 5));

}

