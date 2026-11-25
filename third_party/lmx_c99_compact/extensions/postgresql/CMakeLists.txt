cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
  message(FATAL_ERROR "libpq requires the base collection lmx_c99_target helper")
endif()
if(CMAKE_CONFIGURATION_TYPES)
  message(FATAL_ERROR "The libpq adapter uses a single-configuration upstream build")
endif()
if(WIN32)
  if(NOT MINGW)
    message(FATAL_ERROR "The Windows libpq adapter requires the standard MinGW-w64/MSYS2 toolchain")
  endif()
elseif(NOT UNIX OR CMAKE_CROSSCOMPILING)
  message(FATAL_ERROR "The POSIX libpq adapter currently requires a native desktop build")
endif()
if(NOT CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  message(FATAL_ERROR "This libpq adapter verifies strict C99 with GCC or Clang")
endif()
if(APPLE AND CMAKE_OSX_ARCHITECTURES)
  list(LENGTH CMAKE_OSX_ARCHITECTURES _pq_arch_count)
  if(_pq_arch_count GREATER 1 OR NOT CMAKE_OSX_ARCHITECTURES STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
    message(FATAL_ERROR "libpq requires a native single Apple architecture in this adapter")
  endif()
endif()
include(cmake/PrebuiltWindows.cmake)
if(TARGET lmx_pq)
  include(cmake/Consumers.cmake)
  return()
endif()
find_package(Python3 3.8 REQUIRED COMPONENTS Interpreter)
find_package(Threads REQUIRED)
find_program(LMX_PQ_MAKE NAMES gmake make REQUIRED)
find_program(LMX_PQ_SHELL NAMES sh REQUIRED)
find_program(LMX_PQ_BISON NAMES bison REQUIRED)
find_program(LMX_PQ_FLEX NAMES flex REQUIRED)
find_program(LMX_PQ_PERL NAMES perl REQUIRED)
find_program(LMX_PQ_M4 NAMES m4 REQUIRED)
if(CMAKE_NM)
  set(LMX_PQ_NM "${CMAKE_NM}")
else()
  find_program(LMX_PQ_NM NAMES nm REQUIRED)
endif()
include(ExternalProject)
set(_pq_source "${LMX_VENDOR_DIR}/postgresql")
set(_pq_build "${CMAKE_CURRENT_BINARY_DIR}/upstream-build")
set(_pq_stage "${CMAKE_CURRENT_BINARY_DIR}/stage")
set(_pq_archive "${_pq_stage}/lib/liblmx_pq.a")
set(_pq_platform_configure_args)
set(_pq_platform_build_args)
if(WIN32)
  execute_process(COMMAND "${CMAKE_C_COMPILER}" -dumpmachine
    OUTPUT_VARIABLE _pq_host OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE _pq_host_status)
  if(NOT _pq_host_status EQUAL 0 OR NOT _pq_host MATCHES "mingw")
    message(FATAL_ERROR "Could not determine the MinGW-w64 compiler target triplet")
  endif()
  if(CMAKE_RC_COMPILER)
    set(LMX_PQ_WINDRES "${CMAKE_RC_COMPILER}")
  else()
    find_program(LMX_PQ_WINDRES NAMES "${_pq_host}-windres" windres REQUIRED)
  endif()
  set(_pq_archive "${_pq_stage}/lib/libpq.dll.a")
  set(_pq_dll "${_pq_stage}/bin/libpq.dll")
  list(APPEND _pq_platform_configure_args --host "${_pq_host}" --windres "${LMX_PQ_WINDRES}")
  list(APPEND _pq_platform_build_args --windows-dll "${_pq_dll}")
endif()
set(_pq_byproducts "${_pq_archive}")
if(WIN32)
  list(APPEND _pq_byproducts "${_pq_dll}")
endif()
set(_pq_script "${CMAKE_CURRENT_SOURCE_DIR}/cmake/build_libpq.py")
file(MAKE_DIRECTORY "${_pq_stage}/include/postgresql/libpq" "${_pq_stage}/lib")
foreach(_header libpq-fe.h libpq-events.h)
  configure_file("${_pq_source}/src/interfaces/libpq/${_header}"
    "${_pq_stage}/include/postgresql/${_header}" COPYONLY)
endforeach()
configure_file("${_pq_source}/src/include/postgres_ext.h"
  "${_pq_stage}/include/postgresql/postgres_ext.h" COPYONLY)
configure_file("${_pq_source}/src/include/libpq/libpq-fs.h"
  "${_pq_stage}/include/postgresql/libpq/libpq-fs.h" COPYONLY)

set(_pq_cc "${CMAKE_C_COMPILER}")
if(CMAKE_C_COMPILER_ARG1)
  string(APPEND _pq_cc " ${CMAKE_C_COMPILER_ARG1}")
endif()
set(_pq_cflags "-O2 -std=c99 -pedantic-errors")
if(WIN32)
  # PostgreSQL uses WIN32 before including any headers. Strict C99 GCC keeps
  # _WIN32 but removes the legacy nonreserved WIN32 predefine from GNU mode.
  string(APPEND _pq_cflags " -DWIN32=1")
endif()
if(UNIX)
  string(APPEND _pq_cflags " -fPIC")
endif()
if(APPLE)
  if(CMAKE_OSX_SYSROOT)
    string(APPEND _pq_cflags " -isysroot \"${CMAKE_OSX_SYSROOT}\"")
  endif()
  if(CMAKE_OSX_DEPLOYMENT_TARGET)
    string(APPEND _pq_cflags " -mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
  endif()
endif()
# The adapter selects a single Release-like, non-LTO upstream compilation.
# It deliberately does not inject application fast-math/sanitizer flags into
# bundled authentication crypto. No probes are replaced with canned answers.
ExternalProject_Add(lmx_pq_build
  SOURCE_DIR "${_pq_source}"
  BINARY_DIR "${_pq_build}"
  DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
  CONFIGURE_COMMAND "${Python3_EXECUTABLE}" "${_pq_script}" configure
    --source "${_pq_source}" --build "${_pq_build}"
    --cc "${_pq_cc}" --cflags "${_pq_cflags}" --shell "${LMX_PQ_SHELL}"
    --ar "${CMAKE_AR}" --ranlib "${CMAKE_RANLIB}"
    --bison "${LMX_PQ_BISON}" --flex "${LMX_PQ_FLEX}"
    --perl "${LMX_PQ_PERL}" --m4 "${LMX_PQ_M4}" ${_pq_platform_configure_args}
  BUILD_COMMAND "${Python3_EXECUTABLE}" "${_pq_script}" build
    --source "${_pq_source}" --build "${_pq_build}"
    --archive "${_pq_archive}" --make "${LMX_PQ_MAKE}"
    --ar "${CMAKE_AR}" --ranlib "${CMAKE_RANLIB}"
    --nm "${LMX_PQ_NM}" --m4 "${LMX_PQ_M4}" --jobs 2 ${_pq_platform_build_args}
  INSTALL_COMMAND ""
  BUILD_BYPRODUCTS ${_pq_byproducts}
  LOG_CONFIGURE ON LOG_BUILD ON LOG_OUTPUT_ON_FAILURE ON)
if(WIN32)
  # Upstream libpq.a is an import library on MinGW, not a static implementation.
  # Keep the upstream DLL contract and never feed import stubs to object closure.
  add_library(lmx_pq SHARED IMPORTED GLOBAL)
  set_target_properties(lmx_pq PROPERTIES
    IMPORTED_IMPLIB "${_pq_archive}" IMPORTED_LOCATION "${_pq_dll}")
else()
  add_library(lmx_pq STATIC IMPORTED GLOBAL)
  set_target_properties(lmx_pq PROPERTIES
    IMPORTED_LOCATION "${_pq_archive}"
    INTERFACE_LINK_LIBRARIES "Threads::Threads;m")
endif()
set_target_properties(lmx_pq PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${_pq_stage}/include;${_pq_stage}/include/postgresql"
  INTERFACE_COMPILE_FEATURES c_std_99)
add_dependencies(lmx_pq lmx_pq_build)
add_library(LMX::pq ALIAS lmx_pq)
add_library(LMX::libpq ALIAS lmx_pq)
if(WIN32)
  set(LMX_PQ_SELECTED_MODE "source-mingw-shared" CACHE INTERNAL "Selected libpq implementation" FORCE)
else()
  set(LMX_PQ_SELECTED_MODE "source-posix-static" CACHE INTERNAL "Selected libpq implementation" FORCE)
endif()
include(cmake/Consumers.cmake)
