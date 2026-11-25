/* Read Markdown on stdin and render HTML to stdout. */
#include <complex.h> /* also verifies that the aggregate headers coexist with C99 */
#include <stdlib.h>
#include "lmx_documents.h"
static void output(const char *text, MD_SIZE count, void *userdata) {
    FILE *file=userdata;
    (void)fwrite(text,1,count,file);
}
int main(void) {
    char *text=NULL;size_t length=0,capacity=0;int ch,result;
    while((ch=getchar())!=EOF) {
        if(length==capacity) {
            size_t next=capacity?capacity*2:4096;char *grown;
            if(next<capacity || next>16u*1024u*1024u){free(text);return 2;}
            grown=realloc(text,next);if(!grown){free(text);return 2;}text=grown;capacity=next;
        }
        text[length++]=(char)ch;
    }
    if(ferror(stdin)){free(text);return 1;}
    result=md_html(text?text:"",(MD_SIZE)length,output,stdout,MD_DIALECT_GITHUB,0);
    free(text);
    return result!=0 || ferror(stdout);
}
