/* Known PDFio v1.6.6 failure: encrypted CreationDate returns 0.
 * SPDX-License-Identifier: MIT
 * Expected result: nonzero exit while the defect remains. NOT a passing test.
 */
#include "pdfio.h"
#include <stdio.h>

static bool error(pdfio_file_t *pdf, const char *message, void *data)
{
    (void)pdf;
    (void)data;
    fprintf(stderr, "PDFio: %s\n", message);
    return false;
}

static const char *password(void *data, const char *filename)
{
    (void)data;
    (void)filename;
    return "test-reader";
}

int main(int argc, char **argv)
{
    const time_t expected = (time_t)1700000000;
    time_t actual;
    pdfio_file_t *pdf;
    pdfio_stream_t *page;
    if (argc != 2) {
        fprintf(stderr, "Usage: %s output.pdf\n", argv[0]);
        return 2;
    }
    pdf = pdfioFileCreate(argv[1], "1.7", NULL, NULL, error, NULL);
    if (!pdf || !pdfioFileSetPermissions(pdf, PDFIO_PERMISSION_ALL,
            PDFIO_ENCRYPTION_AES_128, "test-owner", "test-reader"))
        return 2;
    pdfioFileSetCreationDate(pdf, expected);
    page = pdfioFileCreatePage(pdf, NULL);
    if (!page || !pdfioStreamClose(page) || !pdfioFileClose(pdf))
        return 2;
    pdf = pdfioFileOpen(argv[1], password, NULL, error, NULL);
    if (!pdf)
        return 2;
    actual = pdfioFileGetCreationDate(pdf);
    if (!pdfioFileClose(pdf) || remove(argv[1]) != 0)
        return 2;
    if (actual != expected) {
        fprintf(stderr, "KNOWN FAILURE: encrypted CreationDate got %ld, expected %ld\n",
                (long)actual, (long)expected);
        return 1;
    }
    puts("PASS: encrypted CreationDate defect no longer observed; review known-failure status");
    return 0;
}
