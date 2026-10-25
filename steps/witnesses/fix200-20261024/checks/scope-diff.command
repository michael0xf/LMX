# cwd build2; read only known source/header input directories, excluded protected basename. diff exit1 is expected.
diff -qr --exclude=l2_driver_launch.err codex_fix199/src codex_fix200/src > codex_fix200/checks/src-diff.out
diff -qr --exclude=l2_driver_launch.err codex_fix199/headers codex_fix200/headers > codex_fix200/checks/headers-diff.out
