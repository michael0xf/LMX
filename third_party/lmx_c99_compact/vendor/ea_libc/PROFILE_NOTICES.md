# Selected implementation notices

Root `LICENSE` and `UPSTREAM_LICENSES.md` (the original upstream
`docs/LICENSES.md`) preserve Embedded Artistry and musl grants. BSD and ISC
notices remain in the individual selected C files.

`src/string/strstr.c` attributes Regents of the University of California and
Sun Microsystems and refers to Tcl `license.terms`. `TCL_LICENSE_TERMS` was
obtained from `https://raw.githubusercontent.com/tcltk/tcl/core-8-6-branch/license.terms`
on 2026-11-26. It grants permissive reuse with the retained notice.

APSL source files and dependencies on them are outside this selection. The
actual compiled source list is `../../extensions/bundles_extra/ea_sources.cmake`.
The public ABI is `lmx_ea_libc.h`; upstream full-libc header declarations are
not included because they would advertise unimplemented or unselected APIs.
