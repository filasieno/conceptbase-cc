cmake_minimum_required(VERSION 4.1)
project(libcbcos VERSION 0.1.0 LANGUAGES C CXX)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/../buildcbutils")
include(LibcbFindDeps)
libcb_find_general()

find_package(PkgConfig REQUIRED)
pkg_check_modules(SWIPL REQUIRED IMPORTED_TARGET swipl)

add_library(cbcos STATIC
  src/bim2c.c src/objstore.c src/swiCos.c
  src/secure_put.cc src/SYMTBL.cc src/SYMID.cc src/TOID.cc src/SYMIDSTLSET.cc
  src/Statistic.cc src/StatisticHashSet.cc src/Statistics.cc src/trans.cc
  src/TOBJ.cc src/TDB.cc src/TDB_testall.cc src/QUERY.cc
  src/TIMELINE.cc src/TIMEPOINT.cc
  src/TOIDREF.cc src/TOIDREFHashSet.cc src/SYMIDREF.cc src/SYMIDREFHashSet.cc
  src/Literals.cc src/builtin.cc src/error.cc src/TOIDSETSTL.cc src/longSETSTL.cc
)
set_target_properties(cbcos PROPERTIES OUTPUT_NAME cbcos)
target_include_directories(cbcos PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)
libcb_link_general(cbcos PRIVATE)
target_compile_definitions(cbcos PRIVATE SWI LINUX _GNU_SOURCE)
target_compile_options(cbcos PRIVATE -Wall -Wextra -Wno-unused-parameter)
target_link_libraries(cbcos PUBLIC PkgConfig::SWIPL)

include(GNUInstallDirs)
install(TARGETS cbcos ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
