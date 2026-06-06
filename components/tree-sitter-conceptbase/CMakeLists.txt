cmake_minimum_required(VERSION 3.16)
project(tree-sitter-conceptbase VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_WASM "Build tree-sitter WebAssembly grammar module" OFF)
# Semicolon-separated corpus basenames (without .txt). Use "skip" for none.
set(TS_CORPORA "" CACHE STRING "Corpus tests to run (basename list; empty = all; skip = none)")
option(TS_RUN_PARSE_TEST "Build and register C encoding unit test (test_parse)" ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(TREE_SITTER REQUIRED IMPORTED_TARGET tree-sitter)

find_program(TREE_SITTER_CLI tree-sitter REQUIRED)

set(TS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source")
set(TS_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(TS_RUNTIME_HOME "${CMAKE_BINARY_DIR}/ts-home")

file(MAKE_DIRECTORY "${TS_RUNTIME_HOME}")

set(TS_GRAMMAR_SOURCES
  "${TS_SOURCE_DIR}/grammar.js"
  "${TS_SOURCE_DIR}/tree-sitter.json"
)

set(TS_GENERATED_PARSER "${TS_GENERATED_DIR}/parser.c")
set(TS_GENERATED_GRAMMAR_JSON "${TS_GENERATED_DIR}/grammar.json")
set(TS_GENERATED_NODE_TYPES_JSON "${TS_GENERATED_DIR}/node-types.json")

add_custom_command(
  OUTPUT
    "${TS_GENERATED_PARSER}"
    "${TS_GENERATED_GRAMMAR_JSON}"
    "${TS_GENERATED_NODE_TYPES_JSON}"
    "${TS_GENERATED_DIR}/tree_sitter/alloc.h"
    "${TS_GENERATED_DIR}/tree_sitter/array.h"
    "${TS_GENERATED_DIR}/tree_sitter/parser.h"
  COMMAND "${CMAKE_COMMAND}" -E make_directory "${TS_GENERATED_DIR}/tree_sitter"
  COMMAND "${CMAKE_COMMAND}" -E env
    "HOME=${TS_RUNTIME_HOME}"
    "XDG_CACHE_HOME=${TS_RUNTIME_HOME}/.cache"
    "${TREE_SITTER_CLI}" generate
  WORKING_DIRECTORY "${TS_SOURCE_DIR}"
  COMMAND "${CMAKE_COMMAND}" -E copy "${TS_SOURCE_DIR}/src/parser.c" "${TS_GENERATED_PARSER}"
  COMMAND "${CMAKE_COMMAND}" -E copy_directory
    "${TS_SOURCE_DIR}/src/tree_sitter" "${TS_GENERATED_DIR}/tree_sitter"
  COMMAND "${CMAKE_COMMAND}" -E copy_if_different
    "${TS_SOURCE_DIR}/src/grammar.json" "${TS_GENERATED_GRAMMAR_JSON}"
  COMMAND "${CMAKE_COMMAND}" -E copy_if_different
    "${TS_SOURCE_DIR}/src/node-types.json" "${TS_GENERATED_NODE_TYPES_JSON}"
  DEPENDS ${TS_GRAMMAR_SOURCES}
  COMMENT "Generating tree-sitter parser from grammar.js"
  VERBATIM
)

set(TS_PARSER_SOURCES
  "${TS_GENERATED_PARSER}"
  "${TS_SOURCE_DIR}/conceptbase_parser.c"
)

add_library(tree-sitter-conceptbase-objs OBJECT ${TS_PARSER_SOURCES})
target_include_directories(tree-sitter-conceptbase-objs
  PRIVATE
    "${TS_GENERATED_DIR}"
    "${TS_SOURCE_DIR}"
)
target_compile_options(tree-sitter-conceptbase-objs PRIVATE
  -Wall -Wextra -Wno-unused-parameter
)

add_library(tree-sitter-conceptbase SHARED
  $<TARGET_OBJECTS:tree-sitter-conceptbase-objs>
)
set_target_properties(tree-sitter-conceptbase PROPERTIES
  OUTPUT_NAME "tree-sitter-conceptbase"
  VERSION "${PROJECT_VERSION}"
  SOVERSION "${PROJECT_VERSION}"
)
target_link_libraries(tree-sitter-conceptbase PRIVATE PkgConfig::TREE_SITTER)

add_library(tree-sitter-conceptbase-static STATIC
  $<TARGET_OBJECTS:tree-sitter-conceptbase-objs>
)
set_target_properties(tree-sitter-conceptbase-static PROPERTIES
  OUTPUT_NAME "tree-sitter-conceptbase"
)

if(BUILD_WASM)
  set(TS_WASM_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/tree-sitter-conceptbase.wasm")
  add_custom_command(
    OUTPUT "${TS_WASM_OUTPUT}"
    COMMAND "${CMAKE_COMMAND}" -E env
      "HOME=${TS_RUNTIME_HOME}"
      "XDG_CACHE_HOME=${TS_RUNTIME_HOME}/.cache"
      "${TREE_SITTER_CLI}" build --wasm -o "${TS_WASM_OUTPUT}" .
    WORKING_DIRECTORY "${TS_SOURCE_DIR}"
    DEPENDS ${TS_GRAMMAR_SOURCES}
    COMMENT "Building tree-sitter WASM grammar module"
    VERBATIM
  )
  add_custom_target(tree-sitter-conceptbase-wasm DEPENDS "${TS_WASM_OUTPUT}")
endif()

include(GNUInstallDirs)

install(TARGETS tree-sitter-conceptbase tree-sitter-conceptbase-static
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

install(FILES
  "${TS_SOURCE_DIR}/tree-sitter-conceptbase.h"
  "${TS_SOURCE_DIR}/conceptbase_parser.h"
  "${TS_SOURCE_DIR}/conceptbase_parser.hpp"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

install(FILES
  "${TS_GENERATED_PARSER}"
  "${TS_GENERATED_GRAMMAR_JSON}"
  "${TS_GENERATED_NODE_TYPES_JSON}"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/tree-sitter-conceptbase/generated"
)

install(DIRECTORY "${TS_GENERATED_DIR}/tree_sitter"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/tree-sitter-conceptbase/generated"
)

install(DIRECTORY
  "${TS_SOURCE_DIR}/queries"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/tree-sitter-conceptbase"
)

install(FILES
  "${TS_SOURCE_DIR}/grammar.js"
  "${TS_SOURCE_DIR}/tree-sitter.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/tree-sitter-conceptbase"
)

install(DIRECTORY "${TS_SOURCE_DIR}/test/corpus"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/tree-sitter-conceptbase/test"
)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/docs"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/tree-sitter-conceptbase"
)

set(PC_FILE "${CMAKE_CURRENT_BINARY_DIR}/tree-sitter-conceptbase.pc")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/tree-sitter-conceptbase.pc.in"
  "${PC_FILE}"
  @ONLY
)
install(FILES "${PC_FILE}" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

include(CTest)
if(BUILD_TESTING)
  if(TS_RUN_PARSE_TEST)
    add_executable(test_parse tests/test_parse.c)
    target_include_directories(test_parse PRIVATE "${TS_SOURCE_DIR}")
    target_link_libraries(test_parse PRIVATE
      tree-sitter-conceptbase-static
      PkgConfig::TREE_SITTER
    )
    install(TARGETS test_parse RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
    add_test(NAME test_parse COMMAND test_parse)
  endif()

  if(NOT TS_CORPORA STREQUAL "skip")
    if(TS_CORPORA STREQUAL "")
      add_test(
        NAME corpus-all
        COMMAND "${TREE_SITTER_CLI}" test
        WORKING_DIRECTORY "${TS_SOURCE_DIR}"
      )
      set_tests_properties(corpus-all PROPERTIES
        ENVIRONMENT "HOME=${TS_RUNTIME_HOME};XDG_CACHE_HOME=${TS_RUNTIME_HOME}/.cache"
        RUN_SERIAL TRUE
      )
    else()
      string(REPLACE ";" " " _corpus_list "${TS_CORPORA}")
      separate_arguments(_corpus_names UNIX_COMMAND "${_corpus_list}")
      foreach(_corpus IN LISTS _corpus_names)
        add_test(
          NAME "corpus-${_corpus}"
          COMMAND "${TREE_SITTER_CLI}" test --file-name "${_corpus}.txt"
          WORKING_DIRECTORY "${TS_SOURCE_DIR}"
        )
        set_tests_properties("corpus-${_corpus}" PROPERTIES
          ENVIRONMENT "HOME=${TS_RUNTIME_HOME};XDG_CACHE_HOME=${TS_RUNTIME_HOME}/.cache"
          RUN_SERIAL TRUE
        )
      endforeach()
    endif()
  endif()
endif()
