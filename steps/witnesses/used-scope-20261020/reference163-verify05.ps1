#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_reference_values163'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/source-value.ps1" -Frontend frontend-05 -Label source-value-05
& "$stage/source-record.ps1" -Frontend frontend-05 -Label source-record-05
& "$stage/regress.ps1" -Frontend frontend-05 -Attempt 63 -SkipCorpus
foreach($case163 in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23})){
 & "$stage/named-values.ps1" -Frontend frontend-05 -Label ($case163.Source+'-163') -SourceFile ($case163.Source+'.lm2') -ForcedBodies $case163.Bodies
}
& "$stage/regress-values.ps1" -Frontend frontend-05 -Attempt 63
Write-Output 'VERIFY163 frontend05 selected regressions TERMINAL;corpus85 in values-05 is checked separately;not whole closure'
