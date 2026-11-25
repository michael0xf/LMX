cmake_minimum_required(VERSION 3.20)
project(lmx_numeric_integration_reference LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED YES)
set(CMAKE_C_EXTENSIONS NO)
set(LMX_COLLECTION "" CACHE PATH "Path to existing third_party/lmx_c99_compact")
if(NOT EXISTS "${LMX_COLLECTION}/cmake/Precision.cmake")
  message(FATAL_ERROR "Set LMX_COLLECTION to the supplied C99 collection")
endif()

# Reuse exactly the collection's precision targets/configuration. Do not load
# its unrelated database/graphics targets for this standalone reference check.
set(BUILD_TESTING OFF)
set(LMX_BUILD_EXAMPLES OFF)
function(lmx_c99_target target)
  get_target_property(kind ${target} TYPE)
  if(kind STREQUAL "INTERFACE_LIBRARY")
    target_compile_features(${target} INTERFACE c_std_99)
  else()
    set_target_properties(${target} PROPERTIES
      C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
      target_compile_options(${target} PRIVATE -pedantic-errors)
    endif()
  endif()
endfunction()
include("${LMX_COLLECTION}/cmake/Precision.cmake")

set(LMX_NUMERIC_EXTRA "${LMX_COLLECTION}/extensions/numeric_extra" CACHE PATH
    "Path to the supplied additional numeric backends")
if(NOT EXISTS "${LMX_NUMERIC_EXTRA}/CMakeLists.txt")
  message(FATAL_ERROR "Set LMX_NUMERIC_EXTRA to the supplied numeric_extra module")
endif()
add_subdirectory("${LMX_NUMERIC_EXTRA}" numeric_extra)

# Only these two upstream files are needed for decNumber text conversion.
# No DECNUMDIGITS ABI setting is leaked to the rest of the project.
add_library(lmx_ref_decnumber STATIC
  "${LMX_COLLECTION}/vendor/decnumber/decNumber.c"
  "${LMX_COLLECTION}/vendor/decnumber/decContext.c")
target_include_directories(lmx_ref_decnumber PUBLIC "${LMX_COLLECTION}/vendor/decnumber")
lmx_c99_target(lmx_ref_decnumber)

add_library(lmx_numeric_reference STATIC
  primitive_runtime.c numeric_provider.c real_provider.c conversion_bridge.c)
target_link_libraries(lmx_numeric_reference PUBLIC LMX::precision LMX::real lmx_ref_decnumber)
target_include_directories(lmx_numeric_reference PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
if(UNIX)
  target_link_libraries(lmx_numeric_reference PUBLIC m)
endif()
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(lmx_numeric_reference PRIVATE -Wall -Wextra -Werror -pedantic-errors)
endif()
add_executable(lmx_numeric_reference_check reference_check.c)
target_link_libraries(lmx_numeric_reference_check PRIVATE lmx_numeric_reference)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(lmx_numeric_reference_check PRIVATE -Wall -Wextra -Werror -pedantic-errors)
endif()
enable_testing()
add_test(NAME numeric_reference COMMAND lmx_numeric_reference_check)
