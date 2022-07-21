const std = @import("std");
pub const WaylandWindowFlags = struct {};

pub fn init() void {}
pub fn deinit() void {}

test "static analysis" {
    std.testing.refAllDecls(@This());
}
