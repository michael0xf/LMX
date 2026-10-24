# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix182; P = C:/Nyasha_Planet/LMX/build2/opus_fix181;
# W = C:/Nyasha_Planet/LMX/steps/witnesses/fix182-20261024 (the patches were written to S/runs/packet first, then copied
# here unchanged); T = build2/opus_fix176/tool-01/lmxtool-tool.exe.
mkdir -p S/runs/replay-patches-01/stage182/src/l2src S/runs/u0-same-01
cp P/src/l2src/l2trans.lm1 S/runs/replay-patches-01/stage182/src/l2src/
# cwd S/runs/replay-patches-01 (lmx_arena_blocks.lm2.patch creates its file):
patch -p0 --quiet stage182/src/l2src/l2trans.lm1 < S/runs/packet/l2trans.lm1.patch
patch -p0 --quiet stage182/src/l2src/lmx_arena_blocks.lm2 < S/runs/packet/lmx_arena_blocks.lm2.patch
# cwd S/runs/u0-same-01, for each F in l2trans.lm1 lmx_arena_blocks.lm2:
T 0 entry 0 -- same S/runs/replay-patches-01/stage182/src/l2src/F S/src/l2src/F
