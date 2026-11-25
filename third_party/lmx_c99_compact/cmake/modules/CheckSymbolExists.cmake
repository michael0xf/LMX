# C-only, strict-C99 equivalent of CMake's CheckSymbolExists helper.
# Some CMake releases generate ((int *)(&function))[argc], which rejects a
# perfectly available function under -pedantic-errors. Test function pointers
# and object pointers separately; never convert one category into the other.
# A volatile stored address retains a real linker reference. No warning or
# language-standard diagnostic is disabled, and no result is assumed true.
include_guard(GLOBAL)
# Retain CMake's private helpers for a parent application's optional
# CheckCXXSymbolExists module. Only the C check is replaced below.
include("${CMAKE_ROOT}/Modules/CheckSymbolExists.cmake")
include(CheckCSourceCompiles)

function(check_symbol_exists symbol headers variable)
    if(DEFINED ${variable} AND NOT "${${variable}}" STREQUAL "${variable}")
        return()
    endif()
    set(_headers "")
    foreach(_header IN LISTS headers)
        string(APPEND _headers "#include <${_header}>\n")
    endforeach()
    set(_macro_start "")
    set(_macro_end "")
    if(symbol MATCHES "^[A-Za-z_][A-Za-z0-9_]*$")
        set(_macro_start "#ifndef ${symbol}\n")
        set(_macro_end "#else\nint main(void) { return 0; }\n#endif\n")
    endif()
    set(_function_source "${_headers}${_macro_start}
static void (*volatile lmx_probe_function)(void) = (void (*)(void))(&${symbol});
int main(void) { return lmx_probe_function == 0; }
${_macro_end}")
    set(_object_source "${_headers}${_macro_start}
static const volatile void *volatile lmx_probe_object = &${symbol};
int main(void) { return lmx_probe_object == 0; }
${_macro_end}")
    check_c_source_compiles("${_function_source}" _LMX_SYMBOL_${variable}_FUNCTION)
    if(_LMX_SYMBOL_${variable}_FUNCTION)
        set(${variable} 1 CACHE INTERNAL "Have C99 symbol ${symbol}" FORCE)
    else()
        check_c_source_compiles("${_object_source}" _LMX_SYMBOL_${variable}_OBJECT)
        if(_LMX_SYMBOL_${variable}_OBJECT)
            set(${variable} 1 CACHE INTERNAL "Have C99 symbol ${symbol}" FORCE)
        else()
            set(${variable} "" CACHE INTERNAL "Have C99 symbol ${symbol}" FORCE)
        endif()
    endif()
endfunction()
