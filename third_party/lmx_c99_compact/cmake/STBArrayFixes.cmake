# Correct proven multidimensional array UB in generated copies only.
# vendor/stb remains byte-for-byte original; public header search prefers this view.
set(_lmx_stb_generated "${CMAKE_CURRENT_BINARY_DIR}/generated/stb_c99")
file(MAKE_DIRECTORY "${_lmx_stb_generated}")
function(_lmx_stb_replace_checked variable old new)
    string(FIND "${${variable}}" "${old}" _position)
    if(_position EQUAL -1)
        message(FATAL_ERROR "Pinned stb source changed; cannot apply C99 fix: ${old}")
    endif()
    string(REPLACE "${old}" "${new}" _updated "${${variable}}")
    set(${variable} "${_updated}" PARENT_SCOPE)
endfunction()

file(READ "${_lmx_stb_root}/stb_tilemap_editor.h" _lmx_stb_tilemap)
foreach(_field IN ITEMS data props link linkcount)
    _lmx_stb_replace_checked(_lmx_stb_tilemap "tm->${_field}[0][i]"
        "tm->${_field}[i / STBTE_MAX_TILEMAP_X][i % STBTE_MAX_TILEMAP_X]")
endforeach()
file(WRITE "${_lmx_stb_generated}/stb_tilemap_editor.h"
    "/* LMX generated C99 array-index adaptation; original notices follow. */\n${_lmx_stb_tilemap}")

file(READ "${_lmx_stb_root}/stb_voxel_render.h" _lmx_stb_voxel)
foreach(_array IN ITEMS stbvox_vertex_selector stbvox_vmesh_pre_vheight vmesh)
    _lmx_stb_replace_checked(_lmx_stb_voxel "${_array}[0][i]" "${_array}[i / 4][i % 4]")
endforeach()
foreach(_field IN ITEMS output_cur output_buffer)
    _lmx_stb_replace_checked(_lmx_stb_voxel "mm->${_field}[0][i]"
        "mm->${_field}[i / STBVOX_MAX_MESH_SLOTS][i % STBVOX_MAX_MESH_SLOTS]")
endforeach()
# Keep the row type when passing the default [6][4] geometry table.
_lmx_stb_replace_checked(_lmx_stb_voxel
    "stbvox_make_mesh_for_block(stbvox_mesh_maker *mm, stbvox_pos pos, int v_off, stbvox_mesh_vertex *vmesh)"
    "stbvox_make_mesh_for_block(stbvox_mesh_maker *mm, stbvox_pos pos, int v_off, stbvox_mesh_vertex (*vmesh)[4])")
foreach(_face IN ITEMS up down north south east west)
    _lmx_stb_replace_checked(_lmx_stb_voxel "vmesh+4*STBVOX_FACE_${_face}" "vmesh[STBVOX_FACE_${_face}]")
endforeach()
foreach(_geometry IN ITEMS half_z normal)
    _lmx_stb_replace_checked(_lmx_stb_voxel
        "stbvox_mesh_vertex *vmesh = stbvox_vmesh_delta_${_geometry}[0];"
        "stbvox_mesh_vertex (*vmesh)[4] = stbvox_vmesh_delta_${_geometry};")
endforeach()
# Cast before bit packing: the original final cast happened after signed overflow.
_lmx_stb_replace_checked(_lmx_stb_voxel
    [=[((stbvox_uint32) ((x)+((y)<<7)+((z)<<14)+((ao)<<23)+((texlerp)<<29)))]=]
    [=[((stbvox_uint32)(x) + ((stbvox_uint32)(y)<<7) + ((stbvox_uint32)(z)<<14) + ((stbvox_uint32)(ao)<<23) + ((stbvox_uint32)(texlerp)<<29))]=])
file(WRITE "${_lmx_stb_generated}/stb_voxel_render.h"
    "/* LMX generated C99 array/packing adaptation; original notices follow. */\n${_lmx_stb_voxel}")
unset(_lmx_stb_tilemap)
unset(_lmx_stb_voxel)
