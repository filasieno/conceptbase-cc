# Monorepo sibling include paths (local CMake builds without CMAKE_PREFIX_PATH).
macro(libcb_default_include var sibling_rel)
  if(NOT DEFINED ${var} OR "${${var}}" STREQUAL "")
    set(${var} "${CMAKE_CURRENT_SOURCE_DIR}/${sibling_rel}")
  endif()
endmacro()

libcb_default_include(LIBCBGENERAL_INCLUDE_DIR "../libcbgeneral/include/conceptbase")
libcb_default_include(LIBCBTELOS_INCLUDE_DIR "../libcbtelos/src")
libcb_default_include(LIBCBC_INCLUDE_DIR "../libcbc/src")
