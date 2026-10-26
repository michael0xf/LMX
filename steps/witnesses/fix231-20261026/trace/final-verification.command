cwd runs/verify-source74
C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/boot-quick-01/tool-g2/lmxtool-tool.exe 0 entry 0 -- verify 'C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/pins/source74.raw.sha256' 'C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04'
stdout/stderr pins/verify-source74.log

cwd runs/verify-peer2
C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/boot-quick-01/tool-g2/lmxtool-tool.exe 0 entry 0 -- verify 'C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/pins/g2-expected2.sha256' 'C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04'
stdout/stderr pins/verify-peer2.log

cwd runs/exe-same
C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/boot-quick-01/tool-g2/lmxtool-tool.exe 0 entry 0 -- exe-same 'C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/boot-quick-01/tool-g1/lmxtool-tool.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix231drivercold04/boot-quick-01/tool-g2/lmxtool-tool.exe'
stdout/stderr pins/exe-same.log
All are existing language commands, not new compiler/test execution.
