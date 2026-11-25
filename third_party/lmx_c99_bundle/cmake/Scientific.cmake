# Small C99 science libraries: immutable upstream sources, explicit source lists.
# No configure-time downloads, external generators, SIMD, OpenMP, or C++ runtime.
set(_lmx_science_root "${CMAKE_CURRENT_LIST_DIR}/..")
set(_lmx_science_vendor "${_lmx_science_root}/vendor")
set(_lmx_science_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/scientific")
file(MAKE_DIRECTORY "${_lmx_science_generated}/linmath" "${_lmx_science_generated}/cephes")

# C99 does not permit the implicit array-of-array qualification conversions
# used by upstream linmath (standardized only in C23). The generated C99 view
# drops const on mat4x4 input parameters only; vector inputs retain const.
file(READ "${_lmx_science_vendor}/linmath/linmath.h" _lmx_linmath_header)
string(REPLACE "mat4x4 const " "mat4x4 " _lmx_linmath_header "${_lmx_linmath_header}")
file(WRITE "${_lmx_science_generated}/linmath/linmath.h" "/* LMX C99 adaptation; original vendor/linmath/linmath.h is unchanged. */\n${_lmx_linmath_header}")
add_library(lmx_linmath INTERFACE)
add_library(LMX::linmath ALIAS lmx_linmath)
target_include_directories(lmx_linmath INTERFACE "${_lmx_science_generated}/linmath")
lmx_c99_target(lmx_linmath)

# Native KissFFT CMake enables C++, fast-math, tools and datatype variants.
# This wrapper deliberately builds all five portable C modules with double.
set(LMX_KISSFFT_DATATYPE "double" CACHE STRING "KissFFT scalar type: double or float")
set_property(CACHE LMX_KISSFFT_DATATYPE PROPERTY STRINGS double float)
if(NOT LMX_KISSFFT_DATATYPE MATCHES "^(double|float)$")
    message(FATAL_ERROR "LMX_KISSFFT_DATATYPE must be double or float in the C99 collection")
endif()
add_library(lmx_kissfft STATIC
    "${_lmx_science_vendor}/kissfft/kiss_fft.c"
    "${_lmx_science_vendor}/kissfft/kiss_fftr.c"
    "${_lmx_science_vendor}/kissfft/kiss_fftnd.c"
    "${_lmx_science_vendor}/kissfft/kiss_fftndr.c"
    "${_lmx_science_vendor}/kissfft/kfc.c")
add_library(LMX::kissfft ALIAS lmx_kissfft)
target_include_directories(lmx_kissfft PUBLIC "${_lmx_science_vendor}/kissfft")
target_compile_definitions(lmx_kissfft PUBLIC kiss_fft_scalar=${LMX_KISSFFT_DATATYPE})
lmx_c99_target(lmx_kissfft)

# TinySpline's C API includes JSON serialization and therefore its bundled
# MIT-licensed parson.c. No external JSON, SWIG, Python, or C++ dependency.
add_library(lmx_tinyspline STATIC
    "${_lmx_science_vendor}/tinyspline/src/tinyspline.c"
    "${_lmx_science_vendor}/tinyspline/src/parson.c")
add_library(LMX::tinyspline ALIAS lmx_tinyspline)
target_include_directories(lmx_tinyspline PUBLIC "${_lmx_science_vendor}/tinyspline/src")
lmx_c99_target(lmx_tinyspline)

# Upstream uses GNU zero-length trailing arrays. A C99 build view uses the
# standard flexible-array spelling, consistently for library and consumers.
file(COPY "${_lmx_science_vendor}/wavelib/src" "${_lmx_science_vendor}/wavelib/header"
    DESTINATION "${_lmx_science_generated}/wavelib")
file(READ "${_lmx_science_generated}/wavelib/header/wavelib.h" _lmx_wave_header)
string(REPLACE "params[0]" "params[]" _lmx_wave_header "${_lmx_wave_header}")
file(WRITE "${_lmx_science_generated}/wavelib/header/wavelib.h" "${_lmx_wave_header}")
set(_lmx_wavelib_sources)
foreach(_lmx_wave_module IN ITEMS conv cwt cwtmath hsfft real wavefilt wavefunc wavelib wtmath)
    list(APPEND _lmx_wavelib_sources "${_lmx_science_generated}/wavelib/src/${_lmx_wave_module}.c")
endforeach()
add_library(lmx_wavelib STATIC ${_lmx_wavelib_sources})
add_library(LMX::wavelib ALIAS lmx_wavelib)
target_include_directories(lmx_wavelib PUBLIC "${_lmx_science_generated}/wavelib/header")
target_compile_definitions(lmx_wavelib PRIVATE M_SQRT2=1.41421356237309504880168872420969808)
lmx_c99_target(lmx_wavelib)

add_library(lmx_cmpfit STATIC "${_lmx_science_vendor}/cmpfit/mpfit.c")
add_library(LMX::cmpfit ALIAS lmx_cmpfit)
target_include_directories(lmx_cmpfit PUBLIC "${_lmx_science_vendor}/cmpfit")
lmx_c99_target(lmx_cmpfit)

add_library(lmx_rng STATIC "${_lmx_science_root}/src/scientific_rng.c")
add_library(LMX::rng ALIAS lmx_rng)
target_include_directories(lmx_rng PUBLIC "${_lmx_science_root}/include"
    PRIVATE "${_lmx_science_vendor}/xoshiro")
lmx_c99_target(lmx_rng)

# Cephes: bessel + cprob + portable cmath implementations + misc/beta.c.
# Separate namespacing prevents accidental interposition of libc gamma, erf,
# complex functions, or globals. Original vendor tree is retained verbatim.
include("${CMAKE_CURRENT_LIST_DIR}/ScientificCephesSources.cmake")
include(TestBigEndian)
test_big_endian(_lmx_cephes_big_endian)
file(READ "${_lmx_science_vendor}/cephes/cprob/mconf.h" _lmx_cephes_mconf)
if(_lmx_cephes_big_endian)
    string(REPLACE "/* #undef FLOAT_WORDS_BIGENDIAN */" "#define FLOAT_WORDS_BIGENDIAN 1"
        _lmx_cephes_mconf "${_lmx_cephes_mconf}")
endif()
set(_lmx_cephes_guard "#include <float.h>\n#include <limits.h>\n#if FLT_RADIX != 2 || DBL_MANT_DIG != 53 || DBL_MAX_EXP != 1024 || USHRT_MAX != 65535\n#error Cephes needs IEEE binary64 double and 16-bit unsigned short\n#endif\n")
file(WRITE "${_lmx_science_generated}/cephes/mconf.h" "${_lmx_cephes_guard}\n${_lmx_cephes_mconf}")
set(_lmx_cephes_sources)
foreach(_lmx_cephes_source IN LISTS _lmx_cephes_rel_sources)
    get_filename_component(_lmx_cephes_basename "${_lmx_cephes_source}" NAME)
    configure_file("${_lmx_science_vendor}/cephes/${_lmx_cephes_source}"
        "${_lmx_science_generated}/cephes/${_lmx_cephes_basename}" COPYONLY)
    if(_lmx_cephes_basename MATCHES "^(unity|log|log10|log2|pow)\\.c$")
        file(READ "${_lmx_science_generated}/cephes/${_lmx_cephes_basename}" _lmx_cephes_unity)
        # This source intentionally shadows the global constants with macros.
        string(REPLACE "#define SQRTH" "#undef SQRTH\n#define SQRTH" _lmx_cephes_unity "${_lmx_cephes_unity}")
        string(REPLACE "#define SQRT2" "#undef SQRT2\n#define SQRT2" _lmx_cephes_unity "${_lmx_cephes_unity}")
        file(WRITE "${_lmx_science_generated}/cephes/${_lmx_cephes_basename}" "${_lmx_cephes_unity}")
    endif()
    list(APPEND _lmx_cephes_sources "${_lmx_science_generated}/cephes/${_lmx_cephes_basename}")
endforeach()
add_library(lmx_cephes STATIC ${_lmx_cephes_sources})
add_library(LMX::cephes ALIAS lmx_cephes)
target_include_directories(lmx_cephes PUBLIC "${_lmx_science_root}/include"
    PRIVATE "${_lmx_science_generated}/cephes")
foreach(_lmx_cephes_symbol IN LISTS _lmx_cephes_symbols)
    target_compile_definitions(lmx_cephes PRIVATE "${_lmx_cephes_symbol}=lmx_cephes_${_lmx_cephes_symbol}")
endforeach()
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(lmx_cephes PRIVATE -fno-strict-aliasing)
endif()
lmx_c99_target(lmx_cephes)

add_library(lmx_scientific INTERFACE)
add_library(LMX::scientific ALIAS lmx_scientific)
target_include_directories(lmx_scientific INTERFACE "${_lmx_science_root}/include")
target_link_libraries(lmx_scientific INTERFACE
    LMX::linmath LMX::kissfft LMX::tinyspline LMX::wavelib
    LMX::cephes LMX::cmpfit LMX::rng)
if(UNIX)
    foreach(_lmx_math_target IN ITEMS lmx_kissfft lmx_tinyspline lmx_wavelib lmx_cmpfit lmx_cephes)
        target_link_libraries(${_lmx_math_target} PUBLIC m)
    endforeach()
    target_link_libraries(lmx_linmath INTERFACE m)
endif()
lmx_c99_target(lmx_scientific)

if(BUILD_TESTING)
    foreach(_lmx_test IN ITEMS basic cephes cephes_link rng)
        add_executable(lmx_scientific_${_lmx_test}
            "${_lmx_science_root}/tests/scientific_${_lmx_test}.c")
        target_link_libraries(lmx_scientific_${_lmx_test} PRIVATE LMX::scientific)
        lmx_c99_target(lmx_scientific_${_lmx_test})
        add_test(NAME scientific.${_lmx_test} COMMAND lmx_scientific_${_lmx_test})
    endforeach()
    add_executable(lmx_cmpfit_upstream "${_lmx_science_vendor}/cmpfit/testmpfit.c")
    target_link_libraries(lmx_cmpfit_upstream PRIVATE LMX::cmpfit)
    lmx_c99_target(lmx_cmpfit_upstream)
    add_test(NAME scientific.cmpfit_upstream COMMAND lmx_cmpfit_upstream)
endif()
if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_scientific_example "${_lmx_science_root}/examples/scientific_pipeline.c")
    target_link_libraries(lmx_scientific_example PRIVATE LMX::scientific)
    lmx_c99_target(lmx_scientific_example)
endif()
