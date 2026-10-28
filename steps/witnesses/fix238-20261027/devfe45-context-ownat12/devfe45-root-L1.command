$ErrorActionPreference='Stop'
# devfe45 step 2: the frontend root L1 (boot44 G2's frontend-source.lm1) translated by the boot44 G2 backend over the boot44 stage sources with ONE replaced module body: l2src/l2_frontend_context.lm1 = the context-ownat12 translation (step 1); every other file of src/ is a byte copy of the boot44 stage (manifest src-from-boot44-stage.sha256, 223 files). A development FE for the check, never a candidate. 2026-10-28
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/boot44/g2/frontend/l1trans.exe","sha256":"D3B3FE1AB3BD95C44BF3AF469D30E82A897798669D4C7F7D48C7CBE4C6F95A76"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend-source.lm1","sha256":"CBF343676F3E45B7D30015946039A1472E9CB65D6BC154EC8255934C4C295B53"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/src/l2src/l2_frontend_context.lm1","sha256":"4BBC8101AD6E88F706E181AD947797E027C28082CB65CC1B83395217F5CF690C"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/src/l2src/l2_frontend_context.h.lm1","sha256":"F66863F93BEEFAB54FBF350B827A03D39A28DC8DF3140DCDEB2DFD9C46F8F0FC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/src-devfe45.sha256","sha256":"E35A64F5D6A1370EFD5F1374D9F15FEB139660FF97C18DC0CA898DF56D964581"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 6){throw 'Pin count'}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed input: '+$taskG.path)}}
if(@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/src' -Recurse -File).Count -ne 223){throw 'src does not hold 223 files'}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler pipeline running'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/L1.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '600' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/boot44/g2/frontend/l1trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend-source.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/L1.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'BackendExit '+$taskExit
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c'){'frontend.c '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c').Hash+' '+(Get-Item -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c').Length}else{'frontend.c missing'}
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/L1.log' -Tail 20}
exit $taskExit
