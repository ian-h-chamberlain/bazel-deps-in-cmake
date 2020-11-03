#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

target=$1

query="kind('source file', deps(${target}))"
query_output=$(
    bazel query "$query" --output location |
    grep -v 'source file @' # Filter out external workspaces
)

# Print BUILD.bazel file paths (absolute)
echo "$query_output" |
    awk '{ print $1 }' |
    sed -e 's/:.*$//' # Delete the row/column from the end of the BUILD file

# Print source file paths (relative)
echo "$query_output" |
    awk '{ print $NF }' |
    sed -e 's|//:|./|' -e 's|//|./|' -e 's|:|/|' # Convert bazel labels to paths
