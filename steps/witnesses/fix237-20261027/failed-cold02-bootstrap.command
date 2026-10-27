$ErrorActionPreference='Stop'
if((Get-Location).Path.Replace([char]92,[char]47) -ne 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/runs/bootstrap-01'){throw 'Cold bootstrap CWD mismatch'}
$taskColdBusy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskColdBusy.Count -ne 0){throw 'Compiler pipeline active'}
$taskColdFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskColdFree -lt 838861){throw 'Below compiler memory guard'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool-tool.exe' -Algorithm SHA256).Hash -ne 'E8176CBC2D89BFD71053EBEA866F634C6C1C441C270DDEDCA932FADEDD968B77'){throw 'Warm control tool changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l2trans.exe' -Algorithm SHA256).Hash -ne 'CE7501E07AF728DE427B9389F0AC43A08D0047FA0EEA8DE6ECBA6439E6159C8D'){throw 'Explicit F0 changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l1trans.exe' -Algorithm SHA256).Hash -ne '601D350E853CA16A35EC4B7ED7C2B5B82248A63E96B72A545329B1D8C6AA2196'){throw 'Explicit B0 changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/pins/source83-corrected04.raw.sha256' -Algorithm SHA256).Hash -ne '053DA34941BCACA881742796F8E28D267D4A5807FB0D06383F80E298D2736D4B'){throw 'Cold04 source manifest changed'}
Write-Output ('FreeVirtualKiB '+$taskColdFree)
Write-Output ('StartUTC '+[DateTime]::UtcNow.ToString('o'))
& 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool-tool.exe' 0 entry 0 -- bootstrap quick 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02' 'C:/Nyasha_Planet/LMX/buold_temp' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l2trans.exe' boot-quick-01 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tests/smoke-kernel225.tsv' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/pins/cold02-bootstrap.log'
$taskColdExit=$LASTEXITCODE
Write-Output ('EndUTC '+[DateTime]::UtcNow.ToString('o'))
Write-Output ('Cold237BootstrapExit '+$taskColdExit)
exit $taskColdExit
