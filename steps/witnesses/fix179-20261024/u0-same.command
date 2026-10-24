# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix179; P = C:/Nyasha_Planet/LMX/build2/opus_fix178;
# W = C:/Nyasha_Planet/LMX/steps/witnesses/fix179-20261024; T = build2/opus_fix176/tool-01/lmxtool-tool.exe.
mkdir -p S/runs/replay-patches-01/stage179/src/l2src S/runs/u0-same-01
cp P/src/l2src/l2trans.lm1 P/src/l2src/lmx_list_owned.lm2 S/runs/replay-patches-01/stage179/src/l2src/
# cwd S/runs/replay-patches-01, for each F in l2trans.lm1 lmx_list_owned.lm2:
patch -p0 --quiet stage179/src/l2src/F < W/F.patch
# cwd S/runs/u0-same-01, for each F:
T 0 entry 0 -- same S/runs/replay-patches-01/stage179/src/l2src/F S/src/l2src/F
