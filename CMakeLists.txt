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
set(GENERATED_SOURCE_PATH ${BAZEL_BIN}/codegen/generated.cpp)
set(GENERATED_TARGET "//codegen:generated")

execute_process(
    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/bazel_query_sources.sh" "${GENERATED_TARGET}"
    OUTPUT_VARIABLE GENERATED_TARGET_DEPENDS
)

string(REPLACE "\n" ";" GENERATED_TARGET_DEPENDS "${GENERATED_TARGET_DEPENDS}")

add_custom_command(
    OUTPUT  ${GENERATED_SOURCE_PATH}
    COMMAND bazel build ${GENERATED_TARGET}
    DEPENDS ${GENERATED_TARGET_DEPENDS}
    COMMENT "Building ${GENERATED_TARGET} with bazel"
)

include_directories(${BAZEL_BIN})

add_library(
    generated SHARED
    ${GENERATED_SOURCE_PATH}
)

add_executable(main main.cpp)
target_link_libraries(main generated)
