#include "stc_test_common.h"
#include <math.h>
#include <string.h>
#include <stc/algorithm.h>
#include <stc/cbits.h>
#include <stc/coption.h>
#include <stc/cregex.h>
#include <stc/cspan.h>
#include <stc/cstr.h>
#include <stc/csview.h>
#include <stc/random.h>
#define i_header
#include <stc/utf8.h>
#include <stc/zsview.h>

#define i_type IntSort, int
#include <stc/sort.h>
#define i_type FixedBits, 70
#include <stc/cbits.h>
using_cspan(Matrix, int, 2);
c_sumtype(TestValue, (TestInteger, int), (TestReal, double));

int main(void) {
    cstr text = cstr_from("hello");
    cstr_append(&text, " world");
    CHECK(strcmp(cstr_str(&text), "hello world") == 0);
    cstr_insert(&text, 5, ",");
    CHECK(strcmp(cstr_str(&text), "hello, world") == 0);
    CHECK(cstr_find(&text, "world") == 7);
    cstr formatted = cstr_from_fmt("%s:%d", "value", 42);
    CHECK(strcmp(cstr_str(&formatted), "value:42") == 0);
    cstr_drop(&formatted);
    cstr_drop(&text);

    /* UTF-8 bytes are explicit so source-file encoding is not a requirement. */
    const char utf8_text[] = "A\xce\xbb\xf0\x9f\x8c\x8d";
    csview view = csview_from(utf8_text);
    zsview zero_view = zsview_from(utf8_text);
    CHECK(csview_u8_valid(view));
    CHECK(csview_u8_size(view) == 3 && zsview_u8_size(zero_view) == 3);
    CHECK(!csview_u8_valid(csview_from("\xff")));
    cstr unicode = cstr_from(utf8_text);
    CHECK(cstr_u8_size(&unicode) == 3);
    cstr_u8_erase(&unicode, 1, 1);
    CHECK(cstr_u8_size(&unicode) == 2);
    cstr_drop(&unicode);

    FILE *stream = tmpfile();
    CHECK(stream != NULL);
    CHECK(fputs("first\nsecond\n", stream) >= 0);
    rewind(stream);
    cstr line = {0};
    CHECK(cstr_getline(&line, stream));
    CHECK(strcmp(cstr_str(&line), "first") == 0);
    CHECK(cstr_getline(&line, stream));
    CHECK(strcmp(cstr_str(&line), "second") == 0);
    CHECK(!cstr_getline(&line, stream));
    cstr_drop(&line);
    CHECK(fclose(stream) == 0);

    cregex re = {0};
    csview matches[2] = {{0}};
    CHECK(cregex_compile(&re, "item-([0-9]+)") == CREG_OK);
    CHECK(cregex_captures(&re) == 1);
    CHECK(cregex_match(&re, "prefix item-123 suffix", matches) == CREG_OK);
    CHECK(matches[1].size == 3 && memcmp(matches[1].buf, "123", 3) == 0);
    CHECK(!cregex_is_match(&re, "item-abc"));
    cstr replacement = cregex_replace(&re, "item-12 item-34", "found");
    CHECK(strcmp(cstr_str(&replacement), "found found") == 0);
    cstr_drop(&replacement);
    cregex_drop(&re);

    int values[] = {1, 2, 3, 4, 5, 6};
    Matrix matrix = cspan_md(values, 2, 3);
    CHECK(cspan_size(&matrix) == 6 && *cspan_at(&matrix, 1, 2) == 6);
    cspan_transpose(&matrix);
    CHECK(matrix.shape[0] == 3 && matrix.shape[1] == 2);
    CHECK(*cspan_at(&matrix, 2, 1) == 6 && *cspan_at(&matrix, 1, 0) == 2);

    cbits bits = cbits_with_size(130, false);
    cbits_set(&bits, 0);
    cbits_set(&bits, 64);
    cbits_set(&bits, 129);
    CHECK(cbits_count(&bits) == 3 && cbits_test(&bits, 129));
    cbits copy = cbits_clone(bits);
    cbits_reset(&copy, 64);
    CHECK(cbits_count(&copy) == 2 && cbits_count(&bits) == 3);
    cbits_drop(&copy);
    cbits_drop(&bits);
    FixedBits fixed = FixedBits_with_size(70, false);
    FixedBits_set(&fixed, 69);
    CHECK(FixedBits_count(&fixed) == 1 && FixedBits_test(&fixed, 69));

    int unsorted[] = {9, 1, 4, 1, 7};
    IntSort_sort(unsorted, 5);
    CHECK(unsorted[0] == 1 && unsorted[4] == 9);
    CHECK(IntSort_binary_search(unsorted, 4, 5) == 2);
    CHECK(IntSort_lower_bound(unsorted, 5, 5) == 3);

    isize range_sum = 0;
    c_filter(crange, c_iota(1, 11), (*value % 2 == 0)
        && (range_sum += *value, true));
    CHECK(range_sum == 30);
    TestValue tagged = c_variant(TestInteger, 37);
    int selected = 0;
    c_when(&tagged) {
        c_is(TestInteger, value) selected = *value;
        c_is(TestReal) selected = -1;
    }
    CHECK(selected == 37 && c_holds(&tagged, TestInteger));

    crand64 first = crand64_from(1234);
    crand64 second = crand64_from(1234);
    for (int i = 0; i < 32; ++i)
        CHECK(crand64_uint_r(&first, 1) == crand64_uint_r(&second, 1));
    crand64_uniform_dist uniform = crand64_make_uniform(-3, 7);
    for (int i = 0; i < 100; ++i) {
        int64_t value = crand64_uniform_r(&first, 1, &uniform);
        CHECK(value >= -3 && value <= 7);
    }
    crand64_normal_dist normal = {.mean = 0.0, .stddev = 1.0};
    CHECK(isfinite(crand64_normal_r(&first, 1, &normal)));
    crand32 small_first = crand32_from(42);
    crand32 small_second = crand32_from(42);
    CHECK(crand32_uint_r(&small_first, 1) == crand32_uint_r(&small_second, 1));

    char program[] = "program", option_name[] = "--number", argument[] = "42";
    char *args[] = {program, option_name, argument, NULL};
    const coption_long options[] = {{"number", coption_required_argument, 'n'}, {0}};
    coption option = coption_init();
    CHECK(coption_get(&option, 3, args, "n:", options) == 'n');
    CHECK(strcmp(option.arg, "42") == 0);
    CHECK(coption_get(&option, 3, args, "n:", options) == -1);
    return EXIT_SUCCESS;
}
