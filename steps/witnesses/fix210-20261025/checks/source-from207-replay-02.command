# Fresh baseline207 replay, corrected batch-order recipe3383484E; no old successful replay is rewritten.
patch --fuzz=0 -p1 -i ../../../../steps/witnesses/fix210-20261025/l2trans.from207.patch || exit 1
patch --fuzz=0 -p1 -i ../../../../steps/witnesses/fix210-20261025/l2_application.from207.patch || exit 1
patch --fuzz=0 -p1 -i ../../../../steps/witnesses/fix210-20261025/build.from207.patch || exit 1
patch --fuzz=0 -p1 -i ../../../../steps/witnesses/fix210-20261025/lmx_reparent.lm2.patch || exit 1
patch --fuzz=0 -p1 -i ../../../../steps/witnesses/fix210-20261025/lmx_thread.lm2.patch || exit 1
patch --fuzz=0 -p1 -i ../../../../steps/witnesses/fix210-20261025/lmx_root.lm2.patch || exit 1
cmp src/l2src/l2trans.lm1 ../../src/l2src/l2trans.lm1 || exit 1
cmp src/l2src/l2_application.h.lm1 ../../src/l2src/l2_application.h.lm1 || exit 1
cmp src/l2src/lmx_reparent.lm2 ../../src/l2src/lmx_reparent.lm2 || exit 1
cmp src/l2src/lmx_thread.lm2 ../../src/l2src/lmx_thread.lm2 || exit 1
cmp src/l2src/lmx_root.lm2 ../../src/l2src/lmx_root.lm2 || exit 1
cmp tools/build.lm2 ../../tools/build.lm2 || exit 1
sha256sum src/l2src/l2trans.lm1 src/l2src/l2_application.h.lm1 src/l2src/lmx_reparent.lm2 src/l2src/lmx_thread.lm2 src/l2src/lmx_root.lm2 tools/build.lm2
