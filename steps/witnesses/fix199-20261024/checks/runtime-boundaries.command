# Exact runtime C outside the merge replacement, including its includes/prototypes; no identifier normalization.
# Old31629..33147, new31629..35841. cwd build2.
sed -n '1,31628p' codex_fix198/boot-quick-01/runtime/driver.c > codex_fix199/checks/runtime-before-old.c
sed -n '1,31628p' codex_fix199/rt-01/driver.c > codex_fix199/checks/runtime-before-new.c
cmp codex_fix199/checks/runtime-before-old.c codex_fix199/checks/runtime-before-new.c
sed -n '33148,$p' codex_fix198/boot-quick-01/runtime/driver.c > codex_fix199/checks/runtime-after-old.c
sed -n '35842,$p' codex_fix199/rt-01/driver.c > codex_fix199/checks/runtime-after-new.c
cmp codex_fix199/checks/runtime-after-old.c codex_fix199/checks/runtime-after-new.c
