/* LMX declarations, MIT. Upstream kopen.c does not ship a public header. */
#ifndef LMX_KLIB_KOPEN_H
#define LMX_KLIB_KOPEN_H
#ifdef __cplusplus
extern "C" {
#endif
void *kopen(const char *filename, int *fd);
int kclose(void *handle);
#ifdef __cplusplus
}
#endif
#endif
