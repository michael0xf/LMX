# First capture failed because the replay directory had not been created; second used one extra parent in the patch path.
# Neither attempted patch changed the copied source. This third capture is the actual successful zero-fuzz replay.
(cd C:/Nyasha_Planet/LMX/build2/codex_fix202/runs/replay-src && patch -p1 --fuzz=0 < C:/Nyasha_Planet/LMX/steps/witnesses/fix202-20261024/lmx_post.lm2.patch && cmp src/l2src/lmx_post.lm2 ../../src/l2src/lmx_post.lm2 && sha256sum src/l2src/lmx_post.lm2) > C:/Nyasha_Planet/LMX/build2/codex_fix202/checks/source-replay-03.txt 2>&1
