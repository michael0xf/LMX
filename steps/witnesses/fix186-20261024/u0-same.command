# The patch replay, as run. S = C:/Nyasha_Planet/LMX/build2/opus_fix186; P = C:/Nyasha_Planet/LMX/build2/opus_fix185;
# T = C:/Nyasha_Planet/LMX/build2/opus_fix185/boot-quick-01/lmxtool.exe (Verified185's working tool G2).
mkdir -p S/runs/replay-patches-01/stage186/src/l2src S/runs/u0-same-01
# for F in lmx_range.lm2 lmx_pool.lm2 lmx_arena_blocks.lm2 lmx_arena.lm2:
cp P/src/l2src/F S/runs/replay-patches-01/stage186/src/l2src/
# cwd S/runs/replay-patches-01 (lmx_chars.lm2.patch creates its file), for F in lmx_chars.lm2 lmx_range.lm2 lmx_pool.lm2
# lmx_arena_blocks.lm2 lmx_arena.lm2:
patch -p0 --quiet stage186/src/l2src/F < S/runs/packet/F.patch
# cwd S/runs/u0-same-01, for each F:
T 0 entry 0 -- same S/runs/replay-patches-01/stage186/src/l2src/F S/src/l2src/F
