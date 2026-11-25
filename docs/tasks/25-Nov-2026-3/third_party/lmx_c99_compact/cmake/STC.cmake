# STC v5.0, official stable release. All upstream files remain unmodified.
set(_lmx_stc_root "${CMAKE_CURRENT_LIST_DIR}/../vendor/stc")

add_library(lmx_stc_headers INTERFACE)
add_library(LMX::stc_headers ALIAS lmx_stc_headers)
target_include_directories(lmx_stc_headers INTERFACE "${_lmx_stc_root}/include")
target_compile_features(lmx_stc_headers INTERFACE c_std_99)
# Upstream fallback avoids optional typeof-based coroutine/sum-type helpers.
target_compile_definitions(lmx_stc_headers INTERFACE STC_HAS_TYPEOF=0)

add_library(lmx_stc STATIC
    "${_lmx_stc_root}/src/cregex.c"
    "${_lmx_stc_root}/src/cspan.c"
    "${_lmx_stc_root}/src/cstr_core.c"
    "${_lmx_stc_root}/src/cstr_io.c"
    "${_lmx_stc_root}/src/cstr_utf8.c"
    "${_lmx_stc_root}/src/csview.c"
    "${_lmx_stc_root}/src/random.c"
    "${_lmx_stc_root}/src/stc_core.c"
)
add_library(LMX::stc ALIAS lmx_stc)
target_link_libraries(lmx_stc PUBLIC lmx_stc_headers)
if(UNIX OR MINGW)
    target_link_libraries(lmx_stc PUBLIC m)
endif()
lmx_c99_target(lmx_stc)

if(BUILD_TESTING)
    foreach(_lmx_stc_test IN ITEMS containers text_math coroutine)
        add_executable(lmx_test_stc_${_lmx_stc_test}
            "${CMAKE_CURRENT_LIST_DIR}/../tests/stc_${_lmx_stc_test}.c")
        target_link_libraries(lmx_test_stc_${_lmx_stc_test} PRIVATE LMX::stc)
        lmx_c99_target(lmx_test_stc_${_lmx_stc_test})
        add_test(NAME stc.${_lmx_stc_test} COMMAND lmx_test_stc_${_lmx_stc_test})
    endforeach()
endif()

unset(_lmx_stc_root)
unset(_lmx_stc_test)
