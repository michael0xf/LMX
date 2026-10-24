# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix181; P = C:/Nyasha_Planet/LMX/build2/opus_fix180;
# W = C:/Nyasha_Planet/LMX/steps/witnesses/fix181-20261024; T = build2/opus_fix176/tool-01/lmxtool-tool.exe.
mkdir -p S/runs/replay-patches-01/stage181/src/l2src S/runs/u0-same-01
cp P/src/l2src/l2trans.lm1 S/runs/replay-patches-01/stage181/src/l2src/
# cwd S/runs/replay-patches-01 (lmx_pool.lm2.patch creates its file):
patch -p0 --quiet stage181/src/l2src/l2trans.lm1 < W/l2trans.lm1.patch
patch -p0 --quiet stage181/src/l2src/lmx_pool.lm2 < W/lmx_pool.lm2.patch
# cwd S/runs/u0-same-01, for each F in l2trans.lm1 lmx_pool.lm2:
T 0 entry 0 -- same S/runs/replay-patches-01/stage181/src/l2src/F S/src/l2src/F
