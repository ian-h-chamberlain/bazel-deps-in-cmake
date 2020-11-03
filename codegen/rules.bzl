"""Dummy macro to make sure .bzl files are considered"""

load("@bazel_skylib//lib:versions.bzl", "versions")

def gen_source(name, **kwargs):
    if not versions.is_at_least(
        "2.0.0",
        "3.0.0",
    ):
        fail("Not met minimum bazel version")

    native.genrule(name = name, **kwargs)
