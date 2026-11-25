/* SPDX-License-Identifier: 0BSD */
#ifndef LMX_FLASHDB_CALLBACKS_H
#define LMX_FLASHDB_CALLBACKS_H
#include "flashdb.h"
typedef void (*lmx_fdb_callback)(fdb_db_t db);
/* Set before initialization; use native typed fields, never void*/
static inline void lmx_fdb_set_callbacks(fdb_db_t db,
        lmx_fdb_callback lock, lmx_fdb_callback unlock) {
    db->lock = lock;
    db->unlock = unlock;
}
/* In the LMX C99 profile only, *_CTRL_SET_LOCK/UNLOCK also accept
   a pointer to a lmx_fdb_callback object (or NULL to clear).
   Upstream's cast of a function pointer to void* is not ISO C99. */
#endif
