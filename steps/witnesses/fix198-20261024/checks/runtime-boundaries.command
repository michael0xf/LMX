# Exact runtime C outside the copier replacement, including its includes/prototypes. No identifier normalization.
# Old5714..9100; new5714..14912.
cd /c/Nyasha_Planet/LMX/build2
sed -n '1,5713p' codex_fix197/boot-quick-01/runtime/driver.c > codex_fix198/checks/runtime-before-old.c
sed -n '1,5713p' codex_fix198/rt-01/driver.c > codex_fix198/checks/runtime-before-new.c
cmp codex_fix198/checks/runtime-before-old.c codex_fix198/checks/runtime-before-new.c
sed -n '9101,$p' codex_fix197/boot-quick-01/runtime/driver.c > codex_fix198/checks/runtime-after-old.c
sed -n '14913,$p' codex_fix198/rt-01/driver.c > codex_fix198/checks/runtime-after-new.c
cmp codex_fix198/checks/runtime-after-old.c codex_fix198/checks/runtime-after-new.c
