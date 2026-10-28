$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/main.lm2","sha256":"84F1D6BD1AF8352E8A0255EC94D1FC2A74F90F8F3D68C20B93CF05666E936B1E"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/part.lm2","sha256":"8E91129114378DE2994625EED1B90209FFD0FA375E3824C8235B770AF3262EA0"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2","sha256":"1E376CBA102874857EAC2279F0C6E14CCE5AB009CB8764B03BD300F7E9746976"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2","sha256":"CF9AAC78F7347AE0B40E929752FC0400A67507CA302735655CA3BE167DB588C3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe","sha256":"6FF7DB4B977B04CDF8E4E92A9E0CD9ABD3731D0855943670DEF97A375F2966F3"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 6){throw ('Pin count '+@($taskPins).Count+' is not 6: the frontend FE-O1 pin is missing')}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed witness L2 input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native')){New-Item -ItemType Directory -Path 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native' | Out-Null}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native/p.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native/p.L2.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '900' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/main.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/part.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native/p.lm1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native/p.L2.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'Exit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-native/p.L2.log' -Tail 24}
exit $taskExit
