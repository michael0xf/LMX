# Generated from individually reviewed check inventories; no downloads.
# Include after the collection targets exist. Safe to include from a deferred
# validation hook: this file never adds a subdirectory.
include_guard(GLOBAL)

function(_lmx_usage_check_target name)
    cmake_parse_arguments(CHECK "" "" "SOURCES;TARGETS;INCLUDE_DIRS;DEFINITIONS;LINK_OPTIONS" ${ARGN})
    foreach(_dependency IN LISTS CHECK_TARGETS)
        if(NOT TARGET "${_dependency}")
            message(FATAL_ERROR "Usage check ${name}: required target ${_dependency} is unavailable")
        endif()
    endforeach()
    add_executable("${name}" ${CHECK_SOURCES})
    set_target_properties("${name}" PROPERTIES
        C_STANDARD 99 C_STANDARD_REQUIRED ON C_EXTENSIONS OFF
        RUNTIME_OUTPUT_DIRECTORY "${LMX_CHECK_BINARY_DIR}/bin")
    # Assertions must execute even when the collection is built in Release.
    # Target options follow the global Release -DNDEBUG flag; production
    # library flags are never modified here.
    if(MSVC)
        target_compile_options("${name}" PRIVATE /UNDEBUG)
    elseif(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options("${name}" PRIVATE -pedantic-errors -UNDEBUG)
    endif()
    target_link_libraries("${name}" PRIVATE ${CHECK_TARGETS})
    if(CHECK_INCLUDE_DIRS)
        target_include_directories("${name}" PRIVATE ${CHECK_INCLUDE_DIRS})
    endif()
    if(CHECK_DEFINITIONS)
        target_compile_definitions("${name}" PRIVATE ${CHECK_DEFINITIONS})
    endif()
    if(CHECK_LINK_OPTIONS)
        target_link_options("${name}" PRIVATE ${CHECK_LINK_OPTIONS})
    endif()
    if(COMMAND lmx_copy_runtime)
        lmx_copy_runtime("${name}")
    endif()
    add_dependencies(lmx_usage_checks "${name}")
    set_property(GLOBAL APPEND PROPERTY LMX_USAGE_CHECK_TARGETS "${name}")
endfunction()

function(_lmx_usage_check_case name ctest_name work_subdirectory timeout)
    set(_work "${LMX_CHECK_BINARY_DIR}/work/${work_subdirectory}")
    file(MAKE_DIRECTORY "${_work}")
    add_test(NAME "${ctest_name}" COMMAND "${name}" ${ARGN})
    set_tests_properties("${ctest_name}" PROPERTIES
        TIMEOUT "${timeout}" WORKING_DIRECTORY "${_work}"
        LABELS "lmx_usage_checks")
    set_property(GLOBAL APPEND PROPERTY LMX_USAGE_CHECK_TESTS "${ctest_name}")
endfunction()

function(lmx_register_usage_checks)
    if(TARGET lmx_usage_checks)
        return()
    endif()
    set(_lmx_checks_source_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}")
    if(NOT DEFINED LMX_EXAMPLE_COLLECTION_ROOT)
        get_filename_component(LMX_EXAMPLE_COLLECTION_ROOT "${_lmx_checks_source_dir}/../.." ABSOLUTE)
    else()
        get_filename_component(LMX_EXAMPLE_COLLECTION_ROOT "${LMX_EXAMPLE_COLLECTION_ROOT}" ABSOLUTE BASE_DIR "${CMAKE_SOURCE_DIR}")
    endif()
    if(NOT DEFINED LMX_CHECK_BINARY_DIR)
        set(LMX_CHECK_BINARY_DIR "${CMAKE_BINARY_DIR}/usage-checks")
    else()
        get_filename_component(LMX_CHECK_BINARY_DIR "${LMX_CHECK_BINARY_DIR}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
    endif()
    file(MAKE_DIRECTORY "${LMX_CHECK_BINARY_DIR}")
    add_custom_target(lmx_usage_checks)
    set_property(GLOBAL PROPERTY LMX_USAGE_CHECK_TARGETS "")
    set_property(GLOBAL PROPERTY LMX_USAGE_CHECK_TESTS "")
    set_property(GLOBAL PROPERTY LMX_USAGE_CHECK_SKIPPED "")
    _lmx_usage_check_target(lmx_check_klib_core
        SOURCES "${_lmx_checks_source_dir}/scientific/klib_core.c"
        TARGETS "LMX::klib"
    )
    _lmx_usage_check_case(lmx_check_klib_core "usage_checks.klib_core" "klib_core" 30)

    _lmx_usage_check_target(lmx_check_stc_containers
        SOURCES "${_lmx_checks_source_dir}/scientific/stc_containers.c"
        TARGETS "LMX::stc"
    )
    _lmx_usage_check_case(lmx_check_stc_containers "usage_checks.stc.containers" "stc.containers" 30)

    _lmx_usage_check_target(lmx_check_precision_tommath
        SOURCES "${_lmx_checks_source_dir}/scientific/precision_tommath.c"
        TARGETS "LMX::precision"
    )
    _lmx_usage_check_case(lmx_check_precision_tommath "usage_checks.precision.tommath" "precision.tommath" 30)

    _lmx_usage_check_target(lmx_check_precision_mpdecimal
        SOURCES "${_lmx_checks_source_dir}/scientific/precision_mpdecimal.c"
        TARGETS "LMX::precision"
    )
    _lmx_usage_check_case(lmx_check_precision_mpdecimal "usage_checks.precision.mpdecimal" "precision.mpdecimal" 30)

    _lmx_usage_check_target(lmx_check_scientific_basic
        SOURCES "${_lmx_checks_source_dir}/scientific/scientific_basic.c"
        TARGETS "LMX::scientific"
    )
    _lmx_usage_check_case(lmx_check_scientific_basic "usage_checks.scientific.basic" "scientific.basic" 30)

    _lmx_usage_check_target(lmx_check_scientific_cephes
        SOURCES "${_lmx_checks_source_dir}/scientific/scientific_cephes.c"
        TARGETS "LMX::scientific"
    )
    _lmx_usage_check_case(lmx_check_scientific_cephes "usage_checks.scientific.cephes" "scientific.cephes" 30)

    _lmx_usage_check_target(lmx_check_quadrature_finite_infinite
        SOURCES "${_lmx_checks_source_dir}/scientific/quadrature_finite_infinite.c"
        TARGETS "LMX::quadrature"
    )
    _lmx_usage_check_case(lmx_check_quadrature_finite_infinite "usage_checks.quadrature.finite_infinite" "quadrature.finite_infinite" 30)

    _lmx_usage_check_target(lmx_check_quadrature_stroud_moments
        SOURCES "${_lmx_checks_source_dir}/scientific/quadrature_stroud_moments.c"
        TARGETS "LMX::quadrature"
    )
    _lmx_usage_check_case(lmx_check_quadrature_stroud_moments "usage_checks.quadrature.stroud_moments" "quadrature.stroud_moments" 30)

    _lmx_usage_check_target(lmx_check_quadrature_sobol
        SOURCES "${_lmx_checks_source_dir}/scientific/quadrature_sobol.c"
        TARGETS "LMX::quadrature"
    )
    _lmx_usage_check_case(lmx_check_quadrature_sobol "usage_checks.quadrature.sobol" "quadrature.sobol" 30)

    _lmx_usage_check_target(lmx_check_core_helpers_tlsf_pool
        SOURCES "${_lmx_checks_source_dir}/scientific/tlsf_pool.c"
        TARGETS "LMX::core_helpers"
    )
    _lmx_usage_check_case(lmx_check_core_helpers_tlsf_pool "usage_checks.core_helpers.tlsf_pool" "core_helpers.tlsf_pool" 30)

    _lmx_usage_check_target(lmx_check_core_helpers_ryu_roundtrip
        SOURCES "${_lmx_checks_source_dir}/scientific/ryu_roundtrip.c"
        TARGETS "LMX::ryu"
    )
    if(UNIX)
        target_link_libraries(lmx_check_core_helpers_ryu_roundtrip PRIVATE "m")
    endif()
    _lmx_usage_check_case(lmx_check_core_helpers_ryu_roundtrip "usage_checks.core_helpers.ryu_roundtrip" "core_helpers.ryu_roundtrip" 30)

    _lmx_usage_check_target(lmx_check_genann_serialization
        SOURCES "${_lmx_checks_source_dir}/scientific/genann_serialization.c"
        TARGETS "LMX::genann"
    )
    _lmx_usage_check_case(lmx_check_genann_serialization "usage_checks.genann.serialization" "genann.serialization" 30)

    _lmx_usage_check_target(lmx_check_kann_forward_gradient
        SOURCES "${_lmx_checks_source_dir}/scientific/kann_forward_gradient.c"
        TARGETS "LMX::kann"
    )
    get_target_property(_lmx_kann_compile_definitions LMX::kann COMPILE_DEFINITIONS)
    if("HAVE_PTHREAD=1" IN_LIST _lmx_kann_compile_definitions)
        target_compile_definitions(lmx_check_kann_forward_gradient PRIVATE "LMX_KANN_TEST_PTHREADS=1")
    endif()
    _lmx_usage_check_case(lmx_check_kann_forward_gradient "usage_checks.kann.forward_gradient" "kann.forward_gradient" 30)

    _lmx_usage_check_target(lmx_check_kann_train_serialize
        SOURCES "${_lmx_checks_source_dir}/scientific/kann_train_serialize.c"
        TARGETS "LMX::kann"
    )
    _lmx_usage_check_case(lmx_check_kann_train_serialize "usage_checks.kann.train_serialize" "kann.train_serialize" 30)

    _lmx_usage_check_target(lmx_check_nnom_conv_reference
        SOURCES "${_lmx_checks_source_dir}/scientific/nnom_conv_reference.c"
        TARGETS "LMX::nnom"
    )
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" AND NOT LMX_NNOM_STATIC_MEMORY)
        target_sources(lmx_check_nnom_conv_reference PRIVATE "${_lmx_checks_source_dir}/scientific/nnom_allocation_tracking.c")
        target_compile_definitions(lmx_check_nnom_conv_reference PRIVATE "LMX_NNOM_TRACK_ALLOCATIONS")
        target_link_options(lmx_check_nnom_conv_reference PRIVATE "-Wl,--wrap=malloc" "-Wl,--wrap=calloc" "-Wl,--wrap=free")
    endif()
    _lmx_usage_check_case(lmx_check_nnom_conv_reference "usage_checks.nnom.conv_reference" "nnom.conv_reference" 30)

    _lmx_usage_check_target(lmx_check_nnom_model_lifetime
        SOURCES "${_lmx_checks_source_dir}/scientific/nnom_model_lifetime.c"
        TARGETS "LMX::nnom"
    )
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" AND NOT LMX_NNOM_STATIC_MEMORY)
        target_sources(lmx_check_nnom_model_lifetime PRIVATE "${_lmx_checks_source_dir}/scientific/nnom_allocation_tracking.c")
        target_compile_definitions(lmx_check_nnom_model_lifetime PRIVATE "LMX_NNOM_TRACK_ALLOCATIONS")
        target_link_options(lmx_check_nnom_model_lifetime PRIVATE "-Wl,--wrap=malloc" "-Wl,--wrap=calloc" "-Wl,--wrap=free")
    endif()
    _lmx_usage_check_case(lmx_check_nnom_model_lifetime "usage_checks.nnom.model_lifetime" "nnom.model_lifetime" 30)

    _lmx_usage_check_target(lmx_check_channel_codes_rs_errors
        SOURCES "${_lmx_checks_source_dir}/scientific/reed_solomon_errors.c"
        TARGETS "LMX::channel_codes"
    )
    _lmx_usage_check_case(lmx_check_channel_codes_rs_errors "usage_checks.channel_codes.rs_errors" "channel_codes.rs_errors" 30)

    _lmx_usage_check_target(lmx_check_acoustic_liquid_core
        SOURCES "${_lmx_checks_source_dir}/scientific/liquid_core.c"
        TARGETS "LMX::liquid_dsp"
    )
    _lmx_usage_check_case(lmx_check_acoustic_liquid_core "usage_checks.acoustic.liquid_core" "acoustic.liquid_core" 30)

    _lmx_usage_check_target(lmx_check_orbits_time_and_api
        SOURCES "${_lmx_checks_source_dir}/scientific/sgp4_time_and_api.c"
        TARGETS "LMX::sgp4"
    )
    _lmx_usage_check_case(lmx_check_orbits_time_and_api "usage_checks.orbits.time_and_api" "orbits.time_and_api" 30)

    _lmx_usage_check_target(lmx_check_embeddings_static_ids
        SOURCES "${_lmx_checks_source_dir}/scientific/static_embeddings.c"
        TARGETS "LMX::static_embeddings"
    )
    _lmx_usage_check_case(lmx_check_embeddings_static_ids "usage_checks.embeddings_static_ids" "embeddings_static_ids" 30)

    _lmx_usage_check_target(lmx_check_network_systems_json
        SOURCES "${_lmx_checks_source_dir}/network/systems_json.c"
        TARGETS "LMX::jsmn" "LMX::cjson"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_systems_json "usage_checks.network_systems_json" "network_systems_json" 15)

    _lmx_usage_check_target(lmx_check_network_systems_monocypher
        SOURCES "${_lmx_checks_source_dir}/network/systems_monocypher.c"
        TARGETS "LMX::monocypher"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_systems_monocypher "usage_checks.network_systems_monocypher" "network_systems_monocypher" 15)

    _lmx_usage_check_target(lmx_check_network_systems_lz4
        SOURCES "${_lmx_checks_source_dir}/network/systems_lz4.c"
        TARGETS "LMX::lz4"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_systems_lz4 "usage_checks.network_systems_lz4" "network_systems_lz4" 15)

    _lmx_usage_check_target(lmx_check_network_systems_miniz
        SOURCES "${_lmx_checks_source_dir}/network/systems_miniz.c"
        TARGETS "LMX::miniz" "LMX::zlib"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_systems_miniz "usage_checks.network_systems_miniz" "network_systems_miniz" 15)

    _lmx_usage_check_target(lmx_check_network_systems_tinycthread
        SOURCES "${_lmx_checks_source_dir}/network/systems_tinycthread.c"
        TARGETS "LMX::tinycthread"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_systems_tinycthread "usage_checks.network_systems_tinycthread" "network_systems_tinycthread" 15)

    _lmx_usage_check_target(lmx_check_network_systems_libvterm
        SOURCES "${_lmx_checks_source_dir}/network/systems_libvterm.c"
        TARGETS "LMX::vterm"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_systems_libvterm "usage_checks.network_systems_libvterm" "network_systems_libvterm" 15)

    _lmx_usage_check_target(lmx_check_network_messagepack
        SOURCES "${_lmx_checks_source_dir}/network/messagepack.c"
        TARGETS "LMX::cmp" "LMX::mpack"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/network"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_network_messagepack "usage_checks.network_messagepack" "network_messagepack" 15)

    _lmx_usage_check_target(lmx_check_network_bson
        SOURCES "${_lmx_checks_source_dir}/network/bson.c"
        TARGETS "LMX::bson"
    )
    _lmx_usage_check_case(lmx_check_network_bson "usage_checks.network_bson" "network_bson" 15)

    _lmx_usage_check_target(lmx_check_network_mongoc_uri
        SOURCES "${_lmx_checks_source_dir}/network/mongoc_uri.c"
        TARGETS "LMX::databases"
    )
    _lmx_usage_check_case(lmx_check_network_mongoc_uri "usage_checks.network_mongoc_uri" "network_mongoc_uri" 15)

    if(UNIX)
        _lmx_usage_check_target(lmx_check_network_hiredis_protocol
            SOURCES "${_lmx_checks_source_dir}/network/hiredis_protocol.c"
            TARGETS "LMX::hiredis" "Threads::Threads"
            DEFINITIONS "_POSIX_C_SOURCE=200809L"
        )
        _lmx_usage_check_case(lmx_check_network_hiredis_protocol "usage_checks.network_hiredis_protocol" "network_hiredis_protocol" 10)
    else()
        message(STATUS "Skipping network_hiredis_protocol: condition UNIX is false")
        set_property(GLOBAL APPEND PROPERTY LMX_USAGE_CHECK_SKIPPED "network_hiredis_protocol: UNIX")
    endif()

    _lmx_usage_check_target(lmx_check_network_llhttp_streaming
        SOURCES "${_lmx_checks_source_dir}/network/llhttp_streaming.c"
        TARGETS "LMX::llhttp"
    )
    _lmx_usage_check_case(lmx_check_network_llhttp_streaming "usage_checks.network_llhttp_streaming" "network_llhttp_streaming" 15)

    _lmx_usage_check_target(lmx_check_network_sqlite_vec
        SOURCES "${_lmx_checks_source_dir}/network/sqlite_vec.c"
        TARGETS "LMX::sqlite_vec"
    )
    if(LMX_SQLITE_VEC_SIMD STREQUAL "AVX")
        target_compile_definitions(lmx_check_network_sqlite_vec PRIVATE "LMX_TEST_VEC_AVX=1")
    endif()
    _lmx_usage_check_case(lmx_check_network_sqlite_vec "usage_checks.network_sqlite_vec" "network_sqlite_vec" 15)

    _lmx_usage_check_target(lmx_check_network_sqlite3_memory
        SOURCES "${_lmx_checks_source_dir}/network/sqlite3_memory.c"
        TARGETS "LMX::sqlite3"
    )
    _lmx_usage_check_case(lmx_check_network_sqlite3_memory "usage_checks.network_sqlite3_memory" "network_sqlite3_memory" 15)

    _lmx_usage_check_target(lmx_check_network_sodium_crypto
        SOURCES "${_lmx_checks_source_dir}/network/sodium_crypto.c"
        TARGETS "LMX::sodium"
    )
    _lmx_usage_check_case(lmx_check_network_sodium_crypto "usage_checks.network_sodium_crypto" "network_sodium_crypto" 15)

    _lmx_usage_check_target(lmx_check_network_mbedtls_config_crypto
        SOURCES "${_lmx_checks_source_dir}/network/mbedtls_config_crypto.c"
        TARGETS "LMX::mbedtls"
    )
    _lmx_usage_check_case(lmx_check_network_mbedtls_config_crypto "usage_checks.network_mbedtls_config_crypto" "network_mbedtls_config_crypto" 15)

    _lmx_usage_check_target(lmx_check_formats_gui_commands
        SOURCES "${_lmx_checks_source_dir}/formats/gui_commands.c"
        TARGETS "LMX::nuklear" "LMX::microui" "LMX::olive"
    )
    _lmx_usage_check_case(lmx_check_formats_gui_commands "usage_checks.formats_gui_commands" "formats_gui_commands" 30)

    _lmx_usage_check_target(lmx_check_formats_webp_roundtrip
        SOURCES "${_lmx_checks_source_dir}/formats/webp_roundtrip.c"
        TARGETS "LMX::webp" "LMX::webpdemux" "LMX::webpmux"
    )
    _lmx_usage_check_case(lmx_check_formats_webp_roundtrip "usage_checks.formats_webp_roundtrip" "formats_webp_roundtrip" 30)

    if(UNIX)
        _lmx_usage_check_target(lmx_check_formats_video_roundtrip
            SOURCES "${_lmx_checks_source_dir}/formats/video_roundtrip.c"
            TARGETS "LMX::jo_mpeg" "LMX::pl_mpeg" "LMX::minih264" "LMX::h264bsd"
        )
        _lmx_usage_check_case(lmx_check_formats_video_roundtrip "usage_checks.formats_video_roundtrip" "formats_video_roundtrip" 30)
    else()
        message(STATUS "Skipping formats_video_roundtrip: condition UNIX is false")
        set_property(GLOBAL APPEND PROPERTY LMX_USAGE_CHECK_SKIPPED "formats_video_roundtrip: UNIX")
    endif()

    _lmx_usage_check_target(lmx_check_formats_geodesic_reference
        SOURCES "${_lmx_checks_source_dir}/formats/geodesic_reference.c"
        TARGETS "LMX::geodesic"
    )
    _lmx_usage_check_case(lmx_check_formats_geodesic_reference "usage_checks.formats_geodesic_reference" "formats_geodesic_reference" 30)

    _lmx_usage_check_target(lmx_check_formats_h3_grid
        SOURCES "${_lmx_checks_source_dir}/formats/h3_grid.c"
        TARGETS "LMX::h3"
    )
    _lmx_usage_check_case(lmx_check_formats_h3_grid "usage_checks.formats_h3_grid" "formats_h3_grid" 30)

    _lmx_usage_check_target(lmx_check_formats_nmea_parse
        SOURCES "${_lmx_checks_source_dir}/formats/nmea_parse.c"
        TARGETS "LMX::minmea"
    )
    _lmx_usage_check_case(lmx_check_formats_nmea_parse "usage_checks.formats_nmea_parse" "formats_nmea_parse" 30)

    _lmx_usage_check_target(lmx_check_formats_shapefile_roundtrip
        SOURCES "${_lmx_checks_source_dir}/formats/shapefile_roundtrip.c"
        TARGETS "LMX::shapelib"
    )
    _lmx_usage_check_case(lmx_check_formats_shapefile_roundtrip "usage_checks.formats_shapefile_roundtrip" "formats_shapefile_roundtrip" 30 "${LMX_CHECK_BINARY_DIR}/work/formats_shapefile_roundtrip/formats-shape")

    _lmx_usage_check_target(lmx_check_formats_qr_roundtrip
        SOURCES "${_lmx_checks_source_dir}/formats/qr_roundtrip.c"
        TARGETS "LMX::qrcodegen" "LMX::quirc"
    )
    _lmx_usage_check_case(lmx_check_formats_qr_roundtrip "usage_checks.formats_qr_roundtrip" "formats_qr_roundtrip" 30)

    _lmx_usage_check_target(lmx_check_formats_text_formats
        SOURCES "${_lmx_checks_source_dir}/formats/text_formats.c"
        TARGETS "LMX::md4c_html" "LMX::gumbo" "LMX::yxml" "LMX::ezxml" "LMX::tomlc99" "LMX::libyaml"
    )
    _lmx_usage_check_case(lmx_check_formats_text_formats "usage_checks.formats_text_formats.md4c" "formats_text_formats.md4c" 30 "md4c")
    _lmx_usage_check_case(lmx_check_formats_text_formats "usage_checks.formats_text_formats.gumbo" "formats_text_formats.gumbo" 30 "gumbo")
    _lmx_usage_check_case(lmx_check_formats_text_formats "usage_checks.formats_text_formats.yxml" "formats_text_formats.yxml" 30 "yxml")
    _lmx_usage_check_case(lmx_check_formats_text_formats "usage_checks.formats_text_formats.ezxml" "formats_text_formats.ezxml" 30 "ezxml")
    _lmx_usage_check_case(lmx_check_formats_text_formats "usage_checks.formats_text_formats.tomlc99" "formats_text_formats.tomlc99" 30 "tomlc99")
    _lmx_usage_check_case(lmx_check_formats_text_formats "usage_checks.formats_text_formats.libyaml" "formats_text_formats.libyaml" 30 "libyaml")

    _lmx_usage_check_target(lmx_check_formats_zip_roundtrip
        SOURCES "${_lmx_checks_source_dir}/formats/zip_roundtrip.c"
        TARGETS "LMX::kuba_zip" "LMX::miniz" "LMX::zlib"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/formats"
        DEFINITIONS "_POSIX_C_SOURCE=200809L" "LMX_TEST_SHARED_MINIZ_ZLIB=1"
    )
    _lmx_usage_check_case(lmx_check_formats_zip_roundtrip "usage_checks.formats_zip_roundtrip" "formats_zip_roundtrip" 30)

    _lmx_usage_check_target(lmx_check_formats_zstd_roundtrip
        SOURCES "${_lmx_checks_source_dir}/formats/zstd_roundtrip.c"
        TARGETS "LMX::zstd"
        INCLUDE_DIRS "${_lmx_checks_source_dir}/formats"
        DEFINITIONS "_POSIX_C_SOURCE=200809L"
    )
    _lmx_usage_check_case(lmx_check_formats_zstd_roundtrip "usage_checks.formats_zstd_roundtrip" "formats_zstd_roundtrip" 30)

    get_property(_registered GLOBAL PROPERTY LMX_USAGE_CHECK_TARGETS)
    get_property(_tests GLOBAL PROPERTY LMX_USAGE_CHECK_TESTS)
    get_property(_skipped GLOBAL PROPERTY LMX_USAGE_CHECK_SKIPPED)
    list(LENGTH _registered _count)
    list(LENGTH _tests _test_count)
    string(REPLACE ";" "\n" _target_text "${_registered}")
    string(REPLACE ";" "\n" _test_text "${_tests}")
    string(REPLACE ";" "\n" _skip_text "${_skipped}")
    file(WRITE "${LMX_CHECK_BINARY_DIR}/targets.txt" "${_target_text}\n")
    file(WRITE "${LMX_CHECK_BINARY_DIR}/ctest-names.txt" "${_test_text}\n")
    file(WRITE "${LMX_CHECK_BINARY_DIR}/skipped.txt" "${_skip_text}\n")
    message(STATUS "LMX usage checks registered: ${_count} programs, ${_test_count} cases; aggregate target lmx_usage_checks")
endfunction()

# A caller may include this file from inside its own deferred function. In that
# case enable_testing's variable would otherwise disappear on function return.
# Schedule the same command directly in the directory's deferred scope as well;
# CMake 3.20 supports this and it does not add a subdirectory.
enable_testing()
cmake_language(DEFER CALL enable_testing)
lmx_register_usage_checks()
