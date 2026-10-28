$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/seed-driver.o","sha256":"120A09810A60415003EB2376B2C44171137CBF32A9A018D196A2CEC1B06FFE7A"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"}
]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed witness C input: '+$taskG.path)}}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.c')){throw 'p.c missing'}
if(@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/headers/l2src' -Filter '*.lm1.h').Count -lt 29){throw 'initial-tool32-40/headers/l2src does not hold the 29 kernel C headers'}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.o','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.CC.log','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.LD.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
'p.c '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.c').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '900' 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '-pipe' '-std=c99' '-O2' '-fstrict-aliasing' '-DLMX_OBSERVE_WALK=0' '-Wall' '-Wextra' '-Werror=implicit-function-declaration' '-Werror=implicit-int' '-Werror=incompatible-pointer-types' '-Werror=discarded-qualifiers' '-I' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/headers' '--param' 'ggc-min-heapsize=16384' '--param' 'ggc-min-expand=20' '-Dmain=l2_generated_main' '-Dlmx_root_launch=l2_driver_root_launch' '-Dlmx_merge_owned=l2_driver_merge_owned' '-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned' '-Dlmx_merge_used_owned=l2_driver_merge_used_owned' '-Dlmx_service_post=l2_driver_service_post' '-c' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.c' '-o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.o' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.CC.log'
$taskExit=$LASTEXITCODE
'CompileExit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.CC.log' -Tail 40; exit $taskExit}
& 'C:/Git/usr/bin/timeout.exe' '900' 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p.o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-40/seed-driver.o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/l2_libc.o' '-Wl,--strip-debug' '-o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.LD.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'LinkExit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.LD.log' -Tail 40}
if($taskExit -eq 0){'p-prod.exe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe').Hash}
exit $taskExit
