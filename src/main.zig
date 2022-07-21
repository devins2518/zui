const std = @import("std");
pub const Window = @import("window.zig").Window;

test "static analysis" {
    std.testing.refAllDecls(@This());
}
