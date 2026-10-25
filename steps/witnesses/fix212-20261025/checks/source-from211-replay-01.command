# Existing GNU tools only; exact source211 before, source09649180 after. No builder/source reuse claim from an ACK.
# cwd repo: diff -U0 --label a/src/l2src/l2trans.lm1 --label b/src/l2src/l2trans.lm1 build2/codex_fix211/src/l2src/l2trans.lm1 build2/codex_fix212/src/l2src/l2trans.lm1
# cwd build2/codex_fix212/runs/source-replay-01 with exact211 compiler copied first:
patch --batch --fuzz=0 -p1 -i C:/Nyasha_Planet/LMX/steps/witnesses/fix212-20261025/l2trans.from211.patch
cmp -s src/l2src/l2trans.lm1 C:/Nyasha_Planet/LMX/build2/codex_fix212/src/l2src/l2trans.lm1
sha256sum src/l2src/l2trans.lm1
