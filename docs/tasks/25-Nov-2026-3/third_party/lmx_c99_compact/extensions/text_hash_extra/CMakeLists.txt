cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
    message(FATAL_ERROR "The text_hash_extra group requires lmx_c99_target")
endif()
set(_text_extra_root "${CMAKE_CURRENT_LIST_DIR}")
set(_text_extra_vendor "${LMX_VENDOR_DIR}")
set(_text_extra_view "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${_text_extra_view}/divsufsort" "${_text_extra_view}/ccd")

# The two published index widths use the upstream implementation unchanged.
# Explicit C99 widths make the same public headers usable on LP64 and LLP64.
function(_lmx_text_extra_divsufsort)
    include("${_text_extra_vendor}/libdivsufsort/VERSION.cmake")
    set(HAVE_INTTYPES_H 1)
    set(HAVE_STDDEF_H 1)
    set(HAVE_STDINT_H 1)
    set(HAVE_STDLIB_H 1)
    set(HAVE_STRING_H 1)
    foreach(_optional_header IN ITEMS HAVE_STRINGS_H HAVE_MEMORY_H HAVE_SYS_TYPES_H
            HAVE_IO_H HAVE_FCNTL_H HAVE__SETMODE HAVE_SETMODE HAVE__FILENO HAVE_FOPEN_S HAVE__O_BINARY)
        set(${_optional_header} 0)
    endforeach()
    set(INLINE "inline")
    configure_file("${_text_extra_vendor}/libdivsufsort/include/config.h.cmake"
        "${_text_extra_view}/divsufsort/config.h")
    set(_sources
        "${_text_extra_vendor}/libdivsufsort/lib/divsufsort.c"
        "${_text_extra_vendor}/libdivsufsort/lib/sssort.c"
        "${_text_extra_vendor}/libdivsufsort/lib/trsort.c"
        "${_text_extra_vendor}/libdivsufsort/lib/utils.c")
    foreach(_width IN ITEMS "32" "64")
        if(_width STREQUAL "32")
            set(_name divsufsort)
        else()
            set(_name divsufsort64)
        endif()
        add_library(lmx_${_name} STATIC ${_sources})
        add_library(LMX::${_name} ALIAS lmx_${_name})
        target_include_directories(lmx_${_name}
            PUBLIC "${_text_extra_root}/include"
            PRIVATE "${_text_extra_vendor}/libdivsufsort/include"
                    "${_text_extra_view}/divsufsort")
        target_compile_definitions(lmx_${_name} PRIVATE HAVE_CONFIG_H=1)
        if(_width STREQUAL "64")
            target_compile_definitions(lmx_${_name} PRIVATE BUILD_DIVSUFSORT64=1)
        endif()
        lmx_c99_target(lmx_${_name})
        set_target_properties(lmx_${_name} PROPERTIES POSITION_INDEPENDENT_CODE ON)
    endforeach()
endfunction()
_lmx_text_extra_divsufsort()

add_library(lmx_tess2 STATIC
    "${_text_extra_vendor}/libtess2/Source/bucketalloc.c"
    "${_text_extra_vendor}/libtess2/Source/dict.c"
    "${_text_extra_vendor}/libtess2/Source/geom.c"
    "${_text_extra_vendor}/libtess2/Source/mesh.c"
    "${_text_extra_vendor}/libtess2/Source/priorityq.c"
    "${_text_extra_vendor}/libtess2/Source/sweep.c"
    "${_text_extra_vendor}/libtess2/Source/tess.c")
add_library(LMX::tess2 ALIAS lmx_tess2)
target_include_directories(lmx_tess2 PUBLIC "${_text_extra_vendor}/libtess2/Include")
lmx_c99_target(lmx_tess2)
set_target_properties(lmx_tess2 PROPERTIES POSITION_INDEPENDENT_CODE ON)

# A single double profile prevents callers silently mixing float/double ABIs.
set(CCD_SINGLE OFF)
set(CCD_DOUBLE ON)
configure_file("${_text_extra_vendor}/libccd/src/ccd/config.h.cmake.in"
    "${_text_extra_view}/ccd/config.h")
add_library(lmx_ccd STATIC
    "${_text_extra_vendor}/libccd/src/ccd.c"
    "${_text_extra_vendor}/libccd/src/mpr.c"
    "${_text_extra_vendor}/libccd/src/polytope.c"
    "${_text_extra_vendor}/libccd/src/support.c"
    "${_text_extra_vendor}/libccd/src/vec3.c")
add_library(LMX::ccd ALIAS lmx_ccd)
target_include_directories(lmx_ccd PUBLIC "${_text_extra_vendor}/libccd/src" "${_text_extra_view}")
target_compile_definitions(lmx_ccd PUBLIC CCD_STATIC_DEFINE=1)
lmx_c99_target(lmx_ccd)
set_target_properties(lmx_ccd PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_inih STATIC "${_text_extra_vendor}/inih/ini.c")
add_library(LMX::inih ALIAS lmx_inih)
target_include_directories(lmx_inih PUBLIC "${_text_extra_vendor}/inih")
lmx_c99_target(lmx_inih)
set_target_properties(lmx_inih PROPERTIES POSITION_INDEPENDENT_CODE ON)

# Upstream's single-translation-unit C99 build keeps its internal API private.
# The terminal editor has one process-wide environment; LMX must serialize it.
add_library(lmx_isocline STATIC "${_text_extra_vendor}/isocline/src/isocline.c")
add_library(LMX::isocline ALIAS lmx_isocline)
target_include_directories(lmx_isocline PUBLIC "${_text_extra_vendor}/isocline/include")
# Retain upstream's default debug function. IC_NO_DEBUG_MSG uses a GNU-only
# empty variadic-macro call and fails strict C99 in this upstream release.
# Debug output remains dormant unless ISOCLINE_DEBUG is explicitly set.
lmx_c99_target(lmx_isocline)
set_target_properties(lmx_isocline PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_unibreak STATIC
    "${_text_extra_vendor}/libunibreak/src/unibreakbase.c"
    "${_text_extra_vendor}/libunibreak/src/unibreakdef.c"
    "${_text_extra_vendor}/libunibreak/src/linebreak.c"
    "${_text_extra_vendor}/libunibreak/src/linebreakdata.c"
    "${_text_extra_vendor}/libunibreak/src/linebreakdef.c"
    "${_text_extra_vendor}/libunibreak/src/eastasianwidthdef.c"
    "${_text_extra_vendor}/libunibreak/src/emojidef.c"
    "${_text_extra_vendor}/libunibreak/src/graphemebreak.c"
    "${_text_extra_vendor}/libunibreak/src/wordbreak.c")
add_library(LMX::unibreak ALIAS lmx_unibreak)
target_include_directories(lmx_unibreak PUBLIC "${_text_extra_vendor}/libunibreak/src")
lmx_c99_target(lmx_unibreak)
set_target_properties(lmx_unibreak PROPERTIES POSITION_INDEPENDENT_CODE ON)

# Keep the legacy LZ4 copy and the newer XXH3-capable copy in distinct C units.
# PRIVATE is essential: a public namespace macro would change legacy callers.
add_library(lmx_xxhash_modern STATIC "${_text_extra_vendor}/xxhash/xxhash.c")
add_library(LMX::xxhash_modern ALIAS lmx_xxhash_modern)
target_compile_definitions(lmx_xxhash_modern PRIVATE XXH_NAMESPACE=LMXC99_XXH_)
target_include_directories(lmx_xxhash_modern PUBLIC "${_text_extra_root}/include")
lmx_c99_target(lmx_xxhash_modern)
set_target_properties(lmx_xxhash_modern PROPERTIES POSITION_INDEPENDENT_CODE ON)

if(UNIX)
    target_link_libraries(lmx_tess2 PUBLIC m)
    target_link_libraries(lmx_ccd PUBLIC m)
endif()

add_library(lmx_text_hash_extra INTERFACE)
add_library(LMX::text_hash_extra ALIAS lmx_text_hash_extra)
target_link_libraries(lmx_text_hash_extra INTERFACE
    LMX::divsufsort LMX::divsufsort64 LMX::tess2 LMX::ccd LMX::inih LMX::isocline
    LMX::unibreak LMX::xxhash_modern)

if(BUILD_TESTING)
    foreach(_check IN ITEMS divsufsort tess2 ccd inih isocline unibreak xxhash_modern)
        add_executable(lmx_text_extra_test_${_check} "tests/${_check}.c")
        lmx_c99_target(lmx_text_extra_test_${_check})
        target_link_libraries(lmx_text_extra_test_${_check} PRIVATE LMX::${_check})
        if(_check STREQUAL "divsufsort")
            target_link_libraries(lmx_text_extra_test_${_check} PRIVATE LMX::divsufsort64)
        endif()
        add_test(NAME text_hash_extra.${_check} COMMAND lmx_text_extra_test_${_check})
        set_tests_properties(text_hash_extra.${_check} PROPERTIES TIMEOUT 10)
    endforeach()
    add_test(NAME text_hash_extra.isocline_pipe
        COMMAND "${CMAKE_COMMAND}"
            "-DPROGRAM=$<TARGET_FILE:lmx_text_extra_test_isocline>"
            "-DINPUT=${_text_extra_root}/tests/isocline_input.txt"
            -P "${_text_extra_root}/tests/isocline_pipe.cmake")
    set_tests_properties(text_hash_extra.isocline_pipe PROPERTIES TIMEOUT 10)
    if(NOT DEFINED LMX_LEGACY_XXHASH_DIR)
        set(LMX_LEGACY_XXHASH_DIR "${_text_extra_vendor}/lz4/lib")
    endif()
    if(EXISTS "${LMX_LEGACY_XXHASH_DIR}/xxhash.c")
        add_executable(lmx_text_extra_test_hash_alternatives
            tests/hash_alternatives.c tests/hash_legacy_view.c tests/hash_modern_view.c
            "${LMX_LEGACY_XXHASH_DIR}/xxhash.c")
        target_include_directories(lmx_text_extra_test_hash_alternatives PRIVATE "${LMX_LEGACY_XXHASH_DIR}")
        target_link_libraries(lmx_text_extra_test_hash_alternatives PRIVATE LMX::xxhash_modern)
        lmx_c99_target(lmx_text_extra_test_hash_alternatives)
        add_test(NAME text_hash_extra.hash_alternatives COMMAND lmx_text_extra_test_hash_alternatives)
        set_tests_properties(text_hash_extra.hash_alternatives PROPERTIES TIMEOUT 10)
    endif()
endif()
