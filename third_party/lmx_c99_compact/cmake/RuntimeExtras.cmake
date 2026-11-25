# Official decNumber release and a pinned untagged SLJIT snapshot.
# Original vendor sources are not patched. No configure/build-time downloads.
set(_lmx_runtime_vendor "${CMAKE_CURRENT_LIST_DIR}/../vendor")
set(_lmx_runtime_tests "${CMAKE_CURRENT_LIST_DIR}/../tests")

set(_lmx_decnumber_sources)
foreach(_lmx_decnumber_module IN ITEMS
        decContext decNumber decPacked decimal32 decimal64 decimal128
        decSingle decDouble decQuad)
    list(APPEND _lmx_decnumber_sources
        "${_lmx_runtime_vendor}/decnumber/${_lmx_decnumber_module}.c")
endforeach()
add_library(lmx_decnumber STATIC ${_lmx_decnumber_sources})
add_library(LMX::decnumber ALIAS lmx_decnumber)
target_include_directories(lmx_decnumber PUBLIC "${_lmx_runtime_vendor}/decnumber")
# decBasic.c and decCommon.c are included by format modules, not standalone TUs.
include(TestBigEndian)
test_big_endian(_lmx_decnumber_big_endian)
if(_lmx_decnumber_big_endian)
    target_compile_definitions(lmx_decnumber PRIVATE DECLITEND=0)
else()
    target_compile_definitions(lmx_decnumber PRIVATE DECLITEND=1)
endif()
# DECNUMDIGITS is intentionally not forced globally: upstream format modules
# provide their own local capacity and callers choose storage before inclusion.
lmx_c99_target(lmx_decnumber)

# CivetWeb was removed from the active collection by the user. Its original
# source/configuration and historical tests remain as provenance only.

# This one translation unit includes the selected backend, allocator and utils.
add_library(lmx_sljit STATIC "${_lmx_runtime_vendor}/sljit/sljit_src/sljitLir.c")
add_library(LMX::sljit ALIAS lmx_sljit)
target_include_directories(lmx_sljit PUBLIC "${_lmx_runtime_vendor}/sljit/sljit_src")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(lmx_sljit PRIVATE
        _DEFAULT_SOURCE _POSIX_C_SOURCE=200809L)
endif()
if(UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(lmx_sljit PUBLIC Threads::Threads)
endif()
lmx_c99_target(lmx_sljit)

if(BUILD_TESTING)
    foreach(_lmx_runtime_name IN ITEMS decnumber sljit)
        add_executable(lmx_test_${_lmx_runtime_name}
            "${_lmx_runtime_tests}/runtime_${_lmx_runtime_name}.c")
        target_link_libraries(lmx_test_${_lmx_runtime_name}
            PRIVATE LMX::${_lmx_runtime_name})
        lmx_c99_target(lmx_test_${_lmx_runtime_name})
        add_test(NAME runtime.${_lmx_runtime_name}
            COMMAND lmx_test_${_lmx_runtime_name})
        set_tests_properties(runtime.${_lmx_runtime_name} PROPERTIES TIMEOUT 15)
    endforeach()
endif()

unset(_lmx_runtime_vendor)
unset(_lmx_runtime_tests)
unset(_lmx_decnumber_sources)
unset(_lmx_decnumber_module)
unset(_lmx_decnumber_big_endian)
unset(_lmx_runtime_name)
