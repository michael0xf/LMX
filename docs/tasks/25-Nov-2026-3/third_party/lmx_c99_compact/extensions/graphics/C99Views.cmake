# Narrow C99 build copies; all upstream source files remain unchanged.
file(SHA256 "${_gfx_vendor}/nuklear/nuklear.h" _gfx_nk_hash)
if(NOT _gfx_nk_hash STREQUAL "96f1383bebb3c0a7eb167a79d3b614c1550dc280f6ba810d3a99f6f9f87409c1")
    message(FATAL_ERROR "Pinned Nuklear source changed; review the C99 alignment view")
endif()
file(READ "${_gfx_vendor}/nuklear/nuklear.h" _gfx_nk)
# Defining a type inside builtin_offsetof is rejected by Clang21 in C99 mode.
# sizeof permits the same struct type definition in C99. The size difference
# is checked against named-struct offsetof in the GUI test for this ABI.
string(REPLACE "#define NK_ALIGNOF(t) NK_OFFSETOF(struct {char c; t _h;}, _h)"
    "#define NK_ALIGNOF(t) (sizeof(struct {char c; t _h;}) - sizeof(t))" _gfx_nk "${_gfx_nk}")
file(MAKE_DIRECTORY "${_gfx_view}/nuklear")
file(WRITE "${_gfx_view}/nuklear/nuklear.h" "/* LMX C99 sizeof-only alignment view; original preserved in vendor/nuklear. */\n${_gfx_nk}")

if(WIN32)
    file(SHA256 "${_gfx_vendor}/sokol/sokol_gfx.h" _gfx_sokol_hash)
    if(NOT _gfx_sokol_hash STREQUAL "349e8c8a323235f36d5fb1a226f978c969a2a1d987801afb29a988757b445024")
        message(FATAL_ERROR "Pinned Sokol source changed; review the C99 Win32 loader view")
    endif()
    file(READ "${_gfx_vendor}/sokol/sokol_gfx.h" _gfx_sokol_gfx)
    # WinAPI already returns PROC (a function pointer). Preserve that type
    # instead of making a forbidden C99 round trip through void*.
    string(REPLACE "_SOKOL_PRIVATE void* _sg_gl_getprocaddr(const char* name, _sg_wglGetProcAddress wgl_getprocaddress)"
        "_SOKOL_PRIVATE PROC _sg_gl_getprocaddr(const char* name, _sg_wglGetProcAddress wgl_getprocaddress)" _gfx_sokol_gfx "${_gfx_sokol_gfx}")
    string(REPLACE "void* proc_addr = (void*) wgl_getprocaddress(name);"
        "PROC proc_addr = wgl_getprocaddress(name);" _gfx_sokol_gfx "${_gfx_sokol_gfx}")
    string(REPLACE "proc_addr = (void*) GetProcAddress(_sg.gl.opengl32_dll, name);"
        "proc_addr = GetProcAddress(_sg.gl.opengl32_dll, name);" _gfx_sokol_gfx "${_gfx_sokol_gfx}")
    file(MAKE_DIRECTORY "${_gfx_view}/sokol")
    file(WRITE "${_gfx_view}/sokol/sokol_gfx.h" "/* LMX typed Win32 GL-loader C99 view; original preserved in vendor/sokol. */\n${_gfx_sokol_gfx}")
endif()
