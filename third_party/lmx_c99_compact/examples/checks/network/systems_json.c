#include "check.h"
#include <string.h>
#include "jsmn.h"
#include "cJSON.h"
#include "cJSON_Utils.h"
int main(void) {
    const char json[] = "{\"name\":\"LMX\",\"values\":[1,2,3]}";
    jsmn_parser p; jsmntok_t tokens[16]; cJSON *tree, *patches, *array; char *encoded;
    jsmn_init(&p); CHECK(jsmn_parse(&p, json, strlen(json), tokens, 16) == 8);
    CHECK(tokens[0].type == JSMN_OBJECT && tokens[4].type == JSMN_ARRAY && tokens[4].size == 3);
    jsmn_init(&p); CHECK(jsmn_parse(&p, "{\"x\":", 5, tokens, 16) == JSMN_ERROR_PART);
    tree = cJSON_Parse(json); CHECK(tree != NULL);
    patches = cJSON_Parse("[{\"op\":\"replace\",\"path\":\"/values/1\",\"value\":42}]"); CHECK(patches != NULL);
    CHECK(cJSONUtils_ApplyPatches(tree, patches) == 0);
    array = cJSON_GetObjectItemCaseSensitive(tree, "values");
    CHECK(cJSON_GetArraySize(array) == 3 && cJSON_GetArrayItem(array, 1)->valueint == 42);
    encoded = cJSON_PrintUnformatted(tree); CHECK(encoded != NULL && strstr(encoded, "42") != NULL);
    cJSON_free(encoded); cJSON_Delete(patches); cJSON_Delete(tree);
    CHECK(cJSON_Parse("{bad}") == NULL); puts("jsmn tokens + cJSON parse/JSON Patch/invalid input: OK"); return 0;
}
