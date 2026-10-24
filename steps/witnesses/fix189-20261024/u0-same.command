# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix189;
# T = C:/Nyasha_Planet/LMX/build2/opus_fix189/boot-quick-01/lmxtool.exe (this slice's working tool G2).
mkdir -p S/runs/replay-patches-01/stage189/src/l2src S/runs/u0-same-01
# cwd S/runs/replay-patches-01 (the patch creates its file):
patch -p0 --quiet stage189/src/l2src/lmx_scratch.lm2 < S/runs/packet/lmx_scratch.lm2.patch
# cwd S/runs/u0-same-01:
T 0 entry 0 -- same S/runs/replay-patches-01/stage189/src/l2src/lmx_scratch.lm2 S/src/l2src/lmx_scratch.lm2
