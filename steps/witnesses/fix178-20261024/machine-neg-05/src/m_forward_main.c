/* Positive: C calls the machine entries with their explicit arguments; the program links the generated module alone
   -- no driver, no Lmx instance, no graph. Exit 0 iff each result is the one L2 gives. */
#include "m_forward.lm1.h"
int main(void) { return m_twice(5) == 7 && m_half(-9) == -4 && m_rest(10) == 1 && m_span(10, 4) == 14 ? 0 : 1; }
