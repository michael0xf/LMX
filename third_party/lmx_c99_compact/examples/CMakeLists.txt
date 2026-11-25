cmake_minimum_required(VERSION 3.20)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(LMX_Usage_Examples LANGUAGES C)
endif()
set(LMX_EXAMPLE_COLLECTION_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
set(LMX_EXAMPLE_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
if(NOT TARGET LMX::all)
  add_subdirectory("${LMX_EXAMPLE_COLLECTION_ROOT}" lmx_collection)
endif()
# These small programs use the exact targets supplied by the collection.
# Upstream reference examples have their individual prerequisites in the index.
include("${CMAKE_CURRENT_LIST_DIR}/collection/targets.cmake")
enable_testing()
add_subdirectory(checks)
