# bazel-deps-in-cmake

A proof of concept to show translating Bazel dependencies to CMake. This makes
CMake aware of BUILD.bazel files and the source dependencies at configuration
time, so that Bazel targets will be rebuilt if and only if one of the dependent
files changes.

This isn't 100% perfect, but it encompasses the main dependency types that are
likely to change:

* Actual source inputs (e.g. data models and tools used to generate code)
* `.bzl` files that define rules describing how code is generated
* `BUILD.bazel` files that define the code being generated (may use rules from `.bzl` files)
* The `WORKSPACE` file, which could pull in a changed 3rd party dependency that affects the generated code.
* `.bzl` files loaded by `WORKSPACE`, since these could have macro definitions that change 3rd party dependencies.

## Example

The output of `bazel_query_sources.sh` for this repo is:

```sh
$ ../bazel_query_sources.sh //... 2>/dev/null
/Users/ichamberlain/Documents/cmake_bazel_poc/WORKSPACE
/Users/ichamberlain/Documents/cmake_bazel_poc/thirdparty/skylib.bzl
/Users/ichamberlain/Documents/cmake_bazel_poc/codegen/generated_word.txt
/Users/ichamberlain/Documents/cmake_bazel_poc/codegen/rules.bzl
/Users/ichamberlain/Documents/cmake_bazel_poc/codegen/BUILD.bazel
```

By feeding this output back to `DEPENDS` during CMake configuration time, any of
these files changing will result in the `main` target being rebuilt.
