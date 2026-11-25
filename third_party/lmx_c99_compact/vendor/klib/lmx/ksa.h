/* LMX declarations, MIT. Upstream ksa.c does not ship a public header.
 * n includes the trailing zero sentinel. k is the alphabet size (<=256). */
#ifndef LMX_KLIB_KSA_H
#define LMX_KLIB_KSA_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
int ksa_sa(const unsigned char *text, int *suffix_array, int n, int k);
int ksa_bwt(unsigned char *text, int n, int k);
int ksa_sa64(const unsigned char *text, int64_t *suffix_array, int64_t n, int k);
int ksa_bwt64(unsigned char *text, int64_t n, int k);
#ifdef __cplusplus
}
#endif
#endif
