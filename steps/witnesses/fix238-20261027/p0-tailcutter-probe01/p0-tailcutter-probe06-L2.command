$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/src')){throw 'Unexpected CWD'}
$taskW='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/p0-tailcutter-probe01'
$taskPins=@'
[
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe","sha256":"6FF7DB4B977B04CDF8E4E92A9E0CD9ABD3731D0855943670DEF97A375F2966F3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l2trans.exe","sha256":"6FA278313E805DA96674F794DDA0FB1DB2A2A765A62732A14E982780F77558C1"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2","sha256":"1E376CBA102874857EAC2279F0C6E14CCE5AB009CB8764B03BD300F7E9746976"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2","sha256":"CF9AAC78F7347AE0B40E929752FC0400A67507CA302735655CA3BE167DB588C3"}
]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed probe input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe\z'}).Count -ne 0){throw 'Compiler pipeline running'}
foreach($taskT in @('t6','t7')){foreach($taskFe in @('warm40','seed')){if(Test-Path -LiteralPath ($taskW+'/'+$taskT+'.'+$taskFe+'.lm1')){throw ('Output exists: '+$taskT+'.'+$taskFe+'.lm1')}; if(Test-Path -LiteralPath ($taskW+'/'+$taskT+'.'+$taskFe+'.log')){throw ('Output exists: '+$taskT+'.'+$taskFe+'.log')}}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
foreach($taskT in @('t6','t7')){'fixture '+$taskT+' '+(Get-FileHash -LiteralPath ($taskW+'/'+$taskT+'.lm2')).Hash}
foreach($taskT in @('t6','t7')){
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe' ($taskW+'/'+$taskT+'.lm2') 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2' ($taskW+'/'+$taskT+'.warm40.lm1') *> ($taskW+'/'+$taskT+'.warm40.log')
$taskTaskExit=$LASTEXITCODE
$taskT+' warm40 exit '+$taskTaskExit+' : '+((Get-Content -LiteralPath ($taskW+'/'+$taskT+'.warm40.log') | Select-Object -First 1) -join '')
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l2trans.exe' ($taskW+'/'+$taskT+'.lm2') 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40/src/l2src/primitive.lm2' ($taskW+'/'+$taskT+'.seed.lm1') *> ($taskW+'/'+$taskT+'.seed.log')
$taskTaskExit=$LASTEXITCODE
$taskT+' seed exit '+$taskTaskExit+' : '+((Get-Content -LiteralPath ($taskW+'/'+$taskT+'.seed.log') | Select-Object -First 1) -join '')
}
'EndUTC '+[DateTime]::UtcNow.ToString('o')
exit 0
