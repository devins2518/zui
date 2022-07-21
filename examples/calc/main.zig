const std = @import("std");
const zui = @import("zui");

pub fn main() anyerror!void {
    var window = zui.Window.init(.{
        .name = "Calculator",
        .height = 600,
        .width = 800,
    });
    _ = window;
    // defer window.deinit();
}

const App = struct {
    const Self = @This();
    input: u64 = 0,
    output: u64 = 0,
    op: enum { add, sub, mul, div },

    fn eval(self: *Self) void {
        switch (self.op) {
            .add => self.output += self.input,
            .sub => self.output -= self.input,
            .mul => self.output *= self.input,
            .div => self.output /= self.input,
        }
    }
};
