# Full upstream sources retained; selected static C99 archive/binary APIs.
find_package(Threads REQUIRED)
set(_arc_vendor "${LMX_VENDOR_DIR}")
function(lmx_archive_library name)
    add_library(lmx_arc_${name} STATIC ${ARGN})
    lmx_c99_target(lmx_arc_${name})
    add_library(LMX::${name} ALIAS lmx_arc_${name})
endfunction()
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/kuba_zip")
configure_file("${_arc_vendor}/kuba_zip/src/zip.h" "${CMAKE_CURRENT_BINARY_DIR}/include/kuba_zip/zip.h" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/src/kuba_zip.c.in" "${CMAKE_CURRENT_BINARY_DIR}/kuba_zip.c" @ONLY)
lmx_archive_library(kuba_zip "${CMAKE_CURRENT_BINARY_DIR}/kuba_zip.c")
target_include_directories(lmx_arc_kuba_zip PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include"
    PRIVATE "${CMAKE_CURRENT_LIST_DIR}/generated")
target_compile_definitions(lmx_arc_kuba_zip PRIVATE MINIZ_NO_ZLIB_COMPATIBLE_NAMES=1
    _POSIX_C_SOURCE=200809L _DEFAULT_SOURCE=1 _FILE_OFFSET_BITS=64)
if(WIN32)
    target_compile_definitions(lmx_arc_kuba_zip PRIVATE ZIP_HAVE_SYMLINK=0)
else()
    target_compile_definitions(lmx_arc_kuba_zip PRIVATE ZIP_HAVE_SYMLINK=1)
endif()
add_library(LMX::zip ALIAS lmx_arc_kuba_zip)

# Official full-library amalgamation: compressor, decoder, dictionaries.
# Upstream input enables threads, disables assembly and legacy <=0.7 frames,
# and places its private xxHash implementation in the ZSTD_ namespace.
lmx_archive_library(zstd "${CMAKE_CURRENT_LIST_DIR}/generated/zstd.c")
target_include_directories(lmx_arc_zstd PUBLIC "${_arc_vendor}/zstd/lib")
target_compile_definitions(lmx_arc_zstd PRIVATE _POSIX_C_SOURCE=200809L
    divsufsort=lmx_zstd_divsufsort divbwt=lmx_zstd_divbwt)
# Zstd's private libdivsufsort-lite has different function signatures from
# the standalone library. Keep both real implementations in separate namespaces.
target_link_libraries(lmx_arc_zstd PUBLIC Threads::Threads)

set(_lzma_sources Bcj2.c Bra.c Bra86.c BraIA64.c CpuArch.c Delta.c
    Lzma2Dec.c LzmaDec.c Ppmd7.c Ppmd7Dec.c 7zCrc.c 7zCrcOpt.c
    7zAlloc.c 7zArcIn.c 7zBuf.c 7zBuf2.c 7zDec.c 7zFile.c 7zStream.c)
list(TRANSFORM _lzma_sources PREPEND "${_arc_vendor}/lzma_sdk/C/")
lmx_archive_library(lzma_sdk ${_lzma_sources})
target_include_directories(lmx_arc_lzma_sdk PRIVATE "${_arc_vendor}/lzma_sdk/C")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/lzma_sdk")
file(GLOB _lzma_headers "${_arc_vendor}/lzma_sdk/C/*.h")
file(COPY ${_lzma_headers} DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/include/lzma_sdk")
target_include_directories(lmx_arc_lzma_sdk PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include")
target_compile_definitions(lmx_arc_lzma_sdk PRIVATE Z7_EXTRACT_ONLY Z7_PPMD_SUPPORT
    _POSIX_C_SOURCE=200809L _FILE_OFFSET_BITS=64)
add_library(LMX::lzma ALIAS lmx_arc_lzma_sdk)

lmx_archive_library(cmp "${_arc_vendor}/cmp/cmp.c")
target_include_directories(lmx_arc_cmp PUBLIC "${_arc_vendor}/cmp")
file(GLOB _mpack_sources CONFIGURE_DEPENDS "${_arc_vendor}/mpack/src/mpack/*.c")
lmx_archive_library(mpack ${_mpack_sources})
target_include_directories(lmx_arc_mpack PUBLIC "${_arc_vendor}/mpack/src")
# Keep debug-dependent structure layout consistent for all CMake consumers.
target_compile_definitions(lmx_arc_mpack PUBLIC MPACK_DEBUG=$<IF:$<CONFIG:Debug>,1,0>)
lmx_archive_library(nanopb "${_arc_vendor}/nanopb/pb_common.c"
    "${_arc_vendor}/nanopb/pb_decode.c" "${_arc_vendor}/nanopb/pb_encode.c")
target_include_directories(lmx_arc_nanopb PUBLIC "${_arc_vendor}/nanopb")
# Select upstream's C99 assertion implementation on Windows as well. This is
# part of the public header contract; assertions remain enabled.
target_compile_definitions(lmx_arc_nanopb PUBLIC PB_C99_STATIC_ASSERT=1)

add_library(lmx_archives INTERFACE)
target_link_libraries(lmx_archives INTERFACE LMX::kuba_zip LMX::zstd LMX::lzma_sdk
    LMX::cmp LMX::mpack LMX::nanopb)
lmx_c99_target(lmx_archives)
add_library(LMX::archives ALIAS lmx_archives)

if(BUILD_TESTING)
    function(lmx_archive_test name)
        add_executable(lmx_arc_test_${name} "${CMAKE_CURRENT_LIST_DIR}/tests/${name}.c")
        lmx_c99_target(lmx_arc_test_${name})
        target_compile_definitions(lmx_arc_test_${name} PRIVATE _POSIX_C_SOURCE=200809L)
        target_link_libraries(lmx_arc_test_${name} PRIVATE ${ARGN})
        add_test(NAME archives.${name} COMMAND lmx_arc_test_${name})
        set_tests_properties(archives.${name} PROPERTIES TIMEOUT 20)
    endfunction()
    lmx_archive_test(zip LMX::kuba_zip)
    if(TARGET LMX::miniz AND TARGET LMX::zlib)
        target_link_libraries(lmx_arc_test_zip PRIVATE LMX::miniz LMX::zlib)
        target_compile_definitions(lmx_arc_test_zip PRIVATE LMX_TEST_SHARED_MINIZ_ZLIB=1)
    endif()
    lmx_archive_test(zstd LMX::zstd)
    lmx_archive_test(lzma_sdk LMX::lzma_sdk)
    target_compile_definitions(lmx_arc_test_lzma_sdk PRIVATE
        LMX_7Z_FIXTURE="${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/lmx.7z")
    lmx_archive_test(messagepack LMX::cmp LMX::mpack)
    lmx_archive_test(nanopb LMX::nanopb)
    target_sources(lmx_arc_test_nanopb PRIVATE "${CMAKE_CURRENT_LIST_DIR}/tests/generated/lmx_fixture.pb.c")
    target_include_directories(lmx_arc_test_nanopb PRIVATE "${CMAKE_CURRENT_LIST_DIR}/tests/generated")
    lmx_archive_test(combined LMX::archives)
    if(TARGET LMX::systems)
        target_sources(lmx_arc_test_combined PRIVATE
            "${CMAKE_CURRENT_LIST_DIR}/tests/combined_systems.c")
        target_link_libraries(lmx_arc_test_combined PRIVATE LMX::systems LMX::zlib)
        target_compile_definitions(lmx_arc_test_combined PRIVATE LMX_TEST_SYSTEMS=1)
    endif()
endif()
