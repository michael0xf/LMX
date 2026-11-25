/* MIT. Example container for teaching composition, not a new interchange standard.
 * CSV -> zlib -> protected metadata + RS(255,239) -> damaged medium -> recovery.
 */
#include <correct.h>
#include <zlib.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { RAW_CAP = 8192, FRAME_CAP = 16384, BLOCK_DATA = 239, BLOCK_SIZE = 255,
       HEADER_SIZE = 20, PARITY = 16 };

static void put32(uint8_t *p, uint32_t x)
{
    p[0] = (uint8_t)(x >> 24); p[1] = (uint8_t)(x >> 16);
    p[2] = (uint8_t)(x >> 8); p[3] = (uint8_t)x;
}
static uint32_t get32(const uint8_t *p)
{
    return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 |
           (uint32_t)p[2] << 8 | p[3];
}
static int write_file(const char *path, const uint8_t *data, size_t n)
{
    FILE *f = fopen(path, "wb");
    int ok;
    if (f == NULL) return 0;
    ok = fwrite(data, 1, n, f) == n;
    if (fclose(f) != 0) ok = 0;
    return ok;
}

int main(void)
{
    uint8_t *raw = NULL, *frame = NULL, *protected = NULL, *decoded = NULL, *restored = NULL;
    correct_reed_solomon *rs = NULL;
    FILE *f = NULL;
    size_t raw_n = 0, blocks, encoded_n, i, j;
    uLongf compressed_n = FRAME_CAP - HEADER_SIZE, restored_n = RAW_CAP;
    uLong checksum;
    int result = 1;
    raw = (uint8_t *)calloc(RAW_CAP, 1);
    frame = (uint8_t *)calloc(FRAME_CAP, 1);
    decoded = (uint8_t *)calloc(FRAME_CAP, 1);
    restored = (uint8_t *)calloc(RAW_CAP, 1);
    protected = (uint8_t *)malloc(((FRAME_CAP + BLOCK_DATA - 1) / BLOCK_DATA) * BLOCK_SIZE);
    if (!raw || !frame || !decoded || !restored || !protected) goto done;
    {
        const char header[] = "sample,time_s,temperature_mC,pressure_Pa,status\n";
        memcpy(raw, header, sizeof(header) - 1);
        raw_n = sizeof(header) - 1;
    }
    for (i = 0; i < 160; ++i) {
        int n = snprintf((char *)raw + raw_n, RAW_CAP - raw_n,
            "%u,%u,%u,%u,ok\n", (unsigned)i, (unsigned)i * 10,
            21000u + (unsigned)(i * 17 % 401), 99000u + (unsigned)(i * 31 % 1999));
        if (n < 0 || (size_t)n >= RAW_CAP - raw_n) goto done;
        raw_n += (size_t)n;
    }
    checksum = crc32(0L, Z_NULL, 0);
    checksum = crc32(checksum, raw, (uInt)raw_n);
    if (compress2(frame + HEADER_SIZE, &compressed_n, raw, (uLong)raw_n, 6) != Z_OK) goto done;
    memcpy(frame, "LMRC", 4);
    put32(frame + 4, 1); /* Example container version. */
    put32(frame + 8, (uint32_t)raw_n);
    put32(frame + 12, (uint32_t)compressed_n);
    put32(frame + 16, (uint32_t)checksum);
    blocks = (HEADER_SIZE + (size_t)compressed_n + BLOCK_DATA - 1) / BLOCK_DATA;
    if (blocks * BLOCK_DATA > FRAME_CAP) goto done;
    encoded_n = blocks * BLOCK_SIZE;
    rs = correct_reed_solomon_create(correct_rs_primitive_polynomial_8_4_3_2_0, 1, 1, PARITY);
    if (rs == NULL) goto done;
    for (i = 0; i < blocks; ++i) {
        if (correct_reed_solomon_encode(rs, frame + i * BLOCK_DATA, BLOCK_DATA,
                                       protected + i * BLOCK_SIZE) != BLOCK_SIZE) goto done;
    }
    if (!write_file("sample.csv", raw, raw_n) ||
        !write_file("sample.protected", protected, encoded_n)) goto done;
    /* Eight distinct corrupt symbols in EVERY block, including the header block.
       This reaches the RS(255,239) correction limit for unknown error locations. */
    for (i = 0; i < blocks; ++i)
        for (j = 0; j < PARITY / 2; ++j)
            protected[i * BLOCK_SIZE + (j * 29 + i * 7) % BLOCK_SIZE] ^= (uint8_t)(0x81u + j);
    if (!write_file("sample.damaged", protected, encoded_n)) goto done;
    memset(protected, 0, encoded_n);
    f = fopen("sample.damaged", "rb");
    if (f == NULL) goto done;
    if (fread(protected, 1, encoded_n, f) != encoded_n || fgetc(f) != EOF || ferror(f)) goto done;
    if (fclose(f) != 0) { f = NULL; goto done; }
    f = NULL;
    for (i = 0; i < blocks; ++i) {
        if (correct_reed_solomon_decode(rs, protected + i * BLOCK_SIZE, BLOCK_SIZE,
                                       decoded + i * BLOCK_DATA) != BLOCK_DATA) goto done;
    }
    if (memcmp(decoded, "LMRC", 4) || get32(decoded + 4) != 1 ||
        get32(decoded + 8) > RAW_CAP ||
        get32(decoded + 12) > blocks * BLOCK_DATA - HEADER_SIZE) goto done;
    if (uncompress(restored, &restored_n, decoded + HEADER_SIZE, get32(decoded + 12)) != Z_OK) goto done;
    if (restored_n != get32(decoded + 8) || restored_n != raw_n ||
        crc32(crc32(0L, Z_NULL, 0), restored, (uInt)restored_n) != get32(decoded + 16) ||
        memcmp(restored, raw, raw_n)) goto done;
    if (!write_file("sample.restored.csv", restored, (size_t)restored_n)) goto done;
    printf("Data rescue PASS: %lu CSV bytes, %lu zlib bytes, %lu RS blocks, "
           "%lu damaged bytes corrected; readback, decompression and CRC verified\n",
           (unsigned long)raw_n, (unsigned long)compressed_n, (unsigned long)blocks,
           (unsigned long)(blocks * PARITY / 2));
    result = 0;
done:
    if (f != NULL) fclose(f);
    if (rs != NULL) correct_reed_solomon_destroy(rs);
    free(raw); free(frame); free(protected); free(decoded); free(restored);
    if (result) fputs("Data rescue failed\n", stderr);
    return result;
}
