cmake_minimum_required(VERSION 3.20)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  project(LMX_Platform_C99 LANGUAGES C)
  set(_lmx_platform_standalone ON)
else()
  set(_lmx_platform_standalone OFF)
endif()
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_DISABLE_PRECOMPILE_HEADERS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
option(LMX_PLATFORM_EXTRA_BUILD_TESTS "Build offline APR/APU/SDL validation" ${_lmx_platform_standalone})
option(LMX_PLATFORM_BUILD_APR "Build APR and APR-Util local POSIX profile" ON)
option(LMX_PLATFORM_SDL_X11 "Enable available X11 and OpenGL SDL backends" ON)
set(LMX_PLATFORM_VENDOR_DIR "${CMAKE_CURRENT_LIST_DIR}/../../vendor" CACHE PATH "Local source collection")
include("${CMAKE_CURRENT_LIST_DIR}/prepare_views.cmake")
find_package(Threads REQUIRED)

# SDL's full upstream platform sources are retained. This verified profile uses
# C99 Linux/POSIX code; native Objective-C/Java/C++ glue on other OSes is separate.
lmx_platform_c99_view(sdl3 "${LMX_PLATFORM_VENDOR_DIR}/sdl3" "${CMAKE_CURRENT_BINARY_DIR}/c99-views/sdl3")
function(_lmx_platform_sdl)
  foreach(o SDL_SHARED SDL_TEST_LIBRARY SDL_TESTS SDL_EXAMPLES SDL_INSTALL
      SDL_WAYLAND SDL_KMSDRM SDL_OPENGLES SDL_VULKAN SDL_GPU SDL_ALSA
      SDL_PULSEAUDIO SDL_PIPEWIRE SDL_JACK SDL_SNDIO SDL_OSS SDL_DBUS SDL_IBUS
      SDL_LIBURING SDL_HIDAPI_LIBUSB SDL_LIBUDEV SDL_DLOPEN_NOTES SDL_ANDROID_JAR
      SDL_X11_XCURSOR SDL_X11_XINPUT SDL_X11_XFIXES SDL_X11_XRANDR SDL_X11_XSCRNSAVER SDL_X11_XTEST)
    set(${o} OFF CACHE BOOL "LMX selected SDL profile" FORCE)
  endforeach()
  foreach(o SDL_STATIC SDL_UNIX_CONSOLE_BUILD SDL_TRAY)
    set(${o} ON CACHE BOOL "LMX selected SDL profile" FORCE)
  endforeach()
  set(SDL_X11 ${LMX_PLATFORM_SDL_X11} CACHE BOOL "LMX X11 profile" FORCE)
  set(SDL_OPENGL ${LMX_PLATFORM_SDL_X11} CACHE BOOL "LMX OpenGL profile" FORCE)
  add_subdirectory("${CMAKE_CURRENT_BINARY_DIR}/c99-views/sdl3" "${CMAKE_CURRENT_BINARY_DIR}/sdl3")
  set_target_properties(SDL3-static PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
  if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(SDL3-static PRIVATE -pedantic-errors)
  endif()
endfunction()
_lmx_platform_sdl()
add_library(LMX::sdl3 ALIAS SDL3-static)

if(LMX_PLATFORM_BUILD_APR)
  if(NOT UNIX)
    message(FATAL_ERROR "Verified APR adapter requires POSIX configure/make. Retained vendor/apr{,-util}/CMakeLists.txt provides upstream Windows builds; set LMX_PLATFORM_BUILD_APR=OFF for SDL-only.")
  endif()
  include(ExternalProject)
  find_program(_lmx_make NAMES gmake make REQUIRED)
  set(_apr_prefix "${CMAKE_CURRENT_BINARY_DIR}/apr-install")
  set(_apu_prefix "${CMAKE_CURRENT_BINARY_DIR}/apu-install")
  file(MAKE_DIRECTORY "${_apr_prefix}/include/apr-1" "${_apu_prefix}/include/apr-1")
  if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    set(_apr_cflags "-Os -std=c99 -pedantic-errors -fPIC")
  else()
    set(_apr_cflags "${CMAKE_C_FLAGS}")
  endif()
  ExternalProject_Add(lmx_apr_build
    SOURCE_DIR "${LMX_PLATFORM_VENDOR_DIR}/apr"
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/apr-build"
    DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
    CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "CC=${CMAKE_C_COMPILER}" "CFLAGS=${_apr_cflags}"
      /bin/sh <SOURCE_DIR>/configure --prefix=${_apr_prefix} --disable-shared
      --enable-static --enable-dso --enable-threads --enable-ipv6 --disable-pool-debug
    BUILD_COMMAND "${CMAKE_COMMAND}" "-DMAKE=${_lmx_make}" -DMODE=build -DSKIPLIST=OFF -P "${CMAKE_CURRENT_LIST_DIR}/run_make.cmake"
    INSTALL_COMMAND "${CMAKE_COMMAND}" "-DMAKE=${_lmx_make}" -DMODE=install -DSKIPLIST=OFF -P "${CMAKE_CURRENT_LIST_DIR}/run_make.cmake"
    BUILD_BYPRODUCTS "${_apr_prefix}/lib/libapr-1.a")
  add_library(lmx_apr STATIC IMPORTED GLOBAL)
  set_target_properties(lmx_apr PROPERTIES IMPORTED_LOCATION "${_apr_prefix}/lib/libapr-1.a"
    INTERFACE_INCLUDE_DIRECTORIES "${_apr_prefix}/include/apr-1"
    INTERFACE_LINK_LIBRARIES "Threads::Threads;${CMAKE_DL_LIBS}"
    INTERFACE_COMPILE_DEFINITIONS "_GNU_SOURCE")
  add_dependencies(lmx_apr lmx_apr_build)
  add_library(LMX::apr ALIAS lmx_apr)

  if(TARGET LMX::expat)
    set(_apu_expat LMX::expat)
    set(_expat_prefix "${CMAKE_CURRENT_BINARY_DIR}/expat-input")
    find_path(_expat_headers expat.h PATHS "${LMX_PLATFORM_VENDOR_DIR}/expat/lib" "${LMX_VENDOR_DIR}/expat/lib" NO_DEFAULT_PATH REQUIRED)
    add_custom_target(lmx_apu_expat_input
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${_expat_prefix}/lib" "${_expat_prefix}/include"
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different "$<TARGET_FILE:LMX::expat>" "${_expat_prefix}/lib/libexpat.a"
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_expat_headers}/expat.h" "${_expat_headers}/expat_external.h" "${_expat_prefix}/include"
      DEPENDS LMX::expat)
  else()
    find_package(EXPAT REQUIRED)
    set(_apu_expat EXPAT::EXPAT)
    get_filename_component(_expat_prefix "${EXPAT_INCLUDE_DIR}" DIRECTORY)
    add_custom_target(lmx_apu_expat_input)
  endif()
  lmx_platform_c99_view(apr-util "${LMX_PLATFORM_VENDOR_DIR}/apr-util" "${CMAKE_CURRENT_BINARY_DIR}/c99-views/apr-util")
  ExternalProject_Add(lmx_apu_build
    DEPENDS lmx_apr_build lmx_apu_expat_input
    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/c99-views/apr-util"
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/apu-build"
    DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
    CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "CC=${CMAKE_C_COMPILER}" "CFLAGS=${_apr_cflags}"
      /bin/sh <SOURCE_DIR>/configure --prefix=${_apu_prefix} --with-apr=${_apr_prefix}
      --with-expat=${_expat_prefix} --disable-shared --enable-static --disable-util-dso
      --without-ldap --without-crypto --without-pgsql --without-mysql --without-sqlite3
      --without-sqlite2 --without-oracle --without-odbc --without-gdbm --without-ndbm
      --without-berkeley-db --with-dbm=sdbm
    BUILD_COMMAND "${_lmx_make}" -j2
    INSTALL_COMMAND "${_lmx_make}" install
    BUILD_BYPRODUCTS "${_apu_prefix}/lib/libaprutil-1.a")
  add_library(lmx_apr_util STATIC IMPORTED GLOBAL)
  set_target_properties(lmx_apr_util PROPERTIES IMPORTED_LOCATION "${_apu_prefix}/lib/libaprutil-1.a"
    INTERFACE_INCLUDE_DIRECTORIES "${_apu_prefix}/include/apr-1"
    INTERFACE_LINK_LIBRARIES "LMX::apr;${_apu_expat}")
  find_library(_apu_crypt crypt)
  if(_apu_crypt)
    set_property(TARGET lmx_apr_util APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${_apu_crypt}")
  endif()
  add_dependencies(lmx_apr_util lmx_apu_build)
  add_library(LMX::apr_util ALIAS lmx_apr_util)
endif()
add_library(lmx_platform_extra INTERFACE)
add_library(LMX::platform_extra ALIAS lmx_platform_extra)
target_link_libraries(lmx_platform_extra INTERFACE LMX::sdl3)
if(LMX_PLATFORM_BUILD_APR)
  target_link_libraries(lmx_platform_extra INTERFACE LMX::apr_util)
endif()
if(LMX_PLATFORM_EXTRA_BUILD_TESTS)
  enable_testing()
  add_library(lmx_platform_test_plugin SHARED tests/test_plugin.c)
  set_target_properties(lmx_platform_test_plugin PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
  if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(lmx_platform_test_plugin PRIVATE -pedantic-errors)
  endif()
  foreach(test sdl apr apu)
    if(NOT test STREQUAL "sdl" AND NOT LMX_PLATFORM_BUILD_APR)
      continue()
    endif()
    add_executable(lmx_platform_test_${test} "tests/test_${test}.c")
    if(test STREQUAL "sdl")
      target_link_libraries(lmx_platform_test_${test} PRIVATE LMX::sdl3)
    elseif(test STREQUAL "apr")
      target_link_libraries(lmx_platform_test_${test} PRIVATE LMX::apr)
    else()
      target_link_libraries(lmx_platform_test_${test} PRIVATE LMX::apr_util)
    endif()
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
      target_compile_options(lmx_platform_test_${test} PRIVATE -pedantic-errors)
    endif()
    if(test STREQUAL "sdl")
      add_dependencies(lmx_platform_test_sdl lmx_platform_test_plugin)
      add_test(NAME platform_sdl COMMAND lmx_platform_test_sdl "$<TARGET_FILE:lmx_platform_test_plugin>")
    else()
      add_test(NAME platform_${test} COMMAND lmx_platform_test_${test})
    endif()
    set_tests_properties(platform_${test} PROPERTIES TIMEOUT 30)
  endforeach()
endif()
