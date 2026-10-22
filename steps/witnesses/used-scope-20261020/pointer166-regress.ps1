#requires -Version 7.0
param([string]$Frontend='frontend-13',[string]$StartFrom='call-route',[int]$Attempt=0,[switch]$SkipCorpus)
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_pointer_receive166'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline; preserve live work'}
$jobs=@(
 @{Name='call-route';Label='call-route-06'},
 @{Name='site';Label='site-04'},
 @{Name='primary';Label='primary-04'},
 @{Name='application';Label='application-03'},
 @{Name='fixtures';Label='fixtures-01'},
 @{Name='profiles';Label='profiles-01'},
 @{Name='root-test';Label='root-02';OnlyCurrent=$true},
 @{Name='native-test';Label='native-01';OnlyCurrent=$true},
 @{Name='check-compat';Label='check-01';OnlyCurrent=$true},
 @{Name='negatives';Label='negatives-01'},
 @{Name='extra-controls';Label='extra-01'},
 @{Name='named-refusals';Label='named-refusals-01'},
 @{Name='routes';Label='routes-10'},
 @{Name='values';Label='values-02';Routes='routes-10'},
 @{Name='named-values';Label='named-order-02';SourceFile='named-order.lm2';ForcedBodies=28},
 @{Name='named-values';Label='named-prefix-values-02';SourceFile='named-prefix.lm2';ForcedBodies=3},
 @{Name='named-values';Label='named-held-02';SourceFile='named-held.lm2';ForcedBodies=16},
 @{Name='named-values';Label='named-callable-01';SourceFile='named-callable.lm2';ForcedBodies=5},
 @{Name='named-values';Label='pending-call-02';SourceFile='pending-call.lm2';ForcedBodies=5},
 @{Name='named-values';Label='pending-composite-02';SourceFile='pending-composite.lm2';ForcedBodies=8}
)
$started=$false
foreach($job in $jobs){
 if($job.Name -eq $StartFrom){$started=$true}
 if(-not $started){continue}
 if($SkipCorpus -and $job.Name -in @('routes','values')){continue}
 $params=@{Label=$job.Label;Frontend=$Frontend}
 foreach($key in 'OnlyCurrent','Routes','SourceFile','ForcedBodies'){if($job.ContainsKey($key)){$params[$key]=$job[$key]}}
 if($Attempt -gt 0){$number=100+$Attempt;$params.Label=$params.Label -replace '[0-9]+$',"$number";if($params.ContainsKey('Routes')){$params.Routes=$params.Routes -replace '[0-9]+$',"$number"}}
 Write-Output "Verify $($job.Name) $($job.Label), $Frontend"
 & "$stage/$($job.Name).ps1" @params
}
