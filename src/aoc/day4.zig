const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;

const aoc20 = @import("../aoc20.zig");


const Passport = struct {
    const Self = @This();

    byr: [32]u8,
    iyr: [32]u8,
    eyr: [32]u8,
    hgt: [32]u8,
    hcl: [32]u8,
    ecl: [32]u8,
    pid: [32]u8,
    cid: [32]u8,

    pub fn init() Self {
        return Self {
            .byr = std.mem.zeroes([32]u8),
            .iyr = std.mem.zeroes([32]u8),
            .eyr = std.mem.zeroes([32]u8),
            .hgt = std.mem.zeroes([32]u8),
            .hcl = std.mem.zeroes([32]u8),
            .ecl = std.mem.zeroes([32]u8),
            .pid = std.mem.zeroes([32]u8),
            .cid = std.mem.zeroes([32]u8),
        };
    }

    pub fn reset(self: *Self) void {
        self.byr = std.mem.zeroes([32]u8);
        self.iyr = std.mem.zeroes([32]u8);
        self.eyr = std.mem.zeroes([32]u8);
        self.hgt = std.mem.zeroes([32]u8);
        self.hcl = std.mem.zeroes([32]u8);
        self.ecl = std.mem.zeroes([32]u8);
        self.pid = std.mem.zeroes([32]u8);
        self.cid = std.mem.zeroes([32]u8);
    }

    pub fn set(self: *Self, key: [3]u8, value: [] const u8) void {
        std.log.debug("set {} = {}.", .{key, value});
        if(std.mem.eql(u8, key[0..], "byr")) {
            std.mem.copy(u8, self.byr[0..], value);
        } else if (std.mem.eql(u8, key[0..], "iyr")) {
            std.mem.copy(u8, self.iyr[0..], value);
        } else if (std.mem.eql(u8, key[0..], "eyr")) {
            std.mem.copy(u8, self.eyr[0..], value);
        } else if (std.mem.eql(u8, key[0..], "hgt")) {
            std.mem.copy(u8, self.hgt[0..], value);
        } else if (std.mem.eql(u8, key[0..], "hcl")) {
            std.mem.copy(u8, self.hcl[0..], value);
        } else if (std.mem.eql(u8, key[0..], "ecl")) {
            std.mem.copy(u8, self.ecl[0..], value);
        } else if (std.mem.eql(u8, key[0..], "pid")) {
            std.mem.copy(u8, self.pid[0..], value);
        } else if (std.mem.eql(u8, key[0..], "cid")) {
            std.mem.copy(u8, self.cid[0..], value);
        } else {
            @panic("unkown key type");
        }
    }

    pub fn parseStuff(self: *Self, line: [] const u8) !void {
        var start: usize = 0;
        var spaceIdx = std.mem.indexOfPos(u8, line, 0, " ");
        while(spaceIdx != null) {
            std.log.debug("parse {}-{}", .{start, spaceIdx});
            const keyval = line[start..spaceIdx.?];
            const key = keyval[0..3];
            const val = keyval[4..];
            self.set(key.*, val);

            start = spaceIdx.?+1;
            spaceIdx = std.mem.indexOfPos(u8, line, start, " ");
        }

        std.log.debug("parse {}-{}", .{start, spaceIdx});
        const keyval = line[start..];
        const key = keyval[0..3];
        const val = keyval[4..];
        self.set(key.*, val);
    }

    pub fn valid(self: Self) bool {
        const result = (
                !std.mem.allEqual(u8, self.byr[0..], 0)
            and !std.mem.allEqual(u8, self.iyr[0..], 0)
            and !std.mem.allEqual(u8, self.eyr[0..], 0)
            and !std.mem.allEqual(u8, self.hgt[0..], 0)
            and !std.mem.allEqual(u8, self.hcl[0..], 0)
            and !std.mem.allEqual(u8, self.ecl[0..], 0)
            and !std.mem.allEqual(u8, self.pid[0..], 0)
            // and !std.mem.allEqual(u8, self.cid[0..], 0)
        );
        return result;
    }

    pub fn valid2(self: Self) !bool {
        var ok: bool = true;
        ok =  ok and (self.validByr() catch false);
        std.log.debug("1valid2 ok: {}", .{ok});
        ok =  ok and (self.validIyr() catch false);
        std.log.debug("2valid2 ok: {}", .{ok});
        ok =  ok and (self.validEyr() catch false);
        std.log.debug("3valid2 ok: {}", .{ok});
        ok =  ok and (self.validHgt() catch false);
        std.log.debug("4valid2 ok: {}", .{ok});
        ok =  ok and (self.validHcl() catch false);
        std.log.debug("5valid2 ok: {}", .{ok});
        ok =  ok and (self.validEcl() catch false);
        std.log.debug("6valid2 ok: {}", .{ok});
        ok =  ok and (self.validPid() catch false);
        std.log.debug("7valid2 ok: {}", .{ok});
        ok =  ok and (self.validCid() catch false);
        std.log.debug("8valid2 ok: {}", .{ok});
        return ok;
    }

    pub fn validByr(self: Self) !bool {
        std.log.debug("byr: {}.", .{self.byr});
        std.log.debug("byr2: {}.", .{self.byr[4]});
        if(self.byr[4] != 0) return false;
        const byr = try std.fmt.parseInt(u32, self.byr[0..4], 10);
        std.log.debug("byr3: {}.", .{byr});
        return (aoc20.betweenIncl(byr, 1920, 2002));
    }

    pub fn validIyr(self: Self) !bool {
        if(self.iyr[4] != 0) return false;
        const iyr = try std.fmt.parseInt(u32, self.iyr[0..4], 10);
        return (aoc20.betweenIncl(iyr, 2010, 2020));
    }
    pub fn validEyr(self: Self) !bool {
        std.log.debug("eyr: {}.", .{self.eyr});
        if(self.eyr[4] != 0) return false;
        const eyr = try std.fmt.parseInt(u32, self.eyr[0..4], 10);
        return (aoc20.betweenIncl(eyr, 2020, 2030));
    }
    pub fn validHgt(self: Self) !bool {
        std.log.debug("hgt: {}.", .{self.hgt});
        if(std.mem.eql(u8, self.hgt[3..5], "cm")) {
            const hgt = try std.fmt.parseInt(u32, self.hgt[0..3], 10);
            return (aoc20.betweenIncl(hgt, 150, 193));
        } else if (std.mem.eql(u8, self.hgt[2..4], "in")) {
            const hgt = try std.fmt.parseInt(u32, self.hgt[0..2], 10);
            std.log.debug("hgt in: {}.", .{hgt});
            return (aoc20.betweenIncl(hgt, 59, 76));
        } else {
            return false;
        }
    }
    pub fn validHex(c : u8) bool {
        if(c >= '0' and c <= '9') {
            return true;
        } else if (c >= 'a' and c <= 'f') {
            return true;
        } else {
            return false;
        }
    }
    pub fn validHcl(self: Self) !bool {
        if(!std.mem.eql(u8, self.hcl[0..1], "#")) return false;
        var idx: u8 = 1;
        while(idx < 7) {
            if(!validHex(self.hcl[idx])) {
                return false;
            }
            idx += 1;
        }
        return true;
    }
    pub fn validEcl(self: Self) !bool {
        if(self.ecl[3] != 0) return false;
        const ecl = self.ecl[0..3];
        if(std.mem.eql(u8, ecl, "amb")
            or std.mem.eql(u8, ecl, "blu")
            or std.mem.eql(u8, ecl, "brn")
            or std.mem.eql(u8, ecl, "gry")
            or std.mem.eql(u8, ecl, "grn")
            or std.mem.eql(u8, ecl, "hzl")
            or std.mem.eql(u8, ecl, "oth")
            ) {
                return true;
            }
        return false;
    }
    pub fn isDigit(c: u8) bool {
        if(c >= '0' and c <= '9') {
            return true;
        }
        return false;
    }
    pub fn validPid(self: Self) !bool {
        if(self.pid[9] != 0) return false;        
        var idx: u8 = 0;
        while(idx < 9) {
            if(!isDigit(self.pid[idx])) {
                return false;
            }
            idx += 1;
        }
        return true;
    }
    pub fn validCid(self: Self) !bool {
        return true;
    }

};

test "Passport" {
    std.testing.log_level = std.log.Level.debug;

    var p1 = Passport.init();
    try p1.parseStuff("eyr:1972 cid:100");
    try p1.parseStuff("hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926");

    expect(!try p1.valid2());

    var p2 = Passport.init();
    try p2.parseStuff("pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980");
    try p2.parseStuff("hcl:#623a2f");

    expect(try p2.valid2());

}

const Day4 = struct {
    const Self = @This();

    allocator: *Allocator,
    data: std.ArrayList(Passport), // tree topography

    
    pub fn init(allocator: *Allocator) Self{
        return Self {
            .allocator = allocator,
            .data = std.ArrayList(Passport).init(allocator),
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

        var currPassport = Passport.init();

        while (true) {
            reader.readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
                break;
            };
            const line = std.mem.trimRight(u8, buffer.items, "\r\n");

            if(line.len == 0) {
                std.log.debug("wrap", .{});
                try self.data.append(currPassport);
                currPassport.reset();
            } else {
                std.log.debug("line: {}", .{line});
                try currPassport.parseStuff(line);
            }
        }
    }

    pub fn validCount(self: Self) u32 {
        var result: u32 = 0;
        for(self.data.items) | passport| {
            if(passport.valid()) {
                result += 1;
            }
        }
        return result;
    }

    pub fn validCount2(self: Self) !u32 {
        var result: u32 = 0;
        for(self.data.items) | passport| {
            if(try passport.valid2()) {
                result += 1;
            }
        }
        return result;
    }

};


pub fn day4() !void {
    std.log.info("Day 4...", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d4 = Day4.init(&gpa.allocator);
    defer d4.deinit();
    
    const filename = "C:/code/aoc20/inputs/day4.txt";
    try d4.loadDataFile(filename);
 
    const validCount = d4.validCount();
    std.log.info("Day 4A: '{}'.", .{validCount});

    const validCount2 = try d4.validCount2();
    std.log.info("Day 4B: '{}'.", .{validCount2});
}

test "day4" {
    std.testing.log_level = std.log.Level.debug;
    // std.testing.log_level = std.log.Level.info;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var d4 = Day4.init(&gpa.allocator);
    defer d4.deinit();
    
   const passwords = 
        \\ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
        \\byr:1937 iyr:2017 cid:147 hgt:183cm
        \\
        \\iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
        \\hcl:#cfa07d byr:1929
        \\
        \\hcl:#ae17e1 iyr:2013
        \\eyr:2024
        \\ecl:brn pid:760753108 byr:1931
        \\hgt:179cm
        \\
        \\hcl:#cfa07d eyr:2025 pid:166559648
        \\iyr:2011 ecl:brn hgt:59in
        \\
        \\
        ;
    
    var reader = std.io.fixedBufferStream(passwords[0..]).reader();
    try d4.loadData(reader);

    std.log.debug("pass len: {}", .{d4.data.items.len});

    const valid = d4.validCount();
    std.log.debug("valid cnt: {}", .{valid});
    // expect( == 2);

}

