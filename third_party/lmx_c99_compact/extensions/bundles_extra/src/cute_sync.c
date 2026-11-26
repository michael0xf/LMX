#if defined(_WIN32)
#define CUTE_SYNC_WINDOWS
#else
#define CUTE_SYNC_POSIX
#endif
#define CUTE_SYNC_IMPLEMENTATION
#include "cute_sync.h"
