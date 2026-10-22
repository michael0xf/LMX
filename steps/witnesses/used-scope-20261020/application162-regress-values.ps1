#requires -Version 7.0
param([string]$Frontend='frontend-13',[int]$Attempt=0)
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_application_sites162'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline; preserve live work'}
foreach($job in @(
 @{Name='aux-values';Label='aux-01'},
 @{Name='constants';Label='constants-01'},
 @{Name='method-values';Label='method-01'},
 @{Name='machine-values';Label='machine-01'},
 @{Name='receive-values';Label='receive-values-01';SourceFile='receive-values.lm2';ForcedBodies=6},
 @{Name='receive-values';Label='receive-hidden-01';SourceFile='receive-hidden.lm2';ForcedBodies=1},
 @{Name='receive-values';Label='receive-actual-01';SourceFile='receive-actual.lm2';ForcedBodies=1},
 @{Name='receive-values';Label='receive-foreign-01';SourceFile='receive-foreign.lm2';ForcedBodies=0}
)){
 $params=@{Label=$job.Label;Frontend=$Frontend}
 if($Attempt -gt 0){$number=100+$Attempt;$params.Label=$params.Label -replace '[0-9]+$',"$number"}
 foreach($key in 'SourceFile','ForcedBodies'){if($job.ContainsKey($key)){$params[$key]=$job[$key]}}
 Write-Output "Verify $($job.Name) $($job.Label), $Frontend"
 & "$stage/$($job.Name).ps1" @params
}
