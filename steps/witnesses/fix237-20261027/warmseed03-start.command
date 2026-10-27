$ErrorActionPreference='Stop'
if((Get-Location).Path.Replace([char]92,[char]47) -ne 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-start'){throw 'Seed03 start CWD mismatch'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool-tool.exe' -Algorithm SHA256).Hash -ne 'E8176CBC2D89BFD71053EBEA866F634C6C1C441C270DDEDCA932FADEDD968B77'){throw 'Warm tool EXE changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/pins/source83-corrected04.raw.sha256' -Algorithm SHA256).Hash -ne '053DA34941BCACA881742796F8E28D267D4A5807FB0D06383F80E298D2736D4B'){throw 'Known hash input changed'}
Write-Output ('StartUTC '+[DateTime]::UtcNow.ToString('o'))
& 'C:/Git/usr/bin/timeout.exe' --kill-after=10s 180s 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool-tool.exe' 0 entry 0 -- sha256 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/pins/source83-corrected04.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03.start.log'
$taskSeedStartExit=$LASTEXITCODE
Write-Output ('EndUTC '+[DateTime]::UtcNow.ToString('o'))
Write-Output ('Seed03StartExit '+$taskSeedStartExit)
exit $taskSeedStartExit
