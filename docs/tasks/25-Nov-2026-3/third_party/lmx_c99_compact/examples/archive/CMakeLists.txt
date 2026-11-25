add_executable(lmx_archive_data_rescue data_rescue.c)
set_target_properties(lmx_archive_data_rescue PROPERTIES
  C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(lmx_archive_data_rescue PRIVATE -pedantic-errors)
endif()
target_link_libraries(lmx_archive_data_rescue PRIVATE LMX::correct LMX::zlib)
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/data-rescue-output")
add_test(NAME archive.data_rescue COMMAND lmx_archive_data_rescue)
set_tests_properties(archive.data_rescue PROPERTIES
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/data-rescue-output")

add_executable(lmx_archive_suffix_zstd suffix_zstd.c)
set_target_properties(lmx_archive_suffix_zstd PROPERTIES
  C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(lmx_archive_suffix_zstd PRIVATE -pedantic-errors)
endif()
target_link_libraries(lmx_archive_suffix_zstd PRIVATE LMX::divsufsort LMX::zstd)
add_test(NAME archive.suffix_zstd_namespaces COMMAND lmx_archive_suffix_zstd)
