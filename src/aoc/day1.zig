const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;

const Day1 = struct {
    const Self = @This();

    allocator: *Allocator,
    data: std.ArrayList(u32),

    pub fn init(allocator: *Allocator) Self{
        return Self {
            .allocator = allocator,
            .data = std.ArrayList(u32).init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        self.data.deinit();
    }


    pub fn loadDataFile(self: *Self, filename: [] const u8) !void {
        const file = try std.fs.cwd().openFile(filename, .{ .read = true });
        defer file.close();

        var reader = file.reader();
        try loadData(self, reader);
    }

    pub fn loadData(self: *Self, reader: anytype) !void{
        var buffer = ArrayList(u8).init(self.allocator);  // line buffer 
        defer buffer.deinit();

        while (true) {
            reader.readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
                break;
            };
            const line = std.mem.trimRight(u8, buffer.items, "\r\n");
            const val = try std.fmt.parseInt(u32, line, 10);
            try self.data.append(val);
        }
    }

    /// Find two inputs that sum to 2020
    pub fn targetA(self: Self, a: *u32, b: *u32) void {
        var target1: u32 = 0;
        var target2: u32 = 0;
        for (self.data.items) |val1, idx1| {
            var idx2 = idx1 + 1;
            while (idx2 < self.data.items.len) {
                const val2 = self.data.items[idx2];
                const sum = val1 + val2;
                if (sum == 2020) {
                    a.* = val1;
                    b.* = val2;
                }
                idx2 += 1;
            }
        }
    }

    pub fn answerA(self: Self) u32 {
        var a: u32 = 0;
        var b: u32 = 0;
        self.targetA(&a, &b);
        const product = a * b ;
        std.log.debug("{} + {} = 2020.", .{a, b});
        std.log.debug("{} * {} = {}", .{a, b, product});
        return product;
    }

    /// Find three inputs that sum to 2020
    pub fn targetB(self: Self, a: *u32, b: *u32, c:*u32) void {
        for (self.data.items) |val1, idx1| {
            var idx2 = idx1 + 1;
            while (idx2 < self.data.items.len) {
                const val2 = self.data.items[idx2];

                var idx3 = idx2 + 1;
                while (idx3 < self.data.items.len) {
                    const val3 = self.data.items[idx3];

                    const sum = val1 + val2 + val3;
                    if (sum == 2020) {
                        a.* = val1;
                        b.* = val2;
                        c.* = val3;
                    }
                    idx3 += 1;
                }
                idx2 += 1;
            }
        }
    }

    pub fn answerB(self: Self) u32 {
        var a: u32 = 0;
        var b: u32 = 0;
        var c: u32 = 0;
        self.targetB(&a, &b, &c);
        const product = a * b * c;
        std.log.debug("{} + {} + {} = 2020.", .{a, b, c});
        std.log.debug("{} * {} * {} = {}", .{a, b, c, product});
        return product;
    }

};

pub fn day1() !void {
    std.log.info("Day 1...", .{});
    // std.log.default_level = std.log.Level.debug;
    // std.log.default_level = std.log.Level.info;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d1 = Day1.init(&gpa.allocator);
    defer d1.deinit();
    
    const filename = "C:/code/aoc20/inputs/day1.txt";
    try d1.loadDataFile(filename);

    const answerA = d1.answerA();
    std.log.info("Day1 A: '{}'.", .{answerA});

    const answerB = d1.answerB();
    std.log.info("Day1 B: '{}'.", .{answerB});
}

test "day1" {
    std.testing.log_level = std.log.Level.debug;
    std.testing.log_level = std.log.Level.info;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d1 = Day1.init(&gpa.allocator);
    defer d1.deinit();
    
    const filename = "C:/code/aoc20/inputs/day1.txt";
    try d1.loadDataFile(filename);

    const answerA = d1.answerA();
    std.log.info("Day1 A: '{}'.", .{answerA});

    const answerB = d1.answerB();
    std.log.info("Day1 B: '{}'.", .{answerB});
}