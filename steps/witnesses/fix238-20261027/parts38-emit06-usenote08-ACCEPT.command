$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-emit06-usenote08')){throw 'Unexpected CWD'}
$taskDir='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-emit06-usenote08'
$taskRecipe='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/build-usenote08/build.lm2'
$taskPrev='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/component-parts38-emit05-cactual07/l2_frontend_emit.h.lm1'
$taskSource='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/variants/emit-cactual07-usenote08/l2_frontend_emit.lm2'
$taskWarm='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend40/src/l2src'
if((Get-FileHash -LiteralPath $taskRecipe).Hash -ne '335CD8D09C55359C0D793FB220DB4B2A5CDB726EBCB60A0555F562A288D65A7E'){throw 'Recipe variant build-usenote08 changed'}
if((Get-FileHash -LiteralPath $taskPrev).Hash -ne 'E9B98CE34B53B950B5E6490AF0FF84A1C250C87CA44822B71C9D68340B2CBE70'){throw 'emit07 header changed'}
if((Get-FileHash -LiteralPath $taskSource).Hash -ne '8AC2C6892D92F42A40307B4619851CFDD0C50844834C3F58B32BAB2B8D722ADC'){throw 'Source variant emit-cactual07-usenote08 changed'}
if(-not (Test-Path -LiteralPath ($taskDir+'/L2.terminal.txt'))){throw 'L2.terminal.txt missing'}
'--- L2.terminal.txt ---'
Get-Content -LiteralPath ($taskDir+'/L2.terminal.txt')
if(@(Get-Content -LiteralPath ($taskDir+'/L2.terminal.txt') | Where-Object { $_ -eq 'CompilerExit 0' }).Count -ne 1){throw 'CompilerExit 0 not recorded: no acceptance'}
foreach($taskF in @('l2_frontend_emit.lm1','l2_frontend_emit.h.lm1','L2.log')){if(-not (Test-Path -LiteralPath ($taskDir+'/'+$taskF))){throw ('Output missing: '+$taskF)}}
'l2_frontend_emit.lm1 '+(Get-FileHash -LiteralPath ($taskDir+'/l2_frontend_emit.lm1')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/l2_frontend_emit.lm1')).Length
'l2_frontend_emit.h.lm1 '+(Get-FileHash -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1')).Length
'L2.log '+(Get-FileHash -LiteralPath ($taskDir+'/L2.log')).Hash+' '+(Get-Item -LiteralPath ($taskDir+'/L2.log')).Length
'source '+(Get-FileHash -LiteralPath $taskSource).Hash
$taskNames=@(Select-String -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1') -Pattern '^    (fn|sub): ([A-Za-z_][A-Za-z0-9_]*) ' | ForEach-Object { $_.Matches[0].Groups[2].Value })
'HeaderExports '+$taskNames.Count
$taskRecipeNames=@(Select-String -LiteralPath $taskRecipe -Pattern '^    frontend_emit_names\[[0-9]+\]: "([A-Za-z_][A-Za-z0-9_]*)"' | ForEach-Object { $_.Matches[0].Groups[1].Value })
'RecipeEmitNames '+$taskRecipeNames.Count
$taskDiff=@(Compare-Object -ReferenceObject ($taskRecipeNames | Sort-Object) -DifferenceObject ($taskNames | Sort-Object))
'RecipeDifferences '+$taskDiff.Count
if($taskDiff.Count -ne 0){$taskDiff | ForEach-Object { 'DIFF '+$_.SideIndicator+' '+$_.InputObject }}
$taskPrevNames=@(Select-String -LiteralPath $taskPrev -Pattern '^    (fn|sub): ([A-Za-z_][A-Za-z0-9_]*) ' | ForEach-Object { $_.Matches[0].Groups[2].Value })
$taskPrevDiff=@(Compare-Object -ReferenceObject ($taskPrevNames | Sort-Object) -DifferenceObject ($taskNames | Sort-Object))
'Emit07Differences '+$taskPrevDiff.Count
$taskPrevDiff | ForEach-Object { 'DIFF07 '+$_.SideIndicator+' '+$_.InputObject }
'DuplicateExports '+($taskNames.Count-@($taskNames | Sort-Object -Unique).Count)
'BodyLexicalCalls '+@(Select-String -LiteralPath ($taskDir+'/l2_frontend_emit.lm1') -Pattern 'c\.lm_compiler_use_note_lexical\(').Count
'BodyOldNameCalls '+@(Select-String -LiteralPath ($taskDir+'/l2_frontend_emit.lm1') -Pattern 'c\.lm_compiler_use_note\(').Count
if($taskNames.Count -ne 310 -or $taskRecipeNames.Count -ne 310 -or $taskDiff.Count -ne 0 -or $taskPrevDiff.Count -ne 0){throw 'The header does not carry exactly the 310 exports of the recipe variant (same set as emit07): no acceptance'}
if(@(Select-String -LiteralPath ($taskDir+'/l2_frontend_emit.lm1') -Pattern 'c\.lm_compiler_use_note_lexical\(').Count -ne 1 -or @(Select-String -LiteralPath ($taskDir+'/l2_frontend_emit.lm1') -Pattern 'c\.lm_compiler_use_note\(').Count -ne 0){throw 'The body does not call the renamed wrapper exactly once with no old-name call left: no acceptance'}
foreach($taskF in @('l2_frontend_emit.lm1','l2_frontend_emit.h.lm1')){if(Test-Path -LiteralPath ($taskWarm+'/'+$taskF)){throw ('Warm copy exists: '+$taskF)}}
Copy-Item -LiteralPath ($taskDir+'/l2_frontend_emit.lm1') -Destination ($taskWarm+'/l2_frontend_emit.lm1')
Copy-Item -LiteralPath ($taskDir+'/l2_frontend_emit.h.lm1') -Destination ($taskWarm+'/l2_frontend_emit.h.lm1')
foreach($taskF in @('l2_frontend_emit.lm1','l2_frontend_emit.h.lm1')){if((Get-FileHash -LiteralPath ($taskWarm+'/'+$taskF)).Hash -ne (Get-FileHash -LiteralPath ($taskDir+'/'+$taskF)).Hash){throw ('Warm copy differs: '+$taskF)}; 'warm '+$taskF+' '+(Get-FileHash -LiteralPath ($taskWarm+'/'+$taskF)).Hash}
'WarmL2srcFiles '+@(Get-ChildItem -LiteralPath $taskWarm -File).Count
'AcceptedUTC '+[DateTime]::UtcNow.ToString('o')
exit 0
