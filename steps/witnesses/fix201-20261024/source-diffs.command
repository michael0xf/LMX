set -e
diff -U0 --label /dev/null --label codex_fix201/src/l2src/lmx_post.lm2 /dev/null build2/codex_fix201/src/l2src/lmx_post.lm2 > build2/codex_fix201/trace/lmx_post.lm2.patch || test $? -eq 1
diff -U0 --label codex_fix200/src/l2src/lmx_post.h.lm1 --label codex_fix201/src/l2src/lmx_post.h.lm1 build2/codex_fix200/src/l2src/lmx_post.h.lm1 build2/codex_fix201/src/l2src/lmx_post.h.lm1 > build2/codex_fix201/trace/lmx_post.h.lm1.patch || test $? -eq 1
diff -qr --exclude=l2_driver_launch.err build2/codex_fix200/src build2/codex_fix201/src > build2/codex_fix201/checks/src-diff.out || test $? -eq 1
diff -qr --exclude=l2_driver_launch.err build2/codex_fix200/headers build2/codex_fix201/headers > build2/codex_fix201/checks/headers-diff.out
