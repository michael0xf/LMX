# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix183; W = C:/Nyasha_Planet/LMX/steps/witnesses/fix183-20261024
# (the patch was written to S/runs/packet first, then copied here unchanged); T = build2/opus_fix176/tool-01/lmxtool-tool.exe.
diff -U0 -N --label /dev/null --label stage183/src/l2src/lmx_arena.lm2 /dev/null S/src/l2src/lmx_arena.lm2 > S/runs/packet/lmx_arena.lm2.patch
mkdir -p S/runs/replay-patches-01/stage183/src/l2src S/runs/u0-same-01
# cwd S/runs/replay-patches-01 (lmx_arena.lm2.patch creates its file):
patch -p0 --quiet stage183/src/l2src/lmx_arena.lm2 < S/runs/packet/lmx_arena.lm2.patch
# cwd S/runs/u0-same-01:
T 0 entry 0 -- same S/runs/replay-patches-01/stage183/src/l2src/lmx_arena.lm2 S/src/l2src/lmx_arena.lm2
