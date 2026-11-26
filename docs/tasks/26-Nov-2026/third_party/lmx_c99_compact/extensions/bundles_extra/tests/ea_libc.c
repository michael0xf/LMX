#include "check.h"
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include "lmx_ea_libc.h"
static int compare(const void *a,const void *b){int x=*(const int*)a,y=*(const int*)b;return (x>y)-(x<y);}
static int compare_context(void *context,const void *a,const void *b){return *(int*)context*compare(a,b);}
int main(void) {
    int c,i,j,descending=-1,values[257],expected[257],work[257],key=17;char *end;
    unsigned char a[256],b[256];char text[128]="A lunar base; alpha beta beta";
    char tokens[64]="one,two;three",*state=NULL,*token,*copy;unsigned seed1=17,seed2=17;
    lmx_ea_wchar_t wide[]={65,0x4e2d,0x0301,0};void *zero;
#define SAME_CLASS(name) REQUIRE(!!lmx_ea_##name(c)==!!name(c))
    for(c=-1;c<256;++c){SAME_CLASS(isalnum);SAME_CLASS(isalpha);SAME_CLASS(isblank);SAME_CLASS(iscntrl);SAME_CLASS(isdigit);SAME_CLASS(isgraph);SAME_CLASS(islower);SAME_CLASS(isprint);SAME_CLASS(ispunct);SAME_CLASS(isspace);SAME_CLASS(isupper);SAME_CLASS(isxdigit);REQUIRE(lmx_ea_tolower(c)==tolower(c));REQUIRE(lmx_ea_toupper(c)==toupper(c));}
    for(i=0;i<256;++i)a[i]=b[i]=(unsigned char)(i*37);
    for(i=0;i<80;++i){memmove(a+17,a+9,(size_t)i);lmx_ea_memmove(b+17,b+9,(size_t)i);REQUIRE(memcmp(a,b,sizeof(a))==0);memmove(a+3,a+17,(size_t)i);lmx_ea_memmove(b+3,b+17,(size_t)i);REQUIRE(memcmp(a,b,sizeof(a))==0);}
    lmx_ea_memset(b,91,sizeof(b));for(i=0;i<256;++i)REQUIRE(b[i]==91);
    lmx_ea_memcpy(b,a,sizeof(a));REQUIRE(lmx_ea_memcmp(a,b,sizeof(a))==0);
    REQUIRE(lmx_ea_strlen(text)==strlen(text));REQUIRE(lmx_ea_strnlen(text,7)==7);
    REQUIRE(lmx_ea_strstr(text,"beta")==strstr(text,"beta"));REQUIRE(lmx_ea_strnstr(text,"beta",8)==NULL);
    REQUIRE(lmx_ea_strchr(text,'a')==strchr(text,'a'));REQUIRE(lmx_ea_strrchr(text,'a')==strrchr(text,'a'));REQUIRE(lmx_ea_strchrnul(text,'!')==text+strlen(text));
    REQUIRE(lmx_ea_strspn(text,"A lunar")==strspn(text,"A lunar"));REQUIRE(lmx_ea_strcspn(text,";")==strcspn(text,";"));
    REQUIRE(lmx_ea_memmem(text,strlen(text),"base",4)==strstr(text,"base"));
    token=lmx_ea_strtok_r(tokens,",;",&state);REQUIRE(token && strcmp(token,"one")==0);token=lmx_ea_strtok_r(NULL,",;",&state);REQUIRE(token && strcmp(token,"two")==0);token=lmx_ea_strtok_r(NULL,",;",&state);REQUIRE(token && strcmp(token,"three")==0);REQUIRE(lmx_ea_strtok_r(NULL,",;",&state)==NULL);
    copy=lmx_ea_strdup(text);REQUIRE(copy && strcmp(copy,text)==0);free(copy);copy=lmx_ea_strndup(text,7);REQUIRE(copy && strcmp(copy,"A lunar")==0);free(copy);
    zero=lmx_ea_calloc(64,4);REQUIRE(zero);for(i=0;i<256;++i)REQUIRE(((unsigned char*)zero)[i]==0);free(zero);REQUIRE(lmx_ea_calloc(SIZE_MAX,2)==NULL);
    for(i=0;i<257;++i)values[i]=expected[i]=(i*79%89)-44;
    qsort(expected,257,sizeof(int),compare);
    memcpy(work,values,sizeof(work));lmx_ea_qsort(work,257,sizeof(int),compare);REQUIRE(memcmp(work,expected,sizeof(work))==0);
    REQUIRE(lmx_ea_bsearch(&key,work,257,sizeof(int),compare)!=NULL);
    memcpy(work,values,sizeof(work));REQUIRE(lmx_ea_heapsort(work,257,sizeof(int),compare)==0);REQUIRE(memcmp(work,expected,sizeof(work))==0);
    memcpy(work,values,sizeof(work));lmx_ea_qsort_r(work,257,sizeof(int),&descending,compare_context);for(i=0;i<257;++i)REQUIRE(work[i]==expected[256-i]);
    memcpy(work,values,sizeof(work));REQUIRE(lmx_ea_heapsort_r(work,257,sizeof(int),&descending,compare_context)==0);for(i=0;i<257;++i)REQUIRE(work[i]==expected[256-i]);
    REQUIRE(lmx_ea_strtoll(" -9223372036854775808!",&end,10)==LLONG_MIN && *end=='!');
    REQUIRE(lmx_ea_strtoll("9223372036854775808999",&end,10)==LLONG_MAX && *end==0);
    REQUIRE(lmx_ea_strtoull("18446744073709551615",&end,10)==ULLONG_MAX && *end==0);
    REQUIRE(lmx_ea_strtoull(" 0xffff!",&end,0)==65535 && *end=='!');
    REQUIRE(lmx_ea_strtoull("ABCdef!",&end,16)==11259375 && *end=='!');
    REQUIRE(lmx_ea_strtoull("Zz!",&end,36)==1295 && *end=='!');
    REQUIRE(lmx_ea_abs(-17)==17 && lmx_ea_labs(-19)==19 && lmx_ea_llabs(-23)==23 && lmx_ea_imaxabs(-29)==29);
    REQUIRE(lmx_ea_div(17,5).quot==3 && lmx_ea_div(17,5).rem==2);
    for(j=0;j<100;++j)REQUIRE(lmx_ea_rand_r(&seed1)==lmx_ea_rand_r(&seed2));
    REQUIRE(lmx_ea_fls(0)==0 && lmx_ea_fls(16)==5 && lmx_ea_flsl(32)==6 && lmx_ea_flsll(64)==7);
    REQUIRE(lmx_ea_fabs(-3.25)==3.25 && lmx_ea_fabsf(-2.5f)==2.5f);
    REQUIRE(lmx_ea_iswalpha(0x0416) && lmx_ea_towlower(0x0416)==0x0436 && lmx_ea_towupper(0x0436)==0x0416);
    REQUIRE(lmx_ea_towlower(0x10400)==0x10428 && lmx_ea_towupper(0x10428)==0x10400);
    REQUIRE(lmx_ea_iswspace(0x3000) && !lmx_ea_iswspace(0x4e2d));
    REQUIRE(lmx_ea_wcwidth(0x4e2d)==2 && lmx_ea_wcwidth(0x0301)==0 && lmx_ea_wcswidth(wide,3)==3);
    puts("EA libc: ASCII/memory/strings/sort/integer limits/Unicode PASS");return 0;
}
