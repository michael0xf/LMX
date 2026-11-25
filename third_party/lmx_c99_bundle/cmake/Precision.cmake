# Full, pinned upstream sources; this wrapper builds only the C libraries.
# See docs/PRECISION.md for ABI choices and the one generated portability patch.
include_guard(GLOBAL)

set(_lmx_precision_root "${CMAKE_CURRENT_LIST_DIR}/..")

function(_lmx_add_precision root)
    set(_tommath "${root}/vendor/libtommath")
    # Use the upstream's explicit source list, not a glob of demos/tests.
    include("${_tommath}/sources.cmake")
    list(TRANSFORM SOURCES PREPEND "${_tommath}/")
    add_library(lmx_tommath STATIC ${SOURCES})
    add_library(LMX::tommath ALIAS lmx_tommath)
    target_include_directories(lmx_tommath PUBLIC "${_tommath}")
    # Fixed public ABI: 28 significant bits per uint32_t digit, uint64_t word.
    # Upstream's automatic 64-bit mode requires a compiler-specific 128-bit type.
    target_compile_definitions(lmx_tommath PUBLIC MP_32BIT)
    lmx_c99_target(lmx_tommath)
    if(UNIX)
        target_link_libraries(lmx_tommath PUBLIC m)
    elseif(WIN32)
        # Only the upstream platform entropy provider uses this system library.
        target_link_libraries(lmx_tommath PRIVATE advapi32)
    endif()

    set(_mpdec "${root}/vendor/mpdecimal/libmpdec")
    set(_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/mpdecimal")
    file(MAKE_DIRECTORY "${_generated}")
    include(CheckTypeSize)
    check_type_size("size_t" LMX_MPDEC_SIZEOF_SIZE_T LANGUAGE C)
    if(LMX_MPDEC_SIZEOF_SIZE_T EQUAL 8)
        set(_bits 64)
        set(_other_bits 32)
    elseif(LMX_MPDEC_SIZEOF_SIZE_T EQUAL 4)
        set(_bits 32)
        set(_other_bits 64)
    else()
        message(FATAL_ERROR "MPDecimal requires a 32-bit or 64-bit size_t")
    endif()
    # The public header records the target ABI, just as upstream configure does.
    # ANSI and CONFIG_* are implementation settings and must not leak to users.
    set(MPD_HEADER_CONFIG "/* Generated for the target's ${_bits}-bit size_t ABI. */\n#define MPD_CONFIG_${_bits} 1\n#if defined(MPD_CONFIG_${_other_bits}) || defined(CONFIG_${_other_bits})\n#error \"incompatible MPDecimal header configuration\"\n#endif")
    configure_file("${_mpdec}/mpdecimal.h.in" "${_generated}/mpdecimal.h" @ONLY)

    # ANSI disables assembly, but upstream 4.0.1 still auto-enables three
    # uint128 conversion paths. Select their existing portable C alternatives.
    # Original vendor files are retained byte-for-byte.
    file(READ "${_mpdec}/mpdecimal.c" _mpdecimal_c)
    string(REGEX MATCHALL "defined\\(__SIZEOF_INT128__\\)" _int128_guards "${_mpdecimal_c}")
    list(LENGTH _int128_guards _int128_count)
    if(NOT _int128_count EQUAL 3)
        message(FATAL_ERROR "Unexpected MPDecimal conversion guards; review the portability adapter")
    endif()
    string(REPLACE "defined(__SIZEOF_INT128__)" "defined(HAVE_UINT128_T)"
        _mpdecimal_c "${_mpdecimal_c}")
    file(WRITE "${_generated}/mpdecimal_portable.c" "${_mpdecimal_c}")

    # From upstream libmpdec/Makefile.in. fnt.c is ordinary C and is required.
    set(_mpdec_sources)
    foreach(_module IN ITEMS basearith context constants convolute crt
            mpsignal difradix2 fnt fourstep io mpalloc numbertheory sixstep transpose)
        list(APPEND _mpdec_sources "${_mpdec}/${_module}.c")
    endforeach()
    list(APPEND _mpdec_sources "${_generated}/mpdecimal_portable.c")
    add_library(lmx_mpdec STATIC ${_mpdec_sources})
    add_library(LMX::mpdec ALIAS lmx_mpdec)
    target_include_directories(lmx_mpdec PUBLIC "${_generated}" PRIVATE "${_mpdec}")
    target_compile_definitions(lmx_mpdec PRIVATE "CONFIG_${_bits}" ANSI)
    lmx_c99_target(lmx_mpdec)
    if(UNIX)
        target_link_libraries(lmx_mpdec PUBLIC m)
    endif()

    add_library(lmx_precision INTERFACE)
    add_library(LMX::precision ALIAS lmx_precision)
    target_link_libraries(lmx_precision INTERFACE LMX::tommath LMX::mpdec)
    lmx_c99_target(lmx_precision)

    if(BUILD_TESTING)
        foreach(_test IN ITEMS tommath mpdecimal)
            add_executable(lmx_test_precision_${_test} "${root}/tests/precision_${_test}.c")
            target_link_libraries(lmx_test_precision_${_test} PRIVATE LMX::precision)
            lmx_c99_target(lmx_test_precision_${_test})
            add_test(NAME precision.${_test} COMMAND lmx_test_precision_${_test})
            set_tests_properties(precision.${_test} PROPERTIES TIMEOUT 30)
        endforeach()
        add_executable(lmx_test_precision_tommath_upstream
            "${_tommath}/demo/shared.c" "${_tommath}/demo/test.c")
        target_link_libraries(lmx_test_precision_tommath_upstream PRIVATE LMX::tommath)
        lmx_c99_target(lmx_test_precision_tommath_upstream)
        add_test(NAME precision.tommath_upstream COMMAND lmx_test_precision_tommath_upstream)
        set_tests_properties(precision.tommath_upstream PROPERTIES TIMEOUT 180)
    endif()

    if(LMX_BUILD_EXAMPLES)
        add_executable(lmx_example_precision "${root}/examples/precision/main.c")
        target_link_libraries(lmx_example_precision PRIVATE LMX::precision)
        lmx_c99_target(lmx_example_precision)
        if(BUILD_TESTING)
            add_test(NAME precision.example COMMAND lmx_example_precision)
        endif()
    endif()
endfunction()

_lmx_add_precision("${_lmx_precision_root}")
unset(_lmx_precision_root)
