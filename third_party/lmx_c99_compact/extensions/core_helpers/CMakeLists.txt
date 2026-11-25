cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
    message(FATAL_ERROR "The core_helpers group requires lmx_c99_target")
endif()
set(_helpers_vendor "${LMX_VENDOR_DIR}")

# Include the complete float/double C conversion library by default.
# The fixed/scientific routines are a separate archive object, which an
# ordinary static link extracts when referenced. generic_128 is not C99.
add_library(lmx_ryu STATIC
    "${_helpers_vendor}/ryu/ryu/f2s.c"
    "${_helpers_vendor}/ryu/ryu/d2s.c"
    "${_helpers_vendor}/ryu/ryu/d2fixed.c")
add_library(LMX::ryu ALIAS lmx_ryu)
target_include_directories(lmx_ryu PUBLIC "${_helpers_vendor}/ryu")
target_compile_definitions(lmx_ryu PRIVATE RYU_ONLY_64_BIT_OPS=1 RYU_OPTIMIZE_SIZE=1)
lmx_c99_target(lmx_ryu)
set_target_properties(lmx_ryu PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_tlsf STATIC "${_helpers_vendor}/tlsf/tlsf.c")
add_library(LMX::tlsf ALIAS lmx_tlsf)
target_include_directories(lmx_tlsf PUBLIC "${_helpers_vendor}/tlsf")
lmx_c99_target(lmx_tlsf)
set_target_properties(lmx_tlsf PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_core_helpers INTERFACE)
add_library(LMX::core_helpers ALIAS lmx_core_helpers)
target_link_libraries(lmx_core_helpers INTERFACE LMX::ryu LMX::tlsf)

if(BUILD_TESTING)
    add_executable(lmx_core_test_ryu "${CMAKE_CURRENT_SOURCE_DIR}/tests/ryu_roundtrip.c")
    lmx_c99_target(lmx_core_test_ryu)
    target_link_libraries(lmx_core_test_ryu PRIVATE LMX::ryu)
    if(UNIX)
        target_link_libraries(lmx_core_test_ryu PRIVATE m)
    endif()
    add_test(NAME core_helpers.ryu_roundtrip COMMAND lmx_core_test_ryu)
    set_tests_properties(core_helpers.ryu_roundtrip PROPERTIES TIMEOUT 15)

    add_executable(lmx_core_test_tlsf "${CMAKE_CURRENT_SOURCE_DIR}/tests/tlsf_pool.c")
    lmx_c99_target(lmx_core_test_tlsf)
    target_link_libraries(lmx_core_test_tlsf PRIVATE LMX::core_helpers)
    add_test(NAME core_helpers.tlsf_pool COMMAND lmx_core_test_tlsf)
    set_tests_properties(core_helpers.tlsf_pool PROPERTIES TIMEOUT 15)
endif()

if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_core_helpers_example "${CMAKE_CURRENT_SOURCE_DIR}/examples/format_in_pool.c")
    lmx_c99_target(lmx_core_helpers_example)
    target_link_libraries(lmx_core_helpers_example PRIVATE LMX::core_helpers)
endif()
