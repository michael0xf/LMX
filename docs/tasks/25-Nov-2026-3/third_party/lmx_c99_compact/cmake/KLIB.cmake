# klib snapshot 97a0fcb790b43b9e5da8994f4671021fec036f19.
# Kept separate from upstream: see docs/KLIB.md and provenance/klib.json.
set(_lmx_klib "${CMAKE_CURRENT_LIST_DIR}/../vendor/klib")
set(_lmx_klib_tests "${CMAKE_CURRENT_LIST_DIR}/../tests")

add_library(lmx_klib_headers INTERFACE)
add_library(LMX::klib_headers ALIAS lmx_klib_headers)
target_include_directories(lmx_klib_headers INTERFACE "${_lmx_klib}")
target_compile_features(lmx_klib_headers INTERFACE c_std_99)

add_library(lmx_klib STATIC
  "${_lmx_klib}/kalloc.c"
  "${_lmx_klib}/kbarena.c"
  "${_lmx_klib}/keigen.c"
  "${_lmx_klib}/kmempool.c"
  "${_lmx_klib}/ksa.c"
  "${_lmx_klib}/kson.c"
  "${_lmx_klib}/kstring.c"
  "${_lmx_klib}/lmx/kexpr_c99.c"
  "${_lmx_klib}/lmx/knhx_c99.c"
  "${_lmx_klib}/lmx/kmath_c99.c"
  "${_lmx_klib}/lmx/ksa64_c99.c")
add_library(LMX::klib ALIAS lmx_klib)
lmx_c99_target(lmx_klib)
target_link_libraries(lmx_klib PUBLIC lmx_klib_headers)
if(UNIX)
  target_link_libraries(lmx_klib PUBLIC m)
endif()

# POSIX APIs are allowed by the user and kept distinct from ISO C syntax.
# Third-party dependencies are explicit and never downloaded by this adapter.
option(LMX_KLIB_POSIX "Build klib POSIX/XSI support, including BGZF/zlib and kurl/libcurl" ${UNIX})

# kthread is valid in the project's C99 compiler mode but also needs explicit
# GNU-compatible atomics/stack-allocation intrinsics. Never silently substitute
# a different synchronization implementation.
set(_lmx_klib_threads_default OFF)
if(UNIX)
  find_package(Threads QUIET)
  if(Threads_FOUND AND CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    include(CheckCSourceCompiles)
    include(CMakePushCheckState)
    cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Threads::Threads)
    if(LMX_STRICT_C99)
      set(CMAKE_REQUIRED_FLAGS "-pedantic-errors")
    endif()
    check_c_source_compiles([=[
      #include <pthread.h>
      #include <stdint.h>
      int main(void) {
        volatile long counter = 0;
        long *space = (long *)__builtin_alloca(sizeof(long));
        pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
        *space = __sync_fetch_and_add(&counter, 1);
        pthread_mutex_lock(&mutex);
        pthread_mutex_unlock(&mutex);
        pthread_mutex_destroy(&mutex);
        return (int)*space;
      }
    ]=] LMX_KLIB_HAVE_THREAD_INTRINSICS)
    cmake_pop_check_state()
    if(LMX_KLIB_HAVE_THREAD_INTRINSICS)
      set(_lmx_klib_threads_default ON)
    endif()
  endif()
endif()
option(LMX_KLIB_THREADS "Build klib kthread (POSIX threads and checked compiler intrinsics)" ${_lmx_klib_threads_default})
if(LMX_KLIB_THREADS)
  if(NOT UNIX OR NOT Threads_FOUND OR NOT LMX_KLIB_HAVE_THREAD_INTRINSICS)
    message(FATAL_ERROR "LMX_KLIB_THREADS requires POSIX threads and compiler support for __sync atomics and __builtin_alloca.")
  endif()
  add_library(lmx_klib_threads STATIC "${_lmx_klib}/lmx/kthread_posix.c")
  add_library(LMX::klib_threads ALIAS lmx_klib_threads)
  lmx_c99_target(lmx_klib_threads)
  target_link_libraries(lmx_klib_threads PUBLIC lmx_klib_headers Threads::Threads)
endif()

if(LMX_KLIB_POSIX)
  if(NOT UNIX)
    message(FATAL_ERROR "Selected klib OS adapters currently require POSIX/Unix. Use LMX_KLIB_POSIX=OFF for the portable core on another target.")
  endif()
endif()

# Replace GNU void-pointer arithmetic in generated build-directory copies.
# The retained upstream source files stay unmodified.
set(_lmx_klib_gen "${CMAKE_CURRENT_BINARY_DIR}/klib-generated")
file(MAKE_DIRECTORY "${_lmx_klib_gen}")
if(LMX_KLIB_POSIX)
  set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_lmx_klib}/knetfile.c")
  file(READ "${_lmx_klib}/knetfile.c" _lmx_klib_text)
  string(REPLACE "buf + l" "(char *)buf + l" _lmx_klib_text "${_lmx_klib_text}")
  file(WRITE "${_lmx_klib_gen}/knetfile_c99.c" "#include <sys/select.h>\n${_lmx_klib_text}")
  add_library(lmx_klib_posix STATIC
    "${_lmx_klib}/khmm.c"
    "${_lmx_klib}/lmx/kopen_posix.c"
    "${_lmx_klib_gen}/knetfile_c99.c")
  add_library(LMX::klib_posix ALIAS lmx_klib_posix)
  lmx_c99_target(lmx_klib_posix)
  target_compile_definitions(lmx_klib_posix PRIVATE _XOPEN_SOURCE=700)
  target_link_libraries(lmx_klib_posix PUBLIC lmx_klib m)
endif()

if(LMX_KLIB_POSIX)
  if(NOT TARGET ZLIB::ZLIB)
    find_package(ZLIB REQUIRED)
  endif()
  if(NOT TARGET CURL::libcurl)
    find_package(CURL REQUIRED)
  endif()
  set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_lmx_klib}/bgzf.c")
  file(READ "${_lmx_klib}/bgzf.c" _lmx_klib_text)
  string(REPLACE "fp->uncompressed_block + input_length"
    "(char *)fp->uncompressed_block + input_length" _lmx_klib_text "${_lmx_klib_text}")
  string(REPLACE "fp->compressed_block + 18"
    "(unsigned char *)fp->compressed_block + 18" _lmx_klib_text "${_lmx_klib_text}")
  file(WRITE "${_lmx_klib_gen}/bgzf_c99.c" "${_lmx_klib_text}")
  set_source_files_properties("${_lmx_klib_gen}/bgzf_c99.c" PROPERTIES
    COMPILE_DEFINITIONS _POSIX_C_SOURCE=200809L)
  target_sources(lmx_klib PRIVATE
    "${_lmx_klib_gen}/bgzf_c99.c"
    "${_lmx_klib}/lmx/kurl_posix.c")
  target_link_libraries(lmx_klib PUBLIC ZLIB::ZLIB CURL::libcurl)
endif()

if(BUILD_TESTING)
  set(_lmx_klib_enabled_tests core headers hash_l avl)
  if(LMX_KLIB_POSIX)
    list(APPEND _lmx_klib_enabled_tests bgzf curl)
  endif()
  foreach(_lmx_klib_test IN LISTS _lmx_klib_enabled_tests)
    add_executable(klib_${_lmx_klib_test}_test
      "${_lmx_klib_tests}/klib_${_lmx_klib_test}_test.c")
    lmx_c99_target(klib_${_lmx_klib_test}_test)
    target_link_libraries(klib_${_lmx_klib_test}_test PRIVATE lmx_klib)
    add_test(NAME klib_${_lmx_klib_test}
      COMMAND klib_${_lmx_klib_test}_test)
  endforeach()
  foreach(_lmx_klib_opt posix threads)
    if(TARGET lmx_klib_${_lmx_klib_opt})
      add_executable(klib_${_lmx_klib_opt}_test
        "${_lmx_klib_tests}/klib_${_lmx_klib_opt}_test.c")
      lmx_c99_target(klib_${_lmx_klib_opt}_test)
      target_link_libraries(klib_${_lmx_klib_opt}_test PRIVATE lmx_klib_${_lmx_klib_opt})
      add_test(NAME klib_${_lmx_klib_opt} COMMAND klib_${_lmx_klib_opt}_test)
      set_tests_properties(klib_${_lmx_klib_opt} PROPERTIES TIMEOUT 15)
    endif()
  endforeach()
endif()
