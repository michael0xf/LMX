# Exact generated runtime C boundaries: outside the implements replacement (including its includes/prototypes), unchanged.
# Old 15052..18412; new 15052..24164. No identifier normalization is used here.
cd /c/Nyasha_Planet/LMX/build2
sed -n '1,15051p' codex_fix196/boot-quick-01/runtime/driver.c > codex_fix197/checks/runtime-before-old.c
sed -n '1,15051p' codex_fix197/rt-01/driver.c > codex_fix197/checks/runtime-before-new.c
cmp codex_fix197/checks/runtime-before-old.c codex_fix197/checks/runtime-before-new.c
sed -n '18413,$p' codex_fix196/boot-quick-01/runtime/driver.c > codex_fix197/checks/runtime-after-old.c
sed -n '24165,$p' codex_fix197/rt-01/driver.c > codex_fix197/checks/runtime-after-new.c
cmp codex_fix197/checks/runtime-after-old.c codex_fix197/checks/runtime-after-new.c
