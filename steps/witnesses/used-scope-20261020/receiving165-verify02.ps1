#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_reference_receive165'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/reference-span.ps1" -Frontend frontend-02 -Label reference-span-02
& "$stage/model.ps1" -Frontend frontend-02 -Label model-02
& "$stage/source-value.ps1" -Frontend frontend-02 -Label source-value-02
& "$stage/source-record.ps1" -Frontend frontend-02 -Label source-record-02
& "$stage/regress.ps1" -Frontend frontend-02 -Attempt 65
& "$stage/regress-values.ps1" -Frontend frontend-02 -Attempt 65
foreach($case in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23},@{Source='source-mapped';Bodies=1})){
 & "$stage/named-values.ps1" -Frontend frontend-02 -Label ($case.Source+'-165') -SourceFile ($case.Source+'.lm2') -ForcedBodies $case.Bodies
}
& "$stage/source-route.ps1" -Frontend frontend-02 -Label source-route-02
Write-Output 'VERIFY165 frontend02 selected regressions TERMINAL;not whole closure'
