$ErrorActionPreference='Stop'
# candidate46 (full46: the second-os-block literal in emit.lm2:550, the runs root selector in suite.lm2, full-suite.tsv row 32 nf0; CODEX-REPLY-FULL45-FIXES-20261029T130000Z): the maintained 'rebuild frontend' on the fresh tool-build stage by the boot45 G2 tool with the boot45 G2 frontend as previous_fe and its runtime for the smoke run; label fe46; then rebuild runtime/tool with the new FE, the short check, then bootstrap full on the fresh stage cold-candidate46. 2026-10-29
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/lmxtool.exe","sha256":"A69A7EE26315C058E85FE0FA9D1EFD921B4C3032421030704948575C16997FB4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2trans.exe","sha256":"159F3D5EA3F5EA77CD42A8A8706750369CFC36584A28EE3D43D78995E69C06A7"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l1trans.exe","sha256":"DF1FBCD5516C6C463B4BD02D0223342360245538D75BE1834312D0F3E07600A9"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/runtime/driver.o","sha256":"8C2708AF530BC624F1A1C48207F00685AC5C6F5FB72843A49C4C0258277BEEDC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/runtime/driver-observe.o","sha256":"0A1C51D9BAF3B3449D65419169659DD77F1C787697CDE03821203BD3F96A2DB4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool/tools/build.lm2","sha256":"28DFBFA951A20B50F1E1E97DA13232CC543FCC0F6CEAC8A4A62E25B8B053F4C3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool/tools/suite.lm2","sha256":"3F38AF62C153C77231B5FAE6F025F5AEA54C9AAEA52EF84B00D9ADA37762E01C"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool/tests/smoke-kernel225.tsv","sha256":"32EAD2C43E749EA531B0B6D4D610891C17EC9704134FA1C72C63864F51AA3EC6"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 11){throw 'Pin count'}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler or tool pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool/fe46','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate46-tool-rebuild-frontend.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
$env:CPATH=$null
$env:C_INCLUDE_PATH=$null
$env:CPLUS_INCLUDE_PATH=$null
$env:OBJC_INCLUDE_PATH=$null
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
'tool '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/lmxtool.exe').Hash
'fe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2trans.exe').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '14400' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/lmxtool.exe' '0' 'entry' '0' '--' 'rebuild' 'frontend' 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/runtime' 'fe46' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool/tests/smoke-kernel225.tsv' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate46-tool-rebuild-frontend.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'RebuildExit '+$taskExit
foreach($taskF in @('l2trans.exe','l1trans.exe','l2_libc.o','frontend.c')){$taskP='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate46-tool/fe46/'+$taskF; if(Test-Path -LiteralPath $taskP){$taskF+' '+(Get-FileHash -LiteralPath $taskP).Hash+' '+(Get-Item -LiteralPath $taskP).Length}else{$taskF+' missing'}}
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate46-tool-rebuild-frontend.log' | Where-Object { $_ -match '^(PASS|FAIL|REBUILD|SUITE|MANIFEST)' } | Select-Object -Last 12
exit $taskExit
