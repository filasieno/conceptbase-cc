cmake_minimum_required(VERSION 4.1)
project(libcbtelos VERSION 0.1.0 LANGUAGES C)
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
cb_generate_parser(te_parser te_parser_ te_parser_ te_parser.y te_parser.l)

add_library(cbtelos STATIC
  ${te_parser_TAB_C}
  ${te_parser_YY_C}
  src/te_callparser.c
  src/te_smlutil.c
  src/switelos.c
)
set_target_properties(cbtelos PROPERTIES OUTPUT_NAME cbtelos)

add_library(ConceptBase::libcbtelos ALIAS cbtelos)

target_include_directories(cbtelos
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/libcbtelos>
  PRIVATE
    ${te_parser_GEN_DIR}
)
libcb_link_general(cbtelos PRIVATE)
target_compile_definitions(cbtelos PRIVATE SWI LINUX CBSERVER _GNU_SOURCE)
target_compile_options(cbtelos PRIVATE -Wall -Wextra -Wno-unused-parameter)
target_link_libraries(cbtelos PUBLIC PkgConfig::SWIPL)

include(GNUInstallDirs)
install(TARGETS cbtelos
  EXPORT libcbtelosTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libcbtelos
  FILES_MATCHING PATTERN "*.h"
)

install(EXPORT libcbtelosTargets
  FILE libcbtelosTargets.cmake
  NAMESPACE ConceptBase::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbtelos
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libcbtelosConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/libcbtelosConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbtelos
)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/libcbtelosConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/libcbtelosConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/libcbtelosConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbtelos
)
