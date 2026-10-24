# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix192; P = C:/Nyasha_Planet/LMX/build2/opus_fix191 (Verified191's stage);
# T = C:/Nyasha_Planet/LMX/build2/opus_fix192/boot-quick-01/lmxtool.exe (this slice's working tool G2).
mkdir -p S/runs/replay-patches-01/stage192/src/l2src S/runs/u0-same-01
cp P/src/l2src/l2trans.lm1 S/runs/replay-patches-01/stage192/src/l2src/l2trans.lm1
# cwd S/runs/replay-patches-01:
patch -p0 --quiet stage192/src/l2src/l2trans.lm1 < S/runs/packet/l2trans.lm1.patch
# cwd S/runs/u0-same-01:
T 0 entry 0 -- same S/runs/replay-patches-01/stage192/src/l2src/l2trans.lm1 S/src/l2src/l2trans.lm1
