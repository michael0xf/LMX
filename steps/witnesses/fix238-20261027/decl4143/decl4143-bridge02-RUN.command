$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/context')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.exe').Hash -ne '6CBEFC79598713F763A8097CFD0A358DB52CDCC73D777433A88A496DD62162C5'){throw 'Generator executable changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-source02.lm2').Hash -ne 'C946CDD4E0D45258569809537F8D3EDBDC41302D20F7848A2A8B80C84A1BBE5C'){throw 'Generator L3 changed'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/l1src/own.h.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/l1src/parser.lm1','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/RUN.log')){if(Test-Path -LiteralPath $taskF){throw 'Output already exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/generator.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/l1src/own.h.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/l1src/parser.lm1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/RUN.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'GeneratorExit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/bootstrap-decls4143-bridge02/RUN.log' -Tail 24}
exit $taskExit
