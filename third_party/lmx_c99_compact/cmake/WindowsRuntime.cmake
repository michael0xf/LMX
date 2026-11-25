# Deployment helper for consumers of LMX::all. This does not alter linking.
include_guard(GLOBAL)

function(_lmx_select_winpthread_runtime output)
    get_property(_lmx_selected GLOBAL PROPERTY LMX_SELECTED_WINPTHREAD_DLL)
    if(_lmx_selected)
        set(${output} "${_lmx_selected}" PARENT_SCOPE)
        return()
    endif()
    if(NOT MINGW)
        message(FATAL_ERROR "lmx_copy_runtime: the selected Windows collection uses MinGW-w64. Supply the matching compiler runtime for another toolchain; the bundled MSVCRT DLL is not a generic UCRT/MSVC runtime.")
    endif()

    # A DLL supplied by the active compiler is preferred to any bundled copy.
    # GNU cross compilers often locate it beside their target libraries; MSYS2
    # installations commonly place it beside the compiler executable instead.
    set(_lmx_compiler_args)
    if(CMAKE_C_COMPILER_ARG1)
        separate_arguments(_lmx_compiler_args NATIVE_COMMAND "${CMAKE_C_COMPILER_ARG1}")
    endif()
    execute_process(COMMAND "${CMAKE_C_COMPILER}" ${_lmx_compiler_args}
        -print-file-name=libwinpthread-1.dll
        RESULT_VARIABLE _lmx_find_result OUTPUT_VARIABLE _lmx_candidate
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(NOT _lmx_find_result EQUAL 0 OR NOT IS_ABSOLUTE "${_lmx_candidate}"
            OR NOT EXISTS "${_lmx_candidate}")
        get_filename_component(_lmx_compiler_dir "${CMAKE_C_COMPILER}" DIRECTORY)
        set(_lmx_candidate "${_lmx_compiler_dir}/libwinpthread-1.dll")
    endif()
    if(EXISTS "${_lmx_candidate}")
        get_filename_component(_lmx_selected "${_lmx_candidate}" REALPATH)
        set(_lmx_mode "active-compiler")
    else()
        # The fallback was validated with this exact header/CRT family. Do not
        # silently combine it with UCRT, a 32-bit target or unrelated headers.
        include(CheckCSourceCompiles)
        check_c_source_compiles("#include <_mingw.h>
#if !defined(_WIN64) || !defined(__x86_64__) || !defined(__MINGW32__)
#error The bundled runtime requires x86_64 MinGW-w64
#endif
#if defined(_UCRT) || __MSVCRT_VERSION__ != 0x700
#error The bundled runtime requires the verified MSVCRT ABI
#endif
#if __MINGW64_VERSION_MAJOR != 12 || __MINGW64_VERSION_MINOR != 0 || __MINGW64_VERSION_BUGFIX != 0
#error The bundled fallback requires the verified MinGW-w64 12.0.0 headers
#endif
int main(void) { return 0; }
" LMX_BUNDLED_WINPTHREAD_COMPATIBLE)
        if(NOT LMX_BUNDLED_WINPTHREAD_COMPATIBLE)
            message(FATAL_ERROR "lmx_copy_runtime: libwinpthread-1.dll was not found in the active compiler, and the bundled x64/MSVCRT runtime does not match its ABI/header version. Install the runtime from that compiler distribution; no incompatible DLL will be copied.")
        endif()
        set(_lmx_runtime_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../prebuilt/windows-x86_64/runtime")
        file(READ "${_lmx_runtime_dir}/manifest.json" _lmx_manifest)
        string(JSON _lmx_expected GET "${_lmx_manifest}" dll_sha256)
        set(_lmx_selected "${_lmx_runtime_dir}/libwinpthread-1.dll")
        if(NOT EXISTS "${_lmx_selected}")
            message(FATAL_ERROR "Missing bundled libwinpthread-1.dll")
        endif()
        file(SHA256 "${_lmx_selected}" _lmx_actual)
        if(NOT _lmx_actual STREQUAL _lmx_expected)
            message(FATAL_ERROR "Bundled libwinpthread-1.dll checksum mismatch")
        endif()
        get_filename_component(_lmx_selected "${_lmx_selected}" REALPATH)
        set(_lmx_mode "bundled-x86_64-msvcrt-mingw12")
    endif()
    file(SHA256 "${_lmx_selected}" _lmx_sha256)
    set_property(GLOBAL PROPERTY LMX_SELECTED_WINPTHREAD_DLL "${_lmx_selected}")
    set(LMX_WINPTHREAD_RUNTIME_DLL "${_lmx_selected}" CACHE INTERNAL "Selected Windows pthread runtime" FORCE)
    set(LMX_WINPTHREAD_RUNTIME_MODE "${_lmx_mode}" CACHE INTERNAL "Windows runtime selection" FORCE)
    set(LMX_WINPTHREAD_RUNTIME_SHA256 "${_lmx_sha256}" CACHE INTERNAL "Selected runtime SHA256" FORCE)
    message(STATUS "LMX Windows pthread runtime: ${_lmx_mode}: ${_lmx_selected}")
    set(${output} "${_lmx_selected}" PARENT_SCOPE)
endfunction()

function(lmx_copy_runtime target)
    if(NOT TARGET "${target}")
        message(FATAL_ERROR "lmx_copy_runtime requires an existing consumer target: ${target}")
    endif()
    if(NOT WIN32)
        return()
    endif()
    get_target_property(_lmx_done "${target}" LMX_RUNTIME_COPY_ADDED)
    if(_lmx_done)
        return()
    endif()
    if(TARGET LMX::pq AND COMMAND lmx_copy_postgresql_runtime)
        lmx_copy_postgresql_runtime("${target}")
    endif()
    _lmx_select_winpthread_runtime(_lmx_pthread_dll)
    add_custom_command(TARGET "${target}" POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${_lmx_pthread_dll}" "$<TARGET_FILE_DIR:${target}>"
        VERBATIM)
    set_property(TARGET "${target}" PROPERTY LMX_RUNTIME_COPY_ADDED TRUE)
endfunction()
