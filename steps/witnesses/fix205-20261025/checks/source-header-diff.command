# cwd repo, completed runtime inputs/headers only; protected basename excluded recursively, never read.
bash -c 'set -e; { /usr/bin/diff -qr --exclude=l2_driver_launch.err build2/codex_fix204/src build2/codex_fix205/src || test $? = 1; /usr/bin/diff -qr --exclude=l2_driver_launch.err build2/codex_fix204/headers build2/codex_fix205/headers; } > build2/codex_fix205/checks/source-header-diff.txt'
