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
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l1trans.exe","sha256":"3C8976D7001871A919103A9A89E9AAE27A99018FC657F3F582485911F6F20BA5"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.raw.sha256","sha256":"EC11A97FC66D15631E8ACB5E60FFCFD77523FB1A71473D5378FC7770280BAE20"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l2trans.exe","sha256":"6FF7DB4B977B04CDF8E4E92A9E0CD9ABD3731D0855943670DEF97A375F2966F3"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 12){throw ('Pin count '+@($taskPins).Count+' is not 12: the candidate40 tool and warm40 frontend pins are missing')}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed bootstrap input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler or tool pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42/src/l2src/convert.lm2')){throw 'Stage missing: cold-candidate42'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42/boot42','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42/headers','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42/src/l2src/lmx.h.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42/src/l1src/libc_abi.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate42-bootstrap.log','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate42-bootstrap-preflight-GNU.log')){if(Test-Path -LiteralPath $taskF){throw ('Output or generated input exists: '+$taskF)}}
Push-Location -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42'
& 'C:/Git/usr/bin/sha256sum.exe' '-c' '--quiet' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate42-bootstrap-preflight-GNU.log'
$taskGnu=$LASTEXITCODE
Pop-Location
if($taskGnu -ne 0){throw 'Stage GNU mismatch before the bootstrap'}
$env:CPATH=$null
$env:C_INCLUDE_PATH=$null
$env:CPLUS_INCLUDE_PATH=$null
$env:OBJC_INCLUDE_PATH=$null
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
'tool '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-42/self01/lmxtool-tool.exe').Hash
'previous_fe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l2trans.exe').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '43200' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-42/self01/lmxtool-tool.exe' '0' 'entry' '0' '--' 'bootstrap' 'quick' 'C:/Nyasha_Planet/LMX' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l2trans.exe' 'boot42' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate42/tests/smoke-kernel225.tsv' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate42-bootstrap.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'BootstrapExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate42-bootstrap.log' -Tail 40
exit $taskExit
