const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Reader = std.io.Reader;
const expect = std.testing.expect;



pub fn count(items: []const u8, x: u8) u32 {
    var result: u32 = 0;
    for (items) |c, i| {
        if (c == x) result += 1;
    }
    return result;
}

pub fn betweenIncl(x: u32, a: u32, b: u32) bool {
    return (a <= x and x <= b);
}

test "betweenIncl" {
    expect(betweenIncl(5, 2, 8));
    expect(betweenIncl(5, 5, 8));
    expect(betweenIncl(5, 2, 5));
    expect(!betweenIncl(1, 2, 5));
    expect(!betweenIncl(6, 2, 5));
}

pub fn passesPasswordPolicyA(pass: []const u8, min: u32, max: u32, letter: u8) bool {
    const cnt = count(pass, letter);
    const result = betweenIncl(cnt, min, max);
    return result;
}

test "passesPasswordPolicyA" {
    expect(passesPasswordPolicyA("abcde", 1, 3, 'a'));
    expect(!passesPasswordPolicyA("cdefg", 1, 3, 'b'));
    expect(passesPasswordPolicyA("ccccccccc", 2, 9, 'c'));
}

pub fn passesPasswordPolicyB(pass: []const u8, min: u32, max: u32, letter: u8) bool {
    var cnt: u8 = 0;
    if (pass[min-1] == letter) cnt += 1;
    if (pass[max-1] == letter) cnt += 1;
    const result = (cnt == 1);
    return result;
}

test "passesPasswordPolicyB" {
    expect(passesPasswordPolicyB("abcde", 1, 3, 'a'));
    expect(!passesPasswordPolicyB("cdefg", 1, 3, 'b'));
    expect(!passesPasswordPolicyB("ccccccccc", 2, 9, 'c'));
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

test "encodeForestRow" {
    expect(encodeForestRow(".") == 0);
    expect(encodeForestRow("#") == 1);
    expect(encodeForestRow("#.") == 2);
    expect(encodeForestRow("##") == 3);
    expect(encodeForestRow("#..") == 4);
    expect(encodeForestRow("#.#.") == 10);
}

pub fn encodeForestTopography(in: [] const u8, out: *std.ArrayList(u32)) !void {
    // buffer for holding input file line bytes
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var buffer = std.ArrayList(u8).init(&gpa.allocator);
    defer buffer.deinit();

    var reader =  std.io.fixedBufferStream(in).reader();
    while (true) {
        const tmp = reader.readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
            break;
        };
        const line = std.mem.trimRight(u8, buffer.items, "\r\n");

        const val = encodeForestRow(line);
        try out.append(val);

        std.log.warn("line2: {}", .{buffer.items});
        std.log.warn("val  : {b:0>11}", .{val});
    }
}

test "encodeForestTopography" {
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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    
    var buffer = std.ArrayList(u32).init(&gpa.allocator);
    defer buffer.deinit();

    try encodeForestTopography(topography[0..], &buffer);

    std.log.warn("items: {}", .{buffer.items});
    std.log.warn("len: {}", .{buffer.items.len});

    var cnt = try sledThroughForest(buffer, 3, 1, 11, 11);
    std.log.warn("topo cnt {}", .{cnt});

    std.log.warn("one: {b:0>11}", .{1});

    // expect(buffer.items.len == 11);
}

fn sledThroughForestArrayPosHelper(x: 32, y: 32, width: u32) u32{
    var newX = std.math.rem(u32, x, width);
    const result = (y * width) + newX;
    return result;
}

/// Assume startX = 0, startY = 0
/// 'x' is velocity 'right', 'y' is velocity 'down' (positive)
/// width is the input topography maxX
/// Return is number of "trees" landed on
pub fn sledThroughForest(topograph: std.ArrayList(u32), x: u32, y:u32, width: u32, height: u32)!u32 {
    var result:u32 = 0; // tree count

    var currX:u32 = 0;
    var currY:u32 = 0;

    while(currY < height) {
        var rx = try std.math.rem(u32, currX, width);

        const bitIdx = width - rx - 1;

        std.log.warn("y,x,rx: {},{},{}. bitIdx: {}", .{currY, currX, rx, bitIdx});

        const line = topograph.items[currY];
        const flag = std.math.rotl(u32, 1, bitIdx);
        const hit = ((line & flag) > 0);
        std.log.warn("line: {b:0>11}, flag, {}, hit: {}", .{line, flag, hit});
        if(hit) {
            result += 1;
        }

        // keep sledding
        currX += x;
        currY += y;
    }
    return result;
}

pub fn foo() void {
    std.log.warn("this tests aoc20 module1", .{});
    std.log.info("this tests aoc20 module2", .{});
    std.log.debug("this tests aoc20 module3", .{});
}

test "expr1" {

    std.debug.print("Athis is a test1\n", .{});
    std.debug.warn("Athis is a test2\n", .{});
    std.log.warn("Athis is a test3", .{});
    std.log.info("Athis is a test4", .{});
    std.log.debug("Athis is a test5", .{});

    std.testing.log_level = std.log.Level.info;
     
    std.debug.print("Bthis is a test1\n", .{});
    std.debug.warn("Bthis is a test2\n", .{});
    std.log.warn("Bthis is a test3", .{});
    std.log.info("Bthis is a test4", .{});
    std.log.debug("Bthis is a test5", .{});
    
}

test "expr2" {
    std.debug.print("Cthis is a test1\n", .{});
    std.debug.warn("Cthis is a test2\n", .{});
    std.log.warn("Cthis is a test3", .{});
    std.log.info("Cthis is a test4", .{});
    std.log.debug("Cthis is a test5", .{});

    std.testing.log_level = std.log.Level.debug;

    std.debug.print("Dthis is a test1\n", .{});
    std.debug.warn("Dthis is a test2\n", .{});
    std.log.warn("Dthis is a test3", .{});
    std.log.info("Dthis is a test4", .{});
    std.log.debug("Dthis is a test5", .{});
}

