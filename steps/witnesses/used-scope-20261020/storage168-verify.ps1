#requires -Version 7.0
param([string]$Frontend='frontend-06',[int]$Attempt=6,[switch]$ResumeFixtures)
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_primary_contract168'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
if($ResumeFixtures){
 $built=Get-Content -LiteralPath "$stage/$Frontend/results.json" -Raw|ConvertFrom-Json
 $projection=Get-Content -LiteralPath "$stage/projection-06/results.json" -Raw|ConvertFrom-Json
 $builds=@(Get-Content -LiteralPath "$stage/sizeof-values-06/builds.json" -Raw|ConvertFrom-Json);$runs=@(Get-Content -LiteralPath "$stage/sizeof-values-06/results.json" -Raw|ConvertFrom-Json)
 if($projection.Exit -ne 0 -or $projection.FrontendCSha256 -cne $built.FrontendCSha256 -or $builds.Count -ne 2 -or $runs.Count -ne 8 -or @($runs|Where-Object {-not $_.Success}).Count -or @($builds|Where-Object {$_.CompilerSha256 -cne $built.FrontendExeSha256 -or $_.SourceSha256 -cne (Get-FileHash -LiteralPath "$stage/sizeof-values.lm2").Hash}).Count){throw 'Resume only the same completed immutable first two observations'}
 Write-Output 'RESUME168 retained exact06 completed storage values/projection,not earlier frontend observations'
}else{
 & "$stage/named-values.ps1" -Frontend $Frontend -Label sizeof-values-06 -SourceFile sizeof-values.lm2 -ForcedBodies 0
 & "$stage/projection.ps1" -Frontend $Frontend -Label projection-06
}
foreach($name in 'reference-span','receive-span','pointer','model','source-value','source-record'){
 & "$stage/$name.ps1" -Frontend $Frontend -Label "$name-06"
}
& "$stage/regress.ps1" -Frontend $Frontend -Attempt $Attempt
& "$stage/regress-values.ps1" -Frontend $Frontend -Attempt $Attempt
foreach($case in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23},@{Source='source-mapped';Bodies=1},@{Source='projection-machine';Bodies=0},@{Source='projection-length';Bodies=1})){
 & "$stage/named-values.ps1" -Frontend $Frontend -Label ($case.Source+'-168-06') -SourceFile ($case.Source+'.lm2') -ForcedBodies $case.Bodies
}
& "$stage/letter-observe.ps1" -Frontend $Frontend -Label letter-current-06
& "$stage/source-route.ps1" -Frontend $Frontend -Label source-route-06
Write-Output 'VERIFY168 exact frontend selected regressions TERMINAL;not whole closure'
