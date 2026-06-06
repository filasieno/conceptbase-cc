cmake_minimum_required(VERSION 4.1)
project(libcbipc VERSION 0.1.0 LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/../buildcbutils")
include(LibcbFindDeps)
libcb_find_general()

find_package(PkgConfig REQUIRED)
pkg_check_modules(SWIPL REQUIRED IMPORTED_TARGET swipl)

include(CbFlexBisonInclude)
cb_generate_parser(IpcParser Ipc Ipc IpcParser.y IpcParser.l)

add_library(cbipc STATIC
  ${IpcParser_TAB_C}
  ${IpcParser_YY_C}
  src/IpcParser.c
  src/IpcString.c
  src/IpcAnswer.c
  src/swiIpc.c
)
set_target_properties(cbipc PROPERTIES OUTPUT_NAME cbipc)
target_include_directories(cbipc PRIVATE
  ${IpcParser_GEN_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)
libcb_link_general(cbipc PRIVATE)
target_compile_definitions(cbipc PRIVATE SWI LINUX _GNU_SOURCE)
target_compile_options(cbipc PRIVATE -Wall -Wextra -Wno-unused-parameter)
target_link_libraries(cbipc PUBLIC PkgConfig::SWIPL)

include(GNUInstallDirs)
install(TARGETS cbipc ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
