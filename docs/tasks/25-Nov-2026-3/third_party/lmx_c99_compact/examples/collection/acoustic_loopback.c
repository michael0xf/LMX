/* An offline PCM packet loopback. No sound device, PortAudio or file codec. */
#include <sys/types.h>
#include <quiet.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PACKETS 4
#define CAPACITY 400
#define REQUIRE(expr) do { if (!(expr)) { \
  fprintf(stderr, "%s:%d: %s (quiet error %d)\n", __FILE__, __LINE__, #expr, (int)quiet_get_last_error()); \
  goto cleanup; \
} } while (0)

static uint32_t random_state = UINT32_C(0x237ac981);
static uint32_t next_random(void)
{
  random_state = random_state * UINT32_C(1664525) + UINT32_C(1013904223);
  return random_state;
}

static int receive_packets(quiet_decoder *decoder,
                          unsigned char payload[PACKETS][CAPACITY],
                          const size_t lengths[PACKETS], size_t *received)
{
  unsigned char decoded[CAPACITY];
  ssize_t n;
  while ((n = quiet_decoder_recv(decoder, decoded, sizeof(decoded))) > 0) {
    if (*received >= PACKETS || (size_t)n != lengths[*received] ||
        memcmp(decoded, payload[*received], (size_t)n) != 0) {
      fprintf(stderr, "Packet %zu differs: received %zd bytes\n", *received, n);
      return -1;
    }
    ++*received;
  }
  return n < 0 && quiet_get_last_error() != quiet_would_block ? -1 : 0;
}

int main(int argc, char **argv)
{
  const char *profile_file = LMX_QUIET_DEFAULT_PROFILE_FILE;
  const char *profile = "audible";
  unsigned int rate = 44100;
  float noise_amplitude = 0;
  quiet_encoder_options *encoder_options = NULL;
  quiet_decoder_options *decoder_options = NULL;
  quiet_encoder *encoder = NULL;
  quiet_decoder *decoder = NULL;
  unsigned char payload[PACKETS][CAPACITY];
  size_t lengths[PACKETS];
  quiet_sample_t pcm[4096];
  static const size_t blocks[] = {127, 1021, 4096, 257};
  size_t received = 0, samples = 0, payload_bytes = 0, iterations = 0;
  double signal_power = 0, noise_power = 0;
  float peak = 0;
  size_t frame_limit, i, j;
  int result = EXIT_FAILURE;

  if (argc != 1 && argc != 5) {
    fprintf(stderr, "Usage: %s [profiles.json profile rate noise_amplitude]\n", argv[0]);
    return EXIT_FAILURE;
  }
  if (argc == 5) {
    char *end;
    unsigned long parsed_rate;
    profile_file = argv[1];
    profile = argv[2];
    parsed_rate = strtoul(argv[3], &end, 10);
    if (*end || parsed_rate < 8000 || parsed_rate > 192000) return EXIT_FAILURE;
    rate = (unsigned int)parsed_rate;
    noise_amplitude = strtof(argv[4], &end);
    if (*end || !isfinite(noise_amplitude) || noise_amplitude < 0 || noise_amplitude > 0.25f) return EXIT_FAILURE;
  }

  encoder_options = quiet_encoder_profile_filename(profile_file, profile);
  decoder_options = quiet_decoder_profile_filename(profile_file, profile);
  REQUIRE(encoder_options != NULL && decoder_options != NULL);
  encoder = quiet_encoder_create(encoder_options, (float)rate);
  decoder = quiet_decoder_create(decoder_options, (float)rate);
  REQUIRE(encoder != NULL && decoder != NULL);
  frame_limit = quiet_encoder_get_frame_len(encoder);
  REQUIRE(frame_limit > 0);
  if (frame_limit > CAPACITY) frame_limit = CAPACITY;
  lengths[0] = 1;
  lengths[1] = frame_limit < 17 ? frame_limit : 17;
  lengths[2] = frame_limit;
  lengths[3] = frame_limit > 1 ? frame_limit - 1 : 1;

  for (i = 0; i < PACKETS; ++i) {
    for (j = 0; j < lengths[i]; ++j) payload[i][j] = (unsigned char)(next_random() >> 24);
    payload[i][0] = (unsigned char)(i & 1 ? 0xFF : 0);
    REQUIRE(quiet_encoder_send(encoder, payload[i], lengths[i]) == (ssize_t)lengths[i]);
    payload_bytes += lengths[i];
  }
  quiet_encoder_close(encoder);
  for (;;) {
    size_t requested = blocks[iterations % (sizeof(blocks) / sizeof(blocks[0]))];
    ssize_t n = quiet_encoder_emit(encoder, pcm, requested);
    REQUIRE(n >= 0 && (size_t)n <= requested);
    if (n == 0) break;
    REQUIRE(++iterations < 10000);
    for (j = 0; j < (size_t)n; ++j) {
      float signal = pcm[j];
      float noise = noise_amplitude * (2.0f * (float)(next_random() >> 8) / 16777216.0f - 1.0f);
      REQUIRE(isfinite(signal));
      signal_power += (double)signal * signal;
      noise_power += (double)noise * noise;
      if (fabsf(signal) > peak) peak = fabsf(signal);
      pcm[j] = signal + noise;
    }
    REQUIRE(quiet_decoder_consume(decoder, pcm, (size_t)n) == n);
    samples += (size_t)n;
    REQUIRE(receive_packets(decoder, payload, lengths, &received) == 0);
  }
  quiet_decoder_flush(decoder);
  REQUIRE(receive_packets(decoder, payload, lengths, &received) == 0);
  REQUIRE(received == PACKETS && samples > 0 && signal_power > 0);
  printf("profile=%s rate=%u packets=%zu payload_bytes=%zu pcm_samples=%zu peak=%.6f noise_peak=%.6f",
    profile, rate, received, payload_bytes, samples, (double)peak, (double)noise_amplitude);
  if (noise_power > 0) printf(" measured_snr_db=%.2f", 10.0 * log10(signal_power / noise_power));
  puts(" packet_equality=PASS");
  result = EXIT_SUCCESS;

cleanup:
  if (decoder) quiet_decoder_destroy(decoder);
  if (encoder) quiet_encoder_destroy(encoder);
  free(decoder_options);
  free(encoder_options);
  return result;
}
