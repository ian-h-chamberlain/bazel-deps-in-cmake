#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

bazel_target=$1

function find_workspace_root() {
    local workspace_dir
    workspace_dir=$(git rev-parse --show-toplevel)

    if ! [[ -f "$workspace_dir/WORKSPACE" ]]; then
        echo "Must be run from a git repo/bazel workspace" >&2
        exit 1
    fi

    echo "$workspace_dir"
}

workspace_dir=$(find_workspace_root)

function label_to_relpath() {
    # Convert bazel labels to paths
    sed -e "s|//:|${workspace_dir}/|" \
        -e "s|//|${workspace_dir}/|" \
        -e 's|:|/|' | uniq
}

# Unconditionally depend on WORKSPACE as a catch-all for third-party deps changing
echo "$workspace_dir/WORKSPACE"

# Quick + dirty check for load() in WORKSPACE
grep -o 'load("//.*",' "$workspace_dir/WORKSPACE" |
    sed -e 's/load("//' -e 's/",.*//' |
    label_to_relpath

# Print source file paths (relative)
bazel query --output=location "kind('source file', deps(${bazel_target}))" |
     # Filter out external workspaces
    grep -v 'source file @' |
    awk '{ print $NF }' |
    label_to_relpath

# Print BUILD.bazel and *.bzl file paths (absolute)
bazel query "buildfiles(${bazel_target})" |
     # Filter out external workspaces
    grep -v '^@' |
    label_to_relpath
