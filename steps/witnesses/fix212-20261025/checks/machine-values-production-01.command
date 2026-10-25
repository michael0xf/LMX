# The initial gen/ backend command refuses source outside the unit root; it is preserved, not called a PASS.
# New FE output L1/header first raw-compared with actual211 direct references (both0), then copied to normal src/l2src.
# These are generated artifacts only; maintained module source25174A42 is unchanged.
Copy-Item -LiteralPath C:/Nyasha_Planet/LMX/build2/codex_fix212/gen/machine-values-01/lmx_walk_values.lm1 -Destination C:/Nyasha_Planet/LMX/build2/codex_fix212/src/l2src/lmx_walk_values.lm1
Copy-Item -LiteralPath C:/Nyasha_Planet/LMX/build2/codex_fix212/gen/machine-values-01/lmx_walk_values.h.lm1 -Destination C:/Nyasha_Planet/LMX/build2/codex_fix212/src/l2src/lmx_walk_values.h.lm1
# cwd212/src
C:/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/codex_fix212/src/l2src/lmx_walk_values.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix212/gen/machine-values-01/lmx_walk_values.c
