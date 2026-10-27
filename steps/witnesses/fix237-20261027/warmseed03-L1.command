$ErrorActionPreference='Stop'
if((Get-Location).Path.Replace([char]92,[char]47) -ne 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-l1'){throw 'Seed03 B0 CWD mismatch'}
$taskB0Busy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskB0Busy.Count -ne 0){throw 'Compiler pipeline active'}
$taskB0Free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskB0Free -lt 838861){throw 'Below compiler memory guard'}
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.c'){throw 'Seed03 C output exists'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.lm1' -Algorithm SHA256).Hash -ne '0C70A2AD7ECF5DFA2172ED6AD6A337969623F5BD84605D3E670586AF1D87C523'){throw 'Seed03 L1 bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l1trans.exe' -Algorithm SHA256).Hash -ne '601D350E853CA16A35EC4B7ED7C2B5B82248A63E96B72A545329B1D8C6AA2196'){throw 'B0 bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Git/usr/bin/timeout.exe' -Algorithm SHA256).Hash -ne '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4'){throw 'Timeout control changed'}
$taskB0Decls=@(Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/generated59-warm.list' | Where-Object { $_.StartsWith('src/l2src/') })
if($taskB0Decls.Count -ne 29){throw 'Expected29 raw declaration context copies'}
foreach($taskB0Rel in $taskB0Decls){$taskB0From='C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/'+$taskB0Rel; $taskB0To='C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-l1/'+$taskB0Rel.Substring(4); if((Get-FileHash -LiteralPath $taskB0From -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $taskB0To -Algorithm SHA256).Hash){throw 'B0 warm header bytes differ'}}
Write-Output ('FreeVirtualKiB '+$taskB0Free)
Write-Output ('StartUTC '+[DateTime]::UtcNow.ToString('o'))
& 'C:/Git/usr/bin/timeout.exe' --kill-after=10s 900s 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l1trans.exe' --unit-root 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-l1' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.c' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03.L1.log'
$taskB0Exit=$LASTEXITCODE
Write-Output ('EndUTC '+[DateTime]::UtcNow.ToString('o'))
Write-Output ('ManualSeed03L1Exit '+$taskB0Exit)
exit $taskB0Exit
