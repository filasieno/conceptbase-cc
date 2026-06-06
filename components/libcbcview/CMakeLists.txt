cmake_minimum_required(VERSION 4.1)
project(libcbcview VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/../buildcbutils")
include(LibcbFindDeps)
libcb_find_cbc()

add_library(cbcview STATIC
  src/CBanswer.cc src/CBclient.cc src/CBerror.cc src/CBviewDll.cc
)
set_target_properties(cbcview PROPERTIES OUTPUT_NAME cbcview)
target_include_directories(cbcview PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)
libcb_link_cbc(cbcview PRIVATE)
target_compile_definitions(cbcview PRIVATE LINUX _GNU_SOURCE)
target_compile_options(cbcview PRIVATE -Wall -Wextra -Wno-unused-parameter)

include(GNUInstallDirs)
install(TARGETS cbcview ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libcbcview
  FILES_MATCHING PATTERN "*.h"
)
