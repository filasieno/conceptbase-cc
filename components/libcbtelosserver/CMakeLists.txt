cmake_minimum_required(VERSION 4.1)
project(libcbtelosserver VERSION 0.1.0 LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/../buildcbutils")
include(LibcbFindDeps)
libcb_find_general()
libcb_find_telos()

find_package(PkgConfig REQUIRED)
pkg_check_modules(SWIPL REQUIRED IMPORTED_TARGET swipl)

add_library(cbtelosserver STATIC
  src/CharListToCString.c src/te_PrologUtilities.c
  src/te_smlCToProlog.c src/te_smlGetFragmentSpace.c src/switelosServer.c
)
set_target_properties(cbtelosserver PROPERTIES OUTPUT_NAME cbtelosserver)
target_include_directories(cbtelosserver PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)
libcb_link_general(cbtelosserver PRIVATE)
libcb_link_telos(cbtelosserver PRIVATE)
target_compile_definitions(cbtelosserver PRIVATE SWI LINUX _GNU_SOURCE)
target_compile_options(cbtelosserver PRIVATE -Wall -Wextra -Wno-unused-parameter)
target_link_libraries(cbtelosserver PUBLIC PkgConfig::SWIPL)

include(GNUInstallDirs)
install(TARGETS cbtelosserver ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
