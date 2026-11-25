function(_lmx_media_test name)
  add_executable(lmx_media_test_${name} "tests/${name}_smoke.c")
  target_link_libraries(lmx_media_test_${name} PRIVATE ${ARGN})
  target_compile_definitions(lmx_media_test_${name} PRIVATE
    MEDIA_FIXTURES="${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures")
  lmx_c99_target(lmx_media_test_${name})
  add_test(NAME media_${name} COMMAND lmx_media_test_${name})
endfunction()
_lmx_media_test(audio LMX::miniaudio LMX::dr_libs LMX::minimp3 LMX::jo_mp1 LMX::tinysoundfont)
_lmx_media_test(video LMX::jo_mpeg LMX::pl_mpeg LMX::minih264 LMX::h264bsd)
_lmx_media_test(nestegg LMX::nestegg)
_lmx_media_test(webp LMX::webp LMX::webpdemux LMX::webpmux)
_lmx_media_test(headers LMX::media)
# stb_image is already preserved by the base collection, test-only GIF oracle.
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../vendor/stb/stb_image.h")
  _lmx_media_test(gif LMX::jo_gif)
  target_include_directories(lmx_media_test_gif PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../../vendor/stb")
endif()
