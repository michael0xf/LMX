# A pre-C23 C constraint needs one explicit array-pointer qualification cast.
# Preserve the original vendor source and generate only this translation unit.
set(_pdfio_content "${LMX_PDFIO_SOURCE_DIR}/pdfio-content.c")
file(SHA256 "${_pdfio_content}" _pdfio_content_hash)
if(NOT _pdfio_content_hash STREQUAL "5e413d622dd16117145c9e4d05cc9e0d5cdcb5cc8951b9a6a9c678df5df3b5f8")
    message(FATAL_ERROR "Unexpected PDFio content source: review the C99 cast for this version")
endif()
file(READ "${_pdfio_content}" _pdfio_content_text)
string(REPLACE
    "pdfioArrayCreateColorFromMatrix(pdf, num_colors, gamma, matrix, white_point)"
    "pdfioArrayCreateColorFromMatrix(pdf, num_colors, gamma, (const double (*)[3])matrix, white_point)"
    _pdfio_content_text "${_pdfio_content_text}")
set(LMX_PDFIO_CONTENT_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/generated/pdfio-content.c")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(WRITE "${LMX_PDFIO_CONTENT_SOURCE}" "${_pdfio_content_text}")
