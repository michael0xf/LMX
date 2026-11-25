cmake_minimum_required(VERSION 3.20)
# Offline, C-only supplemental libraries without X11/OpenGL/GTK build dependencies.
set(_extras_root "${CMAKE_CURRENT_LIST_DIR}")
set(_extras_vendor "${LMX_VENDOR_DIR}")
set(_extras_view "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${_extras_view}")
option(LMX_EXTRAS_BUILD_TESTS "Build supplemental functional checks" ${BUILD_TESTING})
option(LMX_EXTRAS_BUILD_EXAMPLES "Build supplemental examples" ${LMX_BUILD_EXAMPLES})
if(NOT COMMAND lmx_c99_target)
    function(lmx_c99_target target)
        set_target_properties(${target} PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
        if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
            target_compile_options(${target} PRIVATE -pedantic-errors)
        endif()
    endfunction()
endif()
add_library(lmx_extras INTERFACE)
add_library(LMX::extras ALIAS lmx_extras)
target_include_directories(lmx_extras INTERFACE "${_extras_root}/include")
function(_extras_library name)
    add_library(lmx_extras_${name} STATIC ${ARGN})
    add_library(LMX::${name} ALIAS lmx_extras_${name})
    lmx_c99_target(lmx_extras_${name})
    target_link_libraries(lmx_extras INTERFACE lmx_extras_${name})
endfunction()

_extras_library(whereami "${_extras_vendor}/whereami/src/whereami.c")
target_include_directories(lmx_extras_whereami PUBLIC "${_extras_vendor}/whereami/src")
target_link_libraries(lmx_extras_whereami PUBLIC ${CMAKE_DL_LIBS})

_extras_library(tiny_regex_c "${_extras_vendor}/tiny_regex_c/re.c")
add_library(LMX::tiny_regex ALIAS lmx_extras_tiny_regex_c)
target_include_directories(lmx_extras_tiny_regex_c PUBLIC "${_extras_vendor}/tiny_regex_c")

_extras_library(qrcodegen "${_extras_vendor}/qrcodegen/c/qrcodegen.c")
add_library(LMX::qr_code_gen ALIAS lmx_extras_qrcodegen)
target_include_directories(lmx_extras_qrcodegen PUBLIC "${_extras_vendor}/qrcodegen/c")

_extras_library(quirc
    "${_extras_vendor}/quirc/lib/quirc.c"
    "${_extras_vendor}/quirc/lib/identify.c"
    "${_extras_vendor}/quirc/lib/decode.c"
    "${_extras_vendor}/quirc/lib/version_db.c")
target_include_directories(lmx_extras_quirc PUBLIC "${_extras_vendor}/quirc/lib")
if(UNIX)
    target_link_libraries(lmx_extras_quirc PUBLIC m)
endif()

# Complete upstream Call API source list. Inline and struct APIs are retained.
set(_extras_cglm_sources)
foreach(_unit euler affine io quat cam vec2 ivec2 vec3 ivec3 vec4 ivec4
    mat2 mat2x3 mat2x4 mat3 mat3x2 mat3x4 mat4 mat4x2 mat4x3
    plane noise frustum box aabb2d project sphere ease curve bezier ray affine2d
    clipspace/ortho_lh_no clipspace/ortho_lh_zo clipspace/ortho_rh_no clipspace/ortho_rh_zo
    clipspace/persp_lh_no clipspace/persp_lh_zo clipspace/persp_rh_no clipspace/persp_rh_zo
    clipspace/view_lh_no clipspace/view_lh_zo clipspace/view_rh_no clipspace/view_rh_zo
    clipspace/project_no clipspace/project_zo)
    list(APPEND _extras_cglm_sources "${_extras_vendor}/cglm/src/${_unit}.c")
endforeach()
_extras_library(cglm ${_extras_cglm_sources})
target_include_directories(lmx_extras_cglm PUBLIC "${_extras_vendor}/cglm/include")
# This is the documented upstream C99 configuration; access struct vectors via .raw.
target_compile_definitions(lmx_extras_cglm PUBLIC CGLM_STATIC CGLM_USE_ANONYMOUS_STRUCT=0)
if(UNIX)
    target_link_libraries(lmx_extras_cglm PUBLIC m)
endif()

# tray originals are retained, but its GTK/AppIndicator backend and native
# example have no build target under the current dependency criterion.

# Core tinyfiledialogs has native Windows/macOS/UNIX implementations.
# The contributed UNIX-only more_dialogs API remains source-only.
_extras_library(tinyfiledialogs "${_extras_vendor}/tinyfiledialogs/tinyfiledialogs.c")
target_include_directories(lmx_extras_tinyfiledialogs PUBLIC "${_extras_vendor}/tinyfiledialogs")
if(WIN32)
    target_link_libraries(lmx_extras_tinyfiledialogs PUBLIC comdlg32 ole32 user32 shell32 gdi32)
endif()

if(LMX_EXTRAS_BUILD_TESTS)
    enable_testing()
    include("${_extras_root}/Tests.cmake")
endif()
if(LMX_EXTRAS_BUILD_EXAMPLES)
    add_executable(lmx_extras_qr_example "${_extras_root}/examples/qr_pgm.c")
    lmx_c99_target(lmx_extras_qr_example)
    target_link_libraries(lmx_extras_qr_example PRIVATE LMX::qrcodegen)
    add_executable(lmx_extras_path_regex_example "${_extras_root}/examples/path_regex.c")
    lmx_c99_target(lmx_extras_path_regex_example)
    target_link_libraries(lmx_extras_path_regex_example PRIVATE LMX::whereami LMX::tiny_regex_c)
endif()
