$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-core09')){throw 'Unexpected CWD'}
$taskDir='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-core09'
$taskRecipe='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/build-usenote08/build.lm2'
$taskPrev='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-core08/l2_frontend_core.h.lm1'
$taskSource='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/core-preamble09/l2_frontend_core.lm2'
$taskWarm='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src'
if((Get-FileHash -LiteralPath $taskRecipe).Hash -ne '335CD8D09C55359C0D793FB220DB4B2A5CDB726EBCB60A0555F562A288D65A7E'){throw 'Recipe variant build-usenote08 changed'}
if((Get-FileHash -LiteralPath $taskPrev).Hash -ne 'DA71B0941FCBA80B8017F94FA5BDBBCC332DAC7D6D4C68480827A36FAE7AFE3F'){throw 'core08 header changed'}
if((Get-FileHash -LiteralPath $taskSource).Hash -ne '337E3641952CF13A9F7F1BD371C2C5543277BAD929D82A57B00B4BB86E4E916B'){throw 'Source variant core-preamble09 changed'}
if(-not (Test-Path -LiteralPath ($taskDir+'/L2.terminal.txt'))){throw 'L2.terminal.txt missing'}
'--- L2.terminal.txt ---'
Get-Content -LiteralPath ($taskDir+'/L2.terminal.txt')
if(@(Get-Content -LiteralPath ($taskDir+'/L2.terminal.txt') | Where-Object { $_ -eq 'CompilerExit 0' }).Count -ne 1){throw 'CompilerExit 0 not recorded: no acceptance'}
foreach($taskF in @('l2_frontend_core.lm1','l2_frontend_core.h.lm1','L2.log')){if(-not (Test-Path -LiteralPath ($taskDir+'/'+$taskF))){throw ('Output missing: '+$taskF)}}
'l2_frontend_core.lm1 '+(Get-FileHash -LiteralPath ($taskDir+'/l2_frontend_core.lm1')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/l2_frontend_core.lm1')).Length
'l2_frontend_core.h.lm1 '+(Get-FileHash -LiteralPath ($taskDir+'/l2_frontend_core.h.lm1')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/l2_frontend_core.h.lm1')).Length
'L2.log '+(Get-FileHash -LiteralPath ($taskDir+'/L2.log')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/L2.log')).Length
'source '+(Get-FileHash -LiteralPath $taskSource).Hash
$taskNames=@(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.h.lm1') -Pattern '^    (fn|sub): ([A-Za-z_][A-Za-z0-9_]*) ' | ForEach-Object { $_.Matches[0].Groups[2].Value })
'HeaderExports '+$taskNames.Count
$taskRecipeNames=@(Select-String -LiteralPath $taskRecipe -Pattern '^    frontend_core_names\[[0-9]+\]: "([A-Za-z_][A-Za-z0-9_]*)"' | ForEach-Object { $_.Matches[0].Groups[1].Value })
'RecipeCoreNames '+$taskRecipeNames.Count
$taskDiff=@(Compare-Object -ReferenceObject ($taskRecipeNames | Sort-Object) -DifferenceObject ($taskNames | Sort-Object))
'RecipeDifferences '+$taskDiff.Count
if($taskDiff.Count -ne 0){$taskDiff | ForEach-Object { 'DIFF '+$_.SideIndicator+' '+$_.InputObject }}
$taskPrevNames=@(Select-String -LiteralPath $taskPrev -Pattern '^    (fn|sub): ([A-Za-z_][A-Za-z0-9_]*) ' | ForEach-Object { $_.Matches[0].Groups[2].Value })
$taskPrevDiff=@(Compare-Object -ReferenceObject ($taskPrevNames | Sort-Object) -DifferenceObject ($taskNames | Sort-Object))
'Core08Differences '+$taskPrevDiff.Count
$taskPrevDiff | ForEach-Object { 'DIFF08 '+$_.SideIndicator+' '+$_.InputObject }
'DuplicateExports '+($taskNames.Count-@($taskNames | Sort-Object -Unique).Count)
'OldNamePrototypes '+@(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.h.lm1') -Pattern '^    fn: lm_compiler_use_note ').Count
'BodyLexicalDefinitions '+@(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.lm1') -Pattern '^fn: lm_compiler_use_note_lexical ').Count
'BodyOldNameDefinitions '+@(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.lm1') -Pattern '^fn: lm_compiler_use_note ').Count
if($taskNames.Count -ne 492 -or $taskRecipeNames.Count -ne 492 -or $taskDiff.Count -ne 0){throw 'The header does not carry exactly the 492 exports of the recipe variant: no acceptance'}
if($taskPrevDiff.Count -ne 0){throw 'The export set differs from the core08 header: no acceptance'}
if(@(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.h.lm1') -Pattern '^    fn: lm_compiler_use_note ').Count -ne 0 -or @(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.lm1') -Pattern '^fn: lm_compiler_use_note_lexical ').Count -ne 1 -or @(Select-String -LiteralPath ($taskDir+'/l2_frontend_core.lm1') -Pattern '^fn: lm_compiler_use_note ').Count -ne 0){throw 'The old name is still defined or the new wrapper is not defined once: no acceptance'}
foreach($taskF in @('l2_frontend_core.lm1','l2_frontend_core.h.lm1')){if(Test-Path -LiteralPath ($taskWarm+'/'+$taskF)){throw ('Warm copy exists: '+$taskF)}}
Copy-Item -LiteralPath ($taskDir+'/l2_frontend_core.lm1') -Destination ($taskWarm+'/l2_frontend_core.lm1')
Copy-Item -LiteralPath ($taskDir+'/l2_frontend_core.h.lm1') -Destination ($taskWarm+'/l2_frontend_core.h.lm1')
foreach($taskF in @('l2_frontend_core.lm1','l2_frontend_core.h.lm1')){if((Get-FileHash -LiteralPath ($taskWarm+'/'+$taskF)).Hash -ne (Get-FileHash -LiteralPath ($taskDir+'/'+$taskF)).Hash){throw ('Warm copy differs: '+$taskF)}; 'warm '+$taskF+' '+(Get-FileHash -LiteralPath ($taskWarm+'/'+$taskF)).Hash}
'WarmL2srcFiles '+@(Get-ChildItem -LiteralPath $taskWarm -File).Count
'AcceptedUTC '+[DateTime]::UtcNow.ToString('o')
exit 0
