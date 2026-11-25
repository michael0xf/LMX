cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
    message(FATAL_ERROR "The nnom group requires the collection lmx_c99_target helper")
endif()

# Both variants use the same complete scalar C implementation. The default is
# libc allocation; the optional upstream arena is one process-wide bump pool.
option(LMX_NNOM_STATIC_MEMORY "Use NNoM's caller-owned global static arena" OFF)
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/NNoMView.cmake")
set(_nnom_view "${CMAKE_CURRENT_BINARY_DIR}/generated/nnom")
lmx_nnom_view("${LMX_VENDOR_DIR}/nnom" "${_nnom_view}")

set(_nnom_sources
    "${_nnom_view}/src/backends/nnom_local.c"
    "${_nnom_view}/src/backends/nnom_local_q15.c"
    "${_nnom_view}/src/core/nnom.c"
    "${_nnom_view}/src/core/nnom_layers.c"
    "${_nnom_view}/src/core/nnom_tensor.c"
    "${_nnom_view}/src/core/nnom_utils.c"
    "${_nnom_view}/src/layers/nnom_activation.c"
    "${_nnom_view}/src/layers/nnom_avgpool.c"
    "${_nnom_view}/src/layers/nnom_baselayer.c"
    "${_nnom_view}/src/layers/nnom_concat.c"
    "${_nnom_view}/src/layers/nnom_conv2d.c"
    "${_nnom_view}/src/layers/nnom_conv2d_trans.c"
    "${_nnom_view}/src/layers/nnom_cropping.c"
    "${_nnom_view}/src/layers/nnom_dense.c"
    "${_nnom_view}/src/layers/nnom_dw_conv2d.c"
    "${_nnom_view}/src/layers/nnom_flatten.c"
    "${_nnom_view}/src/layers/nnom_global_pool.c"
    "${_nnom_view}/src/layers/nnom_gru_cell.c"
    "${_nnom_view}/src/layers/nnom_input.c"
    "${_nnom_view}/src/layers/nnom_lambda.c"
    "${_nnom_view}/src/layers/nnom_lstm_cell.c"
    "${_nnom_view}/src/layers/nnom_matrix.c"
    "${_nnom_view}/src/layers/nnom_maxpool.c"
    "${_nnom_view}/src/layers/nnom_output.c"
    "${_nnom_view}/src/layers/nnom_reshape.c"
    "${_nnom_view}/src/layers/nnom_rnn.c"
    "${_nnom_view}/src/layers/nnom_simple_cell.c"
    "${_nnom_view}/src/layers/nnom_softmax.c"
    "${_nnom_view}/src/layers/nnom_sumpool.c"
    "${_nnom_view}/src/layers/nnom_upsample.c"
    "${_nnom_view}/src/layers/nnom_zero_padding.c"
 )
add_library(lmx_nnom STATIC ${_nnom_sources})
add_library(LMX::nnom ALIAS lmx_nnom)
target_include_directories(lmx_nnom PUBLIC
    "${_nnom_view}/inc" "${_nnom_view}/inc/layers" "${_nnom_view}/port")
lmx_c99_target(lmx_nnom)
if(LMX_NNOM_STATIC_MEMORY)
    target_compile_definitions(lmx_nnom PUBLIC NNOM_USING_STATIC_MEMORY)
endif()
if(UNIX)
    target_link_libraries(lmx_nnom PUBLIC m)
endif()

add_library(lmx_mlp_nnom INTERFACE)
add_library(LMX::mlp_nnom ALIAS lmx_mlp_nnom)
target_link_libraries(lmx_mlp_nnom INTERFACE LMX::nnom)

if(BUILD_TESTING)
    foreach(_case IN ITEMS dense_reference model_lifetime conv_reference)
        add_executable(lmx_nnom_${_case} "tests/${_case}.c")
        lmx_c99_target(lmx_nnom_${_case})
        target_link_libraries(lmx_nnom_${_case} PRIVATE LMX::nnom)
        add_test(NAME "nnom.${_case}" COMMAND lmx_nnom_${_case})
    endforeach()
    add_test(NAME nnom.dense_negative_bias COMMAND lmx_nnom_dense_reference negative)
    # Linux validation instrumentation only; the library does not use linker
    # wrapping or require it on consumer platforms. Account for compiler
    # malloc+memset -> calloc folding as well as explicit malloc/free.
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND
       CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" AND NOT LMX_NNOM_STATIC_MEMORY)
        foreach(_case IN ITEMS model_lifetime conv_reference)
            target_sources(lmx_nnom_${_case} PRIVATE tests/allocation_tracking.c)
            target_compile_definitions(lmx_nnom_${_case} PRIVATE LMX_NNOM_TRACK_ALLOCATIONS)
            target_link_options(lmx_nnom_${_case} PRIVATE
                "-Wl,--wrap=malloc" "-Wl,--wrap=calloc" "-Wl,--wrap=free")
        endforeach()
    endif()
endif()

if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_nnom_example examples/hand_written_dense.c)
    lmx_c99_target(lmx_nnom_example)
    target_link_libraries(lmx_nnom_example PRIVATE LMX::nnom)
endif()
