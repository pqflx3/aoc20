const std = @import("std");
const ArrayList = std.ArrayList;
const aoc = @import("./aoc20.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    

pub fn day1a() !void {
    std.log.debug("day 1.", .{});

    // buffer for input numbers
    var day1input = ArrayList(u32).init(&gpa.allocator);
    defer day1input.deinit();

    const filename = "C:/code/aoc20/inputs/day1.txt";
    const file = try std.fs.cwd().openFile(
        filename,
        .{ .read = true },
    );
    defer file.close();

    // buffer for holding input file line bytes
    var buffer = ArrayList(u8).init(&gpa.allocator);
    defer buffer.deinit();

    var ok = true;
    while(ok) {
        file.reader().readUntilDelimiterArrayList(&buffer, '\n', 1024) catch {
            break;            
        };
        std.log.debug("read from buffer: {}", .{buffer.items});
    
        const line = std.mem.trimRight(u8, buffer.items, "\r\n");
        std.log.debug("line: {}", .{line});

        const val = try std.fmt.parseInt(u32, line, 10);
        std.log.debug("attempt to parse: {}.", .{val});

        try day1input.append(val);
    }

    // find two ints that sum 2020
    // TODO: make into function(slice, target): (idx1, idx2)
    // Actually, target, num
    var target1: u32 = 0;
    var target2: u32 = 0;
    for(day1input.items) | val1, idx1 | {
        var idx2 = idx1+1;
        while(idx2 < day1input.items.len) {
            const val2 = day1input.items[idx2];
            const sum = val1 + val2;
            if(sum == 2020) {
                std.log.info("found {}:'{}' + {}:'{}' = 2020", .{idx1, val1, idx2, val2});
                target1 = val1;
                target2 = val2;
            }
            idx2 += 1;
        }
    }
    const product = target1 * target2;
    std.log.info("Day1A Solution: {} * {} = {}", .{target1, target2, product});


    // Day1B
    var targetb1: u32 = 0;
    var targetb2: u32 = 0;
    var targetb3: u32 = 0;
    for(day1input.items) | val1, idx1 | {
        var idx2 = idx1+1;
        while(idx2 < day1input.items.len) {
            const val2 = day1input.items[idx2];

            var idx3 = idx2+1;
            while(idx3 < day1input.items.len) {
                const val3 = day1input.items[idx3];

                const sum = val1 + val2 + val3;
                if(sum == 2020) {
                    targetb1 = val1;
                    targetb2 = val2;
                    targetb3 = val3;
                }
                idx3 +=1;
            }
            idx2 += 1;
        }
    }
    const productB = targetb1 * targetb2 * targetb3;
    std.log.info("Day1B Solution: {} * {} * {} = {}", .{targetb1, targetb2, targetb3, productB});



    std.log.debug("day 1 ends.", .{});
}

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});

    aoc.foo();

    try day1a();

}
