cmake_minimum_required(VERSION 3.20)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(lmx_numeric_extra LANGUAGES C)
    set(LMX_NUMERIC_EXTRA_STANDALONE ON)
    enable_testing()
endif()
set(LMX_NUMERIC_VENDOR "${CMAKE_CURRENT_LIST_DIR}/../../vendor")
find_package(Python3 COMPONENTS Interpreter REQUIRED)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/prepare_libbf.py"
    "${CMAKE_CURRENT_LIST_DIR}/prepare_libtomfloat.py"
    "${LMX_NUMERIC_VENDOR}/libbf/libbf.c"
    "${LMX_NUMERIC_VENDOR}/libbf/libbf.h"
    "${LMX_NUMERIC_VENDOR}/libbf/cutils.c"
    "${LMX_NUMERIC_VENDOR}/libbf/cutils.h"
    "${LMX_NUMERIC_VENDOR}/libtomfloat/mpf_const_d.c"
    "${LMX_NUMERIC_VENDOR}/libtomfloat/mpf_sqrt.c")
if(NOT COMMAND lmx_c99_target)
    function(lmx_c99_target target)
        get_target_property(_type ${target} TYPE)
        if(_type STREQUAL "INTERFACE_LIBRARY")
            target_compile_features(${target} INTERFACE c_std_99)
        else()
            set_target_properties(${target} PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
            if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
                target_compile_options(${target} PRIVATE -pedantic-errors)
            endif()
        endif()
    endfunction()
endif()

# No source download at configure/build time. The build view keeps upstream
# sources intact and avoids collisions with the collection's LibTomMath API.
set(_bf_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/libbf")
execute_process(COMMAND "${Python3_EXECUTABLE}"
    "${CMAKE_CURRENT_LIST_DIR}/prepare_libbf.py"
    "${LMX_NUMERIC_VENDOR}/libbf" "${_bf_generated}"
    RESULT_VARIABLE _bf_result)
if(NOT _bf_result EQUAL 0)
    message(FATAL_ERROR "Cannot create the reviewed portable LibBF build view")
endif()
add_library(lmx_libbf STATIC "${_bf_generated}/libbf.c" "${_bf_generated}/cutils.c")
add_library(LMX::libbf ALIAS lmx_libbf)
add_library(LMX::real ALIAS lmx_libbf)
target_include_directories(lmx_libbf PUBLIC "${_bf_generated}")
lmx_c99_target(lmx_libbf)
if(UNIX)
    target_link_libraries(lmx_libbf PUBLIC m)
endif()

# Pure C99 64-bit integer primitives, without GCC/ISA intrinsics. 8086-SSE is
# the chosen NaN propagation profile, not a requirement for an x86 CPU.
include(TestBigEndian)
test_big_endian(_softfloat_big_endian)
set(_sf_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/softfloat")
file(MAKE_DIRECTORY "${_sf_generated}")
if(_softfloat_big_endian)
    set(_sf_endian "")
else()
    set(_sf_endian "#define LITTLEENDIAN 1\n")
endif()
file(WRITE "${_sf_generated}/platform.h"
    "/* LMX portable C99 SoftFloat configuration. */\n${_sf_endian}#define INLINE inline\n#define THREAD_LOCAL\n")
include("${CMAKE_CURRENT_LIST_DIR}/softfloat_sources.cmake")
add_library(lmx_softfloat STATIC ${LMX_SOFTFLOAT_SOURCES})
add_library(LMX::softfloat ALIAS lmx_softfloat)
target_include_directories(lmx_softfloat PUBLIC "${LMX_NUMERIC_VENDOR}/softfloat/source/include"
    PRIVATE "${_sf_generated}" "${LMX_NUMERIC_VENDOR}/softfloat/source/8086-SSE")
target_compile_definitions(lmx_softfloat PUBLIC SOFTFLOAT_FAST_INT64
    PRIVATE INLINE_LEVEL=0 SOFTFLOAT_ROUND_ODD)
lmx_c99_target(lmx_softfloat)

file(GLOB _fixmath_sources CONFIGURE_DEPENDS "${LMX_NUMERIC_VENDOR}/libfixmath/libfixmath/*.c")
add_library(lmx_fixmath STATIC ${_fixmath_sources})
add_library(LMX::fixmath ALIAS lmx_fixmath)
target_include_directories(lmx_fixmath PUBLIC "${LMX_NUMERIC_VENDOR}/libfixmath/libfixmath")
target_compile_definitions(lmx_fixmath PUBLIC FIXMATH_NO_CACHE)
lmx_c99_target(lmx_fixmath)
if(UNIX)
    target_link_libraries(lmx_fixmath PUBLIC m)
endif()

file(GLOB _fixmatrix_sources CONFIGURE_DEPENDS "${LMX_NUMERIC_VENDOR}/libfixmatrix/*.c")
add_library(lmx_fixmatrix STATIC ${_fixmatrix_sources})
add_library(LMX::fixmatrix ALIAS lmx_fixmatrix)
target_include_directories(lmx_fixmatrix PUBLIC "${LMX_NUMERIC_VENDOR}/libfixmatrix")
target_link_libraries(lmx_fixmatrix PUBLIC LMX::fixmath)
lmx_c99_target(lmx_fixmatrix)

add_library(lmx_fp16 STATIC src/lmx_fp16.c)
add_library(LMX::fp16 ALIAS lmx_fp16)
target_include_directories(lmx_fp16 PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include" "${LMX_NUMERIC_VENDOR}/fp16/include")
target_compile_definitions(lmx_fp16 PUBLIC FP16_USE_NATIVE_CONVERSION=0
    FP16_USE_FLOAT16_TYPE=0 FP16_USE_FP16_TYPE=0)
lmx_c99_target(lmx_fp16)

file(GLOB _cminpack_sources CONFIGURE_DEPENDS "${LMX_NUMERIC_VENDOR}/cminpack/src/*.c")
add_library(lmx_cminpack STATIC ${_cminpack_sources})
add_library(LMX::cminpack ALIAS lmx_cminpack)
target_include_directories(lmx_cminpack PUBLIC "${LMX_NUMERIC_VENDOR}/cminpack/include"
    PRIVATE "${LMX_NUMERIC_VENDOR}/cminpack/src")
target_compile_definitions(lmx_cminpack PUBLIC CMINPACK_NO_DLL)
lmx_c99_target(lmx_cminpack)
if(UNIX)
    target_link_libraries(lmx_cminpack PUBLIC m)
endif()

add_library(lmx_imath STATIC "${LMX_NUMERIC_VENDOR}/imath/imath.c" "${LMX_NUMERIC_VENDOR}/imath/imrat.c")
add_library(LMX::imath ALIAS lmx_imath)
target_include_directories(lmx_imath PUBLIC "${LMX_NUMERIC_VENDOR}/imath")
lmx_c99_target(lmx_imath)
if(UNIX)
    target_link_libraries(lmx_imath PUBLIC m)
endif()

add_library(lmx_numeric_extra INTERFACE)
add_library(LMX::numeric_extra ALIAS lmx_numeric_extra)

# A portable alternative to KissFFT. Keep both float and double C APIs plus
# the C fast-convolution implementation; no C++ PFDSP, benchmark or FFTW code.
add_library(lmx_pffft STATIC
    "${LMX_NUMERIC_VENDOR}/pffft/src/pffft.c"
    "${LMX_NUMERIC_VENDOR}/pffft/src/pffft_double.c"
    "${LMX_NUMERIC_VENDOR}/pffft/src/pffft_common.c"
    "${LMX_NUMERIC_VENDOR}/pffft/src/pffastconv.c")
add_library(LMX::pffft ALIAS lmx_pffft)
target_include_directories(lmx_pffft PUBLIC "${LMX_NUMERIC_VENDOR}/pffft/include"
    PRIVATE "${LMX_NUMERIC_VENDOR}/pffft/include/pffft" "${LMX_NUMERIC_VENDOR}/pffft/src")
target_compile_definitions(lmx_pffft PUBLIC PFFFT_STATIC_DEFINE PFFASTCONV_STATIC_DEFINE
    PRIVATE PFFFT_SIMD_DISABLE=1)
lmx_c99_target(lmx_pffft)
if(UNIX)
    target_link_libraries(lmx_pffft PUBLIC m)
endif()

# All portable 8/16/32/64-bit-state PCG variants. The upstream header enables
# a compiler-specific 128-bit extension automatically; disable that one guard
# in the build view, without changing the retained upstream snapshot.
set(_pcg_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/pcg")
file(MAKE_DIRECTORY "${_pcg_generated}")
file(READ "${LMX_NUMERIC_VENDOR}/pcg-c/include/pcg_variants.h" _pcg_header)
string(REGEX MATCHALL "#if __SIZEOF_INT128__" _pcg_guards "${_pcg_header}")
list(LENGTH _pcg_guards _pcg_guard_count)
if(NOT _pcg_guard_count EQUAL 1)
    message(FATAL_ERROR "PCG 128-bit guard changed; review portable profile")
endif()
string(REPLACE "#if __SIZEOF_INT128__" "#if 0 /* LMX strict C99: no 128-bit compiler extension */"
    _pcg_header "${_pcg_header}")
file(WRITE "${_pcg_generated}/pcg_variants.h" "${_pcg_header}")
file(GLOB _pcg_sources CONFIGURE_DEPENDS "${LMX_NUMERIC_VENDOR}/pcg-c/src/*.c")
file(READ "${LMX_NUMERIC_VENDOR}/pcg-c/src/pcg-global-32.c" _pcg_global)
set(_pcg_void_return "return pcg32_advance_r(&pcg32_global, delta);")
string(FIND "${_pcg_global}" "${_pcg_void_return}" _pcg_return_position)
if(_pcg_return_position LESS 0)
    message(FATAL_ERROR "PCG void-return adapter changed; review strict C99 patch")
endif()
string(REPLACE "${_pcg_void_return}" "pcg32_advance_r(&pcg32_global, delta);"
    _pcg_global "${_pcg_global}")
file(WRITE "${_pcg_generated}/pcg-global-32.c" "${_pcg_global}")
list(REMOVE_ITEM _pcg_sources "${LMX_NUMERIC_VENDOR}/pcg-c/src/pcg-global-32.c")
list(APPEND _pcg_sources "${_pcg_generated}/pcg-global-32.c")
add_library(lmx_pcg STATIC ${_pcg_sources})
add_library(LMX::pcg ALIAS lmx_pcg)
target_include_directories(lmx_pcg PUBLIC "${_pcg_generated}")
target_compile_definitions(lmx_pcg PUBLIC PCG_USE_INLINE_ASM=0)
lmx_c99_target(lmx_pcg)

# Independent arbitrary-precision alternative, explicitly experimental.
# The normal parent collection already provides this LibTomMath target.
if(NOT TARGET LMX::tommath)
    set(LMX_TOMMATH_SOURCE "${LMX_NUMERIC_VENDOR}/libtommath" CACHE PATH
        "Existing LibTomMath production source, for standalone numeric_extra")
    if(NOT EXISTS "${LMX_TOMMATH_SOURCE}/sources.cmake")
        message(FATAL_ERROR "Set LMX_TOMMATH_SOURCE to the existing LibTomMath snapshot")
    endif()
    function(lmx_numeric_extra_tommath_source)
        include("${LMX_TOMMATH_SOURCE}/sources.cmake")
        set(_sources "")
        foreach(_file IN LISTS SOURCES)
            list(APPEND _sources "${LMX_TOMMATH_SOURCE}/${_file}")
        endforeach()
        add_library(lmx_numeric_extra_tommath STATIC ${_sources})
        add_library(LMX::tommath ALIAS lmx_numeric_extra_tommath)
        target_include_directories(lmx_numeric_extra_tommath PUBLIC "${LMX_TOMMATH_SOURCE}")
        target_compile_definitions(lmx_numeric_extra_tommath PUBLIC MP_32BIT)
        lmx_c99_target(lmx_numeric_extra_tommath)
    endfunction()
    lmx_numeric_extra_tommath_source()
endif()
set(_tf_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/libtomfloat")
execute_process(COMMAND "${Python3_EXECUTABLE}"
    "${CMAKE_CURRENT_LIST_DIR}/prepare_libtomfloat.py"
    "${LMX_NUMERIC_VENDOR}/libtomfloat" "${_tf_generated}"
    RESULT_VARIABLE _tf_result)
if(NOT _tf_result EQUAL 0)
    message(FATAL_ERROR "Cannot create the reviewed LibTomFloat fixes")
endif()
file(GLOB _tf_sources CONFIGURE_DEPENDS "${LMX_NUMERIC_VENDOR}/libtomfloat/*.c")
list(REMOVE_ITEM _tf_sources "${LMX_NUMERIC_VENDOR}/libtomfloat/mpf_const_d.c"
    "${LMX_NUMERIC_VENDOR}/libtomfloat/mpf_sqrt.c")
list(APPEND _tf_sources "${_tf_generated}/mpf_const_d.c" "${_tf_generated}/mpf_sqrt.c")
add_library(lmx_tomfloat STATIC ${_tf_sources})
add_library(LMX::tomfloat ALIAS lmx_tomfloat)
target_include_directories(lmx_tomfloat PUBLIC "${LMX_NUMERIC_VENDOR}/libtomfloat")
target_link_libraries(lmx_tomfloat PUBLIC LMX::tommath)
lmx_c99_target(lmx_tomfloat)
if(UNIX)
    target_link_libraries(lmx_tomfloat PUBLIC m)
endif()

target_link_libraries(lmx_numeric_extra INTERFACE LMX::real LMX::softfloat LMX::fixmatrix LMX::fp16 LMX::cminpack LMX::imath LMX::pffft LMX::pcg LMX::tomfloat)

if(LMX_NUMERIC_EXTRA_STANDALONE OR LMX_BUILD_NUMERIC_EXTRA_CHECKS)
    add_executable(lmx_numeric_extra_check tests/numeric_extra_check.c)
    target_link_libraries(lmx_numeric_extra_check PRIVATE LMX::numeric_extra)
    lmx_c99_target(lmx_numeric_extra_check)
    add_test(NAME numeric_extra.usage COMMAND lmx_numeric_extra_check)
    add_executable(lmx_numeric_alternatives_check tests/numeric_alternatives_check.c)
    target_link_libraries(lmx_numeric_alternatives_check PRIVATE LMX::pffft LMX::pcg)
    lmx_c99_target(lmx_numeric_alternatives_check)
    add_test(NAME numeric_extra.alternatives COMMAND lmx_numeric_alternatives_check)
    # Isolated TU avoids the distinct IMath and LibTomMath mp_int typedefs.
    add_executable(lmx_libtomfloat_check tests/libtomfloat_check.c)
    target_link_libraries(lmx_libtomfloat_check PRIVATE LMX::tomfloat)
    lmx_c99_target(lmx_libtomfloat_check)
    add_test(NAME numeric_extra.libtomfloat COMMAND lmx_libtomfloat_check)
endif()
