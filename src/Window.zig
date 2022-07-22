const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");
const trait = std.meta.trait;
const MacOsWindowFlags = @import("macos/Window.zig").MacOsWindowFlags;
const WindowsWindowFlags = @import("windows/Window.zig").WindowsWindowFlags;
const X11WindowFlags = @import("x11/Window.zig").X11WindowFlags;
const WaylandWindowFlags = @import("wayland/Window.zig").WaylandWindowFlags;

pub const WindowFlags = struct {
    name: []const u8,
    height: u16 = 600,
    width: u16 = 800,
    x: u16 = 0,
    y: u16 = 0,
    macos_flags: ?MacOsWindowFlags = null,
    windows_flags: ?WindowsWindowFlags = null,
    x11_flags: ?X11WindowFlags = null,
    wayland_flags: ?WaylandWindowFlags = null,
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
