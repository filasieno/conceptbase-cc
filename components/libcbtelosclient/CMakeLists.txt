cmake_minimum_required(VERSION 4.1)
project(libcbtelosclient VERSION 0.1.0 LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/../buildcbutils")
include(LibcbSetup)
include(CbFlexBisonInclude)
cb_generate_parser(te_parser te_parser_ te_parser_ te_parser.y te_parser.l)

add_library(cbtelosclient STATIC
  ${te_parser_TAB_C}
  ${te_parser_YY_C}
  src/te_access.c
  src/te_callparser.c
  src/te_cursor.c
  src/te_smlutil.c
  src/telosdll.c
)
set_target_properties(cbtelosclient PROPERTIES OUTPUT_NAME cbtelosclient)
target_include_directories(cbtelosclient PRIVATE
  ${te_parser_GEN_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)
target_compile_definitions(cbtelosclient PRIVATE LINUX _GNU_SOURCE)
target_compile_options(cbtelosclient PRIVATE -Wall -Wextra -Wno-unused-parameter)

include(GNUInstallDirs)
install(TARGETS cbtelosclient ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

include(CTest)
include(CbEnableTests)
cb_add_c_test(te_test_access
  LIB cbtelosclient
  SOURCES tests/te_test_access.c
  ARGS batch
  INCLUDES
    ${te_parser_GEN_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
