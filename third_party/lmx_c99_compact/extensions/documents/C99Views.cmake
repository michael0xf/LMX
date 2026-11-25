# Mechanical, private-layout C99 views. Public headers and vendor are unchanged.
# Fail rather than applying these mechanical edits to an unreviewed source revision.
file(SHA256 "${_doc_vendor}/pdfgen/pdfgen.c" _source_sha)
if(NOT _source_sha STREQUAL "5805efade0ff6124d039464c4513337aefa84852222649f08e4e192fcf0cdf0c")
    message(FATAL_ERROR "Unreviewed pdfgen/pdfgen.c: update the C99 view with the source pin")
endif()
file(SHA256 "${_doc_vendor}/md4c/src/md4c.c" _source_sha)
if(NOT _source_sha STREQUAL "b9102e0ddfdfd494fdda903f79c554ffaab7e87b4eeb85b4c113057dee3e0728")
    message(FATAL_ERROR "Unreviewed md4c/src/md4c.c: update the C99 view with the source pin")
endif()
file(SHA256 "${_doc_vendor}/ezxml/ezxml.c" _source_sha)
if(NOT _source_sha STREQUAL "8f60356fd37b5128e6a9bdfb15cbd83fe33cc8f32b12b4f6815fa18168e4b221")
    message(FATAL_ERROR "Unreviewed ezxml/ezxml.c: update the C99 view with the source pin")
endif()
file(READ "${_doc_vendor}/pdfgen/pdfgen.c" _pdf_source)
string(REPLACE "        } font;\n    };" "        } font;\n    } payload;" _pdf_source "${_pdf_source}")
foreach(_member bookmark stream page info font)
    string(REPLACE "->${_member}" "->payload.${_member}" _pdf_source "${_pdf_source}")
endforeach()
file(WRITE "${_doc_view}/pdfgen.c" "${_pdf_source}")

file(READ "${_doc_vendor}/md4c/src/md4c.c" _md_source)
string(REPLACE "        MD_FOOTNOTE_DEF* footnote_defs;\n    };" "        MD_FOOTNOTE_DEF* footnote_defs;\n    } items;" _md_source "${_md_source}")
foreach(_member defs ref_defs footnote_defs)
    string(REPLACE ".${_member}" ".items.${_member}" _md_source "${_md_source}")
    string(REPLACE "->${_member}" "->items.${_member}" _md_source "${_md_source}")
endforeach()
string(REPLACE "            OFF end;\n        };\n        void* pointer; /* Dummy marks can sometimes store a pointer */\n    };"
               "            OFF end;\n        } range;\n        void* pointer; /* Dummy marks can sometimes store a pointer */\n    } payload;" _md_source "${_md_source}")
foreach(_mark mark opener closer next_opener next_closer m delim index_mark first_nested last_nested dummy dest_mark prev_mark left_cursor right_cursor)
    foreach(_member beg end)
        string(REPLACE "${_mark}->${_member}" "${_mark}->payload.range.${_member}" _md_source "${_md_source}")
        string(REPLACE "${_mark}.${_member}" "${_mark}.payload.range.${_member}" _md_source "${_md_source}")
    endforeach()
endforeach()
string(REGEX REPLACE "(ctx->marks\\[[^]]+\\])\\.(beg|end)" "\\1.payload.range.\\2" _md_source "${_md_source}")
string(REGEX REPLACE "(ctx->marks\\[[^]]+\\])\\.pointer" "\\1.payload.pointer" _md_source "${_md_source}")
string(REPLACE "((MD_MARK*) mark)->end" "((MD_MARK*) mark)->payload.range.end" _md_source "${_md_source}")
file(WRITE "${_doc_view}/md4c.c" "${_md_source}")

# Keep ezXML's parser and file APIs unchanged. Windows uses its existing
# non-mmap path with native CRT names; POSIX retains mmap, and Darwin retains
# its native madvise declarations rather than assuming posix_madvise exists.
file(READ "${_doc_vendor}/ezxml/ezxml.c" _ez_source)
if(WIN32)
    string(REPLACE "#include <unistd.h>" "#include <io.h>\n#define EZXML_NOMMAP 1"
        _ez_source "${_ez_source}")
    set(_ez_crt [=[#include "ezxml.h"
/* Native Windows CRT: the existing EZXML_NOMMAP implementation is retained. */
#define stat _stat64
#define fstat _fstat64
#define read _read
#define open(path, flags, mode) _open(path, (flags) | _O_BINARY, mode)
#define close _close
#define strdup _strdup
]=])
    string(REPLACE "#include \"ezxml.h\"" "${_ez_crt}" _ez_source "${_ez_source}")
elseif(NOT APPLE)
    string(REPLACE "madvise(" "posix_madvise(" _ez_source "${_ez_source}")
    string(REPLACE "MADV_SEQUENTIAL" "POSIX_MADV_SEQUENTIAL" _ez_source "${_ez_source}")
    string(REPLACE "MADV_NORMAL" "POSIX_MADV_NORMAL" _ez_source "${_ez_source}")
endif()
file(WRITE "${_doc_view}/ezxml.c" "${_ez_source}")
