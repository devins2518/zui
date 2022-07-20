const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;

pub const pkgs = struct {
    pub const zui = Pkg{
        .name = "zui",
        .source = FileSource{
            .path = "../../src/main.zig",
        },
        .dependencies = &[_]Pkg{
            Pkg{
                .name = "zobjc",
                .source = FileSource{
                    .path = "../../../zobjc/src/lib.zig",
                },
            },
        },
    };

    pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
        artifact.addPackage(pkgs.zui);
    }
};
