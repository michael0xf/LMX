cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
  message(FATAL_ERROR "The text_paths group requires the base lmx_c99_target helper")
endif()
set(_text_paths_vendor "${LMX_VENDOR_DIR}")

# Upstream CMake asks for C11, but its original implementation is C99-clean.
# Retain that full build configuration and build the same one C source here.
add_library(lmx_cwalk STATIC "${_text_paths_vendor}/cwalk/src/cwalk.c")
add_library(LMX::cwalk ALIAS lmx_cwalk)
target_include_directories(lmx_cwalk PUBLIC "${_text_paths_vendor}/cwalk/include")
lmx_c99_target(lmx_cwalk)
set_target_properties(lmx_cwalk PROPERTIES POSITION_INDEPENDENT_CODE ON)

# The implementation is in utf8.h. Consumers compile it directly; no dummy .a.
add_library(lmx_utf8_headers INTERFACE)
add_library(LMX::utf8_headers ALIAS lmx_utf8_headers)
target_include_directories(lmx_utf8_headers INTERFACE "${_text_paths_vendor}/utf8")
lmx_c99_target(lmx_utf8_headers)

add_library(lmx_text_paths INTERFACE)
add_library(LMX::text_paths ALIAS lmx_text_paths)
target_link_libraries(lmx_text_paths INTERFACE LMX::cwalk LMX::utf8_headers)

if(BUILD_TESTING)
  add_executable(lmx_text_paths_cwalk_test tests/cwalk_test.c)
  target_link_libraries(lmx_text_paths_cwalk_test PRIVATE LMX::cwalk)
  lmx_c99_target(lmx_text_paths_cwalk_test)
  add_test(NAME text_paths.cwalk COMMAND lmx_text_paths_cwalk_test)

  add_executable(lmx_text_paths_utf8_test tests/utf8_test.c)
  target_link_libraries(lmx_text_paths_utf8_test PRIVATE LMX::utf8_headers)
  lmx_c99_target(lmx_text_paths_utf8_test)
  add_test(NAME text_paths.utf8 COMMAND lmx_text_paths_utf8_test)

  add_executable(lmx_text_paths_utf8_multitu_test
    tests/utf8_multitu_main.c tests/utf8_multitu_helper.c)
  target_link_libraries(lmx_text_paths_utf8_multitu_test PRIVATE LMX::utf8_headers)
  lmx_c99_target(lmx_text_paths_utf8_multitu_test)
  add_test(NAME text_paths.utf8_multitu COMMAND lmx_text_paths_utf8_multitu_test)
endif()

if(LMX_BUILD_EXAMPLES)
  add_executable(lmx_text_paths_example examples/path_utf8.c)
  target_link_libraries(lmx_text_paths_example PRIVATE LMX::text_paths)
  lmx_c99_target(lmx_text_paths_example)
  if(BUILD_TESTING)
    add_test(NAME text_paths.example COMMAND lmx_text_paths_example)
  endif()
endif()
