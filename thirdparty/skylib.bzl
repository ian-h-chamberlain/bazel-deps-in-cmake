"""Load the upstream skylib repo as an external workspace"""

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

def skylib():
    bazel_skylib_workspace()
