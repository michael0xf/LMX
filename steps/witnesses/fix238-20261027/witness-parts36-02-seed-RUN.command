$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Git/usr/bin/timeout.exe').Hash -ne '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4'){throw 'timeout.exe changed'}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe')){throw 'p-prod.exe missing'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/run-root0.log','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/run-root1.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'p-prod.exe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe').Hash
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe' '0' 'entry' '7' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/run-root0.log'
$taskRoot0=$LASTEXITCODE
'Root0DriverExit '+$taskRoot0
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/p-prod.exe' '0' 'entry' '7' 'walkroot' '1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/run-root1.log'
$taskRoot1=$LASTEXITCODE
'Root1DriverExit '+$taskRoot1
'--- run-root0.log ---'
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/run-root0.log'
'--- run-root1.log ---'
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/witnesses/ordinary-source-parts36/run02-seed/run-root1.log'
'EndUTC '+[DateTime]::UtcNow.ToString('o')
if($taskRoot0 -ne 0 -or $taskRoot1 -ne 0){exit 1}
exit 0
