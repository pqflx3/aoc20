const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;

const aoc20 = @import("../aoc20.zig");



const Day3 = struct {
    const Self = @This();

    allocator: *Allocator,
    data: std.ArrayList(u32), // tree topography

    width: u32,
    
    pub fn height(self: Self) u32 { return @intCast(u32, self.data.items.len); }

    pub fn init(allocator: *Allocator) Self{
        return Self {
            .allocator = allocator,
            .data = std.ArrayList(u32).init(allocator),
            .width = 0,
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

    pub fn loadData(self: *Self, reader: anytype) !void {
        var buffer = ArrayList(u8).init(self.allocator); // readline buffer
        defer buffer.deinit();

        while (true) {
            reader.readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
                break;
            };
            const line = std.mem.trimRight(u8, buffer.items, "\r\n");

            if(self.width == 0) {
                self.width = @intCast(u32, line.len);
            } else if (self.width != line.len) {
                std.log.err("Invalid line width: {}.", .{line});
            }
        
            const encoded = Day3.encodeForestRow(line);
            try self.data.append(encoded);
        }
    }

    /// Encode a treeline '..#..' into a 32-bit integer where
    /// tree '#' is '1' and no-tree is '0'
    pub fn encodeForestRow(treeline: [] const u8) u32 {
        var result: u32 = 0;
        if(treeline.len == 0) return result;
        for(treeline) |c, i| {
            const inv_idx = treeline.len - 1 - i;
            if(c == '#') {
                // std.log.debug("match: {} {}", .{c, inv_idx});
                const new = std.math.rotl(u32, 1, inv_idx);
                result |= new;
            }
        }
        return result;
    }

    /// Count the number of trees run into
    pub fn sledThroughForest(self: Self, startX: u32, startY: u32, velX: u32, velY: u32) !u32 {
        var result: u32 = 0;

        var currX: u32 = startX;
        var currY: u32 = startY;

        while(currY < self.height()) {
            var rx = try std.math.rem(u32, currX, self.width);
            const bitIdx = self.width - rx - 1;
            std.log.debug("y,x,rx: {},{},{}. bitIdx: {}", .{currY, currX, rx, bitIdx});

            const line = self.data.items[currY];
            const flag = std.math.rotl(u32, 1, bitIdx);
            const hit = ((line & flag) > 0);
            std.log.debug("line: {b:0>11}, flag, {}, hit: {}", .{line, flag, hit});
            if(hit) {
                result += 1;
            }

            currX += velX;
            currY += velY;
        }
        return result;
    }

};



test "encodeForestRow" {
    expect(Day3.encodeForestRow(".") == 0);
    expect(Day3.encodeForestRow("#") == 1);
    expect(Day3.encodeForestRow("#.") == 2);
    expect(Day3.encodeForestRow("##") == 3);
    expect(Day3.encodeForestRow("#..") == 4);
    expect(Day3.encodeForestRow("#.#.") == 10);
}



pub fn day3() !void {
    std.log.info("Day 3...", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d3 = Day3.init(&gpa.allocator);
    defer d3.deinit();
    
    const filename = "C:/code/aoc20/inputs/day3.txt";
    try d3.loadDataFile(filename);
 
    const collisionsA = try d3.sledThroughForest(0, 0, 3, 1);
    std.log.info("Day 3A: '{}'.", .{collisionsA});
 
    // Part 2
    const slopeA = try d3.sledThroughForest(0, 0, 1, 1);
    const slopeB = try d3.sledThroughForest(0, 0, 3, 1);
    const slopeC = try d3.sledThroughForest(0, 0, 5, 1);
    const slopeD = try d3.sledThroughForest(0, 0, 7, 1);
    const slopeE = try d3.sledThroughForest(0, 0, 1, 2);

    const product = slopeA * slopeB * slopeC * slopeD * slopeE;
    std.log.info("Day 3B: '{}'.", .{product});

}

test "day3" {
    std.testing.log_level = std.log.Level.debug;
    // std.testing.log_level = std.log.Level.info;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d3 = Day3.init(&gpa.allocator);
    defer d3.deinit();
    
   const topography = 
        \\..##.......
        \\#...#...#..
        \\.#....#..#.
        \\..#.#...#.#
        \\.#...##..#.
        \\..#.##.....
        \\.#.#.#....#
        \\.#........#
        \\#.##...#...
        \\#...##....#
        \\.#..#...#.#
        \\
        ;
    
    var reader = std.io.fixedBufferStream(topography[0..]).reader();
    try d3.loadData(reader);
    std.log.debug("forest width: {}", .{d3.width});
    std.log.debug("forest height: {}", .{d3.height()});

    const collisions = try d3.sledThroughForest(0, 0, 3, 1);
    expect(collisions == 7);

    // Part2
    const a = try d3.sledThroughForest(0, 0, 1, 1);
    expect(a == 2);
    const b = try d3.sledThroughForest(0, 0, 3, 1);
    expect(b == 7);
    const c = try d3.sledThroughForest(0, 0, 5, 1);
    expect(c == 3);
    const d = try d3.sledThroughForest(0, 0, 7, 1);
    expect(d == 4);
    const e = try d3.sledThroughForest(0, 0, 1, 2);
    expect(e == 2);

    // const filename = "C:/code/aoc20/inputs/day3.txt";
    // try d3.loadDataFile(filename);
}