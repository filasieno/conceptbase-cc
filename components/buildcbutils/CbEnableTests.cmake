# Archive regression tests (enabled when CMAKE BUILD_TESTING is ON — Nix doCheck).
include_guard(GLOBAL)

function(cb_add_c_test name)
  set(options "")
  set(oneValueArgs LIB)
  set(multiValueArgs SOURCES ARGS INCLUDES)
  cmake_parse_arguments(T "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT BUILD_TESTING)
    return()
  endif()

  add_executable(${name} ${T_SOURCES})
  target_link_libraries(${name} PRIVATE ${T_LIB})
  if(T_INCLUDES)
    target_include_directories(${name} PRIVATE ${T_INCLUDES})
  endif()
  if(T_ARGS)
    add_test(NAME ${name} COMMAND ${name} ${T_ARGS})
  else()
    add_test(NAME ${name} COMMAND ${name})
  endif()
endfunction()
