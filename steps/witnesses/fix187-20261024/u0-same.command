# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix187;
# T = C:/Nyasha_Planet/LMX/build2/opus_fix187/boot-quick-01/lmxtool.exe (this slice's working tool G2).
mkdir -p S/runs/replay-patches-01/stage187/src/l2src S/runs/u0-same-01
# cwd S/runs/replay-patches-01 (both patches create their files), for F in lmx_chars_owned.lm2 lmx_array_ref_owned.lm2:
patch -p0 --quiet stage187/src/l2src/F < S/runs/packet/F.patch
# cwd S/runs/u0-same-01, for each F:
T 0 entry 0 -- same S/runs/replay-patches-01/stage187/src/l2src/F S/src/l2src/F
