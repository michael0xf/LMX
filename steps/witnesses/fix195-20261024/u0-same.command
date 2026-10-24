# Replay observed from a fresh runs/replay-patches-01: GNU patch is only reconstructing a generated witness copy.
# The maintained edit was made with apply_patch in the new stage; neither frozen stage was edited.
# cwd C:/Nyasha_Planet/LMX/build2/codex_fix195/runs/replay-patches-01:
patch --batch --fuzz=0 --quiet -p0 stage195/src/l2src/l2trans.lm1 < C:/Nyasha_Planet/LMX/steps/witnesses/fix195-20261024/l2trans.lm1.patch
# cwd the new empty C:/Nyasha_Planet/LMX/build2/codex_fix195/runs/u0-same-01:
C:/Nyasha_Planet/LMX/build2/codex_fix195/boot-quick-01/lmxtool.exe 0 entry 0 -- same C:/Nyasha_Planet/LMX/build2/codex_fix195/runs/replay-patches-01/stage195/src/l2src/l2trans.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix195/src/l2src/l2trans.lm1
