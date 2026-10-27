$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/candidate40-tools-context')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe').Hash -ne 'F17AD0A6449E308763D3613FE313F01E06DAE8151820ED44DEE34D93C9CC16FA'){throw 'Language preparation tool changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.list').Hash -ne 'E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF'){throw 'Source list changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/core-usenote08/l2_frontend_core.lm2').Hash -ne 'DBF273319A6D76F1C92F9184DE3FB2AF2F90826E1E4FD7B250BB5D08FAFD304B'){throw 'Variant core-usenote08 changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/emit-cactual07-usenote08/l2_frontend_emit.lm2').Hash -ne '8AC2C6892D92F42A40307B4619851CFDD0C50844834C3F58B32BAB2B8D722ADC'){throw 'Variant emit-cactual07-usenote08 changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/build-usenote08/build.lm2').Hash -ne '335CD8D09C55359C0D793FB220DB4B2A5CDB726EBCB60A0555F562A288D65A7E'){throw 'Variant build-usenote08 changed'}
if(@(Compare-Object -ReferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate39.list') -DifferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.list')).Count -ne 0){throw 'The candidate40 list is not the candidate39 list'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.raw.sha256','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40-manifest.log')){if(Test-Path -LiteralPath $taskF){throw 'Output already exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe' '0' 'entry' '0' '--' 'manifest' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.list' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate40' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40-manifest.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'LanguageManifestExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate40-manifest.log' -Tail 8
exit $taskExit
