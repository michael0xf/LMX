$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/context')){throw 'Unexpected CWD'}
$taskRootGuards=@'
[{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l2trans.exe","sha256":"6FA278313E805DA96674F794DDA0FB1DB2A2A765A62732A14E982780F77558C1"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-source02.lm2","sha256":"C946CDD4E0D45258569809537F8D3EDBDC41302D20F7848A2A8B80C84A1BBE5C"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/src/l2src/convert.lm2","sha256":"1E376CBA102874857EAC2279F0C6E14CCE5AB009CB8764B03BD300F7E9746976"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/src/l2src/primitive.lm2","sha256":"CF9AAC78F7347AE0B40E929752FC0400A67507CA302735655CA3BE167DB588C3"},{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/frontend-existing-parts38/build.lm2","sha256":"6C4E2B110B539A27099B21C91DF8590C8348FD2FDF3633EA52285D0DA3CDB674"},{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"}]
'@|ConvertFrom-Json
foreach($taskPin in $taskRootGuards){if((Get-FileHash -LiteralPath $taskPin.path).Hash -ne $taskPin.sha256){throw ('Input changed: '+$taskPin.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline already running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient FreeVirtualMemory'}
foreach($taskOut in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.h.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/L2.log')){if(Test-Path -LiteralPath $taskOut){throw ('Refusing to overwrite '+$taskOut)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/seed-f1-o1-from-c01/l2trans.exe' '--library' '--machine' 'main' '--header' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.h.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-source02.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/src/l2src/convert.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/src/l2src/primitive.lm2' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.lm1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/L2.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'CompilerExit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/L2.log' -Tail 24}
exit $taskExit
