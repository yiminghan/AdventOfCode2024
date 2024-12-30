const std = @import("std");

const stdout = std.io.getStdOut();
var parts = std.StringHashMap(void).init(std.heap.page_allocator);

fn readParts() !void {
    const partsInput = "grbuu, bbg, rwrwrru, bw, bubrwg, rubrbg, ggubr, uw, gru, bwgrw, rrrggbwr, ugwurr, wuwbrrr, uwruruu, grgwbrb, ubw, gbu, ru, bbgu, rwrbug, grrbr, rwgw, brb, uwug, bugrub, gwwg, uuggguwb, uwu, rwgu, urg, uuug, wgwb, wgwrbwuu, bgbbb, grgr, gwurgr, ubu, gbur, rrbwruu, rrrr, rgugu, bwugw, ug, brbb, wbbrrbr, wub, wr, wrw, bburrur, rrbwgu, rbwbgw, brr, ggb, wuurguu, brgr, b, wggb, buugrr, bgrgr, wurwb, rgrub, bbw, rug, rwwgub, rwrgb, grgu, wgwrub, grwg, uuwgrw, ubgu, wwg, bwurwrg, wbg, grbu, ubbgbrr, wbw, uwuu, ubg, gbbw, gbbugg, bru, ggwwub, rugg, buub, gbwb, uurbb, urgu, uubg, rgwrrbb, uub, ugww, wgbub, gug, grb, wuruu, rgb, ggbbwrb, rrb, ruuuw, grurw, bwguw, gwgbwrwb, grwu, rwuwu, bwg, ubwgbb, bbrbb, wrgrbbw, rbbwub, gr, wbr, bbb, rrur, gu, wwrwgww, gwgbr, bwb, buugur, wru, wgww, ubgwwru, gwbuw, brrg, wuw, ugrw, wwgwwu, rgbubr, brrrrw, uurwb, rbubb, wwwb, bwr, urbbbr, guww, buw, bww, grugur, ggbr, urbg, ruwuwb, br, gwgrurr, wwb, wrrwur, wrb, wrug, wwbrg, rugurgww, gwggwg, wrgbb, wgg, brw, wuu, gub, uug, ruwgurrb, wrruu, bwgwurw, ubbrrg, ugu, ubr, ggbu, bgwgwr, urwwgw, bbbrw, gbru, bgu, ugbgrurr, bgg, rwrbwug, rwgbu, wwgb, wurgru, ugwggg, rbgggb, urwu, gwwbuubw, bgw, bugg, rbu, rrr, rwrbgggu, gw, gb, bwbbu, gbwrb, wwww, wrbgg, gguwur, gwrw, wuwrb, gwu, wgbgwu, guu, rwrur, ww, rwwruug, ggwugg, wbu, wbwwbrw, rwu, wuuug, ur, wurubbw, rbbgg, rrbw, bgbgwr, wgb, wwbu, wgrw, wwrgggu, rwb, wwbg, bgbg, guub, ggr, uuu, rguugw, buwg, ugr, rrgg, bbuugbrr, wgwggwwu, guwu, guw, gg, wubg, uggr, ubbb, wgu, wburrwb, ugbrr, bbwrb, ggw, bgr, bug, buu, gbrrg, rr, rw, w, wbguuu, guggb, r, grrrg, rrbub, grgubuu, rrw, ubb, gbb, uubw, rruuw, bbu, bur, rgwu, gbgr, gubu, rrurwrbw, grw, gwwbubw, ugrbu, gbr, wggr, rgw, rrggb, wwbbg, brbuwwbg, bbguwug, bwu, gww, wur, bwbuu, bgrgg, burr, brrr, rrwu, uuuw, brg, uwggbr, gggw, rwwgggg, ugb, rwru, gbw, bgub, rgwgbr, rbuu, gbgu, bugbr, uu, wgw, wgbug, bguww, wrwgb, wggbbb, brwrb, ubgww, bbbrr, uru, rbw, gbbu, rgr, wbrruw, rbg, wbb, brwr, bgb, uwr, urw, bbgru, rwgrbb, bbr, grr, rbgbrbbw, wwwu, bub, gwwbrgur, ubww, wug, ugwb, uur, gubbwruu, rrbrugw, gwr, rgrg, ugw, grgggur, rwr, brruw, rur, rgu, gwwwww, wuwr, uwb, ruu, wrg, rrggu, wggw, ggbwwrb, rbrg, rwrb, bgugwb, wwr, rbrbwr, bwwr, gwb, bb, uwgu, wrrw, wugg, gur, wrr, uubgrurr, ggu, wrrbu, wruubu, wgr, gruw, rub, wubgbr, bbwb, gbuwrbbw, gbrrrwgg, gburubu, rwg, wurb, rrbuu, gwurb, urr, rb, uuw, wgguu, rugbb, grrb, ruw, rrrrwg, g, ggg, wwguu, rbr, rwrr, bugw, rrbburr, gurb, rrbbw, wrruw, bg, grrrww, bggubu, gbg, rwwu, uwg, uuurg, urrbwg, wb, rubwguu, rrg, ubrbbbb, wbwbuu, ub, ubbgbrw, ggbgg, rgg, rbrrg, gbbgg, wrrb, ugrubr, gbuw, wuugr, ugrgr, buurr, urbrbub, uggu, gwwu, rru, ugg, buuwuw, grg, gbgg, uwwwugu, guwbwwr, rbbu, rrrurw, wrgbuw, ubgwgb, gbruurw, bu, wubbw, www, bwggr, wrrr, brbbur, rg, gbguw, gwg, bguubbrg, uwbug, ubbwg, rwbguw, gwwbg, rubu, urbw, wgrbbg, gwburwr, gubgu, wrbug, brrb";

    var split = std.mem.split(u8, partsInput, ",");
    while (split.next()) |x| {
        try parts.put(try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{std.mem.trim(u8, x, " ")}), {});
    }
}

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var cache = std.StringHashMap(bool).init(allocator);

fn tryPart(in: []const u8, depth: usize) bool {
    if (cache.get(in) != null) return cache.get(in) orelse false;
    if (in.len == 0) {
        cache.put(in, true) catch {};
        return true;
    }

    if (depth > 60) {
        cache.put(in, true) catch {};
        return false;
    }

    var partsIterator = parts.iterator();
    while (partsIterator.next()) |x| {
        if (std.mem.startsWith(u8, in, x.key_ptr.*)) {
            const slice = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{in[x.key_ptr.*.len..]}) catch "";
            if (tryPart(slice, depth + 1)) {
                cache.put(in, true) catch {};
                return true;
            }
        }
    }

    cache.put(in, false) catch {};
    return false;
}

fn readcombos() !void {
    // try cache.ensureTotalCapacity(1_000_000);
    var file = try std.fs.cwd().openFile("./src/combos.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024000]u8 = undefined;

    var counter: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const slice = std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{line}) catch "";
        if (tryPart(slice, 0)) counter += 1;
    }

    try stdout.writer().print("counter {}", .{counter});
}

pub fn main() !void {
    try readParts();
    try readcombos();
}
