# Additional systems libraries: original upstream trees remain immutable.
# Select the original desktop platform implementations automatically.
find_package(Threads REQUIRED)
include("${CMAKE_CURRENT_LIST_DIR}/cmake/LibSSH2.cmake")
set(_sys_vendor "${LMX_VENDOR_DIR}")
function(lmx_system_library name)
    add_library(lmx_sys_${name} STATIC ${ARGN})
    lmx_c99_target(lmx_sys_${name})
    add_library(LMX::${name} ALIAS lmx_sys_${name})
endfunction()

set(_dyad_source "${_sys_vendor}/dyad/src/dyad.c")
if(WIN32)
    # The upstream Win32 fallback defines a global inet_ntop, which collides
    # with modern ws2_32 during whole-object linking. It is private to dyad;
    # keep its implementation and calls under an internal static name.
    file(READ "${_dyad_source}" _dyad_view)
    string(REGEX MATCHALL "inet_ntop\\(" _dyad_matches "${_dyad_view}")
    list(LENGTH _dyad_matches _dyad_match_count)
    if(NOT _dyad_match_count EQUAL 3)
        message(FATAL_ERROR "Review the pinned Dyad Win32 inet_ntop helper")
    endif()
    string(REPLACE "inet_ntop(" "lmx_dyad_inet_ntop(" _dyad_view "${_dyad_view}")
    string(REPLACE "const char *lmx_dyad_inet_ntop(" "static const char *lmx_dyad_inet_ntop("
        _dyad_view "${_dyad_view}")
    set(_dyad_source "${CMAKE_CURRENT_BINARY_DIR}/dyad-win32-view.c")
    file(WRITE "${_dyad_source}" "${_dyad_view}")
endif()
lmx_system_library(dyad "${_dyad_source}")
target_include_directories(lmx_sys_dyad PUBLIC "${_sys_vendor}/dyad/src")
target_compile_definitions(lmx_sys_dyad PRIVATE _POSIX_C_SOURCE=200809L)
if(WIN32)
    target_link_libraries(lmx_sys_dyad PUBLIC ws2_32)
endif()

# Use the upstream source list with narrowly scoped POSIX feature checks;
# upstream's directory-wide -Wno-error is deliberately not part of this wrapper.
if(WIN32)
    set(_enet_platform_source win32.c)
else()
    set(_enet_platform_source unix.c)
endif()
lmx_system_library(enet
    "${_sys_vendor}/enet/callbacks.c" "${_sys_vendor}/enet/compress.c"
    "${_sys_vendor}/enet/host.c" "${_sys_vendor}/enet/list.c"
    "${_sys_vendor}/enet/packet.c" "${_sys_vendor}/enet/peer.c"
    "${_sys_vendor}/enet/protocol.c" "${_sys_vendor}/enet/${_enet_platform_source}")
target_include_directories(lmx_sys_enet PUBLIC "${_sys_vendor}/enet/include")
target_compile_definitions(lmx_sys_enet PRIVATE _POSIX_C_SOURCE=200809L)
if(WIN32)
    target_link_libraries(lmx_sys_enet PUBLIC winmm ws2_32)
else()
include(CheckSymbolExists)
include(CheckStructHasMember)
include(CheckTypeSize)
set(CMAKE_REQUIRED_DEFINITIONS -D_POSIX_C_SOURCE=200809L)
foreach(_feature IN ITEMS FCNTL POLL GETADDRINFO GETNAMEINFO INET_PTON INET_NTOP)
    string(TOLOWER "${_feature}" _symbol)
    check_symbol_exists(${_symbol} "fcntl.h;poll.h;sys/types.h;sys/socket.h;netdb.h;arpa/inet.h" LMX_ENET_${_feature})
    if(LMX_ENET_${_feature})
        target_compile_definitions(lmx_sys_enet PRIVATE HAS_${_feature}=1)
    endif()
endforeach()
check_struct_has_member("struct msghdr" msg_flags "sys/types.h;sys/socket.h" LMX_ENET_MSGHDR_FLAGS)
if(LMX_ENET_MSGHDR_FLAGS)
    target_compile_definitions(lmx_sys_enet PRIVATE HAS_MSGHDR_FLAGS=1)
endif()
set(CMAKE_EXTRA_INCLUDE_FILES sys/types.h sys/socket.h)
check_type_size(socklen_t LMX_ENET_SOCKLEN_T BUILTIN_TYPES_ONLY)
if(LMX_ENET_SOCKLEN_T)
    target_compile_definitions(lmx_sys_enet PRIVATE HAS_SOCKLEN_T=1)
endif()
unset(CMAKE_EXTRA_INCLUDE_FILES)
unset(CMAKE_REQUIRED_DEFINITIONS)
endif()

lmx_system_library(monocypher "${_sys_vendor}/monocypher/src/monocypher.c"
    "${_sys_vendor}/monocypher/src/optional/monocypher-ed25519.c")
target_include_directories(lmx_sys_monocypher PUBLIC "${_sys_vendor}/monocypher/src"
    "${_sys_vendor}/monocypher/src/optional")

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/miniz-generated")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/miniz-generated/miniz_export.h"
    "#ifndef LMX_MINIZ_EXPORT_H\n#define LMX_MINIZ_EXPORT_H\n#define MINIZ_EXPORT\n#endif\n")
lmx_system_library(miniz "${_sys_vendor}/miniz/miniz.c"
    "${_sys_vendor}/miniz/miniz_tdef.c" "${_sys_vendor}/miniz/miniz_tinfl.c"
    "${_sys_vendor}/miniz/miniz_zip.c")
target_include_directories(lmx_sys_miniz PUBLIC "${_sys_vendor}/miniz"
    "${CMAKE_CURRENT_BINARY_DIR}/miniz-generated")
# This is a public header contract, not merely an internal compiler option.
target_compile_definitions(lmx_sys_miniz PUBLIC MINIZ_NO_ZLIB_COMPATIBLE_NAMES=1
    PRIVATE _POSIX_C_SOURCE=200809L _LARGEFILE64_SOURCE=1)

lmx_system_library(lz4 "${_sys_vendor}/lz4/lib/lz4.c" "${_sys_vendor}/lz4/lib/lz4hc.c"
    "${_sys_vendor}/lz4/lib/lz4frame.c" "${_sys_vendor}/lz4/lib/lz4file.c"
    "${_sys_vendor}/lz4/lib/xxhash.c")
target_include_directories(lmx_sys_lz4 PUBLIC "${_sys_vendor}/lz4/lib")
target_compile_definitions(lmx_sys_lz4 PRIVATE _POSIX_C_SOURCE=200809L)

lmx_system_library(microtar "${_sys_vendor}/microtar/src/microtar.c")
target_include_directories(lmx_sys_microtar PUBLIC "${_sys_vendor}/microtar/src")

lmx_system_library(jsmn "${CMAKE_CURRENT_LIST_DIR}/src/jsmn.c")
target_include_directories(lmx_sys_jsmn PUBLIC "${_sys_vendor}/jsmn")
target_compile_definitions(lmx_sys_jsmn PUBLIC JSMN_STRICT=1 INTERFACE JSMN_HEADER=1)

lmx_system_library(cjson "${_sys_vendor}/cjson/cJSON.c" "${_sys_vendor}/cjson/cJSON_Utils.c")
target_include_directories(lmx_sys_cjson PUBLIC "${_sys_vendor}/cjson")
if(UNIX)
    target_link_libraries(lmx_sys_cjson PUBLIC m)
endif()
add_library(LMX::cJSON ALIAS lmx_sys_cjson)

add_library(lmx_sys_tinydir INTERFACE)
target_include_directories(lmx_sys_tinydir INTERFACE "${_sys_vendor}/tinydir")
lmx_c99_target(lmx_sys_tinydir)
add_library(LMX::tinydir ALIAS lmx_sys_tinydir)

lmx_system_library(tinycthread "${_sys_vendor}/tinycthread/source/tinycthread.c")
target_include_directories(lmx_sys_tinycthread PUBLIC "${_sys_vendor}/tinycthread/source")
target_compile_definitions(lmx_sys_tinycthread PRIVATE _POSIX_C_SOURCE=200809L)
target_link_libraries(lmx_sys_tinycthread PUBLIC Threads::Threads)

# Release tarball already includes encoding/*.inc and fullwidth.inc. Perl is
# needed only when regenerating upstream tables, not for this selected build.
file(GLOB _vterm_c CONFIGURE_DEPENDS "${_sys_vendor}/libvterm/src/*.c")
lmx_system_library(libvterm ${_vterm_c})
target_include_directories(lmx_sys_libvterm PUBLIC "${_sys_vendor}/libvterm/include"
    PRIVATE "${_sys_vendor}/libvterm/src")
add_library(LMX::vterm ALIAS lmx_sys_libvterm)

add_library(lmx_systems INTERFACE)
target_link_libraries(lmx_systems INTERFACE LMX::dyad LMX::enet LMX::libssh2
    LMX::monocypher LMX::miniz LMX::lz4 LMX::microtar LMX::jsmn LMX::cjson
    LMX::tinydir LMX::tinycthread LMX::libvterm)
add_library(LMX::systems ALIAS lmx_systems)
lmx_c99_target(lmx_systems)

if(BUILD_TESTING)
    function(lmx_system_test name)
        add_executable(lmx_sys_test_${name} "${CMAKE_CURRENT_LIST_DIR}/tests/${name}.c")
        lmx_c99_target(lmx_sys_test_${name})
        target_compile_definitions(lmx_sys_test_${name} PRIVATE _POSIX_C_SOURCE=200809L)
        target_link_libraries(lmx_sys_test_${name} PRIVATE ${ARGN})
        add_test(NAME systems.${name} COMMAND lmx_sys_test_${name})
        set_tests_properties(systems.${name} PROPERTIES TIMEOUT 15)
    endfunction()
    lmx_system_test(dyad LMX::dyad)
    lmx_system_test(enet LMX::enet)
    lmx_system_test(libssh2 LMX::libssh2)
    lmx_system_test(libssh2_security LMX::libssh2 LMX::mbedcrypto LMX::zlib)
    get_property(_ssh_view GLOBAL PROPERTY LMX_LIBSSH2_VIEW)
    get_property(_ssh_bin GLOBAL PROPERTY LMX_LIBSSH2_BINARY)
    target_compile_definitions(lmx_sys_test_libssh2_security PRIVATE
        HAVE_CONFIG_H LIBSSH2_MBEDTLS LIBSSH2_HAVE_ZLIB _DEFAULT_SOURCE=1
        LMX_LIBSSH2_SFTP_SOURCE="${_ssh_view}/src/sftp.c")
    target_include_directories(lmx_sys_test_libssh2_security PRIVATE
        "${_ssh_view}/src" "${_ssh_bin}/src")
    set_tests_properties(systems.libssh2_security PROPERTIES TIMEOUT 5)
    lmx_system_test(monocypher LMX::monocypher)
    lmx_system_test(miniz LMX::miniz LMX::zlib)
    lmx_system_test(lz4 LMX::lz4)
    lmx_system_test(microtar LMX::microtar)
    lmx_system_test(json LMX::jsmn LMX::cjson)
    lmx_system_test(tinydir LMX::tinydir)
    target_compile_definitions(lmx_sys_test_tinydir PRIVATE LMX_TINYDIR_FIXTURE="${_sys_vendor}/tinydir")
    lmx_system_test(tinycthread LMX::tinycthread)
    lmx_system_test(libvterm LMX::libvterm)
    lmx_system_test(combined LMX::systems LMX::zlib)
endif()
