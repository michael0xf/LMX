cmake_minimum_required(VERSION 3.20)
project(LMX_C99_Libraries VERSION 3.3.0 LANGUAGES C)
set(LMX_VENDOR_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vendor")

# All dependency sources are retained in vendor/. No configure-time downloads.
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

option(LMX_STRICT_C99 "Reject non-C99 constructs with GCC/Clang diagnostics" ON)
option(LMX_BUILD_CATALOG_CHECKS "Run the compact catalog's combined-link C99 checks" OFF)
option(LMX_BUILD_ARCHIVE_EXAMPLES "Build practical collection and recovery examples" OFF)
option(LMX_ARCHIVE_VERIFY "Build the retained offline usage and new-component checks" OFF)
if(LMX_ARCHIVE_VERIFY)
    set(LMX_BUILD_ARCHIVE_EXAMPLES ON)
    set(LMX_BUILD_CATALOG_CHECKS ON)
    set(LMX_STORAGE_BUILD_TESTS ON)
    set(LMX_CONTROL_EXTRA_BUILD_TESTS ON)
    set(LMX_KNOWLEDGE_EXTRA_BUILD_TESTS ON)
    set(LMX_SCIENCE_EXTRA_BUILD_TESTS ON)
    set(LMX_PDF_EXTRA_BUILD_TESTS ON)
    enable_testing()
endif()
# Fixed default composition: all accepted components are included.
# To remove a group for a private build, edit its assignment manually here.
set(LMX_WITH_STB ON) # Build the selected C99 stb components
set(LMX_WITH_KLIB ON) # Build the selected C99/POSIX klib components
set(LMX_WITH_STC ON) # Build the stable STC C99 components
set(LMX_WITH_CURL_ZLIB ON) # Build static curl, zlib and shared Mbed TLS backend
set(LMX_WITH_SODIUM ON) # Build the bundled static libsodium
set(LMX_WITH_SQLITE3 ON) # Build the official SQLite C amalgamation
set(LMX_WITH_RUNTIME_EXTRAS ON) # Build decNumber and SLJIT
set(LMX_WITH_SCIENTIFIC ON) # Build transforms, splines, special functions, fitting and RNG
set(LMX_WITH_PRECISION ON) # Build LibTomMath and MPDecimal
set(LMX_WITH_QUADRATURE ON) # Build QUADPACK, Stroud, Sparse Grid HW and Sobol
set(LMX_WITH_SYSTEMS ON) # Build the verified additional networking and utility libraries
set(LMX_WITH_HTTP_PARSER ON) # llhttp parser; CivetWeb is not part of this collection
set(LMX_WITH_GRAPHICS ON) # Build the verified C99 graphics and small image libraries
set(LMX_WITH_MEDIA ON) # Build the verified C99 audio and video libraries
set(LMX_WITH_DOCUMENTS ON) # Build PDF, markup, configuration and model format libraries
set(LMX_WITH_ARCHIVES ON) # Build additional archive and binary serialization libraries
set(LMX_WITH_XLSXIO ON) # Build XLSX read/write with the bundled Expat and MiniZip
set(LMX_WITH_DATABASES ON) # Build hiredis and the documented no-TLS MongoDB client profile
set(LMX_WITH_POSTGRESQL ON) # Build libpq: static POSIX or bundled Windows DLL
set(LMX_WITH_EXTRAS ON) # Build supplemental dialogs, path, math, QR and small regex libraries
set(LMX_WITH_SQLITE_VEC ON) # Build the verified static sqlite-vec extension
set(LMX_WITH_GEOSPATIAL ON) # Build the verified C99 geospatial libraries
set(LMX_WITH_TENSORS ON) # Build the verified CPU tensor profile
set(LMX_WITH_TEXT_PATHS ON) # Path and UTF-8 utilities
set(LMX_WITH_CORE_HELPERS ON) # Compact Ryu conversion and TLSF pools
set(LMX_WITH_EMBEDDINGS ON) # Build the small C99 token-ID embedding pooling helper
set(LMX_WITH_CHANNEL_CODES ON) # Reed-Solomon and convolutional error correction
set(LMX_WITH_ACOUSTIC ON) # Shared Liquid-DSP and the Quiet PCM modem
set(LMX_WITH_ORBITS ON) # SGP4 orbital states and portable TLE timestamps
set(LMX_WITH_GENANN ON) # Compact feed-forward neural networks
set(LMX_WITH_KANN ON) # CPU autodiff graphs, neural networks and data reader
set(LMX_WITH_MICRO_MLP ON) # Tinn and the reviewed afan MLP
set(LMX_WITH_NNOM ON) # Portable scalar quantized neural inference
set(LMX_WITH_NUMERIC_EXTRA ON) # Compact numeric alternatives and arbitrary-precision real
set(LMX_WITH_TEXT_HASH_EXTRA ON) # Compact text, geometry, terminal and hash alternatives
set(LMX_WITH_NETWORK_EXTRA ON) # Local DNS, events and multicast discovery
set(LMX_WITH_STORAGE_EXTRA ON) # Media filesystems, flash records, CBOR and compression
set(LMX_WITH_CONTROL_EXTRA ON) # Sensors, control and local device protocols
set(LMX_WITH_KNOWLEDGE_EXTRA ON) # External formats, patterns, optimization and Data Matrix
set(LMX_WITH_SCIENCE_EXTRA ON) # Differential equations and astronomical routines
set(LMX_WITH_PDF_EXTRA ON) # PDF objects, pages, streams and metadata read/write
set(LMX_CURL_WITH_LIBSSH2 ON) # Enable curl SCP/SFTP using the bundled libssh2 when systems are enabled

# This compact source distribution contains production build inputs. The
# complete collection retains the test/example fixtures. Local variables also
# prevent a parent's BUILD_TESTING=ON from requesting those omitted fixtures;
# the parent's own tests and cache settings are not changed here.
set(BUILD_TESTING OFF)
set(LMX_BUILD_EXAMPLES OFF)
set(LMX_DOCUMENTS_BUILD_EXAMPLES OFF)
set(LMX_EXTRAS_BUILD_EXAMPLES OFF)
include(CTest)

function(lmx_c99_target target)
    get_target_property(target_type ${target} TYPE)
    if(target_type STREQUAL "INTERFACE_LIBRARY")
        target_compile_features(${target} INTERFACE c_std_99)
    else()
        set_target_properties(${target} PROPERTIES
            C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
        if(LMX_STRICT_C99 AND CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
            target_compile_options(${target} PRIVATE -pedantic-errors)
        endif()
    endif()
endfunction()

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/WindowsRuntime.cmake")

add_library(lmx_c99_all INTERFACE)
add_library(LMX::all ALIAS lmx_c99_all)

# Network comes first so klib/libssh2 reuse these exact targets.
if(LMX_WITH_CURL_ZLIB)
    include(cmake/CURL_ZLIB.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::curl LMX::zlib)
endif()
if(LMX_WITH_SODIUM)
    include(cmake/Sodium.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::sodium)
endif()
if(LMX_WITH_SQLITE3)
    include(cmake/SQLite.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::sqlite3)
endif()
if(LMX_WITH_RUNTIME_EXTRAS)
    include(cmake/RuntimeExtras.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::decnumber LMX::sljit)
endif()
if(LMX_WITH_STB)
    include(cmake/STB.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::stb)
endif()
if(LMX_WITH_KLIB)
    include(cmake/KLIB.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::klib)
    foreach(optional_klib_target IN ITEMS LMX::klib_posix LMX::klib_threads)
        if(TARGET ${optional_klib_target})
            target_link_libraries(lmx_c99_all INTERFACE ${optional_klib_target})
        endif()
    endforeach()
endif()
if(LMX_WITH_STC)
    include(cmake/STC.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::stc)
endif()
if(LMX_WITH_SCIENTIFIC)
    include(cmake/Scientific.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::scientific)
endif()
if(LMX_WITH_PRECISION)
    include(cmake/Precision.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::precision)
endif()
if(LMX_WITH_QUADRATURE)
    include(cmake/Quadrature.cmake)
    target_link_libraries(lmx_c99_all INTERFACE LMX::quadrature)
endif()

# Extension adapters share the single vendor/ source directory. The graphics
# API backend is selected for the target platform.
if(LMX_WITH_SYSTEMS)
    add_subdirectory(extensions/systems)
    target_link_libraries(lmx_c99_all INTERFACE LMX::systems)
endif()
if(LMX_WITH_HTTP_PARSER)
    add_subdirectory(extensions/http_parser)
    target_link_libraries(lmx_c99_all INTERFACE LMX::http_parser)
endif()
if(LMX_WITH_GRAPHICS)
    add_subdirectory(extensions/graphics)
    target_link_libraries(lmx_c99_all INTERFACE LMX::graphics)
endif()
if(LMX_WITH_MEDIA)
    add_subdirectory(extensions/media)
    target_link_libraries(lmx_c99_all INTERFACE LMX::media)
endif()
if(LMX_WITH_DOCUMENTS)
    add_subdirectory(extensions/documents)
    target_link_libraries(lmx_c99_all INTERFACE LMX::documents)
endif()
if(LMX_WITH_ARCHIVES)
    add_subdirectory(extensions/archives)
    target_link_libraries(lmx_c99_all INTERFACE LMX::archives)
endif()
if(LMX_WITH_XLSXIO)
    add_subdirectory(extensions/xlsxio)
    target_link_libraries(lmx_c99_all INTERFACE LMX::xlsxio)
endif()
if(LMX_WITH_DATABASES)
    add_subdirectory(extensions/databases)
    target_link_libraries(lmx_c99_all INTERFACE LMX::databases)
endif()
if(LMX_WITH_POSTGRESQL)
    add_subdirectory(extensions/postgresql)
    target_link_libraries(lmx_c99_all INTERFACE LMX::pq)
endif()
if(LMX_WITH_EXTRAS)
    add_subdirectory(extensions/extras)
    target_link_libraries(lmx_c99_all INTERFACE LMX::extras)
endif()
if(LMX_WITH_SQLITE_VEC)
    add_subdirectory(extensions/sqlite_vec)
    target_link_libraries(lmx_c99_all INTERFACE LMX::sqlite_vec)
endif()
if(LMX_WITH_GEOSPATIAL)
    add_subdirectory(extensions/geospatial)
    target_link_libraries(lmx_c99_all INTERFACE LMX::geospatial)
endif()
if(LMX_WITH_TENSORS)
    add_subdirectory(extensions/tensors)
    target_link_libraries(lmx_c99_all INTERFACE LMX::tensors)
endif()
if(LMX_WITH_EMBEDDINGS)
    add_subdirectory(extensions/embeddings)
    target_link_libraries(lmx_c99_all INTERFACE LMX::embeddings)
endif()

if(LMX_WITH_TEXT_PATHS)
    add_subdirectory(extensions/text_paths)
    target_link_libraries(lmx_c99_all INTERFACE LMX::text_paths)
endif()
if(LMX_WITH_CORE_HELPERS)
    add_subdirectory(extensions/core_helpers)
    target_link_libraries(lmx_c99_all INTERFACE LMX::core_helpers)
endif()
if(LMX_WITH_CHANNEL_CODES)
    add_subdirectory(extensions/channel_codes)
    target_link_libraries(lmx_c99_all INTERFACE LMX::channel_codes)
endif()
if(LMX_WITH_ACOUSTIC)
    add_subdirectory(extensions/acoustic)
    target_link_libraries(lmx_c99_all INTERFACE LMX::acoustic)
endif()
if(LMX_WITH_ORBITS)
    add_subdirectory(extensions/orbits)
    target_link_libraries(lmx_c99_all INTERFACE LMX::orbits)
endif()
if(LMX_WITH_GENANN)
    add_subdirectory(extensions/genann)
    target_link_libraries(lmx_c99_all INTERFACE LMX::mlp_genann)
endif()
if(LMX_WITH_KANN)
    add_subdirectory(extensions/kann)
    target_link_libraries(lmx_c99_all INTERFACE LMX::mlp_kann)
endif()
if(LMX_WITH_MICRO_MLP)
    add_subdirectory(extensions/micro_mlp)
    target_link_libraries(lmx_c99_all INTERFACE LMX::micro_mlp)
endif()
if(LMX_WITH_NNOM)
    add_subdirectory(extensions/nnom)
    target_link_libraries(lmx_c99_all INTERFACE LMX::mlp_nnom)
endif()

if(LMX_WITH_NUMERIC_EXTRA)
    add_subdirectory(extensions/numeric_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::numeric_extra)
endif()
if(LMX_WITH_TEXT_HASH_EXTRA)
    add_subdirectory(extensions/text_hash_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::text_hash_extra)
endif()
if(LMX_WITH_NETWORK_EXTRA)
    add_subdirectory(extensions/network_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::network_extra)
endif()
if(LMX_WITH_STORAGE_EXTRA)
    add_subdirectory(extensions/storage_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::storage_extra)
endif()
if(LMX_WITH_CONTROL_EXTRA)
    add_subdirectory(extensions/control_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::control_extra)
endif()
if(LMX_WITH_KNOWLEDGE_EXTRA)
    add_subdirectory(extensions/knowledge_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::knowledge_extra)
endif()
if(LMX_WITH_SCIENCE_EXTRA)
    add_subdirectory(extensions/science_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::science_extra)
endif()
if(LMX_WITH_PDF_EXTRA)
    add_subdirectory(extensions/pdf_extra)
    target_link_libraries(lmx_c99_all INTERFACE LMX::pdf_extra)
endif()

# Preserve the requested mathematical aggregation target and header name.
# This toolbox is not an API/ABI-compatible implementation of GNU GSL.
if(LMX_WITH_SCIENTIFIC AND LMX_WITH_PRECISION)
    add_library(c99_gsl_lite INTERFACE)
    add_library(LMX::math ALIAS c99_gsl_lite)
    target_include_directories(c99_gsl_lite INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include")
    target_link_libraries(c99_gsl_lite INTERFACE LMX::scientific LMX::precision)
    if(TARGET LMX::quadrature)
        target_link_libraries(c99_gsl_lite INTERFACE LMX::quadrature)
        target_compile_definitions(c99_gsl_lite INTERFACE LMX_MATH_HAS_QUADRATURE=1)
    endif()
    target_compile_features(c99_gsl_lite INTERFACE c_std_99)
    target_link_libraries(lmx_c99_all INTERFACE c99_gsl_lite)
    if(LMX_BUILD_EXAMPLES)
        add_executable(lmx_math_example examples/main.c)
        lmx_c99_target(lmx_math_example)
        target_link_libraries(lmx_math_example PRIVATE c99_gsl_lite)
        if(BUILD_TESTING)
            add_test(NAME examples.math COMMAND lmx_math_example)
        endif()
    endif()
endif()

if(BUILD_TESTING AND LMX_WITH_STB AND LMX_WITH_KLIB AND LMX_WITH_STC)
    add_executable(lmx_bundle_smoke tests/bundle_smoke.c)
    lmx_c99_target(lmx_bundle_smoke)
    target_link_libraries(lmx_bundle_smoke PRIVATE LMX::all)
    lmx_copy_runtime(lmx_bundle_smoke)
    foreach(extra_group IN ITEMS CURL_ZLIB SODIUM SQLITE3 RUNTIME_EXTRAS SCIENTIFIC PRECISION QUADRATURE)
        if(LMX_WITH_${extra_group})
            target_compile_definitions(lmx_bundle_smoke PRIVATE LMX_BUNDLE_${extra_group}=1)
        endif()
    endforeach()
    add_test(NAME bundle.combined_link_and_run COMMAND lmx_bundle_smoke)
endif()

if(BUILD_TESTING AND LMX_WITH_CURL_ZLIB AND LMX_WITH_SYSTEMS AND LMX_CURL_WITH_LIBSSH2)
    add_executable(lmx_curl_ssh_feature_test tests/curl_ssh_feature_test.c)
    lmx_c99_target(lmx_curl_ssh_feature_test)
    target_link_libraries(lmx_curl_ssh_feature_test PRIVATE LMX::curl LMX::libssh2)
    add_test(NAME expanded.curl_scp_sftp_features COMMAND lmx_curl_ssh_feature_test)
    add_executable(lmx_sftp_local_client tests/sftp_local_client.c)
    lmx_c99_target(lmx_sftp_local_client)
    target_link_libraries(lmx_sftp_local_client PRIVATE LMX::curl)
    find_package(Python3 COMPONENTS Interpreter QUIET)
    if(Python3_Interpreter_FOUND AND UNIX)
        add_test(NAME expanded.sftp_local_verified_host
            COMMAND "${Python3_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/tests/sftp_local_test.py"
                "$<TARGET_FILE:lmx_sftp_local_client>")
        set_tests_properties(expanded.sftp_local_verified_host PROPERTIES
            TIMEOUT 45 SKIP_RETURN_CODE 77)
    endif()
endif()

# These tests are retained in this patch and do not need the omitted historical
# test fixtures. Enable explicitly without changing the fixed bundle profile.
if(LMX_BUILD_CATALOG_CHECKS)
    enable_testing()
    add_subdirectory(extensions/catalog_checks)
endif()
if(LMX_BUILD_ARCHIVE_EXAMPLES)
    enable_testing()
    add_subdirectory(examples)
endif()
