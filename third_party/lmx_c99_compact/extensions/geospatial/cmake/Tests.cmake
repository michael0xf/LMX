foreach(_component geodesic h3 rtree shapelib minmea)
  add_executable(lmx_geo_${_component}_smoke
    "${CMAKE_CURRENT_LIST_DIR}/../tests/${_component}_smoke.c")
  lmx_c99_target(lmx_geo_${_component}_smoke)
  target_link_libraries(lmx_geo_${_component}_smoke PRIVATE LMX::${_component})
  if(_component STREQUAL "shapelib")
    add_test(NAME geospatial.shapelib COMMAND lmx_geo_shapelib_smoke
      "${CMAKE_CURRENT_BINARY_DIR}/test-shape")
    set_tests_properties(geospatial.shapelib PROPERTIES FIXTURES_SETUP geo_shape)
  else()
    add_test(NAME geospatial.${_component} COMMAND lmx_geo_${_component}_smoke)
  endif()
endforeach()
add_test(NAME geospatial.shapefile_independent
  COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_LIST_DIR}/../tests/verify_shapefile.py"
    "${CMAKE_CURRENT_BINARY_DIR}/test-shape")
set_tests_properties(geospatial.shapefile_independent PROPERTIES FIXTURES_REQUIRED geo_shape)
add_executable(lmx_geospatial_headers "${CMAKE_CURRENT_LIST_DIR}/../tests/headers.c")
lmx_c99_target(lmx_geospatial_headers)
target_link_libraries(lmx_geospatial_headers PRIVATE LMX::geospatial)
add_test(NAME geospatial.headers COMMAND lmx_geospatial_headers)
