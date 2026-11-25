# C99 has inline. Upstream's old C90 compatibility macro otherwise redefines
# that keyword in every strict-C99 consumer that includes kautodiff.h.
set(_kann_view "${CMAKE_CURRENT_BINARY_DIR}/compat/kann")
file(MAKE_DIRECTORY "${_kann_view}" "${_kann_view}/kann_extra")
foreach(_file kann.c kann.h kautodiff.c kautodiff.h)
    configure_file("${_kann_vendor}/${_file}" "${_kann_view}/${_file}" COPYONLY)
endforeach()
foreach(_file kann_data.c kann_data.h kseq.h)
    configure_file("${_kann_vendor}/kann_extra/${_file}"
                   "${_kann_view}/kann_extra/${_file}" COPYONLY)
endforeach()
file(READ "${_kann_vendor}/kautodiff.h" _kann_header)
set(_kann_inline_old "#ifdef __STRICT_ANSI__\n#define inline\n#endif")
set(_kann_inline_new "#if defined(__STRICT_ANSI__) && (!defined(__STDC_VERSION__) || __STDC_VERSION__ < 199901L)\n#define inline\n#endif")
string(FIND "${_kann_header}" "${_kann_inline_old}" _kann_inline_pos)
if(_kann_inline_pos EQUAL -1)
    message(FATAL_ERROR "KANN C99 inline compatibility fix does not match pinned upstream")
endif()
string(REPLACE "${_kann_inline_old}" "${_kann_inline_new}" _kann_header "${_kann_header}")
file(WRITE "${_kann_view}/kautodiff.h" "${_kann_header}")

# The public header declares kann_copy_mt even in a serial build. Upstream's
# existing serial kann_mt is a no-op; with no worker copies, copy_mt is too.
file(READ "${_kann_vendor}/kann.c" _kann_source)
set(_kann_serial_old "#else\nvoid kann_mt(kann_t *ann, int n_threads, int max_batch_size) {}")
set(_kann_serial_new "#else\nvoid kann_copy_mt(kann_t *a, int B, int j) { (void)a; (void)B; (void)j; }\nvoid kann_mt(kann_t *ann, int n_threads, int max_batch_size) {}")
string(FIND "${_kann_source}" "${_kann_serial_old}" _kann_serial_pos)
if(_kann_serial_pos EQUAL -1)
    message(FATAL_ERROR "KANN serial compatibility fix does not match pinned upstream")
endif()
string(REPLACE "${_kann_serial_old}" "${_kann_serial_new}" _kann_source "${_kann_source}")
# This otherwise-uncompiled serial branch returns a void expression, a GNU
# extension rejected by strict C99. Calling the same void helper is sufficient.
set(_kann_void_old "void kann_switch(kann_t *ann, int is_train) { return kann_switch_core(ann, is_train); }")
set(_kann_void_new "void kann_switch(kann_t *ann, int is_train) { kann_switch_core(ann, is_train); }")
string(FIND "${_kann_source}" "${_kann_void_old}" _kann_void_pos)
if(_kann_void_pos EQUAL -1)
    message(FATAL_ERROR "KANN serial void-return fix does not match pinned upstream")
endif()
string(REPLACE "${_kann_void_old}" "${_kann_void_new}" _kann_source "${_kann_source}")
file(WRITE "${_kann_view}/kann.c" "${_kann_source}")
