# No source downloads and no in-place vendor modifications.
file(MAKE_DIRECTORY "${VIEW}" "${BINARY}")
file(COPY "${SOURCE}/" DESTINATION "${VIEW}")
set(_file "${VIEW}/src/dispatchers/lib_version.c")
file(SHA256 "${_file}" _hash)
if(NOT _hash STREQUAL "f562fbd77f9462766f43e6e8661e10a4d1404143f1f7e1e14d5f1334cd3a8ea0")
  message(FATAL_ERROR "Unreviewed PnetCDF lib_version.c input")
endif()
file(READ "${_file}" _text)
string(REPLACE [==[    if ((void *)pnetcdf_libvers != (void *)ncmpi_inq_libvers) {
	; /* do nothing */
    }]==] [==[    (void)pnetcdf_libvers; /* C99: keep the public object, no function/object pointer comparison. */]==] _text "${_text}")
file(READ "${CMAKE_CURRENT_LIST_DIR}/src/ubyte_aliases.c" _aliases)
file(WRITE "${_file}" "${_text}\n${_aliases}")
execute_process(COMMAND "${CMAKE_COMMAND}" -E env "MPICC=${MPICC}" "CC=${MPICC}" "M4=${M4}" "CFLAGS=${CFLAGS}"
  /bin/sh "${VIEW}/configure" "--prefix=${PREFIX}" --disable-cxx --disable-fortran
  --disable-maintainer-mode
  --disable-shared --enable-static --disable-gio --disable-subfiling --disable-burst-buffering --enable-relax-coord-bound
  --without-netcdf4 --without-adios --no-create
  WORKING_DIRECTORY "${BINARY}" RESULT_VARIABLE _status)
if(NOT _status EQUAL 0)
  message(FATAL_ERROR "PnetCDF offline configure failed (${_status})")
endif()
# Configure only production C build inputs. This avoids retaining unused
# Fortran/C++ bindings, application build files or generated API templates.
execute_process(COMMAND /bin/sh "${BINARY}/config.status"
  Makefile src/Makefile src/include/Makefile src/include/pnetcdf.h src/include/config.h
  src/dispatchers/Makefile src/drivers/Makefile src/drivers/include/Makefile
  src/drivers/common/Makefile src/drivers/ncmpio/Makefile src/libs/Makefile
  depfiles libtool
  WORKING_DIRECTORY "${BINARY}" RESULT_VARIABLE _status)
if(NOT _status EQUAL 0)
  message(FATAL_ERROR "PnetCDF selected config.status failed (${_status})")
endif()
