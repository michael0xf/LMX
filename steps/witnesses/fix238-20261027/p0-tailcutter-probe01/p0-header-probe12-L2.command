$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-41/src')){throw 'Unexpected CWD'}
$taskW='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/p0-tailcutter-probe01'
$taskPins=@'
[
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe","sha256":"6FF7DB4B977B04CDF8E4E92A9E0CD9ABD3731D0855943670DEF97A375F2966F3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l2trans.exe","sha256":"6FA278313E805DA96674F794DDA0FB1DB2A2A765A62732A14E982780F77558C1"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l1trans.exe","sha256":"3C8976D7001871A919103A9A89E9AAE27A99018FC657F3F582485911F6F20BA5"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate41/src/l2src/convert.lm2","sha256":"1E376CBA102874857EAC2279F0C6E14CCE5AB009CB8764B03BD300F7E9746976"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate41/src/l2src/primitive.lm2","sha256":"CF9AAC78F7347AE0B40E929752FC0400A67507CA302735655CA3BE167DB588C3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/p0-tailcutter-probe01/t9.lm2","sha256":"5C9DA7709FAED23B692FB318EB1E2701331FA29E6E28D8A257113CAD4B10FC74"}
]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed probe input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe\z'}).Count -ne 0){throw 'Compiler pipeline running'}
foreach($taskFe in @('warm40','seed')){foreach($taskX in @('.lm1','.h.lm1','.log','.lm1.h','.h.log')){if(Test-Path -LiteralPath ($taskW+'/t9.'+$taskFe+$taskX)){throw ('Output exists: t9.'+$taskFe+$taskX)}}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2trans.exe' '--library' '--machine' 'lib_main' '--header' ($taskW+'/t9.warm40.h.lm1') ($taskW+'/t9.lm2') 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate41/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate41/src/l2src/primitive.lm2' ($taskW+'/t9.warm40.lm1') *> ($taskW+'/t9.warm40.log')
'warm40 L2 exit '+$LASTEXITCODE
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l2trans.exe' '--library' '--machine' 'lib_main' '--header' ($taskW+'/t9.seed.h.lm1') ($taskW+'/t9.lm2') 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate41/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate41/src/l2src/primitive.lm2' ($taskW+'/t9.seed.lm1') *> ($taskW+'/t9.seed.log')
'seed L2 exit '+$LASTEXITCODE
foreach($taskFe in @('warm40','seed')){'--- t9.'+$taskFe+'.h.lm1 ---'; if(Test-Path -LiteralPath ($taskW+'/t9.'+$taskFe+'.h.lm1')){Get-Content -LiteralPath ($taskW+'/t9.'+$taskFe+'.h.lm1')}else{'(missing)'}; '--- log ---'; Get-Content -LiteralPath ($taskW+'/t9.'+$taskFe+'.log') | Select-Object -First 3}
foreach($taskFe in @('warm40','seed')){if(Test-Path -LiteralPath ($taskW+'/t9.'+$taskFe+'.h.lm1')){& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l1trans.exe' ($taskW+'/t9.'+$taskFe+'.h.lm1') ($taskW+'/t9.'+$taskFe+'.lm1.h') *> ($taskW+'/t9.'+$taskFe+'.h.log'); $taskFe+' header L1 exit '+$LASTEXITCODE+' : '+((Get-Content -LiteralPath ($taskW+'/t9.'+$taskFe+'.h.log') | Select-Object -First 1) -join '')}}
'EndUTC '+[DateTime]::UtcNow.ToString('o')
exit 0
