$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.raw.sha256","sha256":"3330AA183AF254FCBA49C9901A91E67FDF9EED0800D9DE81C0C58E73377BDD4F"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Git/usr/bin/sha256sum.exe","sha256":"2C165B5E531182A3A250CBC8DBA42E0CF3C2A4517CE5F0BCA73A16AEA2AB2B04"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 4){throw ('Pin count '+@($taskPins).Count+' is not 4: the candidate40 tool pin (initial-tool32-40/self01/lmxtool-tool.exe) is missing')}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed stage-copy input: '+$taskG.path)}}
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate40'){throw 'Stage exists: cold-candidate40'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate40-stage-copy.log','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate40-stage-GNU.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler or tool pipeline running'}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'tool '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool-tool.exe').Hash
& 'C:/Git/usr/bin/timeout.exe' '600' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/self01/lmxtool-tool.exe' '0' 'entry' '0' '--' 'stage-copy' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.raw.sha256' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate40' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate40-stage-copy.log'
$taskExit=$LASTEXITCODE
'CopyExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate40-stage-copy.log'
if($taskExit -ne 0){exit $taskExit}
Push-Location -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate40'
& 'C:/Git/usr/bin/sha256sum.exe' '-c' '--quiet' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate40-stage-GNU.log'
$taskGnu=$LASTEXITCODE
Pop-Location
'StageGNUExit '+$taskGnu
'StageFiles '+@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate40' -Recurse -File).Count
'EndUTC '+[DateTime]::UtcNow.ToString('o')
if($taskGnu -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate40-stage-GNU.log' -Tail 20; exit 1}
exit 0
