# Fresh exact210 walker/recipe, no pre-existing values module. Zero-context mechanical patches, base hashes pinned.
# cwd build2/codex_fix211/runs/replay-from210-01
patch --batch --fuzz=0 -p1 -i C:/Nyasha_Planet/LMX/steps/witnesses/fix211-20261025/lmx_walk_values.lm2.patch || exit 1
patch --batch --fuzz=0 -p1 -i C:/Nyasha_Planet/LMX/steps/witnesses/fix211-20261025/lmx_walk.from210.patch || exit 1
patch --batch --fuzz=0 -p1 -i C:/Nyasha_Planet/LMX/steps/witnesses/fix211-20261025/build.from210.patch || exit 1
cmp src/l2src/lmx_walk.lm1 ../../src/l2src/lmx_walk.lm1 || exit 1
cmp src/l2src/lmx_walk_values.lm2 ../../src/l2src/lmx_walk_values.lm2 || exit 1
cmp tools/build.lm2 ../../tools/build.lm2 || exit 1
sha256sum src/l2src/lmx_walk.lm1 src/l2src/lmx_walk_values.lm2 tools/build.lm2
