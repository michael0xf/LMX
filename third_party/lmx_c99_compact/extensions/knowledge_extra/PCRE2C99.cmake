# ISO C99 guarantees 4095-character literals; upstream's table is 5686.
# Spell the identical NUL-separated table as a byte array in a build view.
# No upstream source modification or compiler-warning suppression is needed.
function(lmx_pcre2_c99_errors source output out_variable)
    set(input "${source}/src/pcre2_error.c")
    file(SHA256 "${input}" hash)
    if(NOT hash STREQUAL "b564ff9a785fa5d9d0592945dea35a668e34760f61d818daf03dea86d22bf18c")
        message(FATAL_ERROR "PCRE2 error table changed; regenerate and verify C99 array")
    endif()
    file(READ "${input}" original)
    string(FIND "${original}" "static const unsigned char compile_error_texts[] =" start)
    string(FIND "${original}" "/* Match-time and UTF error texts" stop)
    if(start LESS 0 OR stop LESS start)
        message(FATAL_ERROR "Unexpected PCRE2 error-table layout")
    endif()
    string(SUBSTRING "${original}" 0 ${start} prefix)
    string(SUBSTRING "${original}" ${stop} -1 suffix)
    file(MAKE_DIRECTORY "${output}")
    configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/compat/pcre2_compile_errors_c99.inc"
        "${output}/pcre2_compile_errors_c99.inc" COPYONLY)
    file(WRITE "${output}/pcre2_error.c" "${prefix}#include \"pcre2_compile_errors_c99.inc\"\n\n${suffix}")
    set(${out_variable} "${output}/pcre2_error.c" PARENT_SCOPE)
endfunction()
