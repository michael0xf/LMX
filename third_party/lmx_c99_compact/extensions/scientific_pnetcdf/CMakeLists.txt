cmake_minimum_required(VERSION 3.20)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(LMX_PnetCDF_C99 LANGUAGES C)
  set(_standalone ON)
else()
  set(_standalone OFF)
endif()
option(LMX_PNETCDF_BUILD_TESTS "Build MPI CDF-1/2/5 tests" ${_standalone})
option(LMX_PNETCDF_MULTI_RANK_TESTS "Enable an additional two-rank test on capable hosts" OFF)
set(LMX_PNETCDF_VENDOR_DIR "${CMAKE_CURRENT_LIST_DIR}/../../vendor/pnetcdf" CACHE PATH "Pinned local PnetCDF source")
set(LMX_PNETCDF_TEST_ENVIRONMENT "" CACHE STRING "Optional MPI runtime environment for tests")
find_package(MPI REQUIRED COMPONENTS C)
find_program(_make NAMES gmake make REQUIRED)
find_program(_m4 NAMES gm4 m4 REQUIRED)
if(NOT UNIX)
  message(FATAL_ERROR "This configure/make adapter requires a POSIX build environment and an MPI C compiler.")
endif()
include(ExternalProject)
set(_build "${CMAKE_CURRENT_BINARY_DIR}/pnetcdf-build")
set(_install "${CMAKE_CURRENT_BINARY_DIR}/pnetcdf-install")
set(LMX_PNETCDF_INSTALL_PREFIX "${_install}" CACHE INTERNAL "Generated PnetCDF prefix for downstream offline builds" FORCE)
set(_view "${CMAKE_CURRENT_BINARY_DIR}/pnetcdf-source")
file(MAKE_DIRECTORY "${_install}/include")
set(_cflags "-Os -std=c99 -pedantic-errors -fPIC -D_POSIX_C_SOURCE=200809L -D_DEFAULT_SOURCE=1")
ExternalProject_Add(lmx_pnetcdf_build
  SOURCE_DIR "${LMX_PNETCDF_VENDOR_DIR}"
  BINARY_DIR "${_build}"
  BUILD_ALWAYS TRUE
  DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
  CONFIGURE_COMMAND "${CMAKE_COMMAND}" "-DSOURCE=${LMX_PNETCDF_VENDOR_DIR}" "-DVIEW=${_view}"
    "-DBINARY=${_build}" "-DPREFIX=${_install}" "-DMPICC=${MPI_C_COMPILER}" "-DM4=${_m4}"
    "-DCFLAGS=${_cflags}" -P "${CMAKE_CURRENT_LIST_DIR}/configure_local.cmake"
  BUILD_COMMAND "${CMAKE_COMMAND}" "-DMAKE=${_make}" "-DBINARY=${_build}"
    -P "${CMAKE_CURRENT_LIST_DIR}/build_local.cmake"
  INSTALL_COMMAND "${CMAKE_COMMAND}" -E make_directory "${_install}/lib" "${_install}/include"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_build}/src/libs/.libs/libpnetcdf.a" "${_install}/lib/libpnetcdf.a"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_build}/src/include/pnetcdf.h" "${_install}/include/pnetcdf.h"
  BUILD_BYPRODUCTS "${_install}/lib/libpnetcdf.a" "${_install}/include/pnetcdf.h")
ExternalProject_Add_StepDependencies(lmx_pnetcdf_build configure
  "${CMAKE_CURRENT_LIST_DIR}/configure_local.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/src/ubyte_aliases.c")
ExternalProject_Add_StepDependencies(lmx_pnetcdf_build build
  "${CMAKE_CURRENT_LIST_DIR}/build_local.cmake")
add_library(lmx_pnetcdf STATIC IMPORTED GLOBAL)
set_target_properties(lmx_pnetcdf PROPERTIES
  IMPORTED_LOCATION "${_install}/lib/libpnetcdf.a"
  INTERFACE_INCLUDE_DIRECTORIES "${_install}/include"
  INTERFACE_LINK_LIBRARIES "MPI::MPI_C;m")
add_dependencies(lmx_pnetcdf lmx_pnetcdf_build)
add_library(LMX::pnetcdf ALIAS lmx_pnetcdf)
add_library(lmx_scientific_pnetcdf INTERFACE)
target_link_libraries(lmx_scientific_pnetcdf INTERFACE LMX::pnetcdf)
add_library(LMX::scientific_pnetcdf ALIAS lmx_scientific_pnetcdf)
if(LMX_PNETCDF_BUILD_TESTS)
  enable_testing()
  add_executable(lmx_pnetcdf_roundtrip tests/roundtrip.c)
  target_link_libraries(lmx_pnetcdf_roundtrip PRIVATE LMX::pnetcdf)
  set_target_properties(lmx_pnetcdf_roundtrip PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
  target_compile_options(lmx_pnetcdf_roundtrip PRIVATE -pedantic-errors)
  foreach(ranks 1 2)
    if(ranks EQUAL 2 AND NOT LMX_PNETCDF_MULTI_RANK_TESTS)
      continue()
    endif()
    set(_out "${CMAKE_CURRENT_BINARY_DIR}/test-output/mpi${ranks}")
    file(MAKE_DIRECTORY "${_out}")
    add_test(NAME scientific_pnetcdf.cdf125_mpi${ranks}
      COMMAND "${MPIEXEC_EXECUTABLE}" ${MPIEXEC_NUMPROC_FLAG} ${ranks} ${MPIEXEC_PREFLAGS}
      "$<TARGET_FILE:lmx_pnetcdf_roundtrip>" ${MPIEXEC_POSTFLAGS})
    set_tests_properties(scientific_pnetcdf.cdf125_mpi${ranks} PROPERTIES
      WORKING_DIRECTORY "${_out}" TIMEOUT 45 PROCESSORS ${ranks}
      ENVIRONMENT "${LMX_PNETCDF_TEST_ENVIRONMENT}")
  endforeach()
endif()
