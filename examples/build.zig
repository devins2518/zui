const std = @import("std");
const pkgs = @import("deps.zig").pkgs;

pub fn build(b: *std.build.Builder) void {
    addExample(b, "calc");
}

fn addExample(b: *std.build.Builder, comptime name: []const u8) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable(name, name ++ "/main.zig");
    pkgs.addAllTo(exe);
    exe.linkFramework("Cocoa");
    exe.linkFramework("CoreFoundation");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const exe_run = exe.run();
    exe_run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        exe_run.addArgs(args);
    }

    const exe_run_step = b.step("run-" ++ name, "Run the " ++ name ++ " example.");
    exe_run_step.dependOn(&exe_run.step);
}
