#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_reference_receive165'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/call-route.ps1" -Frontend frontend-02 -Label call-route-02
& "$stage/regress.ps1" -Frontend frontend-02 -Attempt 66 -StartFrom site
& "$stage/named-values.ps1" -Frontend frontend-02 -Label letter-receiving-02 -SourceFile letter-receiving.lm2 -ForcedBodies 2
& "$stage/call-route.ps1" -Frontend frontend-02 -Label receive-route-02 -Sources @('machine-values','letter-receiving') -ObserveRemaining
& "$stage/call-route.ps1" -Frontend frontend-02 -Label receive-parent-02 -Sources @('machine-values','letter-receiving') -ObserveRemaining -Baseline -CompilerC 'C:/Nyasha_Planet/LMX/build2/codex_candidate_values164/frontend-08/frontend.c'
& "$stage/regress-values.ps1" -Frontend frontend-02 -Attempt 65
foreach($case in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23},@{Source='source-mapped';Bodies=1})){
 & "$stage/named-values.ps1" -Frontend frontend-02 -Label ($case.Source+'-165') -SourceFile ($case.Source+'.lm2') -ForcedBodies $case.Bodies
}
& "$stage/source-route.ps1" -Frontend frontend-02 -Label source-route-02
Write-Output 'VERIFY165 frontend02 selected regressions TERMINAL;not whole closure'
