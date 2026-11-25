cmake_minimum_required(VERSION 3.20)
project(lmx_compact_usage_checks C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
get_filename_component(_lmx_default_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(LMX_EXAMPLE_COLLECTION_ROOT "${_lmx_default_root}" CACHE PATH "Path to the compact LMX collection")
set(LMX_CHECK_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/usage-checks" CACHE PATH "Check executables, isolated working directories and lists")
# This driver builds only the selected checks, not the original complete tests
# or the separate usage-demo application. Production sources remain untouched.
set(BUILD_TESTING OFF)
set(LMX_BUILD_EXAMPLES OFF)
if(NOT TARGET LMX::all)
    add_subdirectory("${LMX_EXAMPLE_COLLECTION_ROOT}" "${CMAKE_CURRENT_BINARY_DIR}/collection")
endif()
enable_testing()
if(NOT TARGET Threads::Threads)
  # The collection may have found Threads in its own child directory. This
  # harness also uses that system target directly, so resolve it in this scope.
  find_package(Threads REQUIRED)
endif()
include("${CMAKE_CURRENT_LIST_DIR}/targets.cmake")
