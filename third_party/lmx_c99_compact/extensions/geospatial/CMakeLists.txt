cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
  message(FATAL_ERROR "The geospatial group requires the base lmx_c99_target helper")
endif()
find_package(Python3 3.8 REQUIRED COMPONENTS Interpreter)
set(_geo_vendor "${LMX_VENDOR_DIR}")

# GeographicLib's native CMake always adds tools/tests. This target uses the
# identical single C implementation while preserving all original settings.
add_library(lmx_geodesic STATIC "${_geo_vendor}/geodesic/src/geodesic.c")
target_include_directories(lmx_geodesic PUBLIC "${_geo_vendor}/geodesic/src")
add_library(LMX::geodesic ALIAS lmx_geodesic)
lmx_c99_target(lmx_geodesic)
set_target_properties(lmx_geodesic PROPERTIES POSITION_INDEPENDENT_CODE ON)
if(UNIX)
  target_link_libraries(lmx_geodesic PUBLIC m)
endif()

# H3 already has a C-only C99 CMake build. Scope its generic option names so
# unrelated groups keep their own settings; do not compile bundled app cJSON.
function(_lmx_geospatial_h3)
  foreach(_option BUILD_SHARED_LIBS BUILD_TESTING BUILD_BENCHMARKS
      ENABLE_COUNTRY_BENCHMARKS BUILD_FUZZERS BUILD_FILTERS BUILD_GENERATORS
      ENABLE_COVERAGE ENABLE_LIBFUZZER ENABLE_DOCS ENABLE_FORMAT
      ENABLE_LINTING WARNINGS_AS_ERRORS)
    set(${_option} OFF)
  endforeach()
  set(H3_PREFIX "")
  set(H3_ALLOC_PREFIX "")
  set(H3_SKIP_FLT_EVAL_METHOD_CHECK OFF)
  add_subdirectory("${_geo_vendor}/h3" "${CMAKE_CURRENT_BINARY_DIR}/h3")
  foreach(_h3_file h3Index.c area.c)
    execute_process(COMMAND "${Python3_EXECUTABLE}"
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/h3_c99_view.py"
      "${_geo_vendor}/h3/src/h3lib/lib/${_h3_file}"
      "${CMAKE_CURRENT_BINARY_DIR}/generated/${_h3_file}"
      RESULT_VARIABLE _h3_view_result)
    if(NOT _h3_view_result EQUAL 0)
      message(FATAL_ERROR "Could not generate pinned H3 C99 source view")
    endif()
  endforeach()
  set_source_files_properties("${_geo_vendor}/h3/src/h3lib/lib/h3Assert.c"
    "${_geo_vendor}/h3/src/h3lib/lib/h3Index.c"
    "${_geo_vendor}/h3/src/h3lib/lib/area.c"
    DIRECTORY "${_geo_vendor}/h3" PROPERTIES HEADER_FILE_ONLY TRUE)
  target_sources(h3 PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/adapters/h3_assert_c99.c"
    "${CMAKE_CURRENT_BINARY_DIR}/generated/h3Index.c"
    "${CMAKE_CURRENT_BINARY_DIR}/generated/area.c")
  lmx_c99_target(h3)
  set_target_properties(h3 PROPERTIES POSITION_INDEPENDENT_CODE ON)
endfunction()
_lmx_geospatial_h3()
add_library(LMX::h3 ALIAS h3)

# Rtree's upstream no-atomics mode is appropriate for a serialized owner.
# Naming one private union is a mechanical C99 source view, not an algorithm
# rewrite. Original source and public header remain unchanged.
set(_rtree_view "${CMAKE_CURRENT_BINARY_DIR}/generated/rtree.c")
execute_process(COMMAND "${Python3_EXECUTABLE}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/rtree_c99_view.py"
  "${_geo_vendor}/rtree/rtree.c" "${_rtree_view}"
  RESULT_VARIABLE _rtree_result)
if(NOT _rtree_result EQUAL 0)
  message(FATAL_ERROR "Could not generate the pinned rtree C99 view")
endif()
add_library(lmx_rtree STATIC "${_rtree_view}")
add_library(LMX::rtree ALIAS lmx_rtree)
target_include_directories(lmx_rtree PUBLIC "${_geo_vendor}/rtree")
target_compile_definitions(lmx_rtree PRIVATE RTREE_NOATOMICS=1)
lmx_c99_target(lmx_rtree)
set_target_properties(lmx_rtree PROPERTIES POSITION_INDEPENDENT_CODE ON)
if(UNIX)
  target_link_libraries(lmx_rtree PUBLIC m)
endif()

# Shapelib's five library sources are C. Its root project also enables CXX for
# tests/contributed utilities, so declare exactly the library source list here.
add_library(lmx_shapelib STATIC
  "${_geo_vendor}/shapelib/shpopen.c" "${_geo_vendor}/shapelib/dbfopen.c"
  "${_geo_vendor}/shapelib/safileio.c" "${_geo_vendor}/shapelib/shptree.c"
  "${_geo_vendor}/shapelib/sbnsearch.c")
add_library(LMX::shapelib ALIAS lmx_shapelib)
target_include_directories(lmx_shapelib PUBLIC "${_geo_vendor}/shapelib")
lmx_c99_target(lmx_shapelib)
set_target_properties(lmx_shapelib PROPERTIES POSITION_INDEPENDENT_CODE ON)
if(UNIX)
  target_link_libraries(lmx_shapelib PUBLIC m)
endif()

set(_minmea_view "${CMAKE_CURRENT_BINARY_DIR}/generated/minmea")
execute_process(COMMAND "${Python3_EXECUTABLE}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/minmea_c99_view.py"
  "${_geo_vendor}/minmea" "${_minmea_view}"
  RESULT_VARIABLE _minmea_result)
if(NOT _minmea_result EQUAL 0)
  message(FATAL_ERROR "Could not generate the pinned minmea C99 view")
endif()
add_library(lmx_minmea STATIC "${_minmea_view}/minmea.c")
add_library(LMX::minmea ALIAS lmx_minmea)
target_include_directories(lmx_minmea PUBLIC "${_minmea_view}")
if(WIN32)
  # The retained upstream Windows shim supplies the public timespec type where
  # the CRT lacks it. Do not replace the C99 inline keyword or leak timegm as a
  # public macro; map only this implementation to the CRT's UTC conversion.
  include(CheckStructHasMember)
  check_struct_has_member("struct timespec" tv_sec "time.h"
    LMX_MINMEA_HAVE_STRUCT_TIMESPEC)
  file(READ "${_geo_vendor}/minmea/compat/minmea_compat_windows.h" _minmea_windows)
  string(REPLACE "#if defined(_MSC_VER)" "#if defined(_WIN32)"
    _minmea_windows "${_minmea_windows}")
  string(REPLACE "HAVE_STRUCT_TIMESPEC" "LMX_MINMEA_HAVE_STRUCT_TIMESPEC"
    _minmea_windows "${_minmea_windows}")
  string(REPLACE "#define inline __inline\n" ""
    _minmea_windows "${_minmea_windows}")
  string(REPLACE "#define timegm _mkgmtime\n" ""
    _minmea_windows "${_minmea_windows}")
  file(WRITE "${_minmea_view}/minmea_compat.h" "${_minmea_windows}")
  target_compile_definitions(lmx_minmea PUBLIC MINMEA_INCLUDE_COMPAT)
  if(LMX_MINMEA_HAVE_STRUCT_TIMESPEC)
    target_compile_definitions(lmx_minmea PUBLIC LMX_MINMEA_HAVE_STRUCT_TIMESPEC=1)
  endif()
  target_compile_definitions(lmx_minmea PRIVATE timegm=_mkgmtime)
else()
  target_compile_definitions(lmx_minmea PUBLIC _POSIX_C_SOURCE=200809L)
  target_compile_definitions(lmx_minmea PRIVATE _DEFAULT_SOURCE=1 _DARWIN_C_SOURCE=1)
endif()
lmx_c99_target(lmx_minmea)
set_target_properties(lmx_minmea PROPERTIES POSITION_INDEPENDENT_CODE ON)
if(UNIX)
  target_link_libraries(lmx_minmea PUBLIC m)
endif()

add_library(lmx_geospatial INTERFACE)
add_library(LMX::geospatial ALIAS lmx_geospatial)
target_link_libraries(lmx_geospatial INTERFACE
  LMX::geodesic LMX::h3 LMX::rtree LMX::shapelib LMX::minmea)
if(BUILD_TESTING)
  include(cmake/Tests.cmake)
endif()
if(LMX_BUILD_EXAMPLES)
  add_executable(lmx_geospatial_example examples/geodesic_nmea.c)
  lmx_c99_target(lmx_geospatial_example)
  target_link_libraries(lmx_geospatial_example PRIVATE LMX::geodesic LMX::minmea)
endif()
