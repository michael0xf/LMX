# New bootstrap frontend203 -> same L1/C, cwd203/src; no redundant C compilation of unchanged program.
C:/Nyasha_Planet/LMX/build2/codex_fix203/boot-quick-01/frontend/l2trans.exe --library --machine main C:/Nyasha_Planet/LMX/build2/codex_fix203/tests/timing/values.lm2 C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/convert.lm2 C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/primitive.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-current.lm1
C:/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-current.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-current.c
cmp C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-03.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-current.lm1
cmp C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-03.c C:/Nyasha_Planet/LMX/build2/codex_fix203/gen/timing-values-current.c
