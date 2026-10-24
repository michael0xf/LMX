# Observed: a fresh copy of 195's compiler was put in runs/replay-patches-01/stage196/src/l2src/l2trans.lm1.
# cwd build2/codex_fix196/runs/replay-patches-01:
patch --batch --fuzz=0 --quiet -p0 stage196/src/l2src/l2trans.lm1 < C:/Nyasha_Planet/LMX/steps/witnesses/fix196-20261024/l2trans.lm1.patch
# The replay and the frontend's saved source are checked against the actual stage-source SHA by the existing
# language-owned verify in checks/commands.txt (expected-parity.sha256), not an additional tool invocation.
