#include <bson/bson.h>
#include <stdio.h>
#include <string.h>

#define REQUIRE(x) do { if (!(x)) { fprintf(stderr, "BSON check failed: %s\n", #x); return 1; } } while (0)

int main(void)
{
    bson_t document = BSON_INITIALIZER;
    bson_array_builder_t *array;
    bson_t truncated;
    bson_t *copy;
    bson_t *parsed;
    bson_iter_t iterator;
    bson_error_t error;
    bson_decimal128_t decimal;
    const uint8_t payload[] = {0, 1, 0xff, 0};
    const uint8_t *got;
    uint32_t got_length;
    bson_subtype_t subtype;
    char *json;
    size_t json_length;
    REQUIRE(bson_decimal128_from_string("1234567890.125", &decimal));
    REQUIRE(BSON_APPEND_UTF8(&document, "name", "LMX"));
    REQUIRE(BSON_APPEND_DECIMAL128(&document, "value", &decimal));
    REQUIRE(BSON_APPEND_BINARY(&document, "bytes", BSON_SUBTYPE_BINARY, payload, sizeof(payload)));
    REQUIRE(BSON_APPEND_ARRAY_BUILDER_BEGIN(&document, "items", &array));
    REQUIRE(bson_array_builder_append_int32(array, 7));
    REQUIRE(bson_array_builder_append_int32(array, -3));
    REQUIRE(bson_append_array_builder_end(&document, array));
    REQUIRE(bson_validate_with_error(&document, BSON_VALIDATE_UTF8, &error));
    copy = bson_new_from_data(bson_get_data(&document), document.len);
    REQUIRE(copy && bson_equal(&document, copy));
    REQUIRE(bson_iter_init_find(&iterator, copy, "bytes"));
    bson_iter_binary(&iterator, &subtype, &got_length, &got);
    REQUIRE(subtype == BSON_SUBTYPE_BINARY && got_length == sizeof(payload)
        && memcmp(got, payload, sizeof(payload)) == 0);
    json = bson_as_canonical_extended_json(&document, &json_length);
    REQUIRE(json && json_length > 0);
    parsed = bson_new_from_json((const uint8_t *)json, (ssize_t)json_length, &error);
    REQUIRE(parsed && bson_equal(&document, parsed));
    REQUIRE(!bson_init_static(&truncated, bson_get_data(&document), document.len - 1));
    bson_destroy(parsed);
    bson_free(json);
    bson_destroy(copy);
    bson_destroy(&document);
    puts("libbson: nested array, binary, Decimal128, extended JSON and truncation rejection passed");
    return 0;
}
