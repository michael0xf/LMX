cmake_minimum_required(VERSION 3.16)
# Included after the base collection; all sources are local and immutable.
if(NOT COMMAND lmx_c99_target)
  message(FATAL_ERROR "Add the LMX base collection before extensions/media")
endif()
find_package(Threads REQUIRED)
find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(_media_vendor "${LMX_VENDOR_DIR}")
set(_media_generated "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${_media_generated}")
execute_process(
  COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_views.py"
          "${_media_vendor}" "${_media_generated}"
  RESULT_VARIABLE _media_view_status)
if(NOT _media_view_status EQUAL 0)
  message(FATAL_ERROR "Could not generate checked media C99 compatibility views")
endif()

function(lmx_media_static name source includes)
  add_library(lmx_media_${name} STATIC "${source}")
  add_library(LMX::${name} ALIAS lmx_media_${name})
  target_include_directories(lmx_media_${name} PUBLIC ${includes})
  lmx_c99_target(lmx_media_${name})
  set_target_properties(lmx_media_${name} PROPERTIES POSITION_INDEPENDENT_CODE ON)
endfunction()

lmx_media_static(miniaudio adapters/miniaudio.c "${_media_vendor}/miniaudio")
target_compile_definitions(lmx_media_miniaudio PUBLIC MA_NO_SSE2 MA_NO_AVX2 MA_NO_NEON)
target_compile_definitions(lmx_media_miniaudio PRIVATE _POSIX_C_SOURCE=200809L)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(lmx_media_miniaudio PRIVATE _DEFAULT_SOURCE)
endif()
target_link_libraries(lmx_media_miniaudio PUBLIC Threads::Threads ${CMAKE_DL_LIBS})
if(UNIX)
  target_link_libraries(lmx_media_miniaudio PUBLIC m)
endif()
if(APPLE)
  target_link_libraries(lmx_media_miniaudio PUBLIC
    "-framework CoreFoundation" "-framework CoreAudio" "-framework AudioToolbox")
endif()
foreach(_name dr_wav dr_mp3 dr_flac)
  lmx_media_static(${_name} adapters/${_name}.c "${_media_vendor}/dr_libs")
  if(UNIX)
    target_link_libraries(lmx_media_${_name} PUBLIC m)
  endif()
endforeach()
target_compile_definitions(lmx_media_dr_mp3 PUBLIC DR_MP3_NO_SIMD)
target_compile_definitions(lmx_media_dr_flac PUBLIC DR_FLAC_NO_SIMD)
add_library(lmx_media_dr_libs INTERFACE)
add_library(LMX::dr_libs ALIAS lmx_media_dr_libs)
target_link_libraries(lmx_media_dr_libs INTERFACE LMX::dr_wav LMX::dr_mp3 LMX::dr_flac)

lmx_media_static(minimp3 adapters/minimp3.c "${_media_vendor}/minimp3")
target_compile_definitions(lmx_media_minimp3 PUBLIC MINIMP3_NO_SIMD)
if(UNIX)
  target_link_libraries(lmx_media_minimp3 PUBLIC m)
endif()
lmx_media_static(tinysoundfont adapters/tinysoundfont.c "${_media_vendor}/tinysoundfont")
add_library(LMX::tsf ALIAS lmx_media_tinysoundfont)
if(UNIX)
  target_link_libraries(lmx_media_tinysoundfont PUBLIC m)
endif()
foreach(_name pl_mpeg jo_mpeg jo_gif jo_mp1 minih264)
  lmx_media_static(${_name} adapters/${_name}.c "${_media_generated}")
  if(UNIX)
    target_link_libraries(lmx_media_${_name} PUBLIC m)
  endif()
endforeach()
# minih264 keeps its application-provided thread callback; it spawns no threads.
lmx_media_static(nestegg "${_media_vendor}/nestegg/src/nestegg.c"
                 "${_media_vendor}/nestegg/include")
set(_h264bsd_sources
  h264bsd_byte_stream.c h264bsd_cavlc.c h264bsd_conceal.c h264bsd_deblocking.c
  h264bsd_decoder.c h264bsd_dpb.c h264bsd_image.c h264bsd_inter_prediction.c
  h264bsd_intra_prediction.c h264bsd_macroblock_layer.c h264bsd_nal_unit.c
  h264bsd_neighbour.c h264bsd_pic_order_cnt.c h264bsd_pic_param_set.c
  h264bsd_reconstruct.c h264bsd_sei.c h264bsd_seq_param_set.c h264bsd_slice_data.c
  h264bsd_slice_group_map.c h264bsd_slice_header.c h264bsd_storage.c
  h264bsd_stream.c h264bsd_transform.c h264bsd_util.c h264bsd_vlc.c h264bsd_vui.c)
list(TRANSFORM _h264bsd_sources PREPEND "${_media_vendor}/h264bsd/src/")
add_library(lmx_media_h264bsd STATIC ${_h264bsd_sources})
add_library(LMX::h264bsd ALIAS lmx_media_h264bsd)
target_include_directories(lmx_media_h264bsd PUBLIC "${_media_vendor}/h264bsd/src")
lmx_c99_target(lmx_media_h264bsd)
set_target_properties(lmx_media_h264bsd PROPERTIES POSITION_INDEPENDENT_CODE ON)

include(cmake/WebP.cmake)

add_library(lmx_media INTERFACE)
add_library(LMX::media ALIAS lmx_media)
target_link_libraries(lmx_media INTERFACE
  LMX::miniaudio LMX::dr_libs LMX::minimp3 LMX::tinysoundfont
  LMX::pl_mpeg LMX::jo_mpeg LMX::jo_gif LMX::jo_mp1 LMX::minih264
  LMX::nestegg LMX::h264bsd LMX::webp LMX::webpdemux LMX::webpmux)
lmx_c99_target(lmx_media)

if(BUILD_TESTING)
  include(cmake/Tests.cmake OPTIONAL)
endif()
