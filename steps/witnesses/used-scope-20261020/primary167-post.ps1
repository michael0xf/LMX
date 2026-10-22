#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_primary_projection167'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/projection.ps1" -Label projection-parent-02 -Baseline
Write-Output 'POST167 same-source exact-type and COUNT/EMIT counterfactual TERMINAL'
