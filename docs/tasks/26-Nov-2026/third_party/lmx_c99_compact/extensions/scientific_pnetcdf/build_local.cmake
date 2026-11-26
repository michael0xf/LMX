# Generate the numeric conversion header before parallel archive dependencies.
execute_process(COMMAND "${MAKE}" -C src/drivers/include all
  WORKING_DIRECTORY "${BINARY}" RESULT_VARIABLE _status)
if(NOT _status EQUAL 0)
  message(FATAL_ERROR "PnetCDF generated header failed (${_status})")
endif()
foreach(_dir src/dispatchers src/drivers/common src/drivers/ncmpio src/libs)
  execute_process(COMMAND "${MAKE}" -C "${_dir}" -j4 all
    WORKING_DIRECTORY "${BINARY}" RESULT_VARIABLE _status)
  if(NOT _status EQUAL 0)
    message(FATAL_ERROR "PnetCDF C99 library build failed in ${_dir} (${_status})")
  endif()
endforeach()
