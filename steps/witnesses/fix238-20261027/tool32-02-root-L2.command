$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/tools/lmxtool.lm2","sha256":"87D53B298AC1F84A7B5D99CF43A40133B414EBBA1A82A3778F6F66BB8B53757D"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2","sha256":"1E376CBA102874857EAC2279F0C6E14CCE5AB009CB8764B03BD300F7E9746976"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2","sha256":"CF9AAC78F7347AE0B40E929752FC0400A67507CA302735655CA3BE167DB588C3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe","sha256":"6FF7DB4B977B04CDF8E4E92A9E0CD9ABD3731D0855943670DEF97A375F2966F3"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 7){throw ('Pin count '+@($taskPins).Count+' is not 7: the frontend FE-O1 pin and the generated lmxtool_methods body/header pins are missing')}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed tool root L2 input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool.L2.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '3600' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/tools/lmxtool.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool.lm1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool.L2.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'Exit '+$taskExit
if($taskExit -eq 0){'lmxtool.lm1 '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool.lm1').Hash}
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool.L2.log' -Tail 24}
exit $taskExit
