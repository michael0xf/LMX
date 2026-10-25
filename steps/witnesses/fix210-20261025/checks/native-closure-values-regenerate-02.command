# After ordinary02 runtime modules/headers, cwd210/src. Reuse actual01 execution, no C rebuild/run.
C:/Nyasha_Planet/LMX/build2/codex_fix210/boot-quick-02/frontend/l2trans.exe --library --machine main --machine probe_read --machine probe_write --machine lane_body --machine root_step C:/Nyasha_Planet/LMX/build2/codex_fix210/tests/native_closure_values.lm2 C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/convert.lm2 C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/primitive.lm2 C:/Nyasha_Planet/LMX/build2/codex_fix210/gen/native-closure-values-current.lm1
C:/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/codex_fix210/gen/native-closure-values-current.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix210/gen/native-closure-values-current.c
cmp gen/native-closure-values-01.lm1 gen/native-closure-values-current.lm1
cmp gen/native-closure-values-01.c gen/native-closure-values-current.c
