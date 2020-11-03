#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

target=$1

function label_to_relpath() {
    # Convert bazel labels to paths
    sed -e 's|//:|./|' -e 's|//|./|' -e 's|:|/|' | uniq
}

# Unconditionally depend on WORKSPACE as a catch-all for third-party deps changing
echo "./WORKSPACE"

# Quick + dirty check for load() in WORKSPACE
grep -o 'load("//.*",' ./WORKSPACE |
    sed -e 's/load("//' -e 's/",.*//' |
    label_to_relpath

# Print source file paths (relative)
bazel query --output=location "kind('source file', deps(${target}))" |
     # Filter out external workspaces
    grep -v 'source file @' |
    awk '{ print $NF }' |
    label_to_relpath

# Print BUILD.bazel and *.bzl file paths (absolute)
bazel query "buildfiles(${target})" |
     # Filter out external workspaces
    grep -v '^@' |
    label_to_relpath
