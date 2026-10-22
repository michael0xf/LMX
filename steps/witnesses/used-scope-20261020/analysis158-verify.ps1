param([string]$StartFrom='profiles')
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_analysis_children158'
$started=$false
foreach($job in @(
 @{Name='fixtures';Label='fixtures-05'},
 @{Name='profiles';Label='profiles-01'},
 @{Name='root-test';Label='root-01';OnlyCurrent=$true},
 @{Name='native-test';Label='native-01';OnlyCurrent=$true},
 @{Name='check-compat';Label='check-01';OnlyCurrent=$true},
 @{Name='routes';Label='routes-01'},
 @{Name='negatives';Label='negatives-01'},
 @{Name='extra-controls';Label='extra-01'},
 @{Name='values';Label='values-01';Routes='routes-01'},
 @{Name='aux-values';Label='aux-01'},
 @{Name='constants';Label='constants-01'},
 @{Name='method-values';Label='method-01'},
 @{Name='machine-values';Label='machine-01'}
)){
 if($job.Name -eq $StartFrom){$started=$true}
 if(-not $started){continue}
 $params=@{Label=$job.Label;Frontend='frontend-01'}
 if($job.OnlyCurrent){$params.OnlyCurrent=$true}
 if($job.Routes){$params.Routes=$job.Routes}
 & "$stage/$($job.Name).ps1" @params
}
