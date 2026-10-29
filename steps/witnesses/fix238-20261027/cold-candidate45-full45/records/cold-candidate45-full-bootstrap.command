$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},
{"path":"C:/Qt/Tools/mingw1310_64/libexec/gcc/x86_64-w64-mingw32/13.1.0/cc1.exe","sha256":"0193E2C062CA7985975DD85A71B07D7F2C315DFA9D6DEF6DB9DAE6D1B2A606E6"},
{"path":"C:/Qt/Tools/mingw1310_64/x86_64-w64-mingw32/bin/as.exe","sha256":"CEC9608A86DE2B4BE039709A2F87B7EC8F794FB862F35EB3DD54D1783444FDC4"},
{"path":"C:/Qt/Tools/mingw1310_64/libexec/gcc/x86_64-w64-mingw32/13.1.0/collect2.exe","sha256":"77C8676F78FA15375F8E81365299B36BBAE68B39E7D12F8665B330731DC3ECF8"},
{"path":"C:/Qt/Tools/mingw1310_64/x86_64-w64-mingw32/bin/ld.exe","sha256":"57B69033824358B634C2B4BCA0333B0C14ECF972774AF8A9DCC3B625398F1AEF"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Git/usr/bin/sha256sum.exe","sha256":"2C165B5E531182A3A250CBC8DBA42E0CF3C2A4517CE5F0BCA73A16AEA2AB2B04"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l1trans.exe","sha256":"DF1FBCD5516C6C463B4BD02D0223342360245538D75BE1834312D0F3E07600A9"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.raw.sha256","sha256":"D74D30B4BB2459AFC0BCBC418953BC95E5AA7D7ED0EBD652AE98BD2D83ECA8DC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2trans.exe","sha256":"159F3D5EA3F5EA77CD42A8A8706750369CFC36584A28EE3D43D78995E69C06A7"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/tests/full-suite.tsv","sha256":"AD37D6F22B4AED3B3D03E3326E5AFF4522105D7C10E9725EE8956C6CCCF2A788"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/lmxtool.exe","sha256":"A69A7EE26315C058E85FE0FA9D1EFD921B4C3032421030704948575C16997FB4"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 13){throw ('Pin count '+@($taskPins).Count+' is not 13: the boot45 G2 tool, FE bundle and full-list pins are missing')}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed bootstrap input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler or tool pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/src/l2src/convert.lm2')){throw 'Stage missing: cold-candidate45-full'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/full45','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/headers','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/src/l2src/lmx.h.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/src/l1src/libc_abi.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-full-bootstrap.log','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-full-bootstrap-preflight-GNU.log')){if(Test-Path -LiteralPath $taskF){throw ('Output or generated input exists: '+$taskF)}}
Push-Location -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full'
& 'C:/Git/usr/bin/sha256sum.exe' '-c' '--quiet' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-full-bootstrap-preflight-GNU.log'
$taskGnu=$LASTEXITCODE
Pop-Location
if($taskGnu -ne 0){throw 'Stage GNU mismatch before the bootstrap'}
$env:CPATH=$null
$env:C_INCLUDE_PATH=$null
$env:CPLUS_INCLUDE_PATH=$null
$env:OBJC_INCLUDE_PATH=$null
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
'tool '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/lmxtool.exe').Hash
'previous_fe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2trans.exe').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '172800' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/lmxtool.exe' '0' 'entry' '0' '--' 'bootstrap' 'full' 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45/boot45/g2/frontend/l2trans.exe' 'full45' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/tests/smoke-kernel225.tsv' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate45-full/tests/full-suite.tsv' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-full-bootstrap.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'BootstrapExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-full-bootstrap.log' -Tail 40
exit $taskExit
