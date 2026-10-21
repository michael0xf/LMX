#ifndef ACTUAL128_EFFECT_TEST_H
#define ACTUAL128_EFFECT_TEST_H
static int actual128_trace,actual128_effects;
static int actual128_mark(int value){
 actual128_trace=actual128_trace*10+value;++actual128_effects;return value;
}
#endif
