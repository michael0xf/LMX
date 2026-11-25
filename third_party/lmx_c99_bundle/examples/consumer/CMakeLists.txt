cmake_minimum_required(VERSION 3.20)
project(lmx_c99_consumer LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(BUILD_TESTING OFF CACHE BOOL "Dependency tests")
set(LMX_BUILD_EXAMPLES OFF CACHE BOOL "Dependency examples")
add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/../.." lmx-dependencies)
add_executable(my_lmx_math "${CMAKE_CURRENT_LIST_DIR}/../main.c")
target_link_libraries(my_lmx_math PRIVATE c99_gsl_lite)

# Network applications can link the exact same TLS build through:
# target_link_libraries(my_app PRIVATE LMX::civetweb LMX::curl)
# Or select the entire enabled collection:
# target_link_libraries(my_app PRIVATE LMX::all)
# The C targets can be used from a Qt project with LANGUAGES C CXX.
