# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix184; P = C:/Nyasha_Planet/LMX/build2/opus_fix183;
# W = C:/Nyasha_Planet/LMX/steps/witnesses/fix184-20261024 (the patch was written to S/runs/packet first, then copied
# here unchanged); T = build2/opus_fix176/tool-01/lmxtool-tool.exe.
diff -U0 --label stage184/src/l2src/l2trans.lm1 --label stage184/src/l2src/l2trans.lm1 P/src/l2src/l2trans.lm1 S/src/l2src/l2trans.lm1 > S/runs/packet/l2trans.lm1.patch
mkdir -p S/runs/replay-patches-01/stage184/src/l2src S/runs/u0-same-01
cp P/src/l2src/l2trans.lm1 S/runs/replay-patches-01/stage184/src/l2src/
# cwd S/runs/replay-patches-01:
patch -p0 --quiet stage184/src/l2src/l2trans.lm1 < S/runs/packet/l2trans.lm1.patch
# cwd S/runs/u0-same-01:
T 0 entry 0 -- same S/runs/replay-patches-01/stage184/src/l2src/l2trans.lm1 S/src/l2src/l2trans.lm1
