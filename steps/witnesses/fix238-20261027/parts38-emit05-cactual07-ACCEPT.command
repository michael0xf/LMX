$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-emit05-cactual07')){throw 'Unexpected CWD'}
$taskDir='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-emit05-cactual07'
$taskReady='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/parts38-emit05-cactual07-ready.json'
$taskWarm='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend39/src/l2src'
if(-not (Test-Path -LiteralPath ($taskDir+'/L2.terminal.txt'))){throw 'L2.terminal.txt missing'}
'--- L2.terminal.txt ---'
Get-Content -LiteralPath ($taskDir+'/L2.terminal.txt')
if(@(Get-Content -LiteralPath ($taskDir+'/L2.terminal.txt') | Where-Object { $_ -eq 'CompilerExit 0' }).Count -ne 1){throw 'CompilerExit 0 not recorded: no acceptance'}
foreach($taskF in @('l2_frontend_emit.lm1','l2_frontend_emit.h.lm1','L2.log')){if(-not (Test-Path -LiteralPath ($taskDir+'/'+$taskF))){throw ('Output missing: '+$taskF)}}
'l2_frontend_emit.lm1 '+(Get-FileHash -LiteralPath ($taskDir+'/l2_frontend_emit.lm1')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/l2_frontend_emit.lm1')).Length
'l2_frontend_emit.h.lm1 '+(Get-FileHash -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1')).Length
'L2.log '+(Get-FileHash -LiteralPath ($taskDir+'/L2.log')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/L2.log')).Length
'source '+(Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/emit-cactual07/l2_frontend_emit.lm2').Hash
$taskNames=@(Select-String -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1') -Pattern '^    fn: ([A-Za-z_][A-Za-z0-9_]*) ' | ForEach-Object { $_.Matches[0].Groups[1].Value })
'HeaderPrototypes '+$taskNames.Count
$taskExpected=@((Get-Content -Raw -LiteralPath $taskReady | ConvertFrom-Json).exportNames)
'ReadyExportNames '+$taskExpected.Count
$taskDiff=@(Compare-Object -ReferenceObject ($taskExpected | Sort-Object) -DifferenceObject ($taskNames | Sort-Object))
'ExportSetDifferences '+$taskDiff.Count
if($taskDiff.Count -ne 0){$taskDiff | ForEach-Object { 'DIFF '+$_.SideIndicator+' '+$_.InputObject }}
'DuplicatePrototypes '+($taskNames.Count-@($taskNames | Sort-Object -Unique).Count)
if($taskNames.Count -ne 310 -or $taskExpected.Count -ne 310 -or $taskDiff.Count -ne 0){throw 'The header does not carry exactly the 310 machine exports of the ready: no acceptance'}
foreach($taskF in @('l2_frontend_emit.lm1','l2_frontend_emit.h.lm1')){if(Test-Path -LiteralPath ($taskWarm+'/'+$taskF)){throw ('Warm copy exists: '+$taskF)}}
Copy-Item -LiteralPath ($taskDir+'/l2_frontend_emit.lm1') -Destination ($taskWarm+'/l2_frontend_emit.lm1')
Copy-Item -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1') -Destination ($taskWarm+'/l2_frontend_emit.h.lm1')
foreach($taskF in @('l2_frontend_emit.lm1','l2_frontend_emit.h.lm1')){if((Get-FileHash -LiteralPath ($taskWarm+'/'+$taskF)).Hash -ne (Get-FileHash -LiteralPath ($taskDir+'/'+$taskF)).Hash){throw ('Warm copy differs: '+$taskF)}; 'warm '+$taskF+' '+(Get-FileHash -LiteralPath ($taskWarm+'/'+$taskF)).Hash}
'WarmL2srcFiles '+@(Get-ChildItem -LiteralPath $taskWarm -File).Count
'AcceptedUTC '+[DateTime]::UtcNow.ToString('o')
exit 0
