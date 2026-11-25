cmake_minimum_required(VERSION 3.20)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(lmx_pdf_extra LANGUAGES C)
    set(LMX_PDF_EXTRA_STANDALONE ON)
    enable_testing()
endif()

set(LMX_PDF_VENDOR "${CMAKE_CURRENT_LIST_DIR}/../../vendor")
set(LMX_PDFIO_SOURCE_DIR "${LMX_PDF_VENDOR}/pdfio" CACHE PATH "PDFio production source directory")
set(LMX_PDF_DEPENDENCY_VENDOR "${LMX_PDF_VENDOR}" CACHE PATH "Existing compact collection vendor directory with zlib")
option(LMX_PDF_EXTRA_BUILD_TESTS "Build offline PDF write/read checks" ${LMX_PDF_EXTRA_STANDALONE})
option(LMX_PDFIO_RUN_KNOWN_FAILURE "Also run the known failing encrypted CreationDate regression" OFF)

if(NOT COMMAND lmx_c99_target)
    function(lmx_c99_target target)
        get_target_property(_type ${target} TYPE)
        if(_type STREQUAL "INTERFACE_LIBRARY")
            target_compile_features(${target} INTERFACE c_std_99)
        else()
            set_target_properties(${target} PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
            if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
                target_compile_options(${target} PRIVATE -pedantic-errors)
            endif()
        endif()
    endfunction()
endif()

# The full bundle already provides this exact target. This fallback also makes
# the retained group independently rebuildable, without fetching dependencies.
if(NOT TARGET LMX::zlib)
    function(_lmx_pdf_add_zlib)
        set(ZLIB_BUILD_TESTING OFF)
        set(ZLIB_BUILD_SHARED OFF)
        set(ZLIB_BUILD_STATIC ON)
        set(ZLIB_INSTALL OFF)
        add_subdirectory("${LMX_PDF_DEPENDENCY_VENDOR}/zlib" "${CMAKE_CURRENT_BINARY_DIR}/lmx-zlib")
    endfunction()
    _lmx_pdf_add_zlib()
    lmx_c99_target(zlibstatic)
    add_library(LMX::zlib ALIAS zlibstatic)
endif()

set(_lmx_pdf_sources
    pdfio-aes.c pdfio-array.c pdfio-common.c pdfio-crypto.c
    pdfio-dict.c pdfio-file.c pdfio-md5.c pdfio-object.c pdfio-page.c
    pdfio-rc4.c pdfio-sha256.c pdfio-stream.c pdfio-string.c pdfio-token.c
    pdfio-value.c ttf.c)
list(TRANSFORM _lmx_pdf_sources PREPEND "${LMX_PDFIO_SOURCE_DIR}/")
include("${CMAKE_CURRENT_LIST_DIR}/prepare_pdfio.cmake")
add_library(lmx_pdfio STATIC ${_lmx_pdf_sources} "${LMX_PDFIO_CONTENT_SOURCE}")
add_library(LMX::pdfio ALIAS lmx_pdfio)
target_include_directories(lmx_pdfio PUBLIC "${LMX_PDFIO_SOURCE_DIR}")
target_link_libraries(lmx_pdfio PUBLIC LMX::zlib)
lmx_c99_target(lmx_pdfio)

# PDFio's C99 source uses POSIX file/time APIs on Unix and the retained Win32
# branches on Windows. This is a hosted profile, not a freestanding one.
if(WIN32)
    target_compile_definitions(lmx_pdfio PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_link_libraries(lmx_pdfio PUBLIC advapi32)
else()
    target_compile_definitions(lmx_pdfio PRIVATE _POSIX_C_SOURCE=200809L _DEFAULT_SOURCE _GNU_SOURCE)
    target_link_libraries(lmx_pdfio PUBLIC m)
    function(_lmx_pdf_detect_time)
        include(CheckSymbolExists)
        include(CheckStructHasMember)
        list(APPEND CMAKE_REQUIRED_DEFINITIONS -D_POSIX_C_SOURCE=200809L -D_DEFAULT_SOURCE -D_GNU_SOURCE)
        check_symbol_exists(timegm "time.h" LMX_PDF_HAVE_TIMEGM)
        check_struct_has_member("struct tm" tm_gmtoff "time.h" LMX_PDF_HAVE_TM_GMTOFF)
        if(LMX_PDF_HAVE_TIMEGM)
            target_compile_definitions(lmx_pdfio PRIVATE HAVE_TIMEGM=1)
        endif()
        if(LMX_PDF_HAVE_TM_GMTOFF)
            target_compile_definitions(lmx_pdfio PRIVATE HAVE_TM_GMTOFF=1)
        endif()
    endfunction()
    _lmx_pdf_detect_time()
endif()

# HAVE_LIBPNG deliberately stays undefined. The baseline uses PDFio's built-in
# PNG loader and JPEG passthrough; it does not link libpng or libjpeg.
add_library(lmx_pdf_extra INTERFACE)
add_library(LMX::pdf_extra ALIAS lmx_pdf_extra)
target_link_libraries(lmx_pdf_extra INTERFACE LMX::pdfio)
lmx_c99_target(lmx_pdf_extra)

if(LMX_PDF_EXTRA_BUILD_TESTS)
    enable_testing()
    add_executable(lmx_pdf_test_pdfio tests/test_pdfio.c)
    target_link_libraries(lmx_pdf_test_pdfio PRIVATE LMX::pdfio)
    lmx_c99_target(lmx_pdf_test_pdfio)
    add_executable(lmx_pdf_repro_encrypted_date tests/repro_encrypted_date.c)
    target_link_libraries(lmx_pdf_repro_encrypted_date PRIVATE LMX::pdfio)
    lmx_c99_target(lmx_pdf_repro_encrypted_date)
    foreach(_case roundtrip invalid encrypted)
        add_test(NAME pdf_extra.${_case}
            COMMAND lmx_pdf_test_pdfio ${_case} "${CMAKE_CURRENT_BINARY_DIR}/pdfio-${_case}")
    endforeach()
    if(LMX_PDFIO_RUN_KNOWN_FAILURE)
        # Deliberately not WILL_FAIL: this test remains red while the defect is
        # present. See KNOWN_LIMITATIONS.md for its observed result and scope.
        add_test(NAME pdf_extra.encrypted_date_known_failure
            COMMAND lmx_pdf_repro_encrypted_date "${CMAKE_CURRENT_BINARY_DIR}/pdfio-encrypted-date.pdf")
    endif()
endif()
