cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
  message(FATAL_ERROR "The acoustic group requires the base lmx_c99_target helper")
endif()
if(NOT UNIX AND NOT MINGW)
  message(FATAL_ERROR "Acoustic requires C99 complex and POSIX APIs: use Unix or MinGW-w64 with POSIX threads on Windows (not MSVC)")
endif()
if(NOT TARGET LMX::correct_fec)
  message(FATAL_ERROR "Enable the channel_codes group before acoustic (LMX::correct_fec)")
endif()
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)
if(NOT CMAKE_USE_PTHREADS_INIT)
  message(FATAL_ERROR "Quiet requires POSIX pthreads; on Windows select the MinGW-w64 POSIX-thread toolchain")
endif()
include(CheckCSourceCompiles)
include(CMakePushCheckState)
cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LIBRARIES Threads::Threads)
set(CMAKE_REQUIRED_DEFINITIONS -D_XOPEN_SOURCE=700)
check_c_source_compiles("#include <pthread.h>
#include <time.h>
static pthread_once_t once_control = PTHREAD_ONCE_INIT;
static void init_once(void) {}
int main(void) {
  pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
  pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
  pthread_key_t key;
  struct timespec deadline = {0, 0};
  pthread_once(&once_control, init_once);
  pthread_key_create(&key, 0);
  pthread_setspecific(key, 0);
  pthread_getspecific(key);
  pthread_mutex_lock(&mutex);
  pthread_cond_timedwait(&cond, &mutex, &deadline);
  pthread_mutex_unlock(&mutex);
  pthread_key_delete(key);
  pthread_cond_destroy(&cond);
  return pthread_mutex_destroy(&mutex);
}" LMX_ACOUSTIC_HAVE_PTHREAD_API)
cmake_pop_check_state()
if(NOT LMX_ACOUSTIC_HAVE_PTHREAD_API)
  message(FATAL_ERROR "Quiet requires pthread mutex/condition/once/thread-local-key APIs")
endif()
find_package(Python3 3.8 REQUIRED COMPONENTS Interpreter)
set(_acoustic_vendor "${LMX_VENDOR_DIR}")
set(_acoustic_generated "${CMAKE_CURRENT_BINARY_DIR}/generated")

function(_lmx_acoustic_jansson)
  set(JANSSON_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
  set(JANSSON_EXAMPLES OFF CACHE BOOL "" FORCE)
  set(JANSSON_BUILD_DOCS OFF CACHE BOOL "" FORCE)
  set(JANSSON_WITHOUT_TESTS ON CACHE BOOL "" FORCE)
  set(JANSSON_INSTALL OFF CACHE BOOL "" FORCE)
  add_subdirectory("${_acoustic_vendor}/jansson" "${CMAKE_CURRENT_BINARY_DIR}/jansson")
  lmx_c99_target(jansson)
  set_target_properties(jansson PROPERTIES POSITION_INDEPENDENT_CODE ON)
  # utf.h is internal, but its helpers have external linkage upstream. Avoid
  # collisions with STC while preserving every public jansson.h symbol.
  foreach(_utf8_helper encode check_first check_full iterate check_string)
    target_compile_definitions(jansson PRIVATE
      "utf8_${_utf8_helper}=lmx_jansson_utf8_${_utf8_helper}")
  endforeach()
endfunction()
_lmx_acoustic_jansson()
add_library(LMX::jansson ALIAS jansson)

execute_process(COMMAND "${Python3_EXECUTABLE}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/build_views.py"
  "${_acoustic_vendor}" "${_acoustic_generated}"
  RESULT_VARIABLE _acoustic_view_result)
if(NOT _acoustic_view_result EQUAL 0)
  message(FATAL_ERROR "Could not create the pinned acoustic C99/POSIX build views")
endif()

# Full official Liquid-DSP core. This build has only the internal FFT backend:
# no optional external FFT package lookup or link can enter this target.
function(_lmx_acoustic_liquid_config)
  set(PROJECT_COPYRIGHT "Copyright (c) 2007 - 2026 Joseph D. Gaeddert")
  set(PROJECT_LICENSE "MIT")
  set(PROJECT_AUTHOR "Joseph D. Gaeddert <joseph@liquidsdr.org>")
  set(PROJECT_HOMEPAGE "https://liquidsdr.org")
  set(PROJECT_DESCRIPTION "Software-defined radio digital signal processing library")
  set(ENABLE_LOGGING 1)
  set(LIQUID_LOG_LEVEL_COMPILE 0)
  set(ENABLE_COLOR 0)
  set(BUILD_ENV "LMX C99/POSIX; full scalar core; internal FFT")
  foreach(_simd ALTIVEC NEON MMX SSE SSE2 SSE3 SSSE3 SSE41 SSE42 AVX FMA3 AVX2 AVX512 AMX AMX101 AMX102)
    set(BUILD_${_simd} 0)
  endforeach()
  configure_file("${_acoustic_vendor}/liquid_dsp/cmake/liquid.config.h.in"
    "${_acoustic_generated}/liquid_include/liquid.config.h" @ONLY)
endfunction()
_lmx_acoustic_liquid_config()
include("${_acoustic_generated}/LiquidSources.cmake")
add_library(lmx_liquid_dsp STATIC ${_lmx_liquid_sources})
add_library(LMX::liquid_dsp ALIAS lmx_liquid_dsp)
lmx_c99_target(lmx_liquid_dsp)
set_target_properties(lmx_liquid_dsp PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(lmx_liquid_dsp
  PUBLIC "${_acoustic_generated}/liquid_include"
  PRIVATE "${_acoustic_vendor}/liquid_dsp/include"
          "${_acoustic_vendor}/liquid_dsp/src/framing/src"
          "${_acoustic_vendor}/liquid_dsp/src/modem/src")
target_compile_definitions(lmx_liquid_dsp PUBLIC _XOPEN_SOURCE=700
  PRIVATE HAVE_FEC_H=1 HAVE_LIBFEC=1 LIQUID_FFTOVERRIDE=1
          LIQUID_LOGGING_ENABLE=1 LIQUID_LOG_LEVEL_COMPILE=0)
target_link_libraries(lmx_liquid_dsp PUBLIC LMX::correct_fec Threads::Threads)
if(UNIX)
  target_link_libraries(lmx_liquid_dsp PUBLIC m)
endif()

add_library(lmx_quiet STATIC
  "${_acoustic_generated}/quiet/src/demodulator.c"
  "${_acoustic_generated}/quiet/src/modulator.c"
  "${_acoustic_generated}/quiet/src/utility.c"
  "${_acoustic_generated}/quiet/src/decoder.c"
  "${_acoustic_generated}/quiet/src/encoder.c"
  "${_acoustic_generated}/quiet/src/profile.c"
  "${_acoustic_generated}/quiet/src/error.c"
  "${_acoustic_generated}/quiet/src/ring_blocking.c"
  compat/quiet_resampler.c)
add_library(LMX::quiet ALIAS lmx_quiet)
lmx_c99_target(lmx_quiet)
set_target_properties(lmx_quiet PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(lmx_quiet PUBLIC "${_acoustic_generated}/quiet/include"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/compat")
target_compile_definitions(lmx_quiet PUBLIC _XOPEN_SOURCE=700
  PRIVATE RING_BLOCKING=1 RING_ATOMIC=0 QUIET_PTHREAD_ERROR=1)
configure_file("${_acoustic_vendor}/quiet/quiet-profiles.json"
  "${CMAKE_CURRENT_BINARY_DIR}/share/quiet-profiles.json" COPYONLY)
target_compile_definitions(lmx_quiet PRIVATE
  QUIET_PROFILES_LOCATION="${CMAKE_CURRENT_BINARY_DIR}/share/quiet-profiles.json")
target_link_libraries(lmx_quiet PUBLIC LMX::liquid_dsp LMX::jansson Threads::Threads)
if(UNIX)
  target_link_libraries(lmx_quiet PUBLIC m)
endif()

add_library(lmx_acoustic INTERFACE)
add_library(LMX::acoustic ALIAS lmx_acoustic)
target_link_libraries(lmx_acoustic INTERFACE LMX::liquid_dsp LMX::quiet LMX::jansson)

if(BUILD_TESTING OR LMX_BUILD_EXAMPLES)
  add_executable(lmx_quiet_pcm_loopback examples/pcm_loopback.c)
  lmx_c99_target(lmx_quiet_pcm_loopback)
  target_link_libraries(lmx_quiet_pcm_loopback PRIVATE LMX::quiet)
  target_compile_definitions(lmx_quiet_pcm_loopback PRIVATE
    LMX_QUIET_DEFAULT_PROFILE_FILE="${_acoustic_vendor}/quiet/quiet-profiles.json")
endif()
if(BUILD_TESTING)
  add_executable(lmx_quiet_resampler_test tests/resampler_boundaries.c)
  lmx_c99_target(lmx_quiet_resampler_test)
  target_include_directories(lmx_quiet_resampler_test PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/compat")
  target_link_libraries(lmx_quiet_resampler_test PRIVATE LMX::quiet)
  add_test(NAME acoustic.resampler_boundaries COMMAND lmx_quiet_resampler_test)
  add_executable(lmx_liquid_core_test tests/liquid_core.c)
  lmx_c99_target(lmx_liquid_core_test)
  target_link_libraries(lmx_liquid_core_test PRIVATE LMX::liquid_dsp)
  add_test(NAME acoustic.liquid_core COMMAND lmx_liquid_core_test)
  set(_acoustic_profiles "${_acoustic_vendor}/quiet/quiet-profiles.json")
  set(_acoustic_test_profiles "${_acoustic_vendor}/quiet/tests/test-profiles.json")
  add_test(NAME acoustic.audible_44100 COMMAND lmx_quiet_pcm_loopback "${_acoustic_profiles}" audible 44100 0)
  add_test(NAME acoustic.audible_48000 COMMAND lmx_quiet_pcm_loopback "${_acoustic_profiles}" audible 48000 0)
  add_test(NAME acoustic.noisy_pcm COMMAND lmx_quiet_pcm_loopback "${_acoustic_profiles}" audible 48000 0.002)
  add_test(NAME acoustic.ofdm COMMAND lmx_quiet_pcm_loopback "${_acoustic_test_profiles}" ofdm 44100 0)
  add_test(NAME acoustic.modem COMMAND lmx_quiet_pcm_loopback "${_acoustic_test_profiles}" modem 44100 0)
  add_executable(lmx_quiet_profile_test tests/profile_errors.c)
  lmx_c99_target(lmx_quiet_profile_test)
  target_link_libraries(lmx_quiet_profile_test PRIVATE LMX::quiet)
  add_test(NAME acoustic.profiles COMMAND lmx_quiet_profile_test)
  set_tests_properties(acoustic.audible_44100 acoustic.audible_48000
    acoustic.noisy_pcm acoustic.ofdm acoustic.modem acoustic.profiles PROPERTIES TIMEOUT 45)
endif()
