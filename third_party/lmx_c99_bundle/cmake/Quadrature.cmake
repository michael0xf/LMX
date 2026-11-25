# Offline C99/POSIX quadrature collection. Original sources stay in vendor/.
include_guard(GLOBAL)
set(_lmx_quad_root "${CMAKE_CURRENT_LIST_DIR}/..")
set(_lmx_quad_vendor "${_lmx_quad_root}/vendor")
set(_lmx_quad_gen "${CMAKE_CURRENT_BINARY_DIR}/generated/quadrature")
file(MAKE_DIRECTORY "${_lmx_quad_gen}/cquadpack" "${_lmx_quad_gen}/stroud_rule"
    "${_lmx_quad_gen}/sparse_grid_hw")
include("${CMAKE_CURRENT_LIST_DIR}/QuadratureSymbols.cmake")

# CQUADPACK 1.1.1 has an implementation-only header with min/max and constants.
# Keep it private. The public namespaced declarations are lmx_quadpack.h.
file(READ "${_lmx_quad_vendor}/cquadpack/include/cquadpack.h" _lmx_cq_header)
string(REPLACE "#define Pi      M_PI" "#define Pi 3.141592653589793238462643383279502884"
    _lmx_cq_header "${_lmx_cq_header}")
file(WRITE "${_lmx_quad_gen}/cquadpack/cquadpack.h" "${_lmx_cq_header}")
file(WRITE "${_lmx_quad_gen}/cquadpack/cquadpack_export.h"
    "#ifndef LMX_CQUADPACK_EXPORT_H\n#define LMX_CQUADPACK_EXPORT_H\n#define CQUADPACK_EXPORT\n#endif\n")
set(_lmx_cq_sources)
foreach(_lmx_module IN ITEMS dqag dqage dqagi dqagp dqags dqawc dqawce dqawf
        dqawfe dqawo dqaws dqawse dqc25c dqc25o dqc25s dqcheb dqext dqfour
        dqk15 dqk15i dqk15w dqk21 dqk31 dqk41 dqk51 dqk61 dqmomo dqng dqsort dqwgt)
    file(READ "${_lmx_quad_vendor}/cquadpack/src/${_lmx_module}.c" _lmx_cq_source)
    # malloc/free are ISO C stdlib interfaces, not a dependency on malloc.h.
    string(REPLACE "#include <malloc.h>" "#include <stdlib.h>"
        _lmx_cq_source "${_lmx_cq_source}")
    file(WRITE "${_lmx_quad_gen}/cquadpack/${_lmx_module}.c" "${_lmx_cq_source}")
    list(APPEND _lmx_cq_sources "${_lmx_quad_gen}/cquadpack/${_lmx_module}.c")
endforeach()
add_library(lmx_quadpack STATIC ${_lmx_cq_sources})
add_library(LMX::quadpack ALIAS lmx_quadpack)
target_include_directories(lmx_quadpack PUBLIC "${_lmx_quad_root}/include"
    PRIVATE "${_lmx_quad_gen}/cquadpack")
foreach(_lmx_symbol IN LISTS _lmx_quad_cquadpack_symbols)
    target_compile_definitions(lmx_quadpack PRIVATE "${_lmx_symbol}=lmx_quadpack_${_lmx_symbol}")
endforeach()
lmx_c99_target(lmx_quadpack)

# Separate namespaces are required: these libraries intentionally contain
# independent copies of helpers such as r8_uniform_01 and i4_max.
foreach(_lmx_module IN ITEMS stroud_rule sparse_grid_hw)
    if(_lmx_module STREQUAL "stroud_rule")
        set(_lmx_prefix lmx_stroud_)
        set(_lmx_target lmx_stroud)
        set(_lmx_alias LMX::stroud)
    else()
        set(_lmx_prefix lmx_sparse_)
        set(_lmx_target lmx_sparse_grid_hw)
        set(_lmx_alias LMX::sparse_grid_hw)
    endif()
    file(READ "${_lmx_quad_vendor}/${_lmx_module}/${_lmx_module}.c" _lmx_source)
    if(_lmx_module STREQUAL "stroud_rule")
        # CN:3-1 and the degree-3 Xiu variant must integrate every x_i^2
        # to volume/3. Upstream's last coordinate for odd n>1 is sqrt(2/3),
        # giving twice that moment. Use +/-sqrt(1/3), as also used for n=1.
        string(REGEX MATCHALL "x\\[i\\+j\\*n\\] = sqrt \\( 2\\.0 \\) \\* r8_mop \\( j \\+ 1 \\) / sqrt \\( 3\\.0 \\)"
            _lmx_stroud_scale_matches "${_lmx_source}")
        list(LENGTH _lmx_stroud_scale_matches _lmx_stroud_scale_count)
        if(NOT _lmx_stroud_scale_count EQUAL 2)
            message(FATAL_ERROR "Review Stroud odd-dimension moment correction after upstream changes")
        endif()
        string(REPLACE "x[i+j*n] = sqrt ( 2.0 ) * r8_mop ( j + 1 ) / sqrt ( 3.0 );"
            "x[i+j*n] = r8_mop ( j + 1 ) / sqrt ( 3.0 ); /* LMX: correct second moment */"
            _lmx_source "${_lmx_source}")
    endif()
    file(WRITE "${_lmx_quad_gen}/${_lmx_module}/${_lmx_module}.c" "${_lmx_source}")
    file(READ "${_lmx_quad_vendor}/${_lmx_module}/${_lmx_module}.h" _lmx_header)
    string(REPLACE ";;" ";" _lmx_header "${_lmx_header}")
    file(WRITE "${_lmx_quad_gen}/${_lmx_module}/${_lmx_module}.h" "${_lmx_header}")
    add_library(${_lmx_target} STATIC "${_lmx_quad_gen}/${_lmx_module}/${_lmx_module}.c")
    add_library(${_lmx_alias} ALIAS ${_lmx_target})
    target_include_directories(${_lmx_target} PUBLIC "${_lmx_quad_root}/include"
        PRIVATE "${_lmx_quad_gen}/${_lmx_module}")
    foreach(_lmx_symbol IN LISTS _lmx_quad_${_lmx_module}_symbols)
        target_compile_definitions(${_lmx_target} PRIVATE "${_lmx_symbol}=${_lmx_prefix}${_lmx_symbol}")
    endforeach()
    lmx_c99_target(${_lmx_target})
endforeach()

if(NOT UNIX)
    message(FATAL_ERROR "This Sobol C99 profile uses POSIX threads for its upstream sequence caches")
endif()
find_package(Threads REQUIRED)
add_library(lmx_sobol STATIC "${_lmx_quad_root}/src/quadrature/sobol_c99.c")
add_library(LMX::sobol ALIAS lmx_sobol)
target_include_directories(lmx_sobol PUBLIC "${_lmx_quad_root}/include")
target_link_libraries(lmx_sobol PUBLIC Threads::Threads)
lmx_c99_target(lmx_sobol)

foreach(_lmx_target IN ITEMS lmx_quadpack lmx_stroud lmx_sparse_grid_hw lmx_sobol)
    target_link_libraries(${_lmx_target} PUBLIC m)
endforeach()

add_library(lmx_quadrature_api STATIC "${_lmx_quad_root}/src/quadrature/quadrature_api.c")
target_include_directories(lmx_quadrature_api PUBLIC "${_lmx_quad_root}/include")
target_link_libraries(lmx_quadrature_api PUBLIC LMX::quadpack LMX::stroud
    LMX::sparse_grid_hw LMX::sobol)
lmx_c99_target(lmx_quadrature_api)
add_library(c99_quad_lite INTERFACE)
add_library(LMX::quadrature ALIAS c99_quad_lite)
target_link_libraries(c99_quad_lite INTERFACE lmx_quadrature_api)
lmx_c99_target(c99_quad_lite)

if(BUILD_TESTING)
    foreach(_lmx_test IN ITEMS finite_infinite multidimensional sobol stroud_moments)
        add_executable(lmx_test_quadrature_${_lmx_test}
            "${_lmx_quad_root}/tests/quadrature_${_lmx_test}.c")
        target_link_libraries(lmx_test_quadrature_${_lmx_test} PRIVATE LMX::quadrature)
        lmx_c99_target(lmx_test_quadrature_${_lmx_test})
        add_test(NAME quadrature.${_lmx_test} COMMAND lmx_test_quadrature_${_lmx_test})
        set_tests_properties(quadrature.${_lmx_test} PROPERTIES TIMEOUT 60)
    endforeach()
endif()
if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_quadrature_example "${_lmx_quad_root}/examples/quadrature/main.c")
    target_link_libraries(lmx_quadrature_example PRIVATE LMX::quadrature)
    lmx_c99_target(lmx_quadrature_example)
    if(BUILD_TESTING)
        add_test(NAME quadrature.example COMMAND lmx_quadrature_example)
    endif()
endif()
