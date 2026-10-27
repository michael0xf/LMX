CWD C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/runs/final170-01
$ErrorActionPreference='Stop'
if((Get-FileHash -Algorithm SHA256 -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/boot-quick-01/tool-g2/lmxtool-tool.exe').Hash -ne 'A1B7EF4725389A54D601FE2E4D108E31923BE5B2893D558F641E4A5F091E11D7'){throw 'ActualG2changed'}
& 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/boot-quick-01/tool-g2/lmxtool-tool.exe' 0 entry 0 -- verify 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/postterminal-stage85-canonical85.sha256' 'C:/Nyasha_Planet/LMX' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/cold04-final170.log'
$taskVerifyExit=$LASTEXITCODE
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/cold04-final170.log' -Raw
exit $taskVerifyExit
