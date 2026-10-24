# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix191; P = C:/Nyasha_Planet/LMX/build2/opus_fix190 (Verified190's stage);
# T = C:/Nyasha_Planet/LMX/build2/opus_fix191/boot-quick-01/lmxtool.exe (this slice's working tool G2).
mkdir -p S/runs/replay-patches-01/stage191/src/l2src S/runs/u0-same-01
cp P/src/l2src/l2trans.lm1 S/runs/replay-patches-01/stage191/src/l2src/l2trans.lm1
# cwd S/runs/replay-patches-01, for F in l2trans.lm1 lmx_value_owned.lm2 (the second patch creates its file):
patch -p0 --quiet stage191/src/l2src/F < S/runs/packet/F.patch
# cwd S/runs/u0-same-01, for each F:
T 0 entry 0 -- same S/runs/replay-patches-01/stage191/src/l2src/F S/src/l2src/F
