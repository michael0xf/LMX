# CivetWeb 1.16 with a generated Mbed TLS 3.6 compatibility copy.
# Original vendor sources remain unchanged; no configure/build-time downloads.
include_guard(GLOBAL)
set(_lmx_civetweb_root "${CMAKE_CURRENT_LIST_DIR}/..")
set(_lmx_civetweb_source "${_lmx_civetweb_root}/vendor/civetweb")
option(LMX_CIVETWEB_TLS "Enable CivetWeb HTTPS with bundled Mbed TLS" ON)
option(LMX_CIVETWEB_ZLIB "Enable CivetWeb compression with zlib" ON)

if(LMX_CIVETWEB_TLS)
    include("${CMAKE_CURRENT_LIST_DIR}/MbedTLS.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/CivetWebMbedTLSCompat.cmake")
    lmx_civetweb_mbedtls_copy("${_lmx_civetweb_source}/src"
        "${CMAKE_CURRENT_BINARY_DIR}/lmx-civetweb-compat")
    set(_lmx_civetweb_compilation_source
        "${CMAKE_CURRENT_BINARY_DIR}/lmx-civetweb-compat/civetweb.c")
else()
    set(_lmx_civetweb_compilation_source "${_lmx_civetweb_source}/src/civetweb.c")
endif()

find_package(Threads REQUIRED)
add_library(lmx_civetweb STATIC "${_lmx_civetweb_compilation_source}")
add_library(LMX::civetweb ALIAS lmx_civetweb)
target_include_directories(lmx_civetweb PUBLIC "${_lmx_civetweb_source}/include"
    PRIVATE "${_lmx_civetweb_source}/src")
target_compile_definitions(lmx_civetweb PRIVATE USE_WEBSOCKET USE_IPV6)
target_link_libraries(lmx_civetweb PUBLIC Threads::Threads)
if(LMX_CIVETWEB_TLS)
    # NO_SSL excludes the legacy OpenSSL/dlopen paths. USE_MBEDTLS still
    # enables the server TLS transport and its feature flag in CivetWeb 1.16.
    target_compile_definitions(lmx_civetweb PRIVATE USE_MBEDTLS NO_SSL)
    target_link_libraries(lmx_civetweb PUBLIC LMX::mbedtls)
else()
    target_compile_definitions(lmx_civetweb PRIVATE NO_SSL)
endif()

# USE_LUA, USE_DUKTAPE and USE_HTTP2 remain undefined. The C++ wrapper,
# standalone server and upstream tests are not part of this C-only target.
# No OpenSSL backend or runtime TLS library discovery is used.
if(LMX_CIVETWEB_ZLIB)
    if(TARGET LMX::zlib)
        target_link_libraries(lmx_civetweb PUBLIC LMX::zlib)
    else()
        # Standalone runtime group: allow a previously prepared zlib prefix.
        if(NOT TARGET ZLIB::ZLIB)
            find_package(ZLIB REQUIRED)
        endif()
        target_link_libraries(lmx_civetweb PUBLIC ZLIB::ZLIB)
    endif()
    target_compile_definitions(lmx_civetweb PRIVATE USE_ZLIB=1)
endif()

if(WIN32)
    target_link_libraries(lmx_civetweb PUBLIC ws2_32)
elseif(UNIX AND NOT APPLE)
    # Older POSIX runtimes provide clock_gettime in librt rather than libc.
    find_library(_lmx_civetweb_rt NAMES rt)
    if(_lmx_civetweb_rt)
        target_link_libraries(lmx_civetweb PUBLIC "${_lmx_civetweb_rt}")
    endif()
endif()
lmx_c99_target(lmx_civetweb)
message(STATUS "LMX CivetWeb 1.16: C99, HTTP/WebSocket/IPv6, Mbed TLS=${LMX_CIVETWEB_TLS}, zlib=${LMX_CIVETWEB_ZLIB}")

unset(_lmx_civetweb_source)

if(BUILD_TESTING AND LMX_CIVETWEB_TLS AND TARGET LMX::curl)
    add_executable(lmx_network_https_test "${_lmx_civetweb_root}/tests/network_https_test.c")
    lmx_c99_target(lmx_network_https_test)
    target_link_libraries(lmx_network_https_test PRIVATE LMX::civetweb LMX::curl Threads::Threads)
    add_test(NAME network_https_verified_and_rejected
        COMMAND lmx_network_https_test "${_lmx_civetweb_root}/tests/tls-fixtures")
    set_tests_properties(network_https_verified_and_rejected PROPERTIES TIMEOUT 45)
endif()
