# Actual source-creating patch replay, cwd build2, new empty runs/replay-src; no fuzz.
patch --batch --fuzz=0 -p0 codex_fix199/runs/replay-src/lmx_merge_owned.lm2 < codex_fix199/trace/lmx_merge_owned.lm2.patch
sha256sum codex_fix199/src/l2src/lmx_merge_owned.lm2 codex_fix199/runs/replay-src/lmx_merge_owned.lm2
# Both ea08a1445752de4b1b58cbaf335ba7e24b9316faca70a1cf2d567477961751ed.
