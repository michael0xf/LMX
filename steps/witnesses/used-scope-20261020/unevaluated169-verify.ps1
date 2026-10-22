#requires -Version 7.0
# Every 169 observation on ONE exact frontend: the new unevaluated-operand
# witnesses, their parent168 baseline, the historical/negative/OPEN controls,
# then the inherited 168 regression selection. Labels carry the attempt.
param([string]$Frontend='frontend-02',[int]$Attempt=2)
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_unevaluated169'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
$tag='{0:d2}' -f $Attempt
& "$stage/unevaluated.ps1" -Frontend $Frontend -Label "unevaluated-$tag"
& "$stage/unevaluated.ps1" -Frontend $Frontend -Label "unevaluated-parent168-$tag" -Baseline
foreach($case in @(@{Source='unevaluated-values';Bodies=1},@{Source='unevaluated-obligations';Bodies=4},@{Source='unevaluated-deferred';Bodies=1},@{Source='unevaluated-opaque';Bodies=0},@{Source='unevaluated-callable-class';Bodies=2},@{Source='unevaluated-callable-input';Bodies=4},@{Source='unevaluated-receiver';Bodies=0},@{Source='machine-unevaluated-open';Bodies=0})){
 & "$stage/program-values.ps1" -Frontend $Frontend -Label "$($case.Source)-$tag" -SourceFile "$($case.Source).lm2" -ForcedBodies $case.Bodies
}
& "$stage/program-values.ps1" -Frontend $Frontend -Label "unevaluated-entry-$tag" -SourceFile unevaluated-entry.lm2 -ForcedBodies 1 -Roots 0
& "$stage/unevaluated-controls.ps1" -Frontend $Frontend -Label "controls-$tag"
& python.exe -I "$stage/classify-l1.py" "$stage/controls-$tag" "$stage/controls-$tag/l1-classes.json"
if($LASTEXITCODE -ne 0){throw 'Every changed historical L1 line must be explained'}
& "$stage/mutants.ps1" -Frontend $Frontend -Label "mutants-$tag"
& "$stage/named-values.ps1" -Frontend $Frontend -Label "sizeof-values-$tag" -SourceFile sizeof-values.lm2 -ForcedBodies 0
& "$stage/projection.ps1" -Frontend $Frontend -Label "projection-$tag"
foreach($name in 'reference-span','receive-span','pointer','model','source-value','source-record','sizeof','address','opaque-address'){
 & "$stage/$name.ps1" -Frontend $Frontend -Label "$name-$tag"
}
& "$stage/regress.ps1" -Frontend $Frontend -Attempt $Attempt
& "$stage/regress-values.ps1" -Frontend $Frontend -Attempt $Attempt
foreach($case in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23},@{Source='source-mapped';Bodies=1},@{Source='projection-machine';Bodies=0},@{Source='projection-length';Bodies=1})){
 & "$stage/named-values.ps1" -Frontend $Frontend -Label ($case.Source+'-169-'+$tag) -SourceFile ($case.Source+'.lm2') -ForcedBodies $case.Bodies
}
& "$stage/letter-observe.ps1" -Frontend $Frontend -Label "letter-current-$tag"
& "$stage/source-route.ps1" -Frontend $Frontend -Label "source-route-$tag"
Write-Output 'VERIFY169 exact frontend unevaluated witnesses and selected regressions TERMINAL;not whole closure'
