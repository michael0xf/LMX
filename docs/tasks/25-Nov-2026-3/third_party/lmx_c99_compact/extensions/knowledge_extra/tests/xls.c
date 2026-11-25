#include <xls.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "xls_fixture.inc"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "XLS check failed at %d: %s\n", __LINE__, #x); exit(1); } } while (0)
int main(void)
{
    xls_error_t error = LIBXLS_OK;
    xlsWorkBook *wb = xls_open_buffer(xls_fixture, sizeof(xls_fixture), "UTF-8", &error);
    xlsWorkSheet *ws;
    unsigned int i, nonempty = 0;
    CHECK(wb && error == LIBXLS_OK && wb->sheets.count > 0);
    for (i=0; i<wb->sheets.count; ++i) {
        unsigned int r,c;
        ws=xls_getWorkSheet(wb,(int)i); CHECK(ws);
        CHECK(xls_parseWorkSheet(ws) == LIBXLS_OK);
        if (i == 0) {
            xlsCell *a=xls_cell(ws,0,0), *h=xls_cell(ws,0,7);
            CHECK(a && a->str && strcmp(a->str,"a") == 0);
            CHECK(h && h->str && strcmp(h->str,"h") == 0);
        }
        for (r=0; r<=ws->rows.lastrow; ++r) for (c=0; c<=ws->rows.lastcol; ++c) {
            xlsCell *cell=xls_cell(ws,(WORD)r,(WORD)c);
            if (cell && cell->str && cell->str[0]) {
                ++nonempty;
            }
        }
        xls_close_WS(ws);
    }
    CHECK(nonempty > 10); xls_close_WB(wb);
    wb=xls_open_buffer((const unsigned char *)"bad",3,"UTF-8",&error);
    CHECK(wb == NULL && error != LIBXLS_OK);
    return 0;
}
