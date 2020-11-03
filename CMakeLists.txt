# Required cmake version
cmake_minimum_required(VERSION 3.1)

cmake_policy(SET CMP0053 NEW)

project(cmake_bazel_poc CXX)

set(CMAKE_CXX_STANDARD 17)

STRING(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" insource)
GET_FILENAME_COMPONENT(PARENTDIR ${CMAKE_SOURCE_DIR} PATH)
STRING(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${PARENTDIR}" insourcesubdir)

IF(insource OR insourcesubdir)
    MESSAGE(FATAL_ERROR "${CMAKE_PROJECT_NAME} requires an out of source build.")
ENDIF(insource OR insourcesubdir)


set(BAZEL_BIN ${CMAKE_SOURCE_DIR}/bazel-bin)
set(GENERATED_SOURCE_PATH ${BAZEL_BIN}/generated.cpp)

add_custom_command(
    OUTPUT  dummy_output
            ${GENERATED_SOURCE_PATH}
    COMMAND bazel build //:all
    COMMENT "Building //:all with bazel"
)

set_source_files_properties(dummy_output SYMBOLIC TRUE)

include_directories(${BAZEL_BIN})

add_library(
    generated
    ${GENERATED_SOURCE_PATH}
)

add_executable(main main.cpp)
target_link_libraries(main generated)
