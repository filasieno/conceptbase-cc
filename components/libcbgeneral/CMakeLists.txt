cmake_minimum_required(VERSION 4.1)

project(
  libcbgeneral
  VERSION 0.1.0
  DESCRIPTION "ConceptBase.cc server C↔Prolog bridge (libcbgeneral)"
  LANGUAGES C CXX
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(SWIPL REQUIRED IMPORTED_TARGET swipl)

add_library(cbgeneral STATIC
  src/BimIpc.c
  src/FileIO.c
  src/StringBuffer.c
  src/unixToProlog.c
  src/swiGeneral.c
  src/UnixFileSys.c
  src/TermCache.cc
)

set_target_properties(cbgeneral PROPERTIES OUTPUT_NAME cbgeneral)

add_library(ConceptBase::libcbgeneral ALIAS cbgeneral)

target_include_directories(cbgeneral
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/conceptbase>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/conceptbase>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(cbgeneral
  PRIVATE
    _GNU_SOURCE
    SWI
    LINUX
)

target_compile_options(cbgeneral
  PRIVATE
    $<$<COMPILE_LANGUAGE:C,CXX>:-Wall -Wextra -Wpedantic>
    $<$<COMPILE_LANGUAGE:C,CXX>:$<$<CONFIG:Debug>:-O0 -g3>>
    $<$<COMPILE_LANGUAGE:C,CXX>:$<$<CONFIG:Release>:-O3>>
    $<$<COMPILE_LANGUAGE:C,CXX>:$<$<CONFIG:RelWithDebInfo>:-O2 -g>>
)

target_link_libraries(cbgeneral
  PUBLIC
    PkgConfig::SWIPL
)

include(GNUInstallDirs)

install(TARGETS cbgeneral
  EXPORT libcbgeneralTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY include/conceptbase
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING PATTERN "*.h"
)

install(EXPORT libcbgeneralTargets
  FILE libcbgeneralTargets.cmake
  NAMESPACE ConceptBase::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbgeneral
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libcbgeneralConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/libcbgeneralConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbgeneral
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/libcbgeneralConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/libcbgeneralConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/libcbgeneralConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libcbgeneral
)
