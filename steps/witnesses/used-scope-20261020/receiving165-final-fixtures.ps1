#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_reference_receive165'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/receive-span.ps1" -Frontend frontend-02 -Label receive-span-02
& "$stage/named-values.ps1" -Frontend frontend-02 -Label letter-asserted-02 -SourceFile letter-asserted.lm2 -ForcedBodies 1
& "$stage/named-values.ps1" -Frontend frontend-02 -Label letter-parent-02 -SourceFile letter-receiving.lm2 -ForcedBodies 2 -CompilerPath 'C:/Nyasha_Planet/LMX/build2/codex_candidate_values164/frontend-08/l2trans.exe'
& "$stage/named-values.ps1" -Frontend frontend-02 -Label asserted-parent-02 -SourceFile letter-asserted.lm2 -ForcedBodies 1 -CompilerPath 'C:/Nyasha_Planet/LMX/build2/codex_candidate_values164/frontend-08/l2trans.exe'
Write-Output 'RECEIVE165 extra ownership and actual letter comparisons TERMINAL'
