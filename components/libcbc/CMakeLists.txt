cmake_minimum_required(VERSION 4.1)
project(libcbc VERSION 0.1.0 LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/../buildcbutils")

add_library(cbc STATIC
  src/CBinterface.c src/CBipc.c src/CBterm.c src/CButils.c src/CBdll.c
)
set_target_properties(cbc PROPERTIES OUTPUT_NAME cbc)

add_library(ConceptBase::libcbc ALIAS cbc)

target_include_directories(cbc
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/libcbc>
)

target_compile_definitions(cbc PRIVATE LINUX _GNU_SOURCE)
target_compile_options(cbc PRIVATE -Wall -Wextra -Wno-unused-parameter)

include(GNUInstallDirs)
install(TARGETS cbc
  EXPORT libcbcTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libcbc
  FILES_MATCHING PATTERN "*.h"
)

install(EXPORT libcbcTargets
  FILE libcbcTargets.cmake
  NAMESPACE ConceptBase::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbc
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libcbcConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/libcbcConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbc
)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/libcbcConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/libcbcConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/libcbcConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbc
)

include(CTest)
include(CbEnableTests)
cb_add_c_test(testterm
  LIB cbc
  SOURCES tests/testterm.c
)
