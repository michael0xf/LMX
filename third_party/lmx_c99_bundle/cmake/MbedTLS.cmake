# Complete, unmodified official Mbed TLS 3.6.7 release, including framework.
include_guard(GLOBAL)
set(_lmx_mbedtls_root "${CMAKE_CURRENT_LIST_DIR}/..")

if(NOT UNIX)
    message(FATAL_ERROR "The current shared Mbed TLS profile uses POSIX pthreads; a native Windows threading adapter has not been supplied.")
endif()
find_package(Threads REQUIRED)
if(NOT CMAKE_USE_PTHREADS_INIT)
    message(FATAL_ERROR "The shared Mbed TLS profile requires POSIX pthreads.")
endif()

function(_lmx_add_mbedtls)
    # Upstream declares an older policy baseline. Preserve our scoped option
    # values when its option() calls run, including on a fresh CMake cache.
    set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
    set(ENABLE_PROGRAMS OFF)
    set(ENABLE_TESTING OFF)
    set(GEN_FILES OFF)
    set(USE_STATIC_MBEDTLS_LIBRARY ON)
    set(USE_SHARED_MBEDTLS_LIBRARY OFF)
    set(LINK_WITH_PTHREAD ON)
    set(LINK_WITH_TRUSTED_STORAGE OFF)
    set(MBEDTLS_FATAL_WARNINGS OFF)
    set(DISABLE_PACKAGE_CONFIG_AND_INSTALL ON)
    # This cache variable is a FILEPATH in upstream CMake. Pin the same config
    # for all targets to avoid a consumer/library structure-layout mismatch.
    set(MBEDTLS_CONFIG_FILE "" CACHE FILEPATH "Use upstream Mbed TLS defaults" FORCE)
    set(MBEDTLS_USER_CONFIG_FILE
        "${_lmx_mbedtls_root}/include/lmx_mbedtls_user_config.h"
        CACHE FILEPATH "LMX POSIX threaded Mbed TLS configuration" FORCE)
    # Optional Python configure diagnostics must not leave bytecode in vendor/.
    set(_lmx_had_python_bytecode_env FALSE)
    if(DEFINED ENV{PYTHONDONTWRITEBYTECODE})
        set(_lmx_had_python_bytecode_env TRUE)
        set(_lmx_python_bytecode_env "$ENV{PYTHONDONTWRITEBYTECODE}")
    endif()
    set(ENV{PYTHONDONTWRITEBYTECODE} 1)
    add_subdirectory("${_lmx_mbedtls_root}/vendor/mbedtls"
        "${CMAKE_CURRENT_BINARY_DIR}/lmx-mbedtls")
    if(_lmx_had_python_bytecode_env)
        set(ENV{PYTHONDONTWRITEBYTECODE} "${_lmx_python_bytecode_env}")
    else()
        unset(ENV{PYTHONDONTWRITEBYTECODE})
    endif()
endfunction()

if(TARGET mbedtls OR TARGET MbedTLS::mbedtls)
    message(FATAL_ERROR "Include LMX MbedTLS.cmake before another Mbed TLS instance.")
endif()
_lmx_add_mbedtls()
foreach(_lmx_tls_target IN ITEMS mbedtls mbedx509 mbedcrypto everest p256m)
    if(TARGET ${_lmx_tls_target})
        lmx_c99_target(${_lmx_tls_target})
    endif()
endforeach()
target_link_libraries(mbedcrypto PUBLIC Threads::Threads)
add_library(LMX::mbedtls ALIAS mbedtls)
add_library(LMX::mbedx509 ALIAS mbedx509)
add_library(LMX::mbedcrypto ALIAS mbedcrypto)

if(BUILD_TESTING)
    add_executable(mbedtls_smoke_test "${_lmx_mbedtls_root}/tests/mbedtls_smoke_test.c")
    lmx_c99_target(mbedtls_smoke_test)
    target_link_libraries(mbedtls_smoke_test PRIVATE LMX::mbedtls)
    add_test(NAME mbedtls_crypto_and_thread_config COMMAND mbedtls_smoke_test)
endif()
message(STATUS "LMX TLS: bundled static Mbed TLS 3.6.7, POSIX threading, C99")
