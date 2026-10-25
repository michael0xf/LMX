# Existing language manifest generation + verification; independent GNU check follows, no new runner.
& 'C:/Nyasha_Planet/LMX/build2/codex_fix213/boot-quick-01/lmxtool.exe' 0 entry 0 -- manifest 'C:/Nyasha_Planet/LMX/build2/codex_fix213/checks/evidence-213.list' 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/build2/codex_fix213/checks/evidence-213.sha256'
& 'C:/Nyasha_Planet/LMX/build2/codex_fix213/boot-quick-01/lmxtool.exe' 0 entry 0 -- verify 'C:/Nyasha_Planet/LMX/build2/codex_fix213/checks/evidence-213.sha256' 'C:/Nyasha_Planet/LMX'
& 'C:/Git/usr/bin/sha256sum.exe' --check 'C:/Nyasha_Planet/LMX/build2/codex_fix213/checks/evidence-213.sha256'
