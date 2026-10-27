$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"}
]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed C input: '+$taskG.path)}}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/frontend.c')){throw 'frontend.c missing'}
if(@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/headers/l1src' -Filter '*.lm1.h').Count -ne 2){throw 'headers/l1src does not hold 2 C headers'}
if(@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/headers/l2src' -Filter '*.lm1.h').Count -ne 29){throw 'headers/l2src does not hold 29 C headers'}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/l2trans.exe','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/COMPILE.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
'frontend.c '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/frontend.c').Hash
'headers/l2src/l2_application.lm1.h '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/headers/l2src/l2_application.lm1.h').Hash
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '3600' 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '-pipe' '-std=c99' '-O1' '-fno-strict-aliasing' '-DLMX_OBSERVE_WALK=0' '-Wall' '-Wextra' '-Werror=implicit-function-declaration' '-Werror=implicit-int' '-Werror=incompatible-pointer-types' '-Werror=discarded-qualifiers' '-I' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/headers' '--param' 'ggc-min-heapsize=16384' '--param' 'ggc-min-expand=20' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/frontend.c' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/l2_libc.o' '-o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/l2trans.exe' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/COMPILE.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'Exit '+$taskExit
if($taskExit -eq 0){'l2trans.exe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/l2trans.exe').Hash}
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/COMPILE.log' -Tail 40}
exit $taskExit
