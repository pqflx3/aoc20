const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;

const aoc20 = @import("../aoc20.zig");

const Day7Error = error {
    InvalidQuestionAnswer,
};


const Bag = struct {
    bag_id: u32,
    count: u32,
};

const Day7 = struct {
    const Self = @This();

    allocator: *Allocator,
    bag_ids: std.StringHashMap(u32), // map bag name to unique ID
    bag_contains: std.AutoHashMap(u32, ArrayList(Bag)), // map of bag id to bags it contains
    bag_contained_by: std.AutoHashMap(u32, ArrayList(u32)), // map of bag id to bags that contain it

    
    pub fn init(allocator: *Allocator) Self{
        return Self {
            .allocator = allocator,
            .bag_ids = std.StringHashMap(u32).init(allocator),
            .bag_contains = std.AutoHashMap(u32, ArrayList(Bag)).init(allocator),
            .bag_contained_by = std.AutoHashMap(u32, ArrayList(u32)).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.bag_ids.deinit();
        self.bag_contains.deinit();
        self.bag_contained_by.deinit();
        // TODO: the Arraylist values need to be freed?
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

        var nextBagId: u32 = 0; // increment next unseen bag type

        while (true) {
            reader.readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
                break;
            };
            const line = std.mem.trimRight(u8, buffer.items, "\r\n");
            std.log.debug("line {}.", .{line});

            // find the first ' bags' in string
            const needle = " bags contain ";
            const bagsIdx = std.mem.indexOf(u8, line, needle).?;
            const firstBag = line[0..bagsIdx];

            std.log.debug("firstBag: {}, hash: {}.", .{firstBag, std.hash_map.hashString(firstBag)});

            // Upon first seeing bag, assign it a new bagId
            if(!self.bag_ids.contains(firstBag)) {
                std.log.debug("capactity: '{}'.", .{self.bag_ids.capacity()});
                try self.bag_ids.putNoClobber(firstBag, nextBagId);
                nextBagId += 1;
            }
            const bagId = self.bag_ids.get(firstBag).?;
            std.log.debug("firstBag: '{}', id: {}.", .{firstBag, bagId});

            // Parse bags by ','
            var lastIdx: usize =  bagsIdx+needle.len;
            while(true) {
                const commaIdx = std.mem.indexOfPos(u8, line, lastIdx, ",") orelse break;
                const nextBag = line[lastIdx..commaIdx];
                std.log.debug("nextBag: '{}'.", .{nextBag});
                lastIdx = commaIdx+1;
            }
            const lastBag = line[lastIdx..];
            std.log.debug("lastBag: '{}'.", .{lastBag});
                


        }
    }

    pub fn printBagIds(self: Self) void {
        var it = self.bag_ids.iterator();
        while(it.next()) | kv | {
            std.log.debug("key: '{}', value: '{}'.", .{kv.key, kv.value});
        }
    }

    pub fn answer1(self: Self) u32 {
        var result: u32 = 0;

        return result;
    }

    pub fn answer2(self: Self) u32 {
        var result: u32 = 0;

        return result;
    }

};


pub fn day7() !void {
    std.log.info("Day 7...", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d7 = Day7.init(&gpa.allocator);
    defer d7.deinit();
    
    const filename = "C:/code/aoc20/inputs/day7.txt";
    try d7.loadDataFile(filename);
 
    const answer1 = d7.answer1();
    std.log.info("Day 7A: '{}'.", .{answer1});

    const answer2 = d7.answer2();
    std.log.info("Day 7B: '{}'.", .{answer2});
}

fn foo(str: [] const u8) void {
    std.log.debug("str: {}, hash: {}.", .{str, std.hash_map.hashString(str)});
}

test "day7" {
    std.testing.log_level = std.log.Level.debug;
    // std.testing.log_level = std.log.Level.info;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    // var d7 = Day7.init(&gpa.allocator);
    var d7 = Day7.init(std.testing.allocator);
    defer d7.deinit();
     
    foo("light red");
    foo("dark orange");
    foo("bright white");
    foo("muted yellow");
    foo("shiny gold");
    foo("dark olive");
    foo("vibrant plum");
    

    const testInput = 
        \\light red bags contain 1 bright white bag, 2 muted yellow bags.
        \\dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        \\bright white bags contain 1 shiny gold bag.
        \\muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        \\shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        \\dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        \\vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        \\faded blue bags contain no other bags.
        \\dotted black bags contain no other bags.
        \\
        ;

    var reader = std.io.fixedBufferStream(testInput[0..]).reader();
    try d7.loadData(reader);

    d7.printBagIds();

    // expect(d7.answer1() == 4);

}

