const std = @import("std");
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

pub fn foo() void {
    std.log.info("this tests aoc20 module", .{});
}
