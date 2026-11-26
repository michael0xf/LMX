cmake_minimum_required(VERSION 3.26)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(LMX_NetCDF_C99 LANGUAGES C)
  set(_standalone ON)
else()
  set(_standalone OFF)
endif()
include(ExternalProject)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
option(LMX_NETCDF_BUILD_TESTS "Build local XML/netCDF format and MPI interoperability tests" ${_standalone})
option(LMX_NETCDF_MULTI_RANK_TESTS "Enable additional two-rank MPI tests on capable hosts" OFF)
set(LMX_NETCDF_TEST_ENVIRONMENT "" CACHE STRING "Optional MPI runtime environment for netCDF tests")
set(LMX_NETCDF_VENDOR_DIR "${CMAKE_CURRENT_LIST_DIR}/../../vendor/netcdf" CACHE PATH "Retained local netCDF-C source")
set(LMX_LIBXML2_VENDOR_DIR "${CMAKE_CURRENT_LIST_DIR}/../../vendor/libxml2" CACHE PATH "Retained local libxml2 source")
set(LMX_LIBXML2_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/libxml2-install" CACHE PATH "Local libxml2 prefix")
set(LMX_NETCDF_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/netcdf-install" CACHE PATH "Local netCDF prefix")

if(NOT TARGET LMX::hdf5)
  add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/../scientific_hdf5" "${CMAKE_CURRENT_BINARY_DIR}/hdf5")
endif()
if(NOT TARGET LMX::pnetcdf)
  add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/../scientific_pnetcdf" "${CMAKE_CURRENT_BINARY_DIR}/pnetcdf")
endif()
find_package(Threads REQUIRED)
find_package(MPI REQUIRED COMPONENTS C)
set(_deps)
set(_zargs)
if(TARGET LMX::zlib)
  set(_zlib LMX::zlib)
  get_target_property(_zreal LMX::zlib ALIASED_TARGET)
  if(NOT _zreal)
    set(_zreal LMX::zlib)
  endif()
  list(APPEND _deps ${_zreal})
  find_path(_zinc zlib.h PATHS "${CMAKE_CURRENT_LIST_DIR}/../../vendor/zlib" NO_DEFAULT_PATH REQUIRED)
  list(APPEND _zargs "-DZLIB_LIBRARY=$<TARGET_FILE:LMX::zlib>" "-DZLIB_INCLUDE_DIR=${_zinc}")
else()
  find_package(ZLIB REQUIRED)
  set(_zlib ZLIB::ZLIB)
  list(APPEND _zargs "-DZLIB_LIBRARY=${ZLIB_LIBRARY}" "-DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR}")
endif()
set(_curlargs -DCURL_NO_CURL_CMAKE=TRUE)
if(TARGET LMX::curl)
  set(_curl LMX::curl)
  get_target_property(_creal LMX::curl ALIASED_TARGET)
  if(NOT _creal)
    set(_creal LMX::curl)
  endif()
  list(APPEND _deps ${_creal})
  find_path(_cinc curl/curl.h PATHS "${CMAKE_CURRENT_LIST_DIR}/../../vendor/curl/include" NO_DEFAULT_PATH REQUIRED)
  list(APPEND _curlargs "-DCURL_LIBRARY=$<TARGET_FILE:LMX::curl>" "-DCURL_LIBRARY_RELEASE=$<TARGET_FILE:LMX::curl>"
    "-DCURL_INCLUDE_DIR=${_cinc}" -DCURL_USE_STATIC_LIBS=ON)
else()
  find_package(CURL REQUIRED)
  set(_curl CURL::libcurl)
  list(APPEND _curlargs "-DCURL_LIBRARY=${CURL_LIBRARIES}" "-DCURL_INCLUDE_DIR=${CURL_INCLUDE_DIRS}")
endif()
set(_flags "${CMAKE_C_FLAGS}")
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  string(APPEND _flags " -pedantic-errors")
  if(UNIX)
    string(APPEND _flags " -D_DEFAULT_SOURCE=1")
  endif()
endif()
set(_toolchain_args)
if(CMAKE_TOOLCHAIN_FILE)
  list(APPEND _toolchain_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
endif()
set(_common_args "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}" "-DCMAKE_C_FLAGS=${_flags}"
  -DCMAKE_C_STANDARD=99 -DCMAKE_C_STANDARD_REQUIRED=ON -DCMAKE_C_EXTENSIONS=OFF
  -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ${_toolchain_args})
set(LIBXML_VENDOR "${LMX_LIBXML2_VENDOR_DIR}")
set(LIBXML_VIEW "${CMAKE_CURRENT_BINARY_DIR}/libxml2-source")
include("${CMAKE_CURRENT_LIST_DIR}/prepare_libxml2.cmake")
set(_xml_archive "${LMX_LIBXML2_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}xml2${CMAKE_STATIC_LIBRARY_SUFFIX}")
file(MAKE_DIRECTORY "${LMX_LIBXML2_INSTALL_PREFIX}/include/libxml2")
ExternalProject_Add(lmx_libxml2_build
  DEPENDS ${_deps}
  SOURCE_DIR "${LIBXML_VIEW}" BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libxml2-build"
  DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
  CMAKE_ARGS ${_common_args} "-DCMAKE_INSTALL_PREFIX=${LMX_LIBXML2_INSTALL_PREFIX}"
    -DLIBXML2_WITH_PROGRAMS=OFF -DLIBXML2_WITH_TESTS=OFF -DLIBXML2_WITH_PYTHON=OFF
    -DLIBXML2_WITH_DOCS=OFF -DLIBXML2_WITH_LEGACY=ON -DLIBXML2_WITH_SCHEMATRON=ON
    -DLIBXML2_WITH_TLS=OFF ${_zargs}
  BUILD_COMMAND "${CMAKE_COMMAND}" --build <BINARY_DIR> --parallel 4
  INSTALL_COMMAND "${CMAKE_COMMAND}" --install <BINARY_DIR>
  BUILD_BYPRODUCTS "${_xml_archive}")
add_library(lmx_libxml2 STATIC IMPORTED GLOBAL)
set(_xml_links ${_zlib} Threads::Threads ${CMAKE_DL_LIBS})
if(UNIX)
  list(APPEND _xml_links m)
endif()
set_target_properties(lmx_libxml2 PROPERTIES IMPORTED_LOCATION "${_xml_archive}"
  INTERFACE_INCLUDE_DIRECTORIES "${LMX_LIBXML2_INSTALL_PREFIX}/include/libxml2"
  INTERFACE_COMPILE_DEFINITIONS LIBXML_STATIC
  INTERFACE_LINK_LIBRARIES "${_xml_links}")
add_dependencies(lmx_libxml2 lmx_libxml2_build)
add_library(LMX::libxml2 ALIAS lmx_libxml2)

set(NETCDF_VENDOR "${LMX_NETCDF_VENDOR_DIR}")
set(NETCDF_VIEW "${CMAKE_CURRENT_BINARY_DIR}/netcdf-source")
include("${CMAKE_CURRENT_LIST_DIR}/prepare_netcdf.cmake")
set(_nc_archive "${LMX_NETCDF_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}netcdf${CMAKE_STATIC_LIBRARY_SUFFIX}")
file(MAKE_DIRECTORY "${LMX_NETCDF_INSTALL_PREFIX}/include")
ExternalProject_Add(lmx_netcdf_build
  DEPENDS lmx_libxml2_build lmx_hdf5_build lmx_pnetcdf_build ${_deps}
  SOURCE_DIR "${NETCDF_VIEW}" BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/netcdf-build"
  DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
  CMAKE_ARGS ${_common_args} "-DCMAKE_INSTALL_PREFIX=${LMX_NETCDF_INSTALL_PREFIX}"
    -DNETCDF_ENABLE_HDF5=ON "-DHDF5_ROOT=${LMX_HDF5_INSTALL_PREFIX}" -DHDF5_USE_STATIC_LIBRARIES=ON
    -DNETCDF_ENABLE_PNETCDF=ON "-DPNETCDF_INCLUDE_DIR=${LMX_PNETCDF_INSTALL_PREFIX}/include"
    "-DPNETCDF_LIBRARY=${LMX_PNETCDF_INSTALL_PREFIX}/lib/libpnetcdf.a"
    "-DMPI_C_COMPILER=${MPI_C_COMPILER}" "-DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE}"
    -DNETCDF_ENABLE_LIBXML2=ON "-DLIBXML2_LIBRARY=${_xml_archive}"
    "-DLIBXML2_INCLUDE_DIR=${LMX_LIBXML2_INSTALL_PREFIX}/include/libxml2"
    -DNETCDF_ENABLE_CDF5=ON -DNETCDF_ENABLE_PARALLEL4=ON
    -DNETCDF_ENABLE_DAP=ON -DNETCDF_ENABLE_BYTERANGE=ON
    -DNETCDF_ENABLE_NCZARR=ON -DNETCDF_ENABLE_NCZARR_ZIP=OFF
    -DNETCDF_ENABLE_S3_AWS=OFF -DNETCDF_ENABLE_S3_INTERNAL=OFF
    -DNETCDF_ENABLE_FILTER_SZIP=OFF -DNETCDF_ENABLE_FILTER_BZ2=OFF
    -DNETCDF_ENABLE_FILTER_BLOSC=OFF -DNETCDF_ENABLE_FILTER_ZSTD=OFF
    -DNETCDF_ENABLE_HDF4=OFF -DNETCDF_ENABLE_TESTS=OFF
    -DNETCDF_ENABLE_EXAMPLES=OFF -DNETCDF_BUILD_UTILITIES=OFF
    -DNETCDF_ENABLE_DAP_REMOTE_TESTS=OFF ${_zargs} ${_curlargs}
  BUILD_COMMAND "${CMAKE_COMMAND}" --build <BINARY_DIR> --parallel 4
  INSTALL_COMMAND "${CMAKE_COMMAND}" --install <BINARY_DIR>
  BUILD_BYPRODUCTS "${_nc_archive}")
add_library(lmx_netcdf STATIC IMPORTED GLOBAL)
set_target_properties(lmx_netcdf PROPERTIES IMPORTED_LOCATION "${_nc_archive}"
  INTERFACE_INCLUDE_DIRECTORIES "${LMX_NETCDF_INSTALL_PREFIX}/include"
  INTERFACE_LINK_LIBRARIES "LMX::hdf5_hl;LMX::pnetcdf;LMX::libxml2;${_curl};${_zlib};Threads::Threads;${CMAKE_DL_LIBS}")
add_dependencies(lmx_netcdf lmx_netcdf_build)
add_library(LMX::netcdf ALIAS lmx_netcdf)
add_library(lmx_scientific_netcdf INTERFACE)
target_link_libraries(lmx_scientific_netcdf INTERFACE LMX::netcdf LMX::libxml2)
add_library(LMX::scientific_netcdf ALIAS lmx_scientific_netcdf)

if(LMX_NETCDF_BUILD_TESTS)
  enable_testing()
  foreach(test xml formats nczarr parallel interop)
    add_executable(lmx_scientific_${test} "tests/${test}.c")
    if(test STREQUAL "xml")
      target_link_libraries(lmx_scientific_${test} PRIVATE LMX::libxml2)
    else()
      target_link_libraries(lmx_scientific_${test} PRIVATE LMX::netcdf)
    endif()
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
      target_compile_options(lmx_scientific_${test} PRIVATE -pedantic-errors -UNDEBUG)
    elseif(MSVC)
      target_compile_options(lmx_scientific_${test} PRIVATE /UNDEBUG)
    endif()
    if(test MATCHES "^(parallel|interop)$")
      foreach(ranks 1 2)
        if(ranks EQUAL 2 AND NOT LMX_NETCDF_MULTI_RANK_TESTS)
          continue()
        endif()
        set(_test_name "scientific_netcdf.${test}_mpi${ranks}")
        set(_wd "${CMAKE_CURRENT_BINARY_DIR}/test-output/${test}${ranks}")
        file(MAKE_DIRECTORY "${_wd}")
        add_test(NAME ${_test_name} COMMAND "${MPIEXEC_EXECUTABLE}" ${MPIEXEC_NUMPROC_FLAG} ${ranks}
          ${MPIEXEC_PREFLAGS} "$<TARGET_FILE:lmx_scientific_${test}>" ${MPIEXEC_POSTFLAGS})
        set_tests_properties(${_test_name} PROPERTIES WORKING_DIRECTORY "${_wd}" TIMEOUT 45
          PROCESSORS ${ranks} ENVIRONMENT "${LMX_NETCDF_TEST_ENVIRONMENT}")
      endforeach()
    else()
      set(_wd "${CMAKE_CURRENT_BINARY_DIR}/test-output/${test}")
      file(MAKE_DIRECTORY "${_wd}")
      add_test(NAME "scientific_netcdf.${test}" COMMAND lmx_scientific_${test})
      set_tests_properties("scientific_netcdf.${test}" PROPERTIES WORKING_DIRECTORY "${_wd}" TIMEOUT 30)
    endif()
  endforeach()
endif()
