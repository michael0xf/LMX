#ifndef LMX_MBEDTLS_USER_CONFIG_H
#define LMX_MBEDTLS_USER_CONFIG_H

/* Applied to the library and every consumer through the CMake targets.
 * CivetWeb workers share an entropy/CTR-DRBG context; Mbed TLS protects its
 * RNG and PSA global state with POSIX mutexes in this build. */
#define MBEDTLS_THREADING_C
#define MBEDTLS_THREADING_PTHREAD

#endif
