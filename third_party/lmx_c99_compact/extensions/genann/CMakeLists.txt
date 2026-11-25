cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
    message(FATAL_ERROR "The genann group requires the collection lmx_c99_target helper")
endif()

# Compile the complete unmodified stable release. No configure-time download.
add_library(lmx_genann STATIC "${LMX_VENDOR_DIR}/genann/genann.c")
add_library(LMX::genann ALIAS lmx_genann)
target_include_directories(lmx_genann PUBLIC "${LMX_VENDOR_DIR}/genann")
lmx_c99_target(lmx_genann)
if(UNIX)
    target_link_libraries(lmx_genann PUBLIC m)
endif()

add_library(lmx_mlp_genann INTERFACE)
add_library(LMX::mlp_genann ALIAS lmx_mlp_genann)
target_link_libraries(lmx_mlp_genann INTERFACE LMX::genann)

if(BUILD_TESTING)
    foreach(_case IN ITEMS forward training serialization)
        add_executable(lmx_genann_${_case} "tests/${_case}.c")
        lmx_c99_target(lmx_genann_${_case})
        target_link_libraries(lmx_genann_${_case} PRIVATE LMX::genann)
        add_test(NAME "genann.${_case}" COMMAND lmx_genann_${_case})
    endforeach()
endif()

if(LMX_BUILD_EXAMPLES)
    add_executable(lmx_genann_example examples/linear_regression.c)
    lmx_c99_target(lmx_genann_example)
    target_link_libraries(lmx_genann_example PRIVATE LMX::genann)

    # Keep all four upstream examples usable. They are not CTest convergence
    # gates: some seed rand() from time(), and example2 has no iteration limit.
    foreach(_example RANGE 1 4)
        add_executable(lmx_genann_upstream_example${_example}
            "vendor/genann/example${_example}.c")
        lmx_c99_target(lmx_genann_upstream_example${_example})
        target_link_libraries(lmx_genann_upstream_example${_example} PRIVATE LMX::genann)
    endforeach()
endif()
