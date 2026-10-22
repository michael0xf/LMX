#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_projection167";$dest="$repo/steps/witnesses/used-scope-20261020"
function Require167([string]$Path,[string]$Expected){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};$full=[IO.Path]::GetFullPath($Path);if($full.StartsWith([IO.Path]::GetFullPath("$repo/build")+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Old build IO forbidden'};if(-not $Expected -or (Get-FileHash -LiteralPath $full).Hash -cne $Expected){throw "Identity mismatch: $Path"}}
$e=Get-Content -LiteralPath "$dest/primary167-evidence.json" -Raw|ConvertFrom-Json
foreach($item in @(@{Name='u0.patch';Sha=$e.SourcePatchSha256},@{Name='inputs.json';Sha=$e.ManifestSha256},@{Name='results.json';Sha=$e.ResultsSha256},@{Name='artifacts.json';Sha=$e.ArtifactsSha256})){Require167 "$dest/primary167-$($item.Name)" $item.Sha}
Require167 "$dest/pointer166-evidence.json" $e.ParentReceiptSha256
foreach($p in $e.PublishedFiles.PSObject.Properties){Require167 "$dest/$($p.Value.Path)" $p.Value.Sha256;Require167 "$stage/$($p.Name)" $p.Value.Sha256}
$inputs=Get-Content -LiteralPath "$dest/primary167-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281 -or -not $e.U0ReplayExact -or -not $e.HeaderReplayExact){throw 'Exact source closure/replay required'}
foreach($p in $inputs){Require167 "$stage/$($p.Path)" $p.Sha256}
Require167 "$stage/src/l2src/l2trans.lm1" $e.SourceSha256;Require167 "$stage/frontend-05/frontend-source.lm1" $e.SourceSha256;Require167 "$stage/frontend-05/frontend.c" $e.FrontendCSha256;Require167 "$stage/frontend-05/l2trans.exe" $e.FrontendExeSha256
$pins=Get-Content -LiteralPath "$dest/primary167-artifacts.json" -Raw|ConvertFrom-Json
if($pins.Count -ne $e.ArtifactPins){throw 'Artifact count mismatch'}
foreach($p in $pins){Require167 $p.Path $p.Sha256}
$r=Get-Content -LiteralPath "$dest/primary167-results.json" -Raw|ConvertFrom-Json
foreach($p in $e.ExactResultSources.PSObject.Properties){$actual=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json;if(($actual|ConvertTo-Json -Depth 24 -Compress) -cne ($r.PSObject.Properties[$p.Name].Value|ConvertTo-Json -Depth 24 -Compress)){throw "Exact result source mismatch $($p.Name)"}}
Require167 "$stage/projection-test.c" $r.projection.FixtureSha256;Require167 "$stage/projection-06/fixture.c" $r.projection.FixtureSha256;Require167 "$stage/projection-parent-02/fixture.c" $r.projection.FixtureSha256
$lines=[regex]::Matches($r.projection.Diagnostic,'(?m)^PROJECTION167 (type|check|native|count|emit) case=\d+ .*?parsers=(\d+) roots=(\d+) folds=(\d+) raw=(\d+)\r?$')
if($lines.Count -ne 35 -or $r.projection.Diagnostic -notmatch 'PROJECTION167: 65 checks, 0 failures'){throw 'All held primary probes required'}
foreach($line in $lines){foreach($i in 2..5){if([int]$line.Groups[$i].Value){throw 'A prepared primary retried source parsing/resolution'}}}
if($r.allocation04.Exit -ne 1 -or $r.allocation04.Diagnostic -notmatch 'status=0 allocation-error=1 countdown=0' -or $r.projection.Diagnostic -notmatch 'unresolved Array under allocation refusal: status=1 allocation-error=0 countdown=1'){throw 'The same allocation control must prove the shared failed-type fix'}
if($r.projectionParent.FrontendCSha256 -ceq $e.FrontendCSha256 -or $r.projectionParent.Diagnostic -notmatch 'parsers=[1-9]' -or $r.projectionParent.Diagnostic -notmatch 'native case=0 status=1'){throw 'Need measured counterfactual,not an unchanged helper signature'}
if($r.corpusBuilds.Count -ne 85 -or $r.corpusRuns.Count -ne 170 -or @($r.corpusRuns|Where-Object {-not $_.ObservationMatched}).Count -or @($r.corpusRuns|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Original corpus values and8oldRED must remain explicit'}
foreach($b in $r.corpusBuilds){if($b.CompilerSha256 -cne $e.FrontendExeSha256 -or -not $b.FreshStrictO2){throw 'Exact corpus compiler required'};Require167 "$($b.Stem).lm1" $b.GraphSha256;Require167 "$($b.Stem).c" $b.CSha256;Require167 "$($b.Stem).o" $b.ObjectSha256;Require167 "$($b.Stem).exe" $b.ExeSha256}
$currentUnits=85;$currentRuns=170;$oldUnits=0;$oldRuns=0;$oldCompiler=(Get-FileHash -LiteralPath "$repo/build2/codex_places152_runtime_11/frontend-values-02/l2trans.exe").Hash
foreach($property in $r.PSObject.Properties|Where-Object {$_.Name -like '*Builds' -and $_.Name -ne 'corpusBuilds'}){
 $dir=$property.Name.Substring(0,$property.Name.Length-6);$runs=@($r.PSObject.Properties[$dir+'Runs'].Value)
 foreach($b in $property.Value){
  if(-not $b.FreshStrictO2 -and -not $b.FreshStrictO2Unit){throw 'Fresh strictO2 compilation required'}
  if($dir -eq 'aux-105'){$stem="$stage/$dir/$($b.Case)-$($b.Mode)";$graph=$b.GeneratedL1Sha256;$csha=$b.GeneratedCSha256;Require167 $b.Source $b.SourceSha256}
  elseif($dir -in @('constants-105','method-105','machine-105')){$stem="$stage/$dir/$($b.Case)-$($b.Tier)-$($b.Mode)";$graph=$b.GraphSha256;$csha=$b.CSha256;$source=switch($b.Case){text{"$repo/dev/l2src_sandbox/tests/unit_define_ccall.lm2"} shadow{"$stage/constant-shadow.lm2"} method{"$repo/buold_temp/codex_places152_method_address_09.lm2"} machine_nested{"$stage/machine-values.lm2"} default{throw 'Unknown comparative source'}};Require167 $source $b.SourceSha256}
  else{$stem="$stage/$dir/$($b.Mode)";$graph=$b.L1Sha256;$csha=$b.CSha256;Require167 "$stage/$dir/source.lm2" $b.SourceSha256;if($dir -in @('projection-machine-167-05','projection-length-167-05','source-mapped-167-05')){$name=$dir.Replace('-167-05','');Require167 "$stage/$name.lm2" $b.SourceSha256}}
  Require167 "$stem.lm1" $graph;Require167 "$stem.c" $csha;Require167 "$stem.o" $b.ObjectSha256
  $matching=@($runs|Where-Object {$_.Mode -eq $b.Mode -and (-not $b.Case -or $_.Case -eq $b.Case) -and (-not $b.Tier -or $_.Tier -eq $b.Tier)})
  foreach($run in $matching){if(-not $run.Success){throw 'Actual value/body observation failed'};Require167 "$stem-$($run.Runtime).exe" $run.ExeSha256}
  if($b.CompilerSha256 -ceq $e.FrontendExeSha256){$currentUnits++;$currentRuns+=$matching.Count}elseif($b.CompilerSha256 -ceq $oldCompiler){$oldUnits++;$oldRuns+=$matching.Count}else{throw 'Unknown comparative compiler'}
 }
}
if($currentUnits -ne $e.CurrentCompilerUnits -or $currentRuns -ne $e.CurrentCompilerRuntimeExecutions -or $oldUnits -ne $e.BaselineCompilerUnits -or $oldRuns -ne $e.BaselineCompilerRuns){throw 'Do not count baseline comparisons as current executions'}
foreach($key in 'projection-machine-167-05Runs','projection-length-167-05Runs','source-mapped-167-05Runs'){$runs=@($r.PSObject.Properties[$key].Value);if($runs.Count -ne 8 -or @($runs|Where-Object {-not $_.Success}).Count){throw 'Actual value/address/map witnesses required'}}
if(@($r.'projection-machine-167-05Runs'|Where-Object {$_.Runtime -eq 'observed' -and $_.Bodies -ne $_.Root}).Count){throw 'Machine-only method is not a walked proof'}
if(@($r.'projection-length-167-05Runs'|Where-Object {$_.Runtime -eq 'observed' -and $_.Mode -eq 'forced' -and $_.Bodies -ne $_.Root+1}).Count){throw 'Pure Array consumer must actually walk'}
foreach($key in 'callRoute','sourceRoute'){foreach($row in $r.PSObject.Properties[$key].Value){if($row.FrontendCSha256 -cne $e.FrontendCSha256 -or $row.Exit -ne 0){throw 'Current compiler identity required'}}}
if($e.AllPrimaryClosure -or $e.AllApplicationConsumers -or $e.AllPathClosure -or $e.FullKernelGate -or $e.PublicDevIntegrated -or $e.SelfBuild -or $e.Mail){throw 'A local slice is not whole closure'}
[pscustomobject]@{Audit='PASS';ArtifactPins=$pins.Count;Inputs=$inputs.Count;HeldPrimaryProjections=$lines.Count;CurrentUnits=$e.CurrentCompilerUnits;CurrentRuns=$e.CurrentCompilerRuntimeExecutions;AllPrimaryClosure=$false;FullGate=$false}|ConvertTo-Json
