/* Small C99 consumer: writes the explicitly supplied path, then validates it.
 * Run: lmx_xlsxio_example /path/to/new-file.xlsx
 * An existing file at that path is overwritten by the upstream writer API. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "xlsxio_read.h"
#include "xlsxio_write.h"

static const char *const sheetname = "Данные & \"LMX\"";
static const char *const labels[3] = { "Текст", "Счёт", "Число" };
static const char *const texts[2] = {
    "<LMX> & \"quote\" 'apostrophe' — Привет",
    "line1\nline2 \xF0\x9F\x98\x80"
};
static const int64_t integers[2] = { INT64_C(-1234567890123), INT64_C(0) };
static const double reals[2] = { 3.125, -0.0625 };

int main(int argc, char **argv)
{
    xlsxiowriter writer = NULL;
    xlsxioreader reader = NULL;
    xlsxioreadersheet sheet = NULL;
    xlsxioreadersheetlist sheets = NULL;
    char *cell = NULL;
    int result = 1, i;
#define REQUIRE(c) do { if (!(c)) { fprintf(stderr, "XLSX check failed at %d: %s\n", __LINE__, #c); goto cleanup; } } while (0)
    if (argc != 2) {
        fprintf(stderr, "Usage: %s output.xlsx\n", argv[0]);
        return 2;
    }
    writer = xlsxiowrite_open(argv[1], sheetname);
    REQUIRE(writer);
    xlsxiowrite_set_detection_rows(writer, 4);
    for (i = 0; i < 3; ++i) xlsxiowrite_add_column(writer, labels[i], 0);
    xlsxiowrite_next_row(writer);
    for (i = 0; i < 2; ++i) {
        xlsxiowrite_add_cell_string(writer, texts[i]);
        xlsxiowrite_add_cell_int(writer, integers[i]);
        xlsxiowrite_add_cell_float(writer, reals[i]);
        xlsxiowrite_next_row(writer);
    }
    {
        int close_result = xlsxiowrite_close(writer);
        writer = NULL;
        REQUIRE(close_result == 0);
    }
    reader = xlsxioread_open(argv[1]); REQUIRE(reader);
    sheets = xlsxioread_sheetlist_open(reader); REQUIRE(sheets);
    {
        const char *name = xlsxioread_sheetlist_next(sheets);
        REQUIRE(name && strcmp(name, sheetname) == 0);
        REQUIRE(xlsxioread_sheetlist_next(sheets) == NULL);
    }
    xlsxioread_sheetlist_close(sheets); sheets = NULL;
    sheet = xlsxioread_sheet_open(reader, sheetname, XLSXIOREAD_SKIP_NONE); REQUIRE(sheet);
    REQUIRE(xlsxioread_sheet_next_row(sheet));
    for (i = 0; i < 3; ++i) {
        cell = xlsxioread_sheet_next_cell(sheet);
        REQUIRE(cell && strcmp(cell, labels[i]) == 0);
        xlsxioread_free(cell); cell = NULL;
    }
    REQUIRE(xlsxioread_sheet_next_cell(sheet) == NULL);
    for (i = 0; i < 2; ++i) {
        int64_t integer;
        double real;
        REQUIRE(xlsxioread_sheet_next_row(sheet));
        REQUIRE(xlsxioread_sheet_next_cell_string(sheet, &cell));
        REQUIRE(cell && strcmp(cell, texts[i]) == 0);
        xlsxioread_free(cell); cell = NULL;
        REQUIRE(xlsxioread_sheet_next_cell_int(sheet, &integer) && integer == integers[i]);
        REQUIRE(xlsxioread_sheet_next_cell_float(sheet, &real) && real == reals[i]);
        REQUIRE(xlsxioread_sheet_next_cell(sheet) == NULL);
    }
    REQUIRE(!xlsxioread_sheet_next_row(sheet));
    printf("XLSXIO %s: UTF-8, XML escaping, integers, floats and sheet name verified\n",
           xlsxioread_get_version_string());
    result = 0;
cleanup:
    if (cell) xlsxioread_free(cell);
    if (sheets) xlsxioread_sheetlist_close(sheets);
    if (sheet) xlsxioread_sheet_close(sheet);
    if (reader) xlsxioread_close(reader);
    if (writer) (void)xlsxiowrite_close(writer);
    return result;
}
