# Copy only this component's Windows DLL. Any additional application/compiler
# DLLs are determined by the consumer's own link, not by this helper.
function(lmx_copy_postgresql_runtime target)
  if(WIN32)
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
        "$<TARGET_FILE:lmx_pq>" "$<TARGET_FILE_DIR:${target}>"
      VERBATIM)
  endif()
endfunction()

