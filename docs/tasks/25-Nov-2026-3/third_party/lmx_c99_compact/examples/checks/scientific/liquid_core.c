/* Deterministic public-API tests for the complete standalone Liquid-DSP target. */
#include <complex.h>
#include <liquid/liquid.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "line %d: %s\n", __LINE__, #x); return 1; } } while (0)
#define PI 3.14159265358979323846

static int check_fft(unsigned int n)
{
    float complex input[17], output[17], restored[17];
    unsigned int i, k;
    float worst = 0;
    fftplan forward, inverse;
    for (i = 0; i < n; ++i)
        input[i] = (float)((int)(i % 5) - 2) * 0.23f + I * sinf((float)i * 0.41f);
    forward = fft_create_plan(n, input, output, LIQUID_FFT_FORWARD, 0);
    inverse = fft_create_plan(n, output, restored, LIQUID_FFT_BACKWARD, 0);
    CHECK(forward && inverse);
    fft_execute(forward);
    for (k = 0; k < n; ++k) {
        double complex expected = 0;
        for (i = 0; i < n; ++i) {
            double angle = -2.0 * PI * (double)k * i / n;
            expected += (double complex)input[i] * (cos(angle) + I * sin(angle));
        }
        {
            float error = (float)cabs((double complex)output[k] - expected);
            if (error > worst) worst = error;
            CHECK(error < 4e-4f);
        }
    }
    fft_execute(inverse);
    for (i = 0; i < n; ++i) CHECK(cabsf(restored[i] / (float)n - input[i]) < 4e-5f);
    fft_destroy_plan(inverse);
    fft_destroy_plan(forward);
    printf("internal_fft n=%u direct_dft_max_error=%.9g roundtrip=PASS\n", n, (double)worst);
    return 0;
}

static int check_filter(void)
{
    float coefficients[] = {0.25f, 0.5f, 0.25f};
    firfilt_rrrf filter = firfilt_rrrf_create(coefficients, 3);
    unsigned int i;
    float y;
    CHECK(filter);
    for (i = 0; i < 8; ++i) {
        firfilt_rrrf_push(filter, i == 0 ? 1.0f : 0.0f);
        firfilt_rrrf_execute(filter, &y);
        CHECK(fabsf(y - (i < 3 ? coefficients[i] : 0.0f)) < 1e-6f);
    }
    firfilt_rrrf_reset(filter);
    for (i = 0; i < 32; ++i) {
        firfilt_rrrf_push(filter, 1);
        firfilt_rrrf_execute(filter, &y);
        if (i >= 2) CHECK(fabsf(y - 1) < 1e-6f);
    }
    firfilt_rrrf_reset(filter);
    for (i = 0; i < 32; ++i) {
        firfilt_rrrf_push(filter, i & 1 ? -1.0f : 1.0f);
        firfilt_rrrf_execute(filter, &y);
        if (i >= 2) CHECK(fabsf(y) < 1e-6f);
    }
    firfilt_rrrf_destroy(filter);
    puts("fir impulse/DC/Nyquist_rejection=PASS");
    return 0;
}

static int check_modem(void)
{
    modemcf tx = modemcf_create(LIQUID_MODEM_QAM16);
    modemcf rx = modemcf_create(LIQUID_MODEM_QAM16);
    unsigned int i;
    CHECK(tx && rx);
    for (i = 0; i < 256; ++i) {
        unsigned int symbol = (i * 7u + 3u) % 16u, decoded = 999;
        float complex sample;
        CHECK(modemcf_modulate(tx, symbol, &sample) == 0);
        sample += 0.015f * (float)((int)(i % 3) - 1) + I * 0.013f * (float)((int)(i % 5) - 2);
        CHECK(modemcf_demodulate(rx, sample, &decoded) == 0);
        CHECK(symbol == decoded);
    }
    modemcf_destroy(rx);
    modemcf_destroy(tx);
    puts("QAM16 256_symbols deterministic_noise=PASS");
    return 0;
}

static int check_fec(fec_scheme scheme)
{
    unsigned char data[31], decoded[31], encoded[256];
    unsigned int i, n = fec_get_enc_msg_length(scheme, sizeof(data));
    fec code = fec_create(scheme, NULL);
    CHECK(code && n <= sizeof(encoded));
    for (i = 0; i < sizeof(data); ++i) data[i] = (unsigned char)(i * 71u + 23u);
    CHECK(fec_encode(code, sizeof(data), data, encoded) == 0);
    encoded[3] ^= 0x01;
    CHECK(fec_decode(code, sizeof(data), encoded, decoded) == 0);
    CHECK(memcmp(data, decoded, sizeof(data)) == 0);
    fec_destroy(code);
    printf("liquid_fec scheme=%d corrupted_bit recovery=PASS\n", (int)scheme);
    return 0;
}

int main(void)
{
    CHECK(liquid_libversion_number() == (int)LIQUID_VERSION_NUMBER);
    printf("Liquid-DSP %s standalone complete core\n", liquid_libversion());
    CHECK(check_fft(16) == 0);
    CHECK(check_fft(17) == 0);
    CHECK(check_filter() == 0);
    CHECK(check_modem() == 0);
    CHECK(check_fec(LIQUID_FEC_CONV_V27) == 0);
    CHECK(check_fec(LIQUID_FEC_RS_M8) == 0);
    return 0;
}
