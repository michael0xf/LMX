#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"PCRE2 check failed: %s\n",#c); exit(1); } } while (0)
int main(void)
{
    PCRE2_SIZE offset;
    int error, result;
    pcre2_code *code;
    pcre2_match_data *match;
    PCRE2_SIZE *span;
    const unsigned char input[] = "\xce\xb1\xce\xb2:42";
    code = pcre2_compile((PCRE2_SPTR)"^(\\p{L}+):([0-9]+)$",PCRE2_ZERO_TERMINATED,
                         PCRE2_UTF|PCRE2_UCP,&error,&offset,NULL);
    CHECK(code != NULL);
    match = pcre2_match_data_create_from_pattern(code,NULL); CHECK(match != NULL);
    result = pcre2_match(code,input,sizeof input-1,0,0,match,NULL); CHECK(result == 3);
    span = pcre2_get_ovector_pointer(match);
    CHECK(span[2] == 0 && span[3] == 4 && span[4] == 5 && span[5] == 7);
    CHECK(pcre2_match(code,(PCRE2_SPTR)"bad",3,0,0,match,NULL) == PCRE2_ERROR_NOMATCH);
    pcre2_match_data_free(match); pcre2_code_free(code);
    code = pcre2_compile((PCRE2_SPTR)"(",1,0,&error,&offset,NULL);
    CHECK(code == NULL && error != 0);
    puts("PASS: PCRE2 UTF-8 Unicode properties, capture byte offsets, no-match and syntax error");
    return 0;
}
