param([string]$StartFrom='fixtures')
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_index_children157'
$started=$false
foreach($job in @(
 @{Name='fixtures';Label='fixtures-04'},
 @{Name='profiles';Label='profiles-04'},
 @{Name='root-test';Label='root-01';OnlyCurrent=$true},
 @{Name='native-test';Label='native-01';OnlyCurrent=$true},
 @{Name='check-compat';Label='check-01';OnlyCurrent=$true},
 @{Name='routes';Label='routes-03'},
 @{Name='negatives';Label='negatives-01'},
 @{Name='extra-controls';Label='extra-01'},
 @{Name='values';Label='values-01';Routes='routes-03'},
 @{Name='aux-values';Label='aux-01'},
 @{Name='constants';Label='constants-01'},
 @{Name='method-values';Label='method-01'},
 @{Name='machine-values';Label='machine-01'}
)){
 if($job.Name -eq $StartFrom){$started=$true}
 if(-not $started){continue}
 $params=@{Label=$job.Label;Frontend='frontend-07'}
 if($job.OnlyCurrent){$params.OnlyCurrent=$true}
 if($job.Routes){$params.Routes=$job.Routes}
 & "$stage/$($job.Name).ps1" @params
}
