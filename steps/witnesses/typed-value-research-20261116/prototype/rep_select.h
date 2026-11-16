/* rep_select.h -- picks the representation header from -DREP=<name>. */
#ifndef TV_REP_SELECT_H
#define TV_REP_SELECT_H

#define REP_cur_range 1
#define REP_cur_chunkhdr 2
#define REP_tv_full 3
#define REP_tv_compact 4
#define REP_tv_tagged 5
#define REP_tv_prefix 6
#define REP_tv_packed 7
#define REP_tv_word 8
#define REP_tv_align 9

#define REPID_(x) REP_##x
#define REPID(x) REPID_(x)

#ifndef REP
#error "compile with -DREP=cur_range|cur_chunkhdr|tv_full|tv_compact|tv_tagged|tv_prefix|tv_packed|tv_word|tv_align"
#endif

#if REPID(REP) == 1
#include "rep_cur_range.h"
#elif REPID(REP) == 2
#include "rep_cur_chunkhdr.h"
#elif REPID(REP) == 3
#include "rep_tv_full.h"
#elif REPID(REP) == 4
#include "rep_tv_compact.h"
#elif REPID(REP) == 5
#include "rep_tv_tagged.h"
#elif REPID(REP) == 6
#include "rep_tv_prefix.h"
#elif REPID(REP) == 7
#include "rep_tv_packed.h"
#elif REPID(REP) == 8
#include "rep_tv_word.h"
#elif REPID(REP) == 9
#include "rep_tv_align.h"
#else
#error "unknown REP"
#endif

#endif /* TV_REP_SELECT_H */
