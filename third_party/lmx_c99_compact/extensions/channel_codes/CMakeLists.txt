cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
    message(FATAL_ERROR "The channel_codes group requires lmx_c99_target")
endif()

set(_correct_vendor "${LMX_VENDOR_DIR}/libcorrect")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CorrectCompat.cmake")
# Full scalar codec API. Avoid upstream's global -march=native / SSE probe,
# shared-library/test targets, and optional lookup of the unrelated libfec.
add_library(lmx_correct STATIC
    "${_correct_vendor}/src/convolutional/bit.c"
    "${_correct_vendor}/src/convolutional/metric.c"
    "${_correct_vendor}/src/convolutional/history_buffer.c"
    "${_correct_vendor}/src/convolutional/error_buffer.c"
    "${_correct_vendor}/src/convolutional/lookup.c"
    "${_correct_vendor}/src/convolutional/convolutional.c"
    "${_correct_vendor}/src/convolutional/encode.c"
    "${_correct_vendor}/src/convolutional/decode.c"
    "${_correct_vendor}/src/reed-solomon/polynomial.c"
    "${_correct_vendor}/src/reed-solomon/reed-solomon.c"
    "${_correct_rs_encode_view}"
    "${_correct_vendor}/src/reed-solomon/decode.c")
add_library(LMX::correct ALIAS lmx_correct)
target_include_directories(lmx_correct PUBLIC "${_correct_vendor}/include")
lmx_c99_target(lmx_correct)
set_target_properties(lmx_correct PROPERTIES POSITION_INDEPENDENT_CODE ON)

# BSD-licensed compatibility layer from this same upstream project. Its
# fec.h is a byte-for-byte copy, as in upstream's own shim build. This is
# only the documented partial libfec API, not the LGPL libfec library.
set(_correct_fec_include "${CMAKE_CURRENT_BINARY_DIR}/fec_include")
file(MAKE_DIRECTORY "${_correct_fec_include}")
configure_file("${_correct_vendor}/include/fec_shim.h"
               "${_correct_fec_include}/fec.h" COPYONLY)
add_library(lmx_correct_fec STATIC "${_correct_vendor}/src/fec_shim.c")
add_library(LMX::correct_fec ALIAS lmx_correct_fec)
target_include_directories(lmx_correct_fec PUBLIC "${_correct_fec_include}")
target_link_libraries(lmx_correct_fec PUBLIC LMX::correct)
lmx_c99_target(lmx_correct_fec)
set_target_properties(lmx_correct_fec PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_channel_codes INTERFACE)
add_library(LMX::channel_codes ALIAS lmx_channel_codes)
target_link_libraries(lmx_channel_codes INTERFACE LMX::correct LMX::correct_fec)

if(BUILD_TESTING)
    foreach(_test rs_errors convolutional_errors fec_compat)
        add_executable(lmx_channel_test_${_test}
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/${_test}.c")
        lmx_c99_target(lmx_channel_test_${_test})
        target_link_libraries(lmx_channel_test_${_test} PRIVATE LMX::channel_codes)
        add_test(NAME channel_codes.${_test} COMMAND lmx_channel_test_${_test})
        set_tests_properties(channel_codes.${_test} PROPERTIES TIMEOUT 30)
    endforeach()
endif()

if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_channel_codes_example
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/recover_block.c")
    lmx_c99_target(lmx_channel_codes_example)
    target_link_libraries(lmx_channel_codes_example PRIVATE LMX::correct)
endif()
