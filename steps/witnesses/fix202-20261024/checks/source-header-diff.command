# Read-only bounded comparisons; diff status1 means the listed source delta, headers compare equal.
(diff -qr --exclude=l2_driver_launch.err build2/codex_fix201/src build2/codex_fix202/src; diff -qr --exclude=l2_driver_launch.err build2/codex_fix201/headers build2/codex_fix202/headers) > build2/codex_fix202/checks/source-header-diff.txt 2>&1
