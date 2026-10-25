# cwd build2; replay-src contains only the seven copied frozen199 bridge inputs. The L2 source is created from /dev/null.
set -e
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_call.lm2.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_call.h.lm1.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_walk.lm1.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_thread.h.lm1.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_thread.lm1.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_root.h.lm1.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/lmx_root.lm1.patch
patch --batch --fuzz=0 -p1 -d codex_fix200/runs/replay-src -i /c/Nyasha_Planet/LMX/build2/codex_fix200/trace/l2_eternal_driver.lm1.patch
cmp codex_fix200/src/l2src/lmx_call.lm2 codex_fix200/runs/replay-src/src/l2src/lmx_call.lm2
cmp codex_fix200/src/l2src/lmx_call.h.lm1 codex_fix200/runs/replay-src/src/l2src/lmx_call.h.lm1
cmp codex_fix200/src/l2src/lmx_walk.lm1 codex_fix200/runs/replay-src/src/l2src/lmx_walk.lm1
cmp codex_fix200/src/l2src/lmx_thread.h.lm1 codex_fix200/runs/replay-src/src/l2src/lmx_thread.h.lm1
cmp codex_fix200/src/l2src/lmx_thread.lm1 codex_fix200/runs/replay-src/src/l2src/lmx_thread.lm1
cmp codex_fix200/src/l2src/lmx_root.h.lm1 codex_fix200/runs/replay-src/src/l2src/lmx_root.h.lm1
cmp codex_fix200/src/l2src/lmx_root.lm1 codex_fix200/runs/replay-src/src/l2src/lmx_root.lm1
cmp codex_fix200/src/l2_eternal_driver.lm1 codex_fix200/runs/replay-src/src/l2_eternal_driver.lm1
