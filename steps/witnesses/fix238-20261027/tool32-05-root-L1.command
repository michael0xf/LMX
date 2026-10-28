$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l1trans.exe","sha256":"3C8976D7001871A919103A9A89E9AAE27A99018FC657F3F582485911F6F20BA5"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"}
]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed tool root L1 input: '+$taskG.path)}}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1')){throw 'lmxtool.lm1 missing'}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.c','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.L1.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'lmxtool.lm1 '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '1800' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l1trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.c' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.L1.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'Exit '+$taskExit
if($taskExit -eq 0){'lmxtool.c '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.c').Hash}
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.L1.log' -Tail 24}
exit $taskExit
