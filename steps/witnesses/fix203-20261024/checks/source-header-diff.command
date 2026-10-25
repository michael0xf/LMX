# Bounded source/header comparison; source diff1 lists intended module changes, header diff0 means equality.
(diff -qr --exclude=l2_driver_launch.err build2/codex_fix202/src build2/codex_fix203/src; diff -qr --exclude=l2_driver_launch.err build2/codex_fix202/headers build2/codex_fix203/headers) > build2/codex_fix203/checks/source-header-diff.txt 2>&1
