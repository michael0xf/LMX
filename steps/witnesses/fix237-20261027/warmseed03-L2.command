$ErrorActionPreference='Stop'
if((Get-Location).Path.Replace([char]92,[char]47) -ne 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-l2'){throw 'Manual seed03 fresh CWD mismatch'}
$taskSeedBusy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskSeedBusy.Count -ne 0){throw 'Compiler pipeline active'}
$taskSeedFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskSeedFree -lt 838861){throw 'Below compiler memory guard'}
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.lm1'){throw 'Manual seed03 output exists'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/pins/source83-corrected04.raw.sha256' -Algorithm SHA256).Hash -ne '053DA34941BCACA881742796F8E28D267D4A5807FB0D06383F80E298D2736D4B'){throw 'Cold source04 manifest changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l2trans.exe' -Algorithm SHA256).Hash -ne 'CE7501E07AF728DE427B9389F0AC43A08D0047FA0EEA8DE6ECBA6439E6159C8D'){throw 'F0 bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Git/usr/bin/timeout.exe' -Algorithm SHA256).Hash -ne '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4'){throw 'Timeout control changed'}
Push-Location 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02'
& 'C:/Git/usr/bin/sha256sum.exe' -c 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/pins/source83-corrected04.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03-source83-before.log'
$taskSeedSource=$LASTEXITCODE
Pop-Location
Push-Location 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01'
& 'C:/Git/usr/bin/sha256sum.exe' -c 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/generated59-warm.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03-generated59-before.log'
$taskSeedDecl=$LASTEXITCODE
Pop-Location
if($taskSeedSource -ne 0 -or $taskSeedDecl -ne 0){throw 'Source/declaration byte guard failed'}
$taskDecls=@(Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/generated59-warm.list' | Where-Object { $_.StartsWith('src/l2src/') })
if($taskDecls.Count -ne 29){throw 'Expected29 raw declaration context copies'}
foreach($taskRel in $taskDecls){$taskFrom='C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/'+$taskRel; $taskTo='C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-l2/'+$taskRel.Substring(4); if((Get-FileHash -LiteralPath $taskFrom -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $taskTo -Algorithm SHA256).Hash){throw 'L2 warm context bytes differ'}}
$env:L2_RUNTIME_ROOT='l2src/'
Write-Output ('FreeVirtualKiB '+$taskSeedFree)
Write-Output ('StartUTC '+[DateTime]::UtcNow.ToString('o'))
& 'C:/Git/usr/bin/timeout.exe' --kill-after=10s 3600s 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l2trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/lmxtool.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/text.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/winargs.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/sha256.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/replay.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/build.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/tools/suite.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold02/src/l2src/primitive.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.lm1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03.L2.log'
$taskSeedExit=$LASTEXITCODE
Write-Output ('EndUTC '+[DateTime]::UtcNow.ToString('o'))
Write-Output ('ManualSeed03L2Exit '+$taskSeedExit)
exit $taskSeedExit
