#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_application_sites162'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/regress.ps1" -Frontend frontend-24 -Attempt 25 -StartFrom site
foreach($case162 in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11})){
 & "$stage/named-values.ps1" -Frontend frontend-24 -Label ($case162.Source+'-125') -SourceFile ($case162.Source+'.lm2') -ForcedBodies $case162.Bodies
}
& "$stage/regress-values.ps1" -Frontend frontend-24 -Attempt 25
& "$stage/named-values.ps1" -Frontend frontend-24 -Label held-free-names-125 -SourceFile held-free-names.lm2 -ForcedBodies 23
