#ifndef LMX_NATIVE_RESULT124_TEST_H
#define LMX_NATIVE_RESULT124_TEST_H
#include "l2src/tests/opaque_declared_views_test.h"
static unsigned l2_result124_calls,l2_result124_null_calls;
static void *l2_result124_opaque(void){++l2_result124_calls;return l2_test_opaque_declared();}
static void *l2_result124_null(void){++l2_result124_null_calls;return NULL;}
#endif
