cmake_minimum_required(VERSION 3.26)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(LMX_HDF5_C99 LANGUAGES C)
  set(_hdf5_standalone ON)
else()
  set(_hdf5_standalone OFF)
endif()
include(ExternalProject)
include("${CMAKE_CURRENT_LIST_DIR}/prepare_view.cmake")
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
option(LMX_HDF5_PARALLEL "Enable MPI file driver and parallel I/O" ON)
option(LMX_HDF5_BUILD_TESTS "Build self-contained HDF5 format and HL checks" ${_hdf5_standalone})
set(LMX_HDF5_VENDOR_DIR "${CMAKE_CURRENT_LIST_DIR}/../../vendor/hdf5" CACHE PATH "Pinned local HDF5 sources")
set(LMX_HDF5_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install" CACHE PATH "Build-tree HDF5 install prefix for dependent child configurations")
set(_hdf5_view "${CMAKE_CURRENT_BINARY_DIR}/c99-view")
lmx_hdf5_prepare_view("${LMX_HDF5_VENDOR_DIR}" "${_hdf5_view}")
find_package(Threads REQUIRED)
set(_hdf5_deps)
set(_hdf5_zargs)
if(TARGET LMX::zlib)
  set(_hdf5_zlib LMX::zlib)
  get_target_property(_hdf5_zreal LMX::zlib ALIASED_TARGET)
  if(NOT _hdf5_zreal)
    set(_hdf5_zreal LMX::zlib)
  endif()
  list(APPEND _hdf5_deps ${_hdf5_zreal})
  find_path(_hdf5_zinc zlib.h PATHS "${LMX_VENDOR_DIR}/zlib" "${CMAKE_CURRENT_LIST_DIR}/../../vendor/zlib" NO_DEFAULT_PATH REQUIRED)
  # Existing compact zlib includes its portable zconf.h in the same source tree.
  list(APPEND _hdf5_zargs "-DZLIB_LIBRARY=$<TARGET_FILE:LMX::zlib>" "-DZLIB_INCLUDE_DIR=${_hdf5_zinc}")
else()
  find_package(ZLIB REQUIRED)
  set(_hdf5_zlib ZLIB::ZLIB)
  list(APPEND _hdf5_zargs "-DZLIB_LIBRARY=${ZLIB_LIBRARY}" "-DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR}")
endif()
set(_hdf5_links Threads::Threads ${_hdf5_zlib} ${CMAKE_DL_LIBS})
if(UNIX)
  list(APPEND _hdf5_links m)
endif()
set(_hdf5_mpi_args)
if(LMX_HDF5_PARALLEL)
  find_package(MPI REQUIRED COMPONENTS C)
  list(APPEND _hdf5_links MPI::MPI_C)
  list(APPEND _hdf5_mpi_args "-DMPI_C_COMPILER=${MPI_C_COMPILER}" "-DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE}")
endif()
set(_hdf5_flags "${CMAKE_C_FLAGS}")
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  string(APPEND _hdf5_flags " -pedantic-errors")
endif()
set(_hdf5_core "${LMX_HDF5_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}hdf5${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(_hdf5_hl "${LMX_HDF5_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}hdf5_hl${CMAKE_STATIC_LIBRARY_SUFFIX}")
file(MAKE_DIRECTORY "${LMX_HDF5_INSTALL_PREFIX}/include")
ExternalProject_Add(lmx_hdf5_build
  DEPENDS ${_hdf5_deps}
  SOURCE_DIR "${_hdf5_view}" BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/hdf5-build"
  DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
  CMAKE_ARGS
    "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}" "-DCMAKE_C_FLAGS=${_hdf5_flags}"
    -DCMAKE_C_STANDARD=99 -DCMAKE_C_EXTENSIONS=OFF -DCMAKE_BUILD_TYPE=MinSizeRel
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "-DCMAKE_INSTALL_PREFIX=${LMX_HDF5_INSTALL_PREFIX}"
    -DHDF5_INSTALL_LIB_DIR=lib -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON
    -DHDF5_BUILD_HL_LIB=ON -DHDF5_BUILD_CPP_LIB=OFF -DHDF5_BUILD_FORTRAN=OFF
    -DHDF5_BUILD_JAVA=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_UTILS=OFF
    -DHDF5_BUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DHDF5_BUILD_DOC=OFF -DHDF5_NO_PACKAGES=ON
    -DHDF5_ENABLE_NONSTANDARD_FEATURE_FLOAT16=OFF
    -DHDF5_ENABLE_THREADS=ON -DHDF5_ENABLE_THREADSAFE=OFF -DHDF5_ENABLE_CONCURRENCY=OFF
    -DHAVE_STDATOMIC_H=0 "-DHDF5_ENABLE_PARALLEL=${LMX_HDF5_PARALLEL}"
    -DHDF5_ENABLE_ZLIB_SUPPORT=ON -DZLIB_USE_EXTERNAL=OFF -DHDF5_ALLOW_EXTERNAL_SUPPORT=NO
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON -DHDF5_ENABLE_SZIP_SUPPORT=OFF
    -DHDF5_ENABLE_MAP_API=ON -DHDF5_ENABLE_DEPRECATED_SYMBOLS=ON -DHDF5_ENABLE_PLUGIN_SUPPORT=OFF
    ${_hdf5_zargs} ${_hdf5_mpi_args}
  BUILD_COMMAND "${CMAKE_COMMAND}" --build <BINARY_DIR> --parallel 4
  INSTALL_COMMAND "${CMAKE_COMMAND}" --install <BINARY_DIR>
  BUILD_BYPRODUCTS "${_hdf5_core}" "${_hdf5_hl}")
add_library(lmx_hdf5 STATIC IMPORTED GLOBAL)
set_target_properties(lmx_hdf5 PROPERTIES IMPORTED_LOCATION "${_hdf5_core}"
  INTERFACE_INCLUDE_DIRECTORIES "${LMX_HDF5_INSTALL_PREFIX}/include"
  INTERFACE_LINK_LIBRARIES "${_hdf5_links}")
add_dependencies(lmx_hdf5 lmx_hdf5_build)
add_library(LMX::hdf5 ALIAS lmx_hdf5)
add_library(lmx_hdf5_hl STATIC IMPORTED GLOBAL)
set_target_properties(lmx_hdf5_hl PROPERTIES IMPORTED_LOCATION "${_hdf5_hl}"
  INTERFACE_INCLUDE_DIRECTORIES "${LMX_HDF5_INSTALL_PREFIX}/include"
  INTERFACE_LINK_LIBRARIES LMX::hdf5)
add_dependencies(lmx_hdf5_hl lmx_hdf5_build)
add_library(LMX::hdf5_hl ALIAS lmx_hdf5_hl)
add_library(lmx_scientific_hdf5 INTERFACE)
target_link_libraries(lmx_scientific_hdf5 INTERFACE LMX::hdf5_hl)
add_library(LMX::scientific_hdf5 ALIAS lmx_scientific_hdf5)
if(LMX_HDF5_BUILD_TESTS)
  enable_testing()
  add_executable(lmx_hdf5_format_test tests/test_format.c)
  target_link_libraries(lmx_hdf5_format_test PRIVATE LMX::hdf5_hl)
  if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(lmx_hdf5_format_test PRIVATE -pedantic-errors)
  endif()
  add_test(NAME hdf5_core_and_all_hl COMMAND lmx_hdf5_format_test)
  set_tests_properties(hdf5_core_and_all_hl PROPERTIES TIMEOUT 30)
  if(LMX_HDF5_PARALLEL)
    add_executable(lmx_hdf5_mpi_test tests/test_mpi.c)
    target_link_libraries(lmx_hdf5_mpi_test PRIVATE LMX::hdf5)
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
      target_compile_options(lmx_hdf5_mpi_test PRIVATE -pedantic-errors)
    endif()
    add_test(NAME hdf5_mpi_single_rank COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} 1 ${MPIEXEC_PREFLAGS} $<TARGET_FILE:lmx_hdf5_mpi_test> ${MPIEXEC_POSTFLAGS})
    set_tests_properties(hdf5_mpi_single_rank PROPERTIES TIMEOUT 30)
  endif()
endif()
