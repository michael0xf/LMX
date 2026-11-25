cmake_minimum_required(VERSION 3.17)
if(NOT COMMAND lmx_c99_target OR NOT TARGET LMX::zlib)
  message(FATAL_ERROR "XLSXIO requires the base LMX::zlib target and lmx_c99_target")
endif()
find_package(Threads REQUIRED)
set(_xlsxio_vendor "${LMX_VENDOR_DIR}")
get_filename_component(_xlsxio_minizip
  "${CMAKE_CURRENT_SOURCE_DIR}/../../vendor/zlib/contrib/minizip" ABSOLUTE)

# The upstream Expat CMake is already C-only and C99. Keep all entropy providers
# supported by the detected platform; disable only auxiliary build products.
function(_lmx_xlsxio_expat)
  foreach(_option EXPAT_BUILD_TOOLS EXPAT_BUILD_EXAMPLES EXPAT_BUILD_TESTS
      EXPAT_SHARED_LIBS EXPAT_BUILD_DOCS EXPAT_BUILD_FUZZERS EXPAT_BUILD_PKGCONFIG
      EXPAT_OSSFUZZ_BUILD EXPAT_ENABLE_INSTALL EXPAT_WARNINGS_AS_ERRORS)
    set(${_option} OFF)
  endforeach()
  set(EXPAT_CHAR_TYPE char)
  set(EXPAT_DTD ON)
  set(EXPAT_GE ON)
  set(EXPAT_NS ON)
  set(EXPAT_LARGE_SIZE OFF)
  set(EXPAT_SYMBOL_VERSIONING OFF)
  add_subdirectory("${_xlsxio_vendor}/expat" "${CMAKE_CURRENT_BINARY_DIR}/expat")
  lmx_c99_target(expat)
  set_target_properties(expat PROPERTIES POSITION_INDEPENDENT_CODE ON)
endfunction()
_lmx_xlsxio_expat()
add_library(LMX::expat ALIAS expat)

# Actual classic MiniZip from the SAME preserved zlib 1.4 tree.
# Public includes remain namespaced as <minizip/zip.h>, avoiding kuba_zip.
set(_minizip_include "${CMAKE_CURRENT_BINARY_DIR}/include")
file(MAKE_DIRECTORY "${_minizip_include}/minizip")
foreach(_header zip.h unzip.h ioapi.h ints.h mztools.h)
  configure_file("${_xlsxio_minizip}/${_header}"
                 "${_minizip_include}/minizip/${_header}" COPYONLY)
endforeach()
add_library(lmx_minizip STATIC
  "${_xlsxio_minizip}/ioapi.c" "${_xlsxio_minizip}/mztools.c"
  "${_xlsxio_minizip}/unzip.c" "${_xlsxio_minizip}/zip.c")
add_library(LMX::minizip ALIAS lmx_minizip)
target_include_directories(lmx_minizip PUBLIC "${_minizip_include}")
target_include_directories(lmx_minizip PRIVATE "${_xlsxio_minizip}")
target_compile_definitions(lmx_minizip PRIVATE
  _POSIX_C_SOURCE=200809L _LARGEFILE64_SOURCE=1 _FILE_OFFSET_BITS=64)
target_link_libraries(lmx_minizip PUBLIC LMX::zlib)
lmx_c99_target(lmx_minizip)
set_target_properties(lmx_minizip PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_xlsxio_read STATIC
  adapters/read_posix.c
  adapters/sharedstrings_posix.c)
add_library(lmx_xlsxio_write STATIC adapters/write.c)
add_library(LMX::xlsxio_read ALIAS lmx_xlsxio_read)
add_library(LMX::xlsxio_write ALIAS lmx_xlsxio_write)
foreach(_target lmx_xlsxio_read lmx_xlsxio_write)
  target_include_directories(${_target} PUBLIC "${_xlsxio_vendor}/xlsxio/include")
  target_include_directories(${_target} PRIVATE "${_xlsxio_vendor}/xlsxio/lib")
  target_compile_definitions(${_target} PUBLIC BUILD_XLSXIO_STATIC)
  target_compile_definitions(${_target} PRIVATE BUILD_XLSXIO USE_MINIZIP
    _POSIX_C_SOURCE=200809L _LARGEFILE64_SOURCE=1 _FILE_OFFSET_BITS=64)
  target_link_libraries(${_target} PUBLIC LMX::minizip)
  lmx_c99_target(${_target})
  set_target_properties(${_target} PROPERTIES POSITION_INDEPENDENT_CODE ON)
endforeach()
target_link_libraries(lmx_xlsxio_read PUBLIC LMX::expat)
target_link_libraries(lmx_xlsxio_write PUBLIC Threads::Threads)
add_library(lmx_xlsxio INTERFACE)
add_library(LMX::xlsxio ALIAS lmx_xlsxio)
target_link_libraries(lmx_xlsxio INTERFACE LMX::xlsxio_read LMX::xlsxio_write)
lmx_c99_target(lmx_xlsxio)

if(BUILD_TESTING)
  include(cmake/Tests.cmake OPTIONAL)
endif()
if(LMX_BUILD_EXAMPLES AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/examples/roundtrip.c")
  add_executable(lmx_xlsxio_example examples/roundtrip.c)
  target_link_libraries(lmx_xlsxio_example PRIVATE LMX::xlsxio)
  lmx_c99_target(lmx_xlsxio_example)
endif()
