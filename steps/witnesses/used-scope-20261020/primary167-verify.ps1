#requires -Version 7.0
param([string]$Frontend='frontend-05',[int]$Attempt=5)
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_primary_projection167'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/build.ps1" -Label $Frontend
& "$stage/checkpoint.ps1" -Frontend $Frontend -Label checkpoint-02
& "$stage/projection.ps1" -Frontend $Frontend -Label projection-06
foreach($name in 'reference-span','receive-span','pointer','model','source-value','source-record'){
 & "$stage/$name.ps1" -Frontend $Frontend -Label "$name-05"
}
& "$stage/regress.ps1" -Frontend $Frontend -Attempt $Attempt
& "$stage/regress-values.ps1" -Frontend $Frontend -Attempt $Attempt
foreach($case in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23},@{Source='source-mapped';Bodies=1},@{Source='projection-machine';Bodies=0},@{Source='projection-length';Bodies=1})){
 & "$stage/named-values.ps1" -Frontend $Frontend -Label ($case.Source+'-167-05') -SourceFile ($case.Source+'.lm2') -ForcedBodies $case.Bodies
}
& "$stage/letter-observe.ps1" -Frontend $Frontend -Label letter-current-05
& "$stage/source-route.ps1" -Frontend $Frontend -Label source-route-05
Write-Output 'VERIFY167 exact frontend selected regressions TERMINAL;not whole closure'
