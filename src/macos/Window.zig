const std = @import("std");
const zobjc = @import("zobjc");
const WindowFlags = @import("../Window.zig").WindowFlags;
const Window = @This();

pub const MacOsWindowFlags = struct {};

pub fn init(flags: WindowFlags) Window {
    _ = flags;

    const app = zobjc.msgSend(
        zobjc.Object,
        zobjc.Class.getClass("NSApplication"),
        zobjc.Sel.getUid("sharedApplication"),
        .{},
    );
    _ = app;

    @panic("Todo");
}
pub fn deinit(_: *Window) void {}

test "static analysis" {
    std.testing.refAllDecls(@This());
}
