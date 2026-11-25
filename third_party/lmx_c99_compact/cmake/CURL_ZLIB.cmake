# Full, unmodified curl 8.23.0 and zlib 1.4 sources; local build policy only.
# No network access or dependency downloads occur during configuration/build.
include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/MbedTLS.cmake")
set(_lmx_transport_root "${CMAKE_CURRENT_LIST_DIR}/..")

function(_lmx_add_zlib)
  set(ZLIB_BUILD_TESTING OFF)
  set(ZLIB_BUILD_SHARED OFF)
  set(ZLIB_BUILD_STATIC ON)
  set(ZLIB_INSTALL OFF)
  add_subdirectory("${_lmx_transport_root}/vendor/zlib"
    "${CMAKE_CURRENT_BINARY_DIR}/lmx-zlib")
endfunction()

if(NOT TARGET LMX::zlib)
  if(TARGET ZLIB::ZLIB)
    message(FATAL_ERROR "Include CURL_ZLIB.cmake before finding another ZLIB::ZLIB: this bundle builds its own zlib 1.4.")
  endif()
  _lmx_add_zlib()
  lmx_c99_target(zlibstatic)
  add_library(LMX::zlib ALIAS zlibstatic)
  # Preserve the standard target name for klib and other CMake consumers.
  # curl does not link this unbuilt target in its feature probes.
  add_library(ZLIB::ZLIB INTERFACE IMPORTED GLOBAL)
endif()

# Additional consumers share this exact zlib, including the in-tree libssh2.
set_property(TARGET ZLIB::ZLIB PROPERTY INTERFACE_LINK_LIBRARIES zlibstatic)
if(LMX_WITH_SYSTEMS AND LMX_CURL_WITH_LIBSSH2)
  include("${_lmx_transport_root}/extensions/systems/cmake/LibSSH2.cmake")
endif()

function(_lmx_add_curl)
  # Scope generic upstream options locally so other libraries retain their own
  # test/build settings. CMP0077 makes normal variables authoritative.
  set(BUILD_CURL_EXE OFF)
  set(BUILD_SHARED_LIBS OFF)
  set(BUILD_STATIC_LIBS ON)
  set(BUILD_STATIC_CURL ON)
  set(SHARE_LIB_OBJECT OFF)
  set(BUILD_TESTING OFF)
  set(BUILD_EXAMPLES OFF)
  set(BUILD_LIBCURL_DOCS OFF)
  set(BUILD_MISC_DOCS OFF)
  set(ENABLE_CURL_MANUAL OFF)
  set(CMAKE_DISABLE_FIND_PACKAGE_Perl TRUE)
  set(PERL_EXECUTABLE "")
  set(CURL_DISABLE_INSTALL ON)
  set(CURL_ENABLE_EXPORT_TARGET OFF)
  set(PICKY_COMPILER OFF)
  set(CURL_USE_CMAKECONFIG OFF)
  set(CURL_USE_PKGCONFIG OFF)
  set(ENABLE_ARES OFF)
  set(CURL_USE_GNUTLS OFF)
  set(CURL_USE_MBEDTLS ON)
  set(CURL_USE_OPENSSL OFF)
  set(CURL_USE_SCHANNEL OFF)
  set(CURL_DEFAULT_SSL_BACKEND "mbedtls")
  set(CURL_USE_WOLFSSL OFF)
  set(CURL_USE_RUSTLS OFF)
  set(CURL_USE_LIBPSL OFF)
  if(LMX_WITH_SYSTEMS AND LMX_CURL_WITH_LIBSSH2)
    set(CURL_USE_LIBSSH2 ON)
    set(LIBSSH2_USE_STATIC_LIBS ON)
    set(LIBSSH2_INCLUDE_DIR "${_lmx_transport_root}/vendor/libssh2/include"
        CACHE PATH "Bundled libssh2 headers" FORCE)
    set(LIBSSH2_LIBRARY LMX::libssh2 CACHE STRING "Bundled libssh2 CMake target" FORCE)
  else()
    set(CURL_USE_LIBSSH2 OFF)
  endif()
  set(CURL_USE_LIBSSH OFF)
  set(CURL_USE_GSASL OFF)
  set(CURL_USE_GSSAPI OFF)
  set(CURL_USE_LIBUV OFF)
  set(CURL_USE_LIBBACKTRACE OFF)
  set(USE_LIBIDN2 OFF)
  set(USE_NGHTTP2 OFF)
  set(USE_NGTCP2 OFF)
  set(USE_QUICHE OFF)
  set(USE_OPENSSL_QUIC OFF)
  set(USE_HTTPSRR OFF)
  set(USE_ECH OFF)
  set(USE_PROXY_HTTP3 OFF)
  # curl implements these as string cache variables, not option(); set the
  # cache explicitly so its older CMP0126 policy cannot reset them to AUTO.
  set(CURL_BROTLI OFF CACHE STRING "LMX transport profile: no external brotli" FORCE)
  set(CURL_ZSTD OFF CACHE STRING "LMX transport profile: no external zstd" FORCE)
  set(CURL_DISABLE_LDAP ON)
  set(CURL_DISABLE_LDAPS ON)
  set(CURL_DISABLE_HTTP OFF)
  set(CURL_DISABLE_FILE OFF)
  set(CURL_DISABLE_WEBSOCKETS OFF)
  set(ENABLE_UNIX_SOCKETS ON)
  # Point curl's finder at the existing local CMake targets. Their headers
  # and exact version are available now; archives are built by the graph.
  set(MBEDTLS_USE_STATIC_LIBS ON)
  # Older CMake find_* policies can replace normal variables with empty cache
  # entries left by a previous dependency finder. Pin both finders to this
  # same in-tree TLS instance, including when libssh2 was configured first.
  set(MBEDTLS_INCLUDE_DIR "${_lmx_transport_root}/vendor/mbedtls/include"
      CACHE PATH "Bundled Mbed TLS headers" FORCE)
  set(MBEDTLS_LIBRARY mbedtls CACHE STRING "Bundled Mbed TLS target" FORCE)
  set(MBEDX509_LIBRARY mbedx509 CACHE STRING "Bundled Mbed X509 target" FORCE)
  set(MBEDCRYPTO_LIBRARY mbedcrypto CACHE STRING "Bundled Mbed crypto target" FORCE)

  # curl's only Mbed TLS link probe asks whether DES is present. Check the
  # declaration and configuration without trying to link unbuilt targets.
  # A real known-answer/link test in mbedtls_smoke_test verifies this promise.
  include(CheckCSourceCompiles)
  include(CMakePushCheckState)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${MBEDTLS_INCLUDE_DIR}")
  set(CMAKE_REQUIRED_DEFINITIONS
      "-DMBEDTLS_USER_CONFIG_FILE=\"${MBEDTLS_USER_CONFIG_FILE}\"")
  set(_lmx_saved_try_compile_type "${CMAKE_TRY_COMPILE_TARGET_TYPE}")
  set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
  check_c_source_compiles("#include <mbedtls/des.h>
#ifndef MBEDTLS_DES_C
#error DES disabled
#endif
int check(void) { return mbedtls_des_crypt_ecb((mbedtls_des_context *)0,
    (const unsigned char *)0, (unsigned char *)0); }
" LMX_MBEDTLS_HAS_DES_DECL)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE "${_lmx_saved_try_compile_type}")
  cmake_pop_check_state()
  if(NOT LMX_MBEDTLS_HAS_DES_DECL)
    message(FATAL_ERROR "The pinned Mbed TLS profile lacks the DES API used by curl NTLM.")
  endif()
  set(HAVE_MBEDTLS_DES_CRYPT_ECB 1)
  message(STATUS "LMX curl TLS: bundled Mbed TLS 3.6.7")

  # curl's configure-time feature probes cannot link an as-yet unbuilt in-tree
  # zlib target. Disable host zlib discovery, then enable HAVE_LIBZ and link
  # the bundled target below. No upstream file or generated header is patched.
  set(CURL_ZLIB OFF CACHE STRING "LMX attaches bundled zlib after curl feature probes" FORCE)

  # Apply the same diagnostics to feature probes and real compilation; this
  # prevents a C11 atomics probe from enabling unavailable C99 constructs.
  if(LMX_STRICT_C99 AND CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    string(APPEND CMAKE_C_FLAGS " -pedantic-errors")
  endif()
  add_subdirectory("${_lmx_transport_root}/vendor/curl"
    "${CMAKE_CURRENT_BINARY_DIR}/lmx-curl")
endfunction()

if(NOT TARGET LMX::curl)
  if(TARGET CURL::libcurl)
    message(FATAL_ERROR "Include CURL_ZLIB.cmake before finding another CURL::libcurl: this bundle builds its own curl 8.23.0.")
  endif()
  _lmx_add_curl()
  set_property(TARGET ZLIB::ZLIB PROPERTY INTERFACE_LINK_LIBRARIES zlibstatic)
  set_property(TARGET ZLIB::ZLIB PROPERTY INTERFACE_INCLUDE_DIRECTORIES "")
  lmx_c99_target(libcurl_static)
  target_compile_definitions(libcurl_static PRIVATE HAVE_LIBZ=1)
  target_link_libraries(libcurl_static PRIVATE ZLIB::ZLIB)
  add_library(LMX::curl ALIAS libcurl_static)
  message(STATUS "LMX curl: bundled zlib 1.4 enabled for HTTP gzip/deflate")
endif()

if(BUILD_TESTING)
  add_executable(zlib_smoke_test "${_lmx_transport_root}/tests/zlib_smoke_test.c")
  lmx_c99_target(zlib_smoke_test)
  target_link_libraries(zlib_smoke_test PRIVATE LMX::zlib)
  add_test(NAME zlib_roundtrip COMMAND zlib_smoke_test)

  add_executable(curl_smoke_test "${_lmx_transport_root}/tests/curl_smoke_test.c")
  lmx_c99_target(curl_smoke_test)
  target_link_libraries(curl_smoke_test PRIVATE LMX::curl)
  add_test(NAME curl_version_and_url COMMAND curl_smoke_test)
  if(UNIX)
    add_executable(curl_http_test "${_lmx_transport_root}/tests/curl_http_test.c")
    lmx_c99_target(curl_http_test)
    target_link_libraries(curl_http_test PRIVATE LMX::curl LMX::zlib)
    add_test(NAME curl_local_http_gzip COMMAND curl_http_test)
    set_tests_properties(curl_local_http_gzip PROPERTIES TIMEOUT 15)
  endif()
endif()
