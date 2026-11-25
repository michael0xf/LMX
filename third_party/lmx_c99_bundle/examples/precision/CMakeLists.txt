cmake_minimum_required(VERSION 3.20)
project(lmx_precision_example C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Standalone example: builds just LibTomMath and MPDecimal from this bundle.
# No FetchContent/network access, installed GMP, or installed MPFR is needed.
function(lmx_c99_target target)
    get_target_property(_type ${target} TYPE)
    if(_type STREQUAL "INTERFACE_LIBRARY")
        target_compile_features(${target} INTERFACE c_std_99)
    else()
        set_target_properties(${target} PROPERTIES
            C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
        if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
            target_compile_options(${target} PRIVATE -pedantic-errors)
        endif()
    endif()
endfunction()

set(LMX_BUILD_EXAMPLES ON)
include(CTest)
include("${CMAKE_CURRENT_LIST_DIR}/../../cmake/Precision.cmake")
