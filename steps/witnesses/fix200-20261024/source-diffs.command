# cwd build2; generated recovery data only, not a maintained helper or runner. Exit1 of diff means different.
set -e
diff -u --label /dev/null --label codex_fix200/src/l2src/lmx_call.lm2 /dev/null codex_fix200/src/l2src/lmx_call.lm2 > codex_fix200/trace/lmx_call.lm2.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2src/lmx_call.h.lm1 --label codex_fix200/src/l2src/lmx_call.h.lm1 codex_fix199/src/l2src/lmx_call.h.lm1 codex_fix200/src/l2src/lmx_call.h.lm1 > codex_fix200/trace/lmx_call.h.lm1.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2src/lmx_walk.lm1 --label codex_fix200/src/l2src/lmx_walk.lm1 codex_fix199/src/l2src/lmx_walk.lm1 codex_fix200/src/l2src/lmx_walk.lm1 > codex_fix200/trace/lmx_walk.lm1.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2src/lmx_thread.h.lm1 --label codex_fix200/src/l2src/lmx_thread.h.lm1 codex_fix199/src/l2src/lmx_thread.h.lm1 codex_fix200/src/l2src/lmx_thread.h.lm1 > codex_fix200/trace/lmx_thread.h.lm1.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2src/lmx_thread.lm1 --label codex_fix200/src/l2src/lmx_thread.lm1 codex_fix199/src/l2src/lmx_thread.lm1 codex_fix200/src/l2src/lmx_thread.lm1 > codex_fix200/trace/lmx_thread.lm1.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2src/lmx_root.h.lm1 --label codex_fix200/src/l2src/lmx_root.h.lm1 codex_fix199/src/l2src/lmx_root.h.lm1 codex_fix200/src/l2src/lmx_root.h.lm1 > codex_fix200/trace/lmx_root.h.lm1.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2src/lmx_root.lm1 --label codex_fix200/src/l2src/lmx_root.lm1 codex_fix199/src/l2src/lmx_root.lm1 codex_fix200/src/l2src/lmx_root.lm1 > codex_fix200/trace/lmx_root.lm1.patch || test "$?" = 1
diff -U0 --label codex_fix199/src/l2_eternal_driver.lm1 --label codex_fix200/src/l2_eternal_driver.lm1 codex_fix199/src/l2_eternal_driver.lm1 codex_fix200/src/l2_eternal_driver.lm1 > codex_fix200/trace/l2_eternal_driver.lm1.patch || test "$?" = 1
