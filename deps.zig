const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;


pub const exports = struct {
    pub const zui = Pkg{
        .name = "zui",
        .source = FileSource{ .path = "src/main.zig" },
    };
};
