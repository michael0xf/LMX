$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/candidate46-tools-context')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe').Hash -ne 'F17AD0A6449E308763D3613FE313F01E06DAE8151820ED44DEE34D93C9CC16FA'){throw 'Language preparation tool changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46.list').Hash -ne 'E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF'){throw 'Source list changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/full46/l2_frontend_emit.lm2').Hash -ne 'D461991F22087329AA1461B452BA0D05E140F7EB78062E9F0F60AA649596A753'){throw 'Variant full46 emit changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/full46/suite.lm2').Hash -ne '3F38AF62C153C77231B5FAE6F025F5AEA54C9AAEA52EF84B00D9ADA37762E01C'){throw 'Variant full46 suite changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/full46/full-suite.tsv').Hash -ne 'CB3A4CC72B7BE96F895BC803E7F537BD04483FA29A6B87E1A3B9830C207F1ACE'){throw 'Variant full46 full list changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate46/src/l2src/l2_frontend_emit.lm2').Hash -ne 'D461991F22087329AA1461B452BA0D05E140F7EB78062E9F0F60AA649596A753'){throw 'candidate46 emit is not the variant'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate46/tests/full-suite.tsv').Hash -ne 'CB3A4CC72B7BE96F895BC803E7F537BD04483FA29A6B87E1A3B9830C207F1ACE'){throw 'candidate46 full list is not the variant'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate46/tools/build.lm2').Hash -ne '28DFBFA951A20B50F1E1E97DA13232CC543FCC0F6CEAC8A4A62E25B8B053F4C3'){throw 'candidate46 tools/build is not recipe-fe-O2-11'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/recipe-bounds10/suite.lm2').Hash -ne '86C08166D37917E65ABBB02D32CBA9E77DFB67D49A5CD033855AAE300E1D7A42'){throw 'Variant recipe-bounds10 suite changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate46/tools/suite.lm2').Hash -ne '3F38AF62C153C77231B5FAE6F025F5AEA54C9AAEA52EF84B00D9ADA37762E01C'){throw 'candidate46 tools/suite is not the variant'}
if(@(Compare-Object -ReferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.list') -DifferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46.list')).Count -ne 0){throw 'The candidate46 list is not the candidate42 list'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46.raw.sha256','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46-manifest.log')){if(Test-Path -LiteralPath $taskF){throw 'Output already exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe' '0' 'entry' '0' '--' 'manifest' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46.list' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate46' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46-manifest.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'LanguageManifestExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate46-manifest.log' -Tail 8
exit $taskExit
