#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "qrcodegen.h"
#include "quirc.h"

static int decode_rendered(const uint8_t *qr, const uint8_t *expected, size_t expected_len) {
    const int scale = 7, quiet = 4;
    int qr_size = qrcodegen_getSize(qr);
    int side = (qr_size + 2 * quiet) * scale;
    struct quirc *recognizer = quirc_new();
    struct quirc_code code;
    struct quirc_data data;
    quirc_decode_error_t status;
    uint8_t *pixels;
    int x, y, count, ok = 0;
    if (!recognizer || quirc_resize(recognizer, side, side) != 0) goto done;
    pixels = quirc_begin(recognizer, NULL, NULL);
    if (!pixels) goto done;
    memset(pixels, 255, (size_t)side * (size_t)side);
    for (y = 0; y < side; ++y) {
        for (x = 0; x < side; ++x) {
            int mx = x / scale - quiet, my = y / scale - quiet;
            if (mx >= 0 && my >= 0 && mx < qr_size && my < qr_size &&
                qrcodegen_getModule(qr, mx, my)) {
                pixels[(size_t)y * (size_t)side + (size_t)x] = 0;
            }
        }
    }
    quirc_end(recognizer);
    count = quirc_count(recognizer);
    if (count != 1) { fprintf(stderr, "Expected one QR, got %d\n", count); goto done; }
    quirc_extract(recognizer, 0, &code);
    status = quirc_decode(&code, &data);
    if (status != QUIRC_SUCCESS) {
        fprintf(stderr, "Decode failed: %s\n", quirc_strerror(status)); goto done;
    }
    if ((size_t)data.payload_len != expected_len || memcmp(data.payload, expected, expected_len) != 0) {
        fprintf(stderr, "QR payload mismatch\n"); goto done;
    }
    /* Negative image check exercises detector reset/reuse. */
    pixels = quirc_begin(recognizer, NULL, NULL);
    memset(pixels, 255, (size_t)side * (size_t)side);
    quirc_end(recognizer);
    if (quirc_count(recognizer) != 0) { fprintf(stderr, "Blank image yielded a QR\n"); goto done; }
    printf("Roundtrip: %lu bytes, %dx%d modules, %dx%d gray pixels\n",
           (unsigned long)expected_len, qr_size, qr_size, side, side);
    ok = 1;
done:
    quirc_destroy(recognizer);
    return ok;
}

int main(void) {
    static const char text[] = "LMX C99: /hello?q=a%20b; UTF-8: \xd0\x9f\xd1\x80\xd0\xb8\xd0\xb2\xd0\xb5\xd1\x82";
    static const uint8_t binary[] = {0x00, 0xff, 0x01, 0x80, 'L', 'M', 'X', 0x00, 0x7f};
    uint8_t scratch[qrcodegen_BUFFER_LEN_MAX], qr[qrcodegen_BUFFER_LEN_MAX];
    if (!qrcodegen_encodeText(text, scratch, qr, qrcodegen_Ecc_HIGH,
            1, 20, qrcodegen_Mask_AUTO, true)) return 1;
    if (!decode_rendered(qr, (const uint8_t *)text, strlen(text))) return 1;
    memcpy(scratch, binary, sizeof(binary));
    if (!qrcodegen_encodeBinary(scratch, sizeof(binary), qr, qrcodegen_Ecc_MEDIUM,
            1, 20, qrcodegen_Mask_3, false)) return 1;
    if (!decode_rendered(qr, binary, sizeof(binary))) return 1;
    printf("Nayuki C generator -> quirc %s: text, binary and blank-image checks passed\n", quirc_version());
    return 0;
}
