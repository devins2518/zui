const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");
const trait = std.meta.trait;
pub const WindowFlags = struct {
    name: []const u8,
    height: u16,
    width: u16,
    x: ?u16,
    y: ?u16,
};

const MacOsWindow = @import("macos/Window.zig");
const WindowsWindow = @import("windows/Window.zig");
const X11Window = @import("x11/Window.zig");
const WaylandWindow = @import("wayland/Window.zig");
pub const Window = if (builtin.os.tag == .macos)
    MacOsWindow
else if (builtin.os.tag == .linux)
blk: {
    if (@hasDecl(root, "zui_linux_backend")) @compileError("root must have a constant named zui_linux_backend which is either .x11 or .wayland.");
    break :blk if (root.zui_linux_backend == .x11)
        X11Window
    else if (root.zui_linux_backend == .wayland)
        WaylandWindow
    else
        @compileError("Unsuppported zui_linux_backend");
} else if (builtin.target.os.tag == .windows)
    WindowsWindow
else
    @compileError("Unsupported platform, please file an issue at https://github.com/devins2518/zui/issues");

const WindowTrait = trait.multiTrait(.{
    trait.hasFn("init"),
    trait.hasFn("deinit"),
});

test "test window impl" {
    try std.testing.expect(WindowTrait(MacOsWindow));
    try std.testing.expect(WindowTrait(WindowsWindow));
    try std.testing.expect(WindowTrait(X11Window));
    try std.testing.expect(WindowTrait(WaylandWindow));
}
