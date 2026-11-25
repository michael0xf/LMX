# Full official libsodium stable distribution, using its generated configure.
# The CMake adapter never downloads or installs into a system directory.
include_guard(GLOBAL)
include(ExternalProject)
if(NOT UNIX)
    message(FATAL_ERROR "The bundled libsodium adapter currently requires a POSIX shell and make. Native Windows build files remain in vendor/libsodium.")
endif()
if(CMAKE_CROSSCOMPILING)
    message(FATAL_ERROR "This libsodium adapter is verified for native POSIX builds. Cross compilation requires explicit upstream --host/toolchain handling.")
endif()
if(CMAKE_CONFIGURATION_TYPES)
    message(FATAL_ERROR "The libsodium adapter uses one native build configuration. Select Ninja or Unix Makefiles instead of a multi-config generator.")
endif()
if(APPLE AND CMAKE_OSX_ARCHITECTURES)
    list(LENGTH CMAKE_OSX_ARCHITECTURES _lmx_sodium_arch_count)
    if(_lmx_sodium_arch_count GREATER 1 OR NOT CMAKE_OSX_ARCHITECTURES STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
        message(FATAL_ERROR "The libsodium adapter currently supports the native host architecture only; universal/cross Apple builds need explicit upstream handling.")
    endif()
endif()
find_program(LMX_MAKE_EXECUTABLE NAMES gmake make REQUIRED)
find_program(LMX_POSIX_SHELL NAMES sh REQUIRED)
find_package(Threads REQUIRED)
set(LMX_EXTERNAL_JOBS 4 CACHE STRING "Parallel jobs per upstream make-based dependency")
set(_lmx_sodium_source "${CMAKE_CURRENT_LIST_DIR}/../vendor/libsodium")
set(_lmx_sodium_build "${CMAKE_CURRENT_BINARY_DIR}/libsodium-build")
set(_lmx_sodium_stage "${CMAKE_CURRENT_BINARY_DIR}/libsodium-stage")
file(MAKE_DIRECTORY "${_lmx_sodium_stage}/include" "${_lmx_sodium_stage}/lib")

# Preserve upstream's optimization, hardening and CPU-dispatch flags. Select
# the requested C99 language mode through CC; do not propagate application
# fast-math/LTO/sanitizer options into the cryptographic implementation.
set(_lmx_sodium_base_cc "${CMAKE_C_COMPILER}")
if(CMAKE_C_COMPILER_ARG1)
    string(APPEND _lmx_sodium_base_cc " ${CMAKE_C_COMPILER_ARG1}")
endif()
if(APPLE)
    if(CMAKE_OSX_SYSROOT)
        string(APPEND _lmx_sodium_base_cc " -isysroot \"${CMAKE_OSX_SYSROOT}\"")
    endif()
    if(CMAKE_OSX_DEPLOYMENT_TARGET)
        string(APPEND _lmx_sodium_base_cc " -mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()
endif()
set(_lmx_sodium_cc "${_lmx_sodium_base_cc}")
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    string(APPEND _lmx_sodium_cc " -std=c99")
    if(LMX_STRICT_C99)
        string(APPEND _lmx_sodium_cc " -pedantic-errors")
    endif()
endif()
ExternalProject_Add(lmx_sodium_build
    SOURCE_DIR "${_lmx_sodium_source}"
    BINARY_DIR "${_lmx_sodium_build}"
    INSTALL_DIR "${_lmx_sodium_stage}"
    DOWNLOAD_COMMAND ""
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env
        --unset=CFLAGS --unset=CPPFLAGS --unset=LDFLAGS --unset=LIBS
        "CC=${_lmx_sodium_cc}" "AR=${CMAKE_AR}" "RANLIB=${CMAKE_RANLIB}"
        # Prevent Autoconf from appending -std=gnu11 after the requested C99.
        "ac_cv_prog_cc_c23=no" "ac_cv_prog_cc_c11=no"
        "${LMX_POSIX_SHELL}" "${_lmx_sodium_source}/configure"
        --prefix=<INSTALL_DIR> --libdir=<INSTALL_DIR>/lib
        --disable-shared --enable-static --with-pic
        --disable-maintainer-mode --disable-dependency-tracking --disable-opt
    BUILD_COMMAND "${LMX_MAKE_EXECUTABLE}" -j${LMX_EXTERNAL_JOBS}
    INSTALL_COMMAND "${LMX_MAKE_EXECUTABLE}" install
    BUILD_BYPRODUCTS "${_lmx_sodium_stage}/lib/libsodium.a"
    LOG_CONFIGURE ON LOG_BUILD ON LOG_INSTALL ON
    LOG_OUTPUT_ON_FAILURE ON)
add_library(lmx_sodium STATIC IMPORTED GLOBAL)
set_target_properties(lmx_sodium PROPERTIES
    IMPORTED_LOCATION "${_lmx_sodium_stage}/lib/libsodium.a"
    INTERFACE_INCLUDE_DIRECTORIES "${_lmx_sodium_stage}/include"
    INTERFACE_COMPILE_DEFINITIONS SODIUM_STATIC
    INTERFACE_COMPILE_FEATURES c_std_99
    INTERFACE_LINK_LIBRARIES "Threads::Threads;m")
add_dependencies(lmx_sodium lmx_sodium_build)
add_library(LMX::sodium ALIAS lmx_sodium)

option(LMX_SODIUM_UPSTREAM_TESTS "Run the official libsodium test suite through CTest" OFF)
if(BUILD_TESTING)
    add_executable(lmx_sodium_smoke "${CMAKE_CURRENT_LIST_DIR}/../tests/sodium_smoke.c")
    lmx_c99_target(lmx_sodium_smoke)
    target_link_libraries(lmx_sodium_smoke PRIVATE LMX::sodium)
    add_test(NAME sodium.crypto_roundtrip COMMAND lmx_sodium_smoke)
    if(LMX_SODIUM_UPSTREAM_TESTS)
        # A few upstream test-only files contain extra top-level semicolons.
        # Compile the official harness in ordinary C99 mode, leaving the
        # already built library and our smoke under -pedantic-errors.
        set(_lmx_sodium_test_cc "${_lmx_sodium_base_cc}")
        if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
            string(APPEND _lmx_sodium_test_cc " -std=c99")
        endif()
        add_test(NAME sodium.upstream_suite
            COMMAND "${LMX_MAKE_EXECUTABLE}" -C "${_lmx_sodium_build}/test/default"
                -j${LMX_EXTERNAL_JOBS} "CC=${_lmx_sodium_test_cc}" check)
        set_tests_properties(sodium.upstream_suite PROPERTIES TIMEOUT 600)
    endif()
endif()
