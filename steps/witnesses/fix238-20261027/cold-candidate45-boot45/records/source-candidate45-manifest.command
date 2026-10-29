$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/candidate45-tools-context')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe').Hash -ne 'F17AD0A6449E308763D3613FE313F01E06DAE8151820ED44DEE34D93C9CC16FA'){throw 'Language preparation tool changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.list').Hash -ne 'E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF'){throw 'Source list changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/context-ownat12/l2_frontend_context.lm2').Hash -ne '8733F9C99F5727C8BA295E4341F6FEB3DDA7C613F2633B158D31F94015780134'){throw 'Variant context-ownat12 changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate45/src/l2src/l2_frontend_context.lm2').Hash -ne '8733F9C99F5727C8BA295E4341F6FEB3DDA7C613F2633B158D31F94015780134'){throw 'candidate45 context is not the variant'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate45/tools/build.lm2').Hash -ne '28DFBFA951A20B50F1E1E97DA13232CC543FCC0F6CEAC8A4A62E25B8B053F4C3'){throw 'candidate45 tools/build is not recipe-fe-O2-11'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/recipe-bounds10/suite.lm2').Hash -ne '86C08166D37917E65ABBB02D32CBA9E77DFB67D49A5CD033855AAE300E1D7A42'){throw 'Variant recipe-bounds10 suite changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate45/tools/suite.lm2').Hash -ne '86C08166D37917E65ABBB02D32CBA9E77DFB67D49A5CD033855AAE300E1D7A42'){throw 'candidate45 tools/suite is not the variant'}
if(@(Compare-Object -ReferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate44.list') -DifferenceObject (Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.list')).Count -ne 0){throw 'The candidate45 list is not the candidate42 list'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.raw.sha256','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45-manifest.log')){if(Test-Path -LiteralPath $taskF){throw 'Output already exists'}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-control03/lmxtool-tool.exe' '0' 'entry' '0' '--' 'manifest' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.list' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/source-candidate45' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45.raw.sha256' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45-manifest.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'LanguageManifestExit '+$taskExit
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/source-candidate45-manifest.log' -Tail 8
exit $taskExit
