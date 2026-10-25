New-Item -ItemType Directory -Path 'build2/codex_fix218/runs/packet-initial2-u0-02/src/l2src','build2/codex_fix218/runs/packet-initial2-u0-02/tools' -ErrorAction Stop | Out-Null
Copy-Item -LiteralPath 'build2/codex_fix217/src/l2src/lmx_walk_values.lm2' -Destination 'build2/codex_fix218/runs/packet-initial2-u0-02/src/l2src/lmx_walk_values.lm2' -ErrorAction Stop
& 'C:/Git/usr/bin/patch.exe' --batch --fuzz=0 -p1 -d 'build2/codex_fix218/runs/packet-initial2-u0-02' -i 'C:/Nyasha_Planet/LMX/steps/witnesses/fix218-20261025/values.initial2.from217.patch'; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& 'C:/Git/usr/bin/cmp.exe' -s 'build2/codex_fix218/runs/packet-initial2-u0-02/src/l2src/lmx_walk_values.lm2' 'build2/codex_fix218/runs/packet-initial2-u0-01/src/l2src/lmx_walk_values.lm2'; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Copy-Item -LiteralPath 'build2/codex_fix217/src/l2src/lmx_walk.lm1' -Destination 'build2/codex_fix218/runs/packet-initial2-u0-02/src/l2src/lmx_walk.lm1' -ErrorAction Stop
& 'C:/Git/usr/bin/patch.exe' --batch --fuzz=0 -p1 -d 'build2/codex_fix218/runs/packet-initial2-u0-02' -i 'C:/Nyasha_Planet/LMX/steps/witnesses/fix218-20261025/walker.initial2.from217.patch'; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& 'C:/Git/usr/bin/cmp.exe' -s 'build2/codex_fix218/runs/packet-initial2-u0-02/src/l2src/lmx_walk.lm1' 'build2/codex_fix218/runs/packet-initial2-u0-01/src/l2src/lmx_walk.lm1'; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Copy-Item -LiteralPath 'build2/codex_fix217/tools/build.lm2' -Destination 'build2/codex_fix218/runs/packet-initial2-u0-02/tools/build.lm2' -ErrorAction Stop
& 'C:/Git/usr/bin/patch.exe' --batch --fuzz=0 -p1 -d 'build2/codex_fix218/runs/packet-initial2-u0-02' -i 'C:/Nyasha_Planet/LMX/steps/witnesses/fix218-20261025/build.initial2.from217.patch'; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& 'C:/Git/usr/bin/cmp.exe' -s 'build2/codex_fix218/runs/packet-initial2-u0-02/tools/build.lm2' 'build2/codex_fix218/runs/packet-initial2-u0-01/tools/build.lm2'; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'INITIAL2_U0_REPLAY_3_RAW_EQUAL; source/compiler/runtime/program bytes untouched'
