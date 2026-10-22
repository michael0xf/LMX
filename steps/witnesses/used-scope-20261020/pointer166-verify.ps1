#requires -Version 7.0
param([string]$Frontend='frontend-06',[int]$Attempt=67,[ValidateSet('all','model')][string]$StartFrom='all')
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_pointer_receive166'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
$version=$Frontend.Replace('frontend-','')
if($StartFrom -eq 'all'){
 & "$stage/reference-span.ps1" -Frontend $Frontend -Label "reference-span-$version"
 & "$stage/receive-span.ps1" -Frontend $Frontend -Label "receive-span-$version"
 & "$stage/pointer.ps1" -Frontend $Frontend -Label "pointer-$version"
}
& "$stage/model.ps1" -Frontend $Frontend -Label "model-$version"
& "$stage/source-value.ps1" -Frontend $Frontend -Label "source-value-$version"
& "$stage/source-record.ps1" -Frontend $Frontend -Label "source-record-$version"
& "$stage/call-route.ps1" -Frontend $Frontend -Label "call-route-$version"
& "$stage/call-route.ps1" -Frontend $Frontend -Label "receive-route-$version" -Sources @('machine-values','letter-receiving')
& "$stage/regress.ps1" -Frontend $Frontend -Attempt $Attempt -StartFrom site
& "$stage/regress-values.ps1" -Frontend $Frontend -Attempt $Attempt
foreach($case in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23},@{Source='source-mapped';Bodies=1})){
 & "$stage/named-values.ps1" -Frontend $Frontend -Label ($case.Source+'-166') -SourceFile ($case.Source+'.lm2') -ForcedBodies $case.Bodies
}
& "$stage/letter-observe.ps1" -Frontend $Frontend -Label "letter-current-$version"
& "$stage/source-route.ps1" -Frontend $Frontend -Label "source-route-$version"
Write-Output 'VERIFY166 exact frontend selected regressions TERMINAL;not whole closure'
