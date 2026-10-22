param([string]$StartFrom='fixtures')
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_primary_children160'
$started=$false
foreach($job in @(
 @{Name='fixtures';Label='fixtures-09'},
 @{Name='receive-values';Label='receive-values-08'},
 @{Name='receive-values';Label='receive-hidden-02';SourceFile='receive-hidden.lm2';ForcedBodies=1},
 @{Name='receive-values';Label='receive-actual-03';SourceFile='receive-actual.lm2';ForcedBodies=1},
 @{Name='receive-values';Label='receive-foreign-01';SourceFile='receive-foreign.lm2';ForcedBodies=0},
 @{Name='receive-values';Label='receive-actual-old-01';SourceFile='receive-actual.lm2';ForcedBodies=1;CompilerPath='C:/Nyasha_Planet/LMX/build2/codex_analysis_children158/frontend-01/l2trans.exe'},
 @{Name='receive-values';Label='receive-foreign-old-01';SourceFile='receive-foreign.lm2';ForcedBodies=0;CompilerPath='C:/Nyasha_Planet/LMX/build2/codex_analysis_children158/frontend-01/l2trans.exe'},
 @{Name='profiles';Label='profiles-05'},
 @{Name='root-test';Label='root-04';OnlyCurrent=$true},
 @{Name='native-test';Label='native-04';OnlyCurrent=$true},
 @{Name='check-compat';Label='check-04';OnlyCurrent=$true},
 @{Name='negatives';Label='negatives-04'},
 @{Name='extra-controls';Label='extra-04'},
 @{Name='routes';Label='routes-05'},
 @{Name='values';Label='values-04';Routes='routes-05'},
 @{Name='aux-values';Label='aux-04'},
 @{Name='constants';Label='constants-03'},
 @{Name='method-values';Label='method-03'},
 @{Name='machine-values';Label='machine-03'},
 @{Name='primary';Label='primary-06'}
)){
 if($job.Name -eq $StartFrom){$started=$true}
 if(-not $started){continue}
 $params=@{Label=$job.Label;Frontend='frontend-04'}
 if($job.OnlyCurrent){$params.OnlyCurrent=$true}
 if($job.Routes){$params.Routes=$job.Routes}
 if($job.SourceFile){$params.SourceFile=$job.SourceFile;$params.ForcedBodies=$job.ForcedBodies}
 if($job.CompilerPath){$params.CompilerPath=$job.CompilerPath}
 & "$stage/$($job.Name).ps1" @params
}
