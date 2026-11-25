# Vendor files remain unchanged. Adapt only error formatting and C99 varargs.
function(lmx_prepare_lsoda source_dir output_dir)
  foreach(pair IN ITEMS
      "lsoda.c|be6a6d9a72c69ba62ccb7387976e41263b43afc71e71fc08712fa6dba39fc707"
      "lsoda_internal.h|7052d666c666eea8733f7f2c33f4ac8c9376fe57964c95e0b9887c8039c969aa"
      "strdup_printf.c|38d53fa0f877b87e6d6d56d44282506b328fa934313df5d620ae70abd2b30f2b")
    string(REPLACE "|" ";" pair "${pair}")
    list(GET pair 0 name)
    list(GET pair 1 expected)
    file(SHA256 "${source_dir}/${name}" actual)
    if(NOT actual STREQUAL expected)
      message(FATAL_ERROR "Review liblsoda C99 adapter for changed upstream file ${name}")
    endif()
  endforeach()
  file(MAKE_DIRECTORY "${output_dir}")
  file(GLOB source_files "${source_dir}/*.c" "${source_dir}/*.h" "${source_dir}/*.inc")
  foreach(source IN LISTS source_files)
    get_filename_component(name "${source}" NAME)
    configure_file("${source}" "${output_dir}/${name}" COPYONLY)
  endforeach()
  file(READ "${source_dir}/lsoda_internal.h" text)
  string(REGEX REPLACE "#define ERROR\\(fmt, \\.\\.\\.\\)[^\n]*"
    "#define ERROR(...) (ctx->error? free(ctx->error):(void)1, ctx->error=_strdup_printf(__VA_ARGS__))" text "${text}")
  file(WRITE "${output_dir}/lsoda_internal.h" "${text}")
  file(READ "${source_dir}/lsoda.c" text)
  string(REPLACE "#define hardfailure(fmt,...)" "#define hardfailure(...)" text "${text}")
  string(REPLACE "#define softfailure(code, fmt,...)" "#define softfailure(code,...)" text "${text}")
  string(REPLACE "ERROR(fmt, ## __VA_ARGS__)" "ERROR(__VA_ARGS__)" text "${text}")
  file(WRITE "${output_dir}/lsoda.c" "${text}")
  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/compat/strdup_printf.c"
    "${output_dir}/strdup_printf.c" COPYONLY)
endfunction()
