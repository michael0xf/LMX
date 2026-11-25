cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
    message(FATAL_ERROR "The orbits group requires the collection lmx_c99_target helper")
endif()

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/SGP4View.cmake")
set(_sgp4_view "${CMAKE_CURRENT_BINARY_DIR}/generated/sgp4")
lmx_sgp4_view("${LMX_VENDOR_DIR}/sgp4/src/c" "${_sgp4_view}")

add_library(lmx_sgp4 STATIC "${_sgp4_view}/SGP4.c" "${_sgp4_view}/TLE.c")
add_library(LMX::sgp4 ALIAS lmx_sgp4)
target_include_directories(lmx_sgp4 PUBLIC "${_sgp4_view}")
lmx_c99_target(lmx_sgp4)
if(UNIX)
    target_link_libraries(lmx_sgp4 PUBLIC m)
endif()

add_library(lmx_orbits INTERFACE)
add_library(LMX::orbits ALIAS lmx_orbits)
target_link_libraries(lmx_orbits INTERFACE LMX::sgp4)

if(BUILD_TESTING)
    add_executable(lmx_sgp4_reference tests/reference.c)
    lmx_c99_target(lmx_sgp4_reference)
    target_link_libraries(lmx_sgp4_reference PRIVATE LMX::sgp4)
    add_test(NAME orbits.vallado_reference COMMAND lmx_sgp4_reference
        "${LMX_VENDOR_DIR}/sgp4/data/SGP4-VER.TLE"
        "${LMX_VENDOR_DIR}/sgp4/data/tcppver.out")

    add_executable(lmx_sgp4_time tests/time_and_api.c)
    lmx_c99_target(lmx_sgp4_time)
    target_link_libraries(lmx_sgp4_time PRIVATE LMX::sgp4)
    add_test(NAME orbits.time_and_api COMMAND lmx_sgp4_time)
endif()

if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_sgp4_example examples/tle_teme.c)
    lmx_c99_target(lmx_sgp4_example)
    target_link_libraries(lmx_sgp4_example PRIVATE LMX::sgp4)
endif()
