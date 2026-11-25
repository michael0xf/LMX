# sqlite-vec 0.1.9: narrow, reviewed source-language adaptation.
# Originals remain unchanged; only the generated build copy is compiled.
function(lmx_sqlite_vec_c99_view source_dir output_dir)
    file(SHA256 "${source_dir}/sqlite-vec.c" _c_sha)
    file(SHA256 "${source_dir}/sqlite-vec.h" _h_sha)
    if(NOT _c_sha STREQUAL "ba081a47fa02eadc3cf6b16c314b695b84081269349aac722b4efa338fe8fd85"
       OR NOT _h_sha STREQUAL "8e4d7bfcd779c89bd19a6b2959fce24ee391b2eaf79a85a979377a36627cb060")
        message(FATAL_ERROR "Unexpected sqlite-vec 0.1.9 amalgamation; review the C99 adaptation")
    endif()
    file(READ "${source_dir}/sqlite-vec.c" _source)
    set(_redundant_typedefs [=[#ifndef _WIN32
#ifndef __EMSCRIPTEN__
#ifndef __COSMOPOLITAN__
#ifndef __wasi__
typedef u_int8_t uint8_t;
typedef u_int16_t uint16_t;
typedef u_int64_t uint64_t;
#endif
#endif
#endif
#endif
]=])
    string(REPLACE "${_redundant_typedefs}"
        "/* LMX C99: stdint.h above supplies the exact-width integer typedefs. */\n"
        _source "${_source}")
    # These binary literals have identical C99 hexadecimal values and types.
    string(REPLACE "0b10000000" "0x80" _source "${_source}")
    string(REPLACE "0b11111111" "0xff" _source "${_source}")
    file(MAKE_DIRECTORY "${output_dir}")
    file(WRITE "${output_dir}/sqlite-vec.c" "${_source}")
    configure_file("${source_dir}/sqlite-vec.h" "${output_dir}/sqlite-vec.h" COPYONLY)
endfunction()
