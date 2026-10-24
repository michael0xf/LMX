# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix193; T = S/boot-quick-01/lmxtool.exe (this slice's
# working tool G2). The patch creates the module's source, which Verified192's stage does not have.
mkdir -p S/runs/replay-patches-01/stage193/src/l2src S/runs/u0-same-01
# cwd S/runs/replay-patches-01:
patch -p0 --quiet < S/runs/packet/lmx_source_names.lm2.patch
# cwd S/runs/u0-same-01:
T 0 entry 0 -- same S/runs/replay-patches-01/stage193/src/l2src/lmx_source_names.lm2 S/src/l2src/lmx_source_names.lm2
