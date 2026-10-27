$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/context')){throw 'Unexpected CWD'}
$taskPins=@'
[{"path":"C:/Qt/Tools/mingw1310_64/bin/gcc.exe","sha256":"920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.c","sha256":"9A0E81D9BFA33D6DC48D1B0CA3E11CDDB406BFF9711B904B336393A48CC5ECAE"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.lm1.h","sha256":"B11D9B18318E9C9EDA9D5F3F3244008FE454E5781068AFC6CFA137D2F24B0884","bytes":212},{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"}]
'@|ConvertFrom-Json
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw 'Changed C input'}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.exe','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/CC.log')){if(Test-Path -LiteralPath $taskF){throw 'Output exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '-pipe' '-std=c99' '-O1' '-fno-strict-aliasing' '-Wall' '-Wextra' '-Werror=implicit-function-declaration' '-Werror=implicit-int' '-Werror=incompatible-pointer-types' '-Werror=discarded-qualifiers' '-Werror=int-conversion' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.c' '-o' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.exe' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/CC.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'CompilerExit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/CC.log' -Tail 24}
exit $taskExit
