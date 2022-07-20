const std = @import("std");
const pkgs = @import("deps.zig").pkgs;

var target: std.zig.CrossTarget = undefined;

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("zui", "src/main.zig");
    addFrameworks(lib);
    pkgs.addAllTo(lib);
    lib.setBuildMode(mode);
    lib.setTarget(target);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    addFrameworks(lib);
    pkgs.addAllTo(main_tests);
    main_tests.setBuildMode(mode);
    main_tests.setTarget(target);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

fn addFrameworks(step: *std.build.LibExeObjStep) void {
    if (target.isDarwin()) {
        step.linkFramework("Cocoa");
    }
}
