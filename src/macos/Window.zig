const std = @import("std");
const c = @import("../c.zig");
const zobjc = @import("zobjc");
const WindowFlags = @import("../Window.zig").WindowFlags;
const Window = @This();

ns_app: zobjc.Object,
// Strong reference to AppDelegateClass
app_del_class: zobjc.Class,

pub const MacOsWindowFlags = struct {};

const WindowStyle = enum(zobjc.c.NSUInteger) {
    NSWindowStyleMaskBorderless = 0,
    NSWindowStyleMaskTitled = 1 << 0,
    NSWindowStyleMaskClosable = 1 << 1,
    NSWindowStyleMaskMiniaturizable = 1 << 2,
    NSWindowStyleMaskResizable = 1 << 3,
    NSWindowStyleMaskUtilityWindow = 1 << 4,
    NSWindowStyleMaskDocModalWindow = 1 << 6,
    NSWindowStyleMaskNonactivatingPanel = 1 << 7,
    NSWindowStyleMaskUnifiedTitleAndToolbar = 1 << 12,
    NSWindowStyleMaskHUDWindow = 1 << 13,
    NSWindowStyleMaskFullScreen = 1 << 14,
    NSWindowStyleMaskFullSizeContentView = 1 << 15,
};

const StoreType = enum(zobjc.c.NSUInteger) {
    NSBackingStoreBuffered = 2,
};

pub fn init(flags: WindowFlags) Window {
    const view_class = zobjc.Class.allocateClassPair(zobjc.Class.getClass("NSView"), "View", 0);
    std.debug.assert(view_class.addMethod(
        zobjc.Sel.getUid("drawRect:"),
        zobjc.Imp{ ._inner = @ptrCast(zobjc.c.IMP, drawRect) },
        "v@:",
    ) == zobjc.YES);
    view_class.registerClassPair();

    _ = flags;
    // Create AppDelegate class
    const app_del_class = zobjc.Class.allocateClassPair(zobjc.Class.getClass("NSObject"), "AppDelegate", 0);
    std.debug.assert(app_del_class.addMethod(
        zobjc.Sel.getUid("applicationDidFinishLaunching:"),
        zobjc.Imp{ ._inner = @ptrCast(zobjc.c.IMP, applicationDidFinishLaunching) },
        "i@:@",
    ) == zobjc.YES);
    app_del_class.registerClassPair();

    // Create our app to run
    const ns_app = zobjc.msgSend(zobjc.Object, zobjc.Class.getClass("NSApplication"), zobjc.Sel.getUid("sharedApplication"), .{});
    std.debug.assert(ns_app._inner != null);

    // Create object to interact with app
    const app_del_obj = zobjc.msgSend(zobjc.Object, zobjc.Class.getClass("AppDelegate"), zobjc.Sel.getUid("alloc"), .{});
    zobjc.msgSend(void, app_del_obj, zobjc.Sel.getUid("init"), .{});
    zobjc.msgSend(void, ns_app, zobjc.Sel.getUid("setDelegate:"), .{app_del_obj._inner});
    zobjc.msgSend(void, ns_app, zobjc.Sel.getUid("run"), .{});

    return Window{ .app_del_class = app_del_class, .ns_app = ns_app };
}
pub fn deinit(_: *Window) void {}

fn applicationDidFinishLaunching(self: zobjc.c.id, _: zobjc.c.SEL, _: zobjc.c.id) callconv(.C) zobjc.BOOL {
    const window = zobjc.Class.getClass("NSWindow");
    const alloc = zobjc.Sel.getUid("alloc");
    const window_ivar = zobjc.c.class_getClassVariable(zobjc.c.object_getClass(self), "window");
    // self.window = NSWindow.new(CGRect{0, 0, 600, 800}, Titled | Closable | Resizeable | Miniaturizable, Buffered, false)
    zobjc.c.object_setIvar(
        self,
        window_ivar,
        zobjc.msgSend(zobjc.c.id, zobjc.msgSend(zobjc.c.id, window, alloc, .{}), zobjc.Sel.getUid("initWithContentRect:styleMask:backing:defer:"), .{
            c.CGRect{
                .origin = c.CGPoint{
                    .x = @intToFloat(c.CGFloat, 0),
                    .y = @intToFloat(c.CGFloat, 0),
                },
                .size = c.CGSize{
                    .width = @intToFloat(c.CGFloat, 600),
                    .height = @intToFloat(c.CGFloat, 800),
                },
            },
            @enumToInt(WindowStyle.NSWindowStyleMaskTitled) |
                @enumToInt(WindowStyle.NSWindowStyleMaskClosable) |
                @enumToInt(WindowStyle.NSWindowStyleMaskResizable) |
                @enumToInt(WindowStyle.NSWindowStyleMaskMiniaturizable),
            StoreType.NSBackingStoreBuffered,
            false,
        }),
    );
    const window_id = zobjc.c.object_getIvar(self, window_ivar);

    const view = zobjc.msgSend(
        zobjc.c.id,
        zobjc.msgSend(zobjc.c.id, zobjc.Class.getClass("View"), alloc, .{}),
        zobjc.Sel.getUid("initWithFrame:"),
        .{c.CGRect{
            .origin = c.CGPoint{
                .x = @intToFloat(c.CGFloat, 0),
                .y = @intToFloat(c.CGFloat, 0),
            },
            .size = c.CGSize{
                .width = @intToFloat(c.CGFloat, 300),
                .height = @intToFloat(c.CGFloat, 400),
            },
        }},
    );

    zobjc.msgSend(void, window_id, zobjc.Sel.getUid("setContentView:"), .{view});
    zobjc.msgSend(void, window_id, zobjc.Sel.getUid("becomeFirstResponder"), .{});

    zobjc.msgSend(void, window_id, zobjc.Sel.getUid("makeKeyAndOrderFront:"), .{self});
    zobjc.msgSend(void, window_id, zobjc.Sel.getUid("display"), .{});

    return zobjc.YES;
}

fn drawRect(_: zobjc.c.id, _: zobjc.c.SEL, _: c.CGRect) void {
    const red = zobjc.msgSend(zobjc.Object, zobjc.Class.getClass("NSColor"), zobjc.Sel.getUid("redColor"), .{});

    const rect = c.CGRect{
        .origin = c.CGPoint{
            .x = @intToFloat(c.CGFloat, 21),
            .y = @intToFloat(c.CGFloat, 21),
        },
        .size = c.CGSize{
            .width = @intToFloat(c.CGFloat, 210),
            .height = @intToFloat(c.CGFloat, 210),
        },
    };

    zobjc.msgSend(void, red, zobjc.Sel.getUid("set"), .{});
    zobjc.msgSend(void, zobjc.Class.getClass("NSBezierPath"), zobjc.Sel.getUid("NSFrameRect"), .{rect});
}

test "static analysis" {
    std.testing.refAllDecls(@This());
}
