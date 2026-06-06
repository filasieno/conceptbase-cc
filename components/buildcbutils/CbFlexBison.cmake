# Flex/Bison outputs live under ${CMAKE_CURRENT_BINARY_DIR}/generated — do not commit them.
#
# cb_generate_parser(<stem> <bison_prefix> <flex_prefix> <yfile> <lfile>)
#   <stem>     base name of outputs: <stem>.tab.c, <stem>.tab.h, <stem>.yy.c
#   prefixes   legacy CB_Make LPREFIX / YPREFIX (-p / -P)
# Sets ${stem}_TAB_C, ${stem}_YY_C, ${stem}_GEN_DIR in parent scope.
function(cb_generate_parser stem bison_prefix flex_prefix yfile lfile)
  set(gen_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
  file(MAKE_DIRECTORY "${gen_dir}")

  set(y_in "${CMAKE_CURRENT_SOURCE_DIR}/src/${yfile}")
  set(l_in "${CMAKE_CURRENT_SOURCE_DIR}/src/${lfile}")
  set(tab_c "${gen_dir}/${stem}.tab.c")
  set(tab_h "${gen_dir}/${stem}.tab.h")
  set(yy_c "${gen_dir}/${stem}.yy.c")

  find_package(BISON REQUIRED)
  find_package(FLEX REQUIRED)

  bison_target("${stem}_yacc" "${y_in}" "${tab_c}"
    DEFINES_FILE "${tab_h}"
    COMPILE_FLAGS "-p ${bison_prefix}"
  )
  flex_target("${stem}_lex" "${l_in}" "${yy_c}"
    COMPILE_FLAGS "-P${flex_prefix}"
  )
  add_flex_bison_dependency("${stem}_lex" "${stem}_yacc")

  set("${stem}_TAB_C" "${tab_c}" PARENT_SCOPE)
  set("${stem}_YY_C" "${yy_c}" PARENT_SCOPE)
  set("${stem}_GEN_DIR" "${gen_dir}" PARENT_SCOPE)
endfunction()
