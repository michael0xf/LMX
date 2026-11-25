#ifndef LMX_MBEDTLS_USER_CONFIG_H
#define LMX_MBEDTLS_USER_CONFIG_H

/* Applied to the library and every consumer through the CMake targets.
 * Mbed TLS protects shared RNG and PSA state with POSIX mutexes in this
 * build; curl and libssh2 use the same configuration. */
#define MBEDTLS_THREADING_C
#define MBEDTLS_THREADING_PTHREAD

#endif
