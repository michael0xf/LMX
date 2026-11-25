#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>
#ifdef LMX_ORIGINAL_CPP
#include <string>
using std::string;
#include "sobol.hpp"
#define I8_FN i8_sobol
#define I4_FN i4_sobol
#else
#include "lmx_sobol.h"
#define I8_FN lmx_sobol_i8_sobol
#define I4_FN lmx_sobol_i4_sobol
#endif
int main(void) {
  const int dims[] = {1, 3, 40, 1111, 2};
  const int indices[] = {0, 1, 2, 7, 37, 1024, 4095};
  double point[1111]; float point4[1111];
  size_t d, k; int j;
  for(d=0;d<sizeof(dims)/sizeof(dims[0]);++d) {
    for(k=0;k<sizeof(indices)/sizeof(indices[0]);++k) {
      long long seed = indices[k]; int seed4=indices[k];
      I8_FN(dims[d],&seed,point); I4_FN(dims[d],&seed4,point4);
      for(j=0;j<dims[d];++j) {
        uint64_t b; uint32_t b4;
        memcpy(&b,&point[j],sizeof(b)); memcpy(&b4,&point4[j],sizeof(b4));
        printf("%d %d %d %016" PRIx64 " %08" PRIx32 "\n",dims[d],indices[k],j,b,b4);
      }
    }
  }
  return 0;
}
