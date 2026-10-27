$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/context')){throw 'Unexpected CWD'}
$taskPins=@'
[{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l1trans.exe","sha256":"3C8976D7001871A919103A9A89E9AAE27A99018FC657F3F582485911F6F20BA5"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.lm1","sha256":"3B459B429FB839A68EAB09DA300E25B860D6FFD610F14DFC07698B131D8F2265"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.h.lm1","sha256":"E7712365CD5C437C9B46E01A96D33536477F9B3E1FDBDAF24206E21F89E96C3E"},{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"}]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw 'Changed L1 input'}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.lm1.h','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/L1-header.log')){if(Test-Path -LiteralPath $taskF){throw 'Output exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l1trans.exe' '--unit-root' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.h.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.lm1.h' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/L1-header.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'CompilerExit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/L1-header.log' -Tail 24}
exit $taskExit
