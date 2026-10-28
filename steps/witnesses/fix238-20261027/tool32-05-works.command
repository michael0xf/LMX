$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/tool-run')){throw 'Unexpected CWD'}
if((Get-FileHash -LiteralPath 'C:/Git/usr/bin/timeout.exe').Hash -ne '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4'){throw 'timeout.exe changed'}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool-tool.exe')){throw 'lmxtool-tool.exe missing'}
if(-not (Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1')){throw 'lmxtool.lm1 missing'}
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/tool-sha256.log'){throw 'Output exists: tool-sha256.log'}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'lmxtool-tool.exe '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool-tool.exe').Hash
$taskExpected=(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1').Hash
'ExpectedDigest '+$taskExpected
& 'C:/Git/usr/bin/timeout.exe' '--signal=KILL' '300' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool-tool.exe' '0' 'entry' '0' '--' 'sha256' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/tool-sha256.log'
$taskExit=$LASTEXITCODE
'DriverExit '+$taskExit
'--- tool-sha256.log ---'
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/tool-sha256.log'
$taskSame=0
foreach($taskLine in @(Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/tool-sha256.log')){if($taskLine -match '^([0-9A-Fa-f]{64})  (.+)$'){if(($Matches[1] -ieq $taskExpected) -and ($Matches[2] -eq 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/self01/lmxtool.lm1')){$taskSame=1}}}
'SameDigestLine '+$taskSame
'EndUTC '+[DateTime]::UtcNow.ToString('o')
if($taskExit -ne 0 -or $taskSame -ne 1){exit 1}
exit 0
