# cwd205/src. New current FE regenerates L1/C for byte comparison with actual03 EXE inputs.
# On equality reuse actual03 EXE/output; no unnecessary C rebuild or re-execution.
C:/Nyasha_Planet/LMX/build2/codex_fix205/boot-quick-01/frontend/l2trans.exe --library --machine main C:/Nyasha_Planet/LMX/build2/codex_fix205/tests/settle/values.lm2 C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/convert.lm2 C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/primitive.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-current.lm1
C:/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-current.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-current.c
cmp C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-03.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-current.lm1
cmp C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-03.c C:/Nyasha_Planet/LMX/build2/codex_fix205/gen/settle-values-current.c
