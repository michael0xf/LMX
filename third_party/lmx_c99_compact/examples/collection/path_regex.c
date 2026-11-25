#include <stdio.h>
#include <stdlib.h>
#include "whereami.h"
#include "re.h"
int main(void) {
    int n=wai_getExecutablePath(NULL,0,NULL), length=0, offset;
    char *path;
    if(n<=0) return 1;
    path=malloc((size_t)n+1);
    if(!path) return 1;
    if(wai_getExecutablePath(path,n,NULL)!=n) { free(path); return 1; }
    path[n]='\0';
    printf("Executable: %s\n",path);
    free(path);
    offset=re_match("\\d+","request id=2048",&length);
    if(offset<0) return 1;
    printf("Numeric match at %d, length %d\n",offset,length);
    return 0;
}
