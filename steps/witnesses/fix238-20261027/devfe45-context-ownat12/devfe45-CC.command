$ErrorActionPreference='Stop'
# devfe45 step 3: gcc -O2 -fno-strict-aliasing of the development frontend.c (step 2) with the boot44 stage C headers and the boot44 G2 l2_libc.o: the same flags as the recipe (candidate44 build.lm2:713 + bld_cflags). A development FE for the useplan check, never a candidate. 2026-10-28
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c","sha256":"712126F6C2189C601066EF7BEC3B584BFF8DF4481236F676D88A0481E5142517"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/boot44/g2/frontend/l2_libc.o","sha256":"AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 4){throw 'Pin count'}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed C input: '+$taskG.path)}}
if(@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/headers/l1src' -Filter '*.lm1.h').Count -ne 3){throw 'headers/l1src does not hold 3 C headers'}
if(@(Get-ChildItem -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/headers/l2src' -Filter '*.lm1.h').Count -ne 81){throw 'headers/l2src does not hold 81 C headers'}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/l2trans.exe','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/COMPILE.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '3600' 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '-pipe' '-std=c99' '-O2' '-fno-strict-aliasing' '-DLMX_OBSERVE_WALK=0' '-Wall' '-Wextra' '-Werror=implicit-function-declaration' '-Werror=implicit-int' '-Werror=incompatible-pointer-types' '-Werror=discarded-qualifiers' '-I' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/headers' '--param' 'ggc-min-heapsize=16384' '--param' 'ggc-min-expand=20' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/frontend.c' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-candidate44/boot44/g2/frontend/l2_libc.o' '-o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/l2trans.exe' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/COMPILE.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'Exit '+$taskExit
if($taskExit -eq 0){'l2trans.exe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/l2trans.exe').Hash+' '+(Get-Item -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/l2trans.exe').Length}
'warnings '+@(Select-String -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/COMPILE.log' -Pattern 'warning').Count
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-devfe45/COMPILE.log' -Tail 40}
exit $taskExit
