/* Build with LMX::qrcodegen. Usage: qr_example output.pgm "message" */
#include <stdio.h>
#include "qrcodegen.h"
int main(int argc, char **argv) {
    uint8_t scratch[qrcodegen_BUFFER_LEN_MAX], qr[qrcodegen_BUFFER_LEN_MAX];
    FILE *file;
    int size, side, x, y;
    const int quiet = 4, scale = 8;
    if (argc != 3) { fprintf(stderr,"Usage: %s output.pgm message\n",argv[0]); return 2; }
    if (!qrcodegen_encodeText(argv[2],scratch,qr,qrcodegen_Ecc_MEDIUM,
            qrcodegen_VERSION_MIN,qrcodegen_VERSION_MAX,qrcodegen_Mask_AUTO,true)) {
        fputs("Message exceeds QR capacity\n",stderr); return 1;
    }
    size = qrcodegen_getSize(qr); side = (size + 2*quiet)*scale;
    file = fopen(argv[1],"wb");
    if (!file) { perror(argv[1]); return 1; }
    if (fprintf(file,"P5\n%d %d\n255\n",side,side) < 0) { fclose(file); return 1; }
    for (y=0;y<side;++y) for(x=0;x<side;++x) {
        int mx=x/scale-quiet, my=y/scale-quiet;
        int black=mx>=0 && my>=0 && mx<size && my<size && qrcodegen_getModule(qr,mx,my);
        if (fputc(black?0:255,file)==EOF) { fclose(file); return 1; }
    }
    if (fclose(file)!=0) return 1;
    printf("Wrote %dx%d QR image to %s\n",side,side,argv[1]);
    return 0;
}
