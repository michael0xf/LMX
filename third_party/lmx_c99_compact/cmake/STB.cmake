# Current versioned stb components, each implementation in a separate C99 TU.
set(_lmx_stb_root "${CMAKE_CURRENT_LIST_DIR}/../vendor/stb")
set(_lmx_stb_bundle "${CMAKE_CURRENT_LIST_DIR}/..")

include("${CMAKE_CURRENT_LIST_DIR}/STBArrayFixes.cmake")

add_library(lmx_stb_headers INTERFACE)
add_library(LMX::stb_headers ALIAS lmx_stb_headers)
target_include_directories(lmx_stb_headers INTERFACE "${_lmx_stb_generated}" "${_lmx_stb_root}")
target_compile_features(lmx_stb_headers INTERFACE c_std_99)
# Optional compiler/C11 TLS and Windows-only UTF-8 filename extensions are not
# enabled. The standard C99 stdio and global image settings remain available.
target_compile_definitions(lmx_stb_headers INTERFACE
    STBI_NO_THREAD_LOCALS STBI_NO_SIMD STBIR_NO_SIMD)

file(GLOB _lmx_stb_sources CONFIGURE_DEPENDS "${_lmx_stb_bundle}/src/stb/*.c")
list(REMOVE_ITEM _lmx_stb_sources "${_lmx_stb_bundle}/src/stb/stb_leakcheck.c")
add_library(lmx_stb STATIC ${_lmx_stb_sources})
add_library(LMX::stb ALIAS lmx_stb)
lmx_c99_target(lmx_stb)
target_link_libraries(lmx_stb PUBLIC LMX::stb_headers)
if(UNIX OR MINGW)
    target_link_libraries(lmx_stb PUBLIC m)
endif()

# Opt-in allocator instrumentation; it never changes the other libraries'
# allocation behavior merely by linking LMX::stb or LMX::all.
add_library(lmx_stb_leakcheck STATIC "${_lmx_stb_bundle}/src/stb/stb_leakcheck.c")
add_library(LMX::stb_leakcheck ALIAS lmx_stb_leakcheck)
lmx_c99_target(lmx_stb_leakcheck)
target_link_libraries(lmx_stb_leakcheck PUBLIC LMX::stb_headers)

if(BUILD_TESTING)
    add_executable(lmx_stb_smoke "${_lmx_stb_bundle}/tests/stb_smoke.c")
    lmx_c99_target(lmx_stb_smoke)
    target_link_libraries(lmx_stb_smoke PRIVATE LMX::stb)
    add_test(NAME stb.functional_smoke COMMAND lmx_stb_smoke)

    add_executable(lmx_stb_leakcheck_test "${_lmx_stb_bundle}/tests/stb_leakcheck_test.c")
    lmx_c99_target(lmx_stb_leakcheck_test)
    target_link_libraries(lmx_stb_leakcheck_test PRIVATE LMX::stb_leakcheck)
    add_test(NAME stb.leakcheck_allocator COMMAND lmx_stb_leakcheck_test)

    # These components require application types, callbacks or grid/mesh config.
    # Validate their implementation in real C99 instantiations, while exposing
    # them as headers so consumers can select their own configuration.
    file(GLOB _lmx_stb_custom_tests CONFIGURE_DEPENDS "${_lmx_stb_bundle}/tests/stb_custom_*.c")
    foreach(test_source IN LISTS _lmx_stb_custom_tests)
        get_filename_component(test_name "${test_source}" NAME_WE)
        add_executable(${test_name} "${test_source}")
        lmx_c99_target(${test_name})
        target_link_libraries(${test_name} PRIVATE LMX::stb_headers)
        if(UNIX OR MINGW)
            target_link_libraries(${test_name} PRIVATE m)
        endif()
        add_test(NAME ${test_name} COMMAND ${test_name})
    endforeach()
endif()

unset(_lmx_stb_root)
unset(_lmx_stb_bundle)
unset(_lmx_stb_sources)
unset(_lmx_stb_custom_tests)
