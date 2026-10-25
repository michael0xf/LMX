set -e
mkdir -p build2/codex_fix201/runs/replay-src/src/l2src
cp build2/codex_fix200/src/l2src/lmx_post.h.lm1 build2/codex_fix201/runs/replay-src/src/l2src/lmx_post.h.lm1
patch --batch --fuzz=0 -d build2/codex_fix201/runs/replay-src -p1 < build2/codex_fix201/trace/lmx_post.lm2.patch
patch --batch --fuzz=0 -d build2/codex_fix201/runs/replay-src -p1 < build2/codex_fix201/trace/lmx_post.h.lm1.patch
cmp build2/codex_fix201/src/l2src/lmx_post.lm2 build2/codex_fix201/runs/replay-src/src/l2src/lmx_post.lm2
cmp build2/codex_fix201/src/l2src/lmx_post.h.lm1 build2/codex_fix201/runs/replay-src/src/l2src/lmx_post.h.lm1
