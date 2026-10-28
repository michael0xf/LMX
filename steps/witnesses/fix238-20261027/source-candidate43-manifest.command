$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/candidate43-tools-context')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe').Hash -ne 'F17AD0A6449E308763D3613FE313F01E06DAE8151820ED44DEE34D93C9CC16FA'){throw 'Language preparation tool changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43.list').Hash -ne 'E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF'){throw 'Source list changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/recipe-bounds10/build.lm2').Hash -ne 'E9E93E8D5FDD70426B8A7F792E901DE07614AAAE2B318FF0D4ABA673536CA67B'){throw 'Variant recipe-bounds10 build changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate43/tools/build.lm2').Hash -ne 'E9E93E8D5FDD70426B8A7F792E901DE07614AAAE2B318FF0D4ABA673536CA67B'){throw 'candidate43 tools/build is not the variant'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/recipe-bounds10/suite.lm2').Hash -ne '86C08166D37917E65ABBB02D32CBA9E77DFB67D49A5CD033855AAE300E1D7A42'){throw 'Variant recipe-bounds10 suite changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate43/tools/suite.lm2').Hash -ne '86C08166D37917E65ABBB02D32CBA9E77DFB67D49A5CD033855AAE300E1D7A42'){throw 'candidate43 tools/suite is not the variant'}
if(@(Compare-Object -ReferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate42.list') -DifferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43.list')).Count -ne 0){throw 'The candidate43 list is not the candidate42 list'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43.raw.sha256','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43-manifest.log')){if(Test-Path -LiteralPath $taskF){throw 'Output already exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe' '0' 'entry' '0' '--' 'manifest' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43.list' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate43' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43-manifest.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'LanguageManifestExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate43-manifest.log' -Tail 8
exit $taskExit
