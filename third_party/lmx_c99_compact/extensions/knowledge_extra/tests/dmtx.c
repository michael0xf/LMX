#include <dmtx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"DataMatrix check failed: %s\n",#c); exit(1); } } while (0)
int main(void)
{
    unsigned char input[] = {'C','9','9',0,1,2,255};
    DmtxEncode *encoder = dmtxEncodeCreate();
    DmtxDecode *decoder;
    DmtxRegion *region;
    DmtxMessage *message;
    DmtxTime limit;
    CHECK(encoder != NULL);
    CHECK(dmtxEncodeDataMatrix(encoder,(int)sizeof input,input) == DmtxPass);
    decoder = dmtxDecodeCreate(encoder->image,1); CHECK(decoder != NULL);
    limit = dmtxTimeAdd(dmtxTimeNow(), 2000);
    region = dmtxRegionFindNext(decoder,&limit); CHECK(region != NULL);
    message = dmtxDecodeMatrixRegion(decoder,region,DmtxUndefined); CHECK(message != NULL);
    CHECK(message->outputIdx == (int)sizeof input && !memcmp(message->output,input,sizeof input));
    dmtxMessageDestroy(&message); dmtxRegionDestroy(&region);
    dmtxDecodeDestroy(&decoder); dmtxEncodeDestroy(&encoder);
    puts("PASS: DataMatrix ECC200 image encode/detect/decode with embedded NUL and binary bytes");
    return 0;
}
