/* SPDX-License-Identifier: MIT
 * Private CPU-time adapter for Liquid-DSP's process resource timer.
 * FILETIME counts 100-nanosecond CPU ticks, not elapsed wall-clock time.
 */
#ifndef LMX_LIQUID_WIN32_RESOURCE_H
#define LMX_LIQUID_WIN32_RESOURCE_H
#include <stdint.h>
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>

typedef struct {
    int64_t tv_sec;
    long tv_usec;
} lmx_liquid_cpu_time;

typedef struct {
    lmx_liquid_cpu_time ru_utime;
    lmx_liquid_cpu_time ru_stime;
} lmx_liquid_rusage;

static void lmx_liquid_filetime_cpu(const FILETIME *value,
                                  lmx_liquid_cpu_time *result)
{
    uint64_t ticks = ((uint64_t)value->dwHighDateTime << 32) |
                     (uint64_t)value->dwLowDateTime;
    result->tv_sec = (int64_t)(ticks / UINT64_C(10000000));
    result->tv_usec = (long)((ticks % UINT64_C(10000000)) / UINT64_C(10));
}

static int lmx_liquid_getrusage(lmx_liquid_rusage *result)
{
    FILETIME created, exited, kernel, user;
    if (!GetProcessTimes(GetCurrentProcess(), &created, &exited, &kernel, &user))
        return -1;
    lmx_liquid_filetime_cpu(&user, &result->ru_utime);
    lmx_liquid_filetime_cpu(&kernel, &result->ru_stime);
    return 0;
}
#endif
