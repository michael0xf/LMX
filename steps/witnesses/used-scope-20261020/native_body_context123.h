#ifndef LMX_NATIVE_BODY_CONTEXT123_H
#define LMX_NATIVE_BODY_CONTEXT123_H
#include "l2src/lmx_value.lm1.h"
static unsigned l2_native_context123_calls;
static void *l2_native_context123_echo(LmxWalkValue *inputs,LmxWalkValue *result,void *value){
 ++l2_native_context123_calls;
 if(result&&inputs){result->model=inputs[0].model;result->references=inputs[0].references;}
 return value;
}
#endif
