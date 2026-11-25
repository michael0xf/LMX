# Preserve the downloaded source tree. All adaptations are generated in build/.
function(lmx_sgp4_view source_dir output_dir)
    file(MAKE_DIRECTORY "${output_dir}")
    set(_sgp4_files SGP4.c SGP4.h TLE.c TLE.h)
    set(_sgp4_hashes
        461c5c70e16c1de6b2e7850c0a45745288cdb3ab5c42b74bf24dbed3c2b4d027
        d12bf2f20a88aaa92fffc64f5292a93c84333d1b9ec2f8f8ada2ffae3dfd6762
        f168ec458f2ac982f12becc347df8885a98fcd9cc5268dad6594bb43c885ff27
        3796d7a17d2edc74b233719036a5bd78a2505fae59e0566db7b3eb30887079cd)
    foreach(_i RANGE 0 3)
        list(GET _sgp4_files ${_i} _name)
        list(GET _sgp4_hashes ${_i} _expected)
        file(SHA256 "${source_dir}/${_name}" _actual)
        if(NOT _actual STREQUAL _expected)
            message(FATAL_ERROR "SGP4 source hash mismatch: ${_name}")
        endif()
        configure_file("${source_dir}/${_name}" "${output_dir}/${_name}" COPYONLY)
    endforeach()

    file(READ "${source_dir}/TLE.h" _header)
    string(REPLACE "#include \"SGP4.h\"" "#include <stdint.h>\n#include \"SGP4.h\"" _header "${_header}")
    string(REPLACE "long epoch;" "int64_t epoch;" _header "${_header}")
    string(REPLACE "long parseEpoch(" "int64_t parseEpoch(" _header "${_header}")
    string(REPLACE "long millisSince1970" "int64_t millisSince1970" _header "${_header}")
    file(WRITE "${output_dir}/TLE.h" "${_header}")

    file(READ "${source_dir}/TLE.c" _source)
    string(REPLACE "long parseEpoch(" "int64_t parseEpoch(" _source "${_source}")
    string(REPLACE "long epoch = (long)diff2;" "int64_t epoch = (int64_t)diff2;" _source "${_source}")
    string(REPLACE "epoch+=(long)diff;" "epoch+=(int64_t)diff;" _source "${_source}")
    string(REPLACE "long millisSince1970" "int64_t millisSince1970" _source "${_source}")
    string(REPLACE "double diff = millisSince1970-tle->epoch;"
        "double diff = (double)millisSince1970-(double)tle->epoch;" _source "${_source}")
    # Terminate immediately after the bytes actually copied.
    string(REPLACE "tmp[15]=0;" "tmp[14]=0;" _source "${_source}")
    string(REPLACE "tmp2[11]=0;" "tmp2[10]=0;" _source "${_source}")
    string(REPLACE "strncpy(tle->intlid,&line1[9],8);"
        "strncpy(tle->intlid,&line1[9],8);\n    tle->intlid[8]=0;" _source "${_source}")
    string(REPLACE "strncpy(rec->satid,tle->objectID,5);"
        "strncpy(rec->satid,tle->objectID,5);\n    rec->satid[5]=0;" _source "${_source}")
    file(WRITE "${output_dir}/TLE.c" "${_source}")
endfunction()
