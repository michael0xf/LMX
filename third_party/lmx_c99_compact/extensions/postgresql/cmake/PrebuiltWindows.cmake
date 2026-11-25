# A ready libpq DLL is an architecture- and CRT-specific implementation.
# In particular PQtrace accepts FILE*, so a DLL using MSVCRT must not silently
# receive a FILE allocated by a UCRT consumer. Other configurations retain the
# source build; this is automatic artifact selection, not a disabled component.
if(NOT WIN32 OR NOT MINGW OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  return()
endif()

set(_pq_prebuilt "${CMAKE_CURRENT_LIST_DIR}/../prebuilt/windows-x86_64")
set(_pq_prebuilt_manifest "${_pq_prebuilt}/manifest.json")
if(NOT EXISTS "${_pq_prebuilt_manifest}")
  return()
endif()

include(CheckCSourceCompiles)
check_c_source_compiles("#include <_mingw.h>
#if !defined(_WIN64) || !defined(__x86_64__) || !defined(__MINGW32__)
#error This DLL requires the x86_64 MinGW-w64 ABI
#endif
#if defined(_UCRT) || __MSVCRT_VERSION__ != 0x700
#error This DLL requires the matching MSVCRT FILE ABI
#endif
int main(void) { return 0; }
" LMX_PQ_COMPATIBLE_X64_MSVCRT)
if(NOT LMX_PQ_COMPATIBLE_X64_MSVCRT)
  message(STATUS "libpq: bundled x64/MSVCRT DLL does not match this compiler; building the DLL from source")
  return()
endif()

file(READ "${_pq_prebuilt_manifest}" _pq_prebuilt_json)
string(JSON _pq_prebuilt_version GET "${_pq_prebuilt_json}" version)
if(NOT _pq_prebuilt_version STREQUAL "18.7")
  message(FATAL_ERROR "Unexpected bundled libpq version: ${_pq_prebuilt_version}")
endif()
string(JSON _pq_prebuilt_count LENGTH "${_pq_prebuilt_json}" files)
math(EXPR _pq_prebuilt_last "${_pq_prebuilt_count} - 1")
if(_pq_prebuilt_last LESS 0)
  message(FATAL_ERROR "The bundled libpq manifest contains no files")
endif()
foreach(_pq_i RANGE 0 ${_pq_prebuilt_last})
  string(JSON _pq_file GET "${_pq_prebuilt_json}" files ${_pq_i} path)
  string(JSON _pq_sha GET "${_pq_prebuilt_json}" files ${_pq_i} sha256)
  if(IS_ABSOLUTE "${_pq_file}" OR _pq_file MATCHES "(^|/)\\.\\.(/|$)" OR _pq_file MATCHES "\\\\")
    message(FATAL_ERROR "Unsafe bundled libpq manifest path: ${_pq_file}")
  endif()
  if(NOT EXISTS "${_pq_prebuilt}/${_pq_file}")
    message(FATAL_ERROR "Missing bundled libpq file: ${_pq_file}")
  endif()
  file(SHA256 "${_pq_prebuilt}/${_pq_file}" _pq_actual_sha)
  if(NOT _pq_actual_sha STREQUAL _pq_sha)
    message(FATAL_ERROR "Bundled libpq checksum mismatch: ${_pq_file}")
  endif()
endforeach()

add_library(lmx_pq SHARED IMPORTED GLOBAL)
set_target_properties(lmx_pq PROPERTIES
  IMPORTED_IMPLIB "${_pq_prebuilt}/lib/libpq.dll.a"
  IMPORTED_LOCATION "${_pq_prebuilt}/bin/libpq.dll"
  INTERFACE_INCLUDE_DIRECTORIES "${_pq_prebuilt}/include;${_pq_prebuilt}/include/postgresql"
  INTERFACE_COMPILE_FEATURES c_std_99)
add_library(LMX::pq ALIAS lmx_pq)
add_library(LMX::libpq ALIAS lmx_pq)
set(LMX_PQ_SELECTED_MODE "bundled-windows-x86_64-msvcrt" CACHE INTERNAL "Selected libpq implementation" FORCE)
message(STATUS "libpq: verified bundled PostgreSQL 18.7 Windows x64/MSVCRT DLL")
