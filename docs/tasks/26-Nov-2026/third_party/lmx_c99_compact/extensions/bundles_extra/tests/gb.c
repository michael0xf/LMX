#include "check.h"
#include <string.h>
#include "gb.h"
#include "gb_ini.h"
static GB_THREAD_PROC(worker) { *(int*)thread->user_data = 42; return 17; }
static GB_INI_HANDLER(ini_value) {
    int *count = data;
    REQUIRE(strcmp(section, "device") == 0);
    REQUIRE(strcmp(name, "rate") == 0 && strcmp(value, "44100") == 0);
    ++*count; return 1;
}
int main(void) {
    gbAllocator heap = gb_heap_allocator();
    gbArena arena; gbTempArenaMemory temp; gbThread thread;
    gbArray(i32) numbers; gbString text; gbFile file; gbFileContents contents;
    int i, result = 0, ini_count = 0; FILE *ini; gbIniError error;
    gb_arena_init_from_allocator(&arena, heap, 4096);
    temp = gb_temp_arena_memory_begin(&arena);
    REQUIRE(gb_alloc(gb_arena_allocator(&arena), 127) != NULL);
    REQUIRE(arena.total_allocated >= 127);
    gb_temp_arena_memory_end(temp); REQUIRE(arena.total_allocated == 0);
    gb_arena_check(&arena); gb_arena_free(&arena);
    gb_array_init(numbers, heap);
    for (i = 127; i >= 0; --i) gb_array_append(numbers, i);
    gb_sort_array(numbers, gb_array_count(numbers), gb_i32_cmp(0));
    for (i = 0; i < 128; ++i) REQUIRE(numbers[i] == i);
    gb_array_free(numbers);
    text = gb_string_make(heap, "Moon"); REQUIRE(text);
    text = gb_string_appendc(text, " base");
    REQUIRE(gb_string_length(text) == 9 && strcmp(text, "Moon base") == 0);
    gb_string_free(text);
    REQUIRE(gb_fnv32a("hello", 5) == 0x4f9f2cabu);
    REQUIRE(gb_file_create(&file, "gb-roundtrip.bin") == gbFileError_None);
    REQUIRE(gb_file_write(&file, "hello\0world", 11));
    REQUIRE(gb_file_close(&file) == gbFileError_None);
    contents = gb_file_read_contents(heap, 1, "gb-roundtrip.bin");
    REQUIRE(contents.size == 11 && memcmp(contents.data, "hello\0world", 11) == 0);
    gb_file_free_contents(&contents); remove("gb-roundtrip.bin");
    gb_thread_init(&thread); gb_thread_start(&thread, worker, &result);
    gb_thread_join(&thread); REQUIRE(result == 42 && thread.return_value == 17);
    gb_thread_destroy(&thread);
    ini = tmpfile(); REQUIRE(ini); fputs("; imported device file\n[device]\nrate=44100\n", ini); rewind(ini);
    error = gb_ini_parse_file(ini, ini_value, &ini_count); fclose(ini);
    REQUIRE(error.type == GB_INI_ERROR_NONE && ini_count == 1);
    puts("gb: arena/array/string/hash/file/thread/foreign INI PASS"); return 0;
}
