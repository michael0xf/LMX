# Keep upstream inputs untouched. The public correct.h contract says encode
# returns bytes written. The pinned implementation instead returns 255 for
# shortened blocks, even though only msg_length + parity bytes were written.
file(READ "${_correct_vendor}/src/reed-solomon/encode.c" _correct_rs_encode)
set(_correct_old_return "    return rs->block_length;")
set(_correct_new_return "    return (ssize_t)(msg_length + rs->min_distance);")
string(REGEX MATCHALL "return rs->block_length" _correct_return_matches "${_correct_rs_encode}")
list(LENGTH _correct_return_matches _correct_return_count)
if(NOT _correct_return_count EQUAL 1)
    message(FATAL_ERROR "libcorrect shortened-block fix no longer matches pinned upstream")
endif()
string(REPLACE "${_correct_old_return}" "${_correct_new_return}"
       _correct_rs_encode "${_correct_rs_encode}")
set(_correct_rs_encode_view "${CMAKE_CURRENT_BINARY_DIR}/compat/libcorrect/reed-solomon/encode.c")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/compat/libcorrect/reed-solomon")
file(WRITE "${_correct_rs_encode_view}" "${_correct_rs_encode}")
