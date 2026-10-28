$ErrorActionPreference='Stop'
# candidate44 (recipe-fe-O2-11: frontend gcc -O2 -fno-strict-aliasing at build.lm2:713): the maintained 'rebuild tool' builds the new producer from the stage's tools sources with the boot43 G2 frontend and runtime, runs tool_works and the smoke list; plan item 4 (existing component rebuild), 2026-10-28
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/lmxtool.exe","sha256":"BDA3AB459D599B795C278EE6B02398E760B08600ABA6AB32D00F27AA057F8865"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/frontend/l2trans.exe","sha256":"37AA0FB5FC90F51AC73F1D123EB66E9678DDDD22A4859B41F1F2412A82B38899"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/frontend/l1trans.exe","sha256":"93131615B260B765A2406E28C3C15F432F04FEF33EB4F5D124EE8839BE4B3B4D"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/frontend/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/runtime/driver.o","sha256":"8C2708AF530BC624F1A1C48207F00685AC5C6F5FB72843A49C4C0258277BEEDC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/runtime/driver-observe.o","sha256":"0A1C51D9BAF3B3449D65419169659DD77F1C787697CDE03821203BD3F96A2DB4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool/tools/build.lm2","sha256":"28DFBFA951A20B50F1E1E97DA13232CC543FCC0F6CEAC8A4A62E25B8B053F4C3"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool/tools/suite.lm2","sha256":"86C08166D37917E65ABBB02D32CBA9E77DFB67D49A5CD033855AAE300E1D7A42"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool/tests/smoke-kernel225.tsv","sha256":"32EAD2C43E749EA531B0B6D4D610891C17EC9704134FA1C72C63864F51AA3EC6"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 11){throw 'Pin count'}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler or tool pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool/tool44','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate44-tool-rebuild.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
$env:CPATH=$null
$env:C_INCLUDE_PATH=$null
$env:CPLUS_INCLUDE_PATH=$null
$env:OBJC_INCLUDE_PATH=$null
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
'tool '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/lmxtool.exe').Hash
'fe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/frontend/l2trans.exe').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '7200' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/lmxtool.exe' '0' 'entry' '0' '--' 'rebuild' 'tool' 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/frontend/l2trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate43/boot43/g2/runtime' 'tool44' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool/tests/smoke-kernel225.tsv' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate44-tool-rebuild.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'RebuildExit '+$taskExit
foreach($taskF in @('lmxtool-tool.exe','lmxtool.lm1','lmxtool.c')){$taskP='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44-tool/tool44/'+$taskF; if(Test-Path -LiteralPath $taskP){$taskF+' '+(Get-FileHash -LiteralPath $taskP).Hash+' '+(Get-Item -LiteralPath $taskP).Length}else{$taskF+' missing'}}
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate44-tool-rebuild.log' | Where-Object { $_ -match '^(PASS|FAIL|REBUILD|SUITE|MANIFEST)' } | Select-Object -Last 12
exit $taskExit
