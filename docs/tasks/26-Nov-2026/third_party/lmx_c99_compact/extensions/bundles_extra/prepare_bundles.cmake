# Build-view edits are exact, hash-guarded; vendor inputs remain unchanged.
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(_gen "${CMAKE_CURRENT_BINARY_DIR}/generated")
function(lmx_bundles_input rel expected out)
  file(SHA256 "${LMX_BUNDLES_VENDOR_DIR}/${rel}" actual)
  if(NOT actual STREQUAL expected)
    message(FATAL_ERROR "Reviewed source changed: ${rel}")
  endif()
  file(READ "${LMX_BUNDLES_VENDOR_DIR}/${rel}" data)
  set(${out} "${data}" PARENT_SCOPE)
endfunction()
lmx_bundles_input("gb/gb.h" "dd69c3d4a726349f36a0273087eabf22be0e36ea5a427f53de1d82346465513c" text)
string(REPLACE [==[#define GB_ASSERT_MSG(cond, msg, ...)]==] [==[#define GB_ASSERT_MSG(cond, ...)]==] text "${text}")
string(REPLACE [==[cast(i64)__LINE__, msg, ##__VA_ARGS__]==] [==[cast(i64)__LINE__, __VA_ARGS__]==] text "${text}")
string(REPLACE [==[#define GB_PANIC(msg, ...)]==] [==[#define GB_PANIC(...)]==] text "${text}")
string(REPLACE [==[#define GB_THREAD_PROC(name) isize name(struct gbThread *thread)]==] [==[struct gbThread;
#define GB_THREAD_PROC(name) isize name(struct gbThread *thread)]==] text "${text}")
string(REPLACE [==[gb_inline gbDllProc gb_dll_proc_address(gbDllHandle dll, char const *proc_name) { return cast(gbDllProc)dlsym(dll, proc_name); }]==] [==[gb_inline gbDllProc gb_dll_proc_address(gbDllHandle dll, char const *proc_name) {
 void *address = dlsym(dll, proc_name); gbDllProc result = NULL;
 GB_STATIC_ASSERT(sizeof(result) == sizeof(address));
 gb_memcopy(&result, &address, sizeof(result)); return result;
}]==] text "${text}")
string(REPLACE "GB__COMPARE_PROC(i16);" "GB__COMPARE_PROC(i16)" text "${text}")
string(REPLACE "GB__COMPARE_PROC(i32);" "GB__COMPARE_PROC(i32)" text "${text}")
string(REPLACE "GB__COMPARE_PROC(i64);" "GB__COMPARE_PROC(i64)" text "${text}")
string(REPLACE "GB__COMPARE_PROC(isize);" "GB__COMPARE_PROC(isize)" text "${text}")
string(REPLACE "GB__COMPARE_PROC(f32);" "GB__COMPARE_PROC(f32)" text "${text}")
string(REPLACE "GB__COMPARE_PROC(f64);" "GB__COMPARE_PROC(f64)" text "${text}")
string(REPLACE "GB__COMPARE_PROC(char);" "GB__COMPARE_PROC(char)" text "${text}")
string(REPLACE "GB_RADIX_SORT_PROC_GEN(u8);" "GB_RADIX_SORT_PROC_GEN(u8)" text "${text}")
string(REPLACE "GB_RADIX_SORT_PROC_GEN(u16);" "GB_RADIX_SORT_PROC_GEN(u16)" text "${text}")
string(REPLACE "GB_RADIX_SORT_PROC_GEN(u32);" "GB_RADIX_SORT_PROC_GEN(u32)" text "${text}")
string(REPLACE "GB_RADIX_SORT_PROC_GEN(u64);" "GB_RADIX_SORT_PROC_GEN(u64)" text "${text}")
file(WRITE "${_gen}/gb.h" "${text}")
lmx_bundles_input("gb/gb_ini.h" "3215436d8e77e36d928499235dd7c2676dd93e7f30581572b1bacda2934260d4" text)
string(REPLACE [==[gbini_inline char const *gb_ini_error_string(gbIniError const err) { return GB_ERROR_STRINGS[err.type]; }]==] [==[char const *gb_ini_error_string(gbIniError const err);]==] text "${text}")
string(REPLACE [==[#ifdef GB_INI_IMPLEMENTATION
#include <ctype.h>]==] [==[#ifdef GB_INI_IMPLEMENTATION
char const *gb_ini_error_string(gbIniError const err) { return GB_ERROR_STRINGS[err.type]; }
#include <ctype.h>]==] text "${text}")
file(WRITE "${_gen}/gb_ini.h" "${text}")
lmx_bundles_input("cute_headers/cute_net.h" "2c38ff7b0474f92ff65c05e11df1cfc672b4bbe07f18e119e1ee9ac0b3e6ef5a" text)
string(REPLACE [==[#define CN_STATIC_ASSERT(cond, message) typedef char cn_static_assert_##message[(cond) ? 1 : -1]]==] [==[#define CN_STATIC_ASSERT(cond, message) do { typedef char cn_static_assert_##message[(cond) ? 1 : -1]; (void)sizeof(cn_static_assert_##message); } while (0)]==] text "${text}")
file(WRITE "${_gen}/cute_net.h" "${text}")
lmx_bundles_input("cute_headers/cute_tiled.h" "9e050b42d5f9c929d5834d2eee7907156d511a142bdd0d77b2dfee094902b733" text)
string(REPLACE [==[struct cute_tiled_chunk_t
{]==] [==[typedef struct cute_tiled_chunk_t cute_tiled_chunk_t;
struct cute_tiled_chunk_t
{]==] text "${text}")
file(WRITE "${_gen}/cute_tiled.h" "${text}")
lmx_bundles_input("cute_headers/cute_png.h" "f5b224bfc6fbbca43243c5121cb94365c6d1c5c6087c26396983f9dc8e905443" text)
string(REPLACE [==[typedef struct cp_lz77_state_t
{]==] [==[struct cp_lz77_state_t
{]==] text "${text}")
string(REPLACE [==[} cp_lz77_state_t;]==] [==[};]==] text "${text}")
file(WRITE "${_gen}/cute_png.h" "${text}")
lmx_bundles_input("cute_headers/cute_sync.h" "8fe24410cf17b56bdbc77f3434baaefc08a9ee77d6ad6a6340619e85196b97d5" text)
string(REPLACE [==[typedef struct cute_threadpool_t
{]==] [==[struct cute_threadpool_t
{]==] text "${text}")
string(REPLACE [==[} cute_threadpool_t;]==] [==[};]==] text "${text}")
string(REPLACE [==[__sync_val_compare_and_swap(&atomic->i, expected, value) == value]==] [==[__sync_val_compare_and_swap(&atomic->i, expected, value) == expected]==] text "${text}")
string(REPLACE [==[__sync_val_compare_and_swap(atomic, expected, value) == value]==] [==[__sync_val_compare_and_swap(atomic, expected, value) == expected]==] text "${text}")
file(WRITE "${_gen}/cute_sync.h" "${text}")
lmx_bundles_input("cute_headers/cute_spritebatch.h" "706c91aed4080ba11836219a1377aeead7703039487487db844688c89ff7b32c" text)
string(REPLACE [==[void spritebatch_term(spritebatch_t* sb)
{]==] [==[void spritebatch_term(spritebatch_t* sb)
{
	/* Release only handles created by this batcher; premade atlases are borrowed. */
	spritebatch_internal_lonely_texture_t* owned = (spritebatch_internal_lonely_texture_t*)sb->sprites_to_lonely_textures.items;
	for (int i = 0; i < sb->sprites_to_lonely_textures.count; ++i) {
		if (owned[i].texture_id != (SPRITEBATCH_U64)~0)
			sb->delete_texture_callback(owned[i].texture_id, sb->udata);
	}]==] text "${text}")
string(REPLACE [==[			spritebatch_map_term(&atlas->sprites_to_textures);
			spritebatch_internal_atlas_t* next]==] [==[			sb->delete_texture_callback(atlas->texture_id, sb->udata);
			spritebatch_map_term(&atlas->sprites_to_textures);
			spritebatch_internal_atlas_t* next]==] text "${text}")
file(WRITE "${_gen}/cute_spritebatch.h" "${text}")
lmx_bundles_input("cute_headers/cute_sound.h" "43d173bbe8c0190366e8854963c5d72a058957dcc53f6b53aafaf50e12fbcda1" text)
string(REPLACE "!defined(CUTE_SOUND_SCALAR_MODE) && defined(__ARM_NEON) || defined(__ARM_NEON__)" "!defined(CUTE_SOUND_SCALAR_MODE) && (defined(__ARM_NEON) || defined(__ARM_NEON__))" text "${text}")
string(REPLACE "!defined(CUTE_SOUND_SCALAR_MODE) && defined(__SSE__) || defined(__SSE2__) || defined(__SSE3__) || defined(__SSE4_1__) || defined(__SSE4_2__)" "!defined(CUTE_SOUND_SCALAR_MODE) && (defined(__SSE__) || defined(__SSE2__) || defined(__SSE3__) || defined(__SSE4_1__) || defined(__SSE4_2__))" text "${text}")
string(REPLACE [==[typedef struct cs_audio_source_t
{]==] [==[struct cs_audio_source_t
{]==] text "${text}")
string(REPLACE [==[} cs_audio_source_t;]==] [==[};]==] text "${text}")
string(REPLACE [==[; /* = NULL */;]==] [==[; /* = NULL */]==] text "${text}")
file(WRITE "${_gen}/cute_sound.h" "${text}")
lmx_bundles_input("ea_libc/src/stdlib/calloc.c" "fe6707641def9efae0640fc1be71c16a8a93185f0eec9dc9a2d412e23da34dd9" text)
string(REPLACE "(1UL << (sizeof(size_t) * 4))" "((size_t)1 << (sizeof(size_t) * 4))" text "${text}")
file(WRITE "${_gen}/ea_calloc_input.c" "${text}")
lmx_bundles_input("ea_libc/src/stdlib/strtoull.c" "bf77cbaf3145c3a91258f6a2c4a34ea3190626645ab74efe527f9a319e929b1e" text)
string(REPLACE "c - 'A' - 10" "c - 'A' + 10" text "${text}")
string(REPLACE "c - 'a' - 10" "c - 'a' + 10" text "${text}")
file(WRITE "${_gen}/ea_strtoull_input.c" "${text}")
lmx_bundles_input("ea_libc/src/wchar/towccase.c" "2d06d5d7b37826e2ff2e92638bd46d8c972d9d282e773104bdcdd7136e2ce602" text)
string(REPLACE "wc - (wchar_t)base <" "(uint32_t)(wc - (wchar_t)base) <" text "${text}")
foreach(delta 0x28 0x40 0x20 0x22)
  if(delta STREQUAL "0x28")
    set(twice 0x50)
  elseif(delta STREQUAL "0x40")
    set(twice 0x80)
  elseif(delta STREQUAL "0x20")
    set(twice 0x40)
  else()
    set(twice 0x44)
  endif()
  string(REPLACE "wc - (wchar_t)(${delta} + ${twice} * lower)" "wc + (wchar_t)(lmul * ${delta})" text "${text}")
endforeach()
foreach(range "0x10428 - 0x28 * lower" "0x104d8 - 0x28 * lower" "0x10cc0 - 0x40 * lower" "0x118c0 - 0x20 * lower" "0x1e922 - 0x22 * lower")
  string(REPLACE "wc - (wchar_t)(${range}) <" "(uint32_t)(wc - (wchar_t)(${range})) <" text "${text}")
endforeach()
file(WRITE "${_gen}/ea_towccase_input.c" "${text}")
lmx_bundles_input("ea_libc/src/wchar/wcwidth.c" "3fb8bb661a896a761c6e129c27576c65bcebb1d5a3a4c1b008a29d463d1bb439" text)
string(REPLACE "if((wtable[entry] >>" "entry = (wchar_t)wtable[wc >> 8] * 32 + (wchar_t)((wc & 255) >> 3);\n\t\tif((wtable[entry] >>" text "${text}")
foreach(range "wc - (wchar_t)0x20000U" "wc - (wchar_t)0xe0020U" "wc - (wchar_t)0xe0100")
  string(REPLACE "(${range}) <" "(uint32_t)(${range}) <" text "${text}")
endforeach()
file(WRITE "${_gen}/ea_wcwidth_input.c" "${text}")
lmx_bundles_input("ea_libc/src/wchar/iswspace.c" "fc5313ce0ed8b38db3e922d257deeda3b2421c72c9f73b890ced83b810940f7a" text)
string(REPLACE "return wc && wcschr(spaces, (wchar_t)wc);" "for (size_t i = 0; spaces[i]; ++i) if ((wint_t)spaces[i] == wc) return 1;\n\treturn 0;" text "${text}")
file(WRITE "${_gen}/ea_iswspace_input.c" "${text}")
