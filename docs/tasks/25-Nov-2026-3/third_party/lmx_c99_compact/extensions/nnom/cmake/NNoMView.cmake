# Reproducible private build copy; upstream files are never edited.
function(lmx_nnom_view source destination)
    set(_files
        src/backends/nnom_local.c
        src/backends/nnom_local_q15.c
        inc/nnom_local.h
        src/layers/nnom_dense.c
        src/layers/nnom_conv2d.c)
    set(_hashes
        82c81638546cba486f176474164e729d1bd427137a7455911999a0be53678e5a
        191babc04f56af61df800657632c858f7f4882abeb54daecdc321b4d2d7e418e
        ab17114404a60fd4e6055f16009e87d63721ffe25f23e3245d04178b95302858
        640c3188f66a9f2bb1438e492f6ab8e59a1219c2905f9fe59bace5c2ed1f74c0
        9c85c697df5b0ec9127633297a5a1b0f67f25662299e7af557c17457d92d5494)
    foreach(_index RANGE 0 4)
        list(GET _files ${_index} _file)
        list(GET _hashes ${_index} _expected)
        file(SHA256 "${source}/${_file}" _actual)
        if(NOT _actual STREQUAL _expected)
            message(FATAL_ERROR "NNoM source pin mismatch: ${_file}")
        endif()
    endforeach()
    file(MAKE_DIRECTORY "${destination}")
    file(COPY "${source}/inc" "${source}/src" "${source}/port" DESTINATION "${destination}")

    # Legacy constructors create owned metadata tensors and must install the
    # same cleanup callbacks already used by their structured counterparts.
    foreach(_kind IN ITEMS dense conv2d)
        set(_file "${destination}/src/layers/nnom_${_kind}.c")
        file(READ "${_file}" _text)
        set(_old "\tlayer->super.build = ${_kind}_build;\n\n")
        string(FIND "${_text}" "${_old}" _found)
        if(_found EQUAL -1)
            message(FATAL_ERROR "NNoM ${_kind} constructor patch anchor missing")
        endif()
        string(REPLACE "${_old}"
            "\tlayer->super.build = ${_kind}_build;\n\tlayer->super.free = ${_kind}_free;\n\n"
            _text "${_text}")
        file(WRITE "${_file}" "/* LMX adapted build copy: install owned-tensor cleanup. */\n${_text}")
    endforeach()

    foreach(_name IN ITEMS nnom_local.c nnom_local_q15.c)
        set(_file "${destination}/src/backends/${_name}")
        file(READ "${_file}" _text)
        string(REPLACE "#include \"nnom_local.h\""
            "#include \"nnom_local.h\"\n#include \"lmx_nnom_scaling.h\"" _text "${_text}")
        if(_name STREQUAL "nnom_local.c")
            # Only the optimized tail uses this spelling. The already
            # advanced pBias must continue after complete four-output groups.
            string(REPLACE "ip_out=((q31_t)(*bias++) << bias_shift)"
                "ip_out=((q31_t)(*pBias++) << bias_shift)" _text "${_text}")
            string(REPLACE "*des++ = (q15_t)*src++<<8;"
                "*des++ = (q15_t)((int32_t)*src++ * 256);" _text "${_text}")
        endif()
        foreach(_value IN ITEMS "bias[i]" "bias[i_ch_out]")
            string(REPLACE "((q31_t)(${_value}) << bias_shift[shift_idx])"
                "lmx_nnom_scale_signed(${_value}, bias_shift[shift_idx])" _text "${_text}")
        endforeach()
        foreach(_value IN ITEMS "bias[i]" "*pBias++" "*bias++")
            string(REPLACE "((q31_t)(${_value}) << bias_shift)"
                "lmx_nnom_scale_signed(${_value}, bias_shift)" _text "${_text}")
        endforeach()
        string(REPLACE "data[i] = data[i] << int_bit;"
            "data[i] = lmx_nnom_scale_signed(data[i], int_bit);" _text "${_text}")
        file(WRITE "${_file}" "/* LMX adapted build copy: signed scaling and q7 dense tail bias. */\n${_text}")
    endforeach()

    # Encode negative q7/q15 tanh constants as signed decimal values rather
    # than relying on out-of-range positive-to-signed conversions.
    set(_file "${destination}/inc/nnom_local.h")
    file(READ "${_file}" _text)
    foreach(_bits IN ITEMS 8 16)
        math(EXPR _q "${_bits} - 1")
        string(FIND "${_text}" "static const q${_q}_t nnom_tanh_table_q${_q}[256] = {" _begin)
        if(_begin EQUAL -1)
            message(FATAL_ERROR "NNoM tanh table patch anchor missing")
        endif()
        string(SUBSTRING "${_text}" ${_begin} -1 _tail)
        string(FIND "${_tail}" "};" _end)
        math(EXPR _length "${_end} + 2")
        string(SUBSTRING "${_tail}" 0 ${_length} _block)
        string(REGEX MATCHALL "0x[0-9a-fA-F]+" _hex_values "${_block}")
        list(REMOVE_DUPLICATES _hex_values)
        math(EXPR _threshold "1 << (${_bits} - 1)")
        foreach(_hex IN LISTS _hex_values)
            math(EXPR _value "${_hex}")
            if(_value GREATER_EQUAL _threshold)
                math(EXPR _signed "${_value} - (1 << ${_bits})")
                string(REPLACE "${_hex}" "${_signed}" _block "${_block}")
            endif()
        endforeach()
        string(SUBSTRING "${_text}" 0 ${_begin} _prefix)
        string(SUBSTRING "${_tail}" ${_length} -1 _suffix)
        set(_text "${_prefix}${_block}${_suffix}")
    endforeach()
    file(WRITE "${_file}" "/* LMX adapted build copy: explicitly signed tanh constants. */\n${_text}")
    configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/lmx_nnom_scaling.h"
        "${destination}/inc/lmx_nnom_scaling.h" COPYONLY)
endfunction()
