$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/candidate42-tools-context')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe').Hash -ne 'F17AD0A6449E308763D3613FE313F01E06DAE8151820ED44DEE34D93C9CC16FA'){throw 'Language preparation tool changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.list').Hash -ne 'E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF'){throw 'Source list changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/core-preamble09/l2_frontend_core.lm2').Hash -ne '337E3641952CF13A9F7F1BD371C2C5543277BAD929D82A57B00B4BB86E4E916B'){throw 'Variant core-preamble09 changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate42/src/l2src/l2_frontend_core.lm2').Hash -ne '337E3641952CF13A9F7F1BD371C2C5543277BAD929D82A57B00B4BB86E4E916B'){throw 'candidate42 src/l2src/l2_frontend_core.lm2 is not the variant'}
if(@(Compare-Object -ReferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate41.list') -DifferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.list')).Count -ne 0){throw 'The candidate42 list is not the candidate41 list'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.raw.sha256','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42-manifest.log')){if(Test-Path -LiteralPath $taskF){throw 'Output already exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe' '0' 'entry' '0' '--' 'manifest' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.list' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate42' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42-manifest.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'LanguageManifestExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42-manifest.log' -Tail 8
exit $taskExit
