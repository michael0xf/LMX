# Executed from build2 into the new empty runs/replay-src; no fuzz.
patch --batch --fuzz=0 -p0 codex_fix197/runs/replay-src/lmx_implements.lm2 < /c/Nyasha_Planet/LMX/steps/witnesses/fix197-20261024/lmx_implements.lm2.patch
sha256sum codex_fix197/src/l2src/lmx_implements.lm2 codex_fix197/runs/replay-src/lmx_implements.lm2
