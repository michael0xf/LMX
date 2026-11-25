find_package(Python3 REQUIRED COMPONENTS Interpreter)
add_executable(lmx_xlsxio_roundtrip examples/roundtrip.c)
target_link_libraries(lmx_xlsxio_roundtrip PRIVATE LMX::xlsxio)
lmx_c99_target(lmx_xlsxio_roundtrip)
set(_xlsxio_test_file "${CMAKE_CURRENT_BINARY_DIR}/xlsxio-roundtrip.xlsx")
add_test(NAME xlsxio_roundtrip COMMAND lmx_xlsxio_roundtrip "${_xlsxio_test_file}")
set_tests_properties(xlsxio_roundtrip PROPERTIES FIXTURES_SETUP xlsxio_fixture)
add_test(NAME xlsxio_independent_zipxml
  COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/verify_zipxml.py"
          "${_xlsxio_test_file}")
set_tests_properties(xlsxio_independent_zipxml PROPERTIES FIXTURES_REQUIRED xlsxio_fixture)
