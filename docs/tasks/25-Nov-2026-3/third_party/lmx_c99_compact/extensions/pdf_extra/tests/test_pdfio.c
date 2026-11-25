/* Offline PDF interoperability checks for the compact C99 collection.
 * SPDX-License-Identifier: MIT
 * These tests exercise file/data semantics; they do not render PDF pages.
 */
#include "pdfio.h"
#include "pdfio-content.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define REQUIRE(expr) do { if (!(expr)) { \
    fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #expr); \
    return 1; } } while (0)

static const char title[] = "LMX compact archive PDF";
static const char author[] = "C99 offline test";
static const char page_text[] = "Preserved engineering knowledge";
static const time_t created = (time_t)1700000000;

static bool on_error(pdfio_file_t *pdf, const char *message, void *data)
{
    int *count = (int *)data;
    (void)pdf;
    if (count) {
        ++*count;
    } else {
        fprintf(stderr, "PDFio: %s\n", message);
    }
    return false;
}

static const char *password(void *data, const char *filename)
{
    (void)filename;
    return (const char *)data;
}

static int path_for(char *path, size_t size, const char *prefix, const char *suffix)
{
    int n = snprintf(path, size, "%s-%s.pdf", prefix, suffix);
    return n < 0 || (size_t)n >= size;
}

static int make_pdf(const char *path, bool encrypt)
{
    pdfio_rect_t box = {0, 0, 600, 800};
    pdfio_file_t *pdf;
    pdfio_obj_t *font, *payload;
    pdfio_dict_t *dict;
    pdfio_stream_t *stream;
    unsigned char bytes[512];
    size_t i;

    pdf = pdfioFileCreate(path, "1.7", &box, &box, on_error, NULL);
    REQUIRE(pdf != NULL);
    if (encrypt) {
        REQUIRE(pdfioFileSetPermissions(pdf, PDFIO_PERMISSION_ALL,
            PDFIO_ENCRYPTION_AES_128, "test-owner", "test-reader"));
    }
    pdfioFileSetTitle(pdf, title);
    pdfioFileSetAuthor(pdf, author);
    pdfioFileSetCreator(pdf, "LMX PDFio C99 usage check");
    pdfioFileSetSubject(pdf, "External document read/write");
    pdfioFileSetKeywords(pdf, "offline,roundtrip");
    pdfioFileSetCreationDate(pdf, created);

    for (i = 0; i < sizeof(bytes); ++i)
        bytes[i] = (unsigned char)(17U * (unsigned int)i);
    dict = pdfioDictCreate(pdf);
    REQUIRE(dict != NULL);
    REQUIRE(pdfioDictSetName(dict, "Type", "EmbeddedFile"));
    REQUIRE(pdfioDictSetName(dict, "Filter", "FlateDecode"));
    payload = pdfioFileCreateObj(pdf, dict);
    REQUIRE(payload != NULL);
    REQUIRE(pdfioDictSetObj(pdfioFileGetCatalog(pdf), "LMXPayload", payload));
    stream = pdfioObjCreateStream(payload, PDFIO_FILTER_FLATE);
    REQUIRE(stream != NULL);
    REQUIRE(pdfioStreamWrite(stream, bytes, sizeof(bytes)));
    REQUIRE(pdfioStreamClose(stream));

    font = pdfioFileCreateFontObjFromBase(pdf, "Helvetica");
    REQUIRE(font != NULL);
    for (i = 0; i < 2; ++i) {
        dict = pdfioDictCreate(pdf);
        REQUIRE(dict != NULL);
        REQUIRE(pdfioPageDictAddFont(dict, "F1", font));
        stream = pdfioFileCreatePage(pdf, dict);
        REQUIRE(stream != NULL);
        REQUIRE(pdfioContentTextBegin(stream));
        REQUIRE(pdfioContentSetTextFont(stream, "F1", 12));
        REQUIRE(pdfioContentTextMoveTo(stream, 36, 750));
        REQUIRE(pdfioContentTextShow(stream, false, page_text));
        REQUIRE(pdfioContentTextEnd(stream));
        REQUIRE(pdfioStreamClose(stream));
    }
    REQUIRE(pdfioFileClose(pdf));
    return 0;
}

static int check_page(pdfio_obj_t *page)
{
    pdfio_rect_t box;
    pdfio_stream_t *stream;
    char content[2048];
    size_t total = 0;
    ssize_t count;

    REQUIRE(page != NULL);
    REQUIRE(pdfioDictGetRect(pdfioObjGetDict(page), "MediaBox", &box) != NULL);
    REQUIRE(box.x1 == 0 && box.y1 == 0 && box.x2 == 600 && box.y2 == 800);
    REQUIRE(pdfioPageGetNumStreams(page) == 1);
    stream = pdfioPageOpenStream(page, 0, true);
    REQUIRE(stream != NULL);
    while ((count = pdfioStreamRead(stream, content + total,
                                   sizeof(content) - 1 - total)) > 0) {
        total += (size_t)count;
        REQUIRE(total < sizeof(content) - 1);
    }
    REQUIRE(count == 0);
    content[total] = '\0';
    REQUIRE(strstr(content, page_text) != NULL);
    REQUIRE(strstr(content, "BT") != NULL && strstr(content, "ET") != NULL);
    REQUIRE(pdfioStreamClose(stream));
    return 0;
}

static int check_pdf(const char *path, const char *copy_path, bool encrypted)
{
    pdfio_file_t *pdf, *copy;
    pdfio_obj_t *payload;
    pdfio_stream_t *stream;
    unsigned char bytes[513];
    size_t total = 0, i;
    ssize_t count;

    pdf = pdfioFileOpen(path, encrypted ? password : NULL,
                       encrypted ? (void *)"test-reader" : NULL, on_error, NULL);
    REQUIRE(pdf != NULL);
    REQUIRE(pdfioFileGetNumPages(pdf) == 2);
    REQUIRE(pdfioFileGetTitle(pdf) != NULL && !strcmp(pdfioFileGetTitle(pdf), title));
    REQUIRE(pdfioFileGetAuthor(pdf) != NULL && !strcmp(pdfioFileGetAuthor(pdf), author));
    /* v1.6.6 has a known encrypted DATE/hex-string conversion defect. The
     * separate repro_encrypted_date.c asserts it and returns failure.
     * Ordinary PDF dates remain part of the mandatory roundtrip check. */
    if (!encrypted)
        REQUIRE(pdfioFileGetCreationDate(pdf) == created);
    REQUIRE(check_page(pdfioFileGetPage(pdf, 0)) == 0);
    REQUIRE(check_page(pdfioFileGetPage(pdf, 1)) == 0);
    payload = pdfioDictGetObj(pdfioFileGetCatalog(pdf), "LMXPayload");
    REQUIRE(payload != NULL);
    stream = pdfioObjOpenStream(payload, true);
    REQUIRE(stream != NULL);
    while ((count = pdfioStreamRead(stream, bytes + total, sizeof(bytes) - total)) > 0) {
        total += (size_t)count;
        REQUIRE(total < sizeof(bytes));
    }
    REQUIRE(count == 0 && total == 512);
    for (i = 0; i < total; ++i)
        REQUIRE(bytes[i] == (unsigned char)(17U * (unsigned int)i));
    REQUIRE(pdfioStreamClose(stream));

    copy = pdfioFileCreate(copy_path, "1.7", NULL, NULL, on_error, NULL);
    REQUIRE(copy != NULL);
    REQUIRE(pdfioPageCopy(copy, pdfioFileGetPage(pdf, 1)));
    REQUIRE(pdfioFileClose(copy));
    REQUIRE(pdfioFileClose(pdf));
    copy = pdfioFileOpen(copy_path, NULL, NULL, on_error, NULL);
    REQUIRE(copy != NULL);
    REQUIRE(pdfioFileGetNumPages(copy) == 1);
    REQUIRE(check_page(pdfioFileGetPage(copy, 0)) == 0);
    REQUIRE(pdfioFileClose(copy));
    return 0;
}

static int invalid_pdf(const char *path)
{
    const char *bad[] = {"This is not a PDF\n", "%PDF-1.7\n1 0 obj\n<< /Type /Catalog >>\n"};
    size_t i;
    for (i = 0; i < sizeof(bad) / sizeof(bad[0]); ++i) {
        FILE *fp = fopen(path, "wb");
        pdfio_file_t *pdf;
        int errors = 0;
        REQUIRE(fp != NULL);
        REQUIRE(fwrite(bad[i], 1, strlen(bad[i]), fp) == strlen(bad[i]));
        REQUIRE(fclose(fp) == 0);
        pdf = pdfioFileOpen(path, NULL, NULL, on_error, &errors);
        REQUIRE(pdf == NULL);
        REQUIRE(errors > 0);
    }
    REQUIRE(remove(path) == 0);
    puts("PASS: non-PDF and truncated object input rejected");
    return 0;
}

int main(int argc, char **argv)
{
    char path[2048], copy_path[2048];
    bool encrypted;
    REQUIRE(argc == 3);
    REQUIRE(path_for(path, sizeof(path), argv[2], "document") == 0);
    REQUIRE(path_for(copy_path, sizeof(copy_path), argv[2], "copied-page") == 0);
    if (!strcmp(argv[1], "invalid"))
        return invalid_pdf(path);
    encrypted = !strcmp(argv[1], "encrypted");
    REQUIRE(encrypted || !strcmp(argv[1], "roundtrip"));
    REQUIRE(make_pdf(path, encrypted) == 0);
    REQUIRE(check_pdf(path, copy_path, encrypted) == 0);
    if (encrypted) {
        int errors = 0;
        pdfio_file_t *pdf = pdfioFileOpen(path, password, (void *)"wrong-password", on_error, &errors);
        REQUIRE(pdf == NULL && errors > 0);
    }
    REQUIRE(remove(path) == 0);
    REQUIRE(remove(copy_path) == 0);
    puts(encrypted ? "PASS: AES-128 pages/strings/streams (date excluded: known failure), wrong-password rejection" :
        "PASS: PDF pages, metadata, UTC date, Flate binary stream, and page-copy roundtrip");
    return 0;
}
