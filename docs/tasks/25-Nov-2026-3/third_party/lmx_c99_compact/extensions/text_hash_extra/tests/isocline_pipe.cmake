execute_process(COMMAND "${PROGRAM}" --readline INPUT_FILE "${INPUT}"
    RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE error TIMEOUT 5)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "isocline pipe check failed (${result}): ${output}${error}")
endif()
