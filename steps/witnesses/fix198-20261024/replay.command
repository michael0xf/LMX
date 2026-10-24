# Executed from build2, new empty runs/replay-src, source-creating patch; no fuzz.
patch --batch --fuzz=0 -p0 codex_fix198/runs/replay-src/lmx_graph_copy_owned.lm2 < codex_fix198/trace/lmx_graph_copy_owned.lm2.patch
sha256sum codex_fix198/src/l2src/lmx_graph_copy_owned.lm2 codex_fix198/runs/replay-src/lmx_graph_copy_owned.lm2
# Both e0facb8cebbc192e721ab65ed2516453746ba6218ab403c6848e41fa918a1f37.
