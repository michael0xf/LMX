#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$dest="$repo/steps/witnesses/used-scope-20261020";$stage="$repo/build2/codex_pointer_receive166"
function Hash166([string]$Path){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};$absolute=[IO.Path]::GetFullPath($Path);$forbidden=[IO.Path]::GetFullPath("$repo/build")+'\';if($absolute.StartsWith($forbidden,[StringComparison]::OrdinalIgnoreCase)){throw 'Old build IO forbidden'};(Get-FileHash -LiteralPath $absolute).Hash}
function Require166([string]$Path,[string]$Expected){if(-not $Expected -or (Hash166 $Path) -cne $Expected){throw "Observed identity mismatch: $Path"}}
$e=Get-Content -LiteralPath "$dest/pointer166-evidence.json" -Raw|ConvertFrom-Json
foreach($item in @(@{Name='u0.patch';Sha=$e.SourcePatchSha256},@{Name='inputs.json';Sha=$e.ManifestSha256},@{Name='results.json';Sha=$e.ResultsSha256},@{Name='artifacts.json';Sha=$e.ArtifactsSha256},@{Name='history.json';Sha=$e.HistorySha256})){Require166 "$dest/pointer166-$($item.Name)" $item.Sha}
Require166 "$dest/receiving165-evidence.json" $e.ParentReceiptSha256
foreach($p in $e.PublishedFiles.PSObject.Properties){Require166 "$dest/$($p.Value.Path)" $p.Value.Sha256;Require166 "$stage/$($p.Name)" $p.Value.Sha256}
$inputs=Get-Content -LiteralPath "$dest/pointer166-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281 -or -not $e.U0ReplayExact -or -not $e.HeaderReplayExact){throw 'Missing exact source closure'}
foreach($p in $inputs){Require166 "$stage/$($p.Path)" $p.Sha256}
Require166 "$stage/src/l2src/l2trans.lm1" $e.SourceSha256;Require166 "$stage/frontend-06/frontend-source.lm1" $e.SourceSha256;Require166 "$stage/frontend-06/frontend.c" $e.FrontendCSha256;Require166 "$stage/frontend-06/l2trans.exe" $e.FrontendExeSha256
$pins=Get-Content -LiteralPath "$dest/pointer166-artifacts.json" -Raw|ConvertFrom-Json
if($pins.Count -ne $e.ArtifactPins){throw 'Artifact inventory count changed'}
foreach($p in $pins){Require166 $p.Path $p.Sha256}
$r=Get-Content -LiteralPath "$dest/pointer166-results.json" -Raw|ConvertFrom-Json
$history=Get-Content -LiteralPath "$dest/pointer166-history.json" -Raw|ConvertFrom-Json
Require166 "$stage/pointer-06b/fixture.c" $r.pointer.FixtureSha256;Require166 "$stage/pointer-test.c" $r.pointer.FixtureSha256
foreach($p in $e.ExactResultSources.PSObject.Properties){$actual=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json;$record=$r.PSObject.Properties[$p.Name].Value;if(($actual|ConvertTo-Json -Depth 24 -Compress) -cne ($record|ConvertTo-Json -Depth 24 -Compress)){throw "Published result source differs: $($p.Name)"}}
foreach($assert in @(@{Key='model';Text='MODEL164: 45 checks, 0 failures'},@{Key='referenceSpan';Text='REFSPAN164: 21 checks, 0 failures'},@{Key='receiveSpan';Text='RECEIVE165: 50 checks, 0 failures'},@{Key='pointer';Text='POINTER166: 58 checks, 0 failures'},@{Key='sourceValue';Text='held values: 27 checks, 0 failures'},@{Key='sourceRecord';Text='record projection: 26 checks, 0 failures'},@{Key='site';Text='SITE162: 322 checks, 0 failures'},@{Key='primary';Text='ANALYSIS158: 291 checks, 0 failures'},@{Key='application';Text='APPLICATION161: 197 checks, 0 failures'},@{Key='root';Text='ROOT155: 150 checks, 0 failures'})){if($r.PSObject.Properties[$assert.Key].Value.Diagnostic -notmatch [regex]::Escape($assert.Text)){throw "Fixture assertion mismatch: $($assert.Key)"}}
if(@($r.profiles).Count -ne 17 -or @($r.profiles|Where-Object {-not $_.Success -or $_.FrontendSha256 -cne $e.FrontendCSha256}).Count){throw 'Exact17 profiles'}
if(@($r.corpusBuilds).Count -ne 85 -or @($r.corpusRuns).Count -ne 170 -or @($r.corpusRuns|Where-Object {-not $_.ObservationMatched}).Count -or @($r.corpusRuns|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Keep original162positive and8sameRED'}
foreach($b in $r.corpusBuilds){if($b.CompilerSha256 -cne $e.FrontendExeSha256 -or -not $b.FreshStrictO2){throw 'Corpus compiler identity'};Require166 "$($b.Stem).lm1" $b.GraphSha256;Require166 "$($b.Stem).c" $b.CSha256;Require166 "$($b.Stem).o" $b.ObjectSha256;Require166 "$($b.Stem).exe" $b.ExeSha256}
$currentUnits=85;$currentRuns=170;$oldUnits=0;$oldRuns=0;$oldCompiler=Hash166 "$repo/build2/codex_places152_runtime_11/frontend-values-02/l2trans.exe"
foreach($property in $r.PSObject.Properties|Where-Object {$_.Name -like '*Builds' -and $_.Name -ne 'corpusBuilds'}){
 $dir=$property.Name.Substring(0,$property.Name.Length-6);$runs=@($r.PSObject.Properties[$dir+'Runs'].Value)
 foreach($b in $property.Value){
  if($dir -eq 'aux-167'){$stem="$stage/$dir/$($b.Case)-$($b.Mode)";$graph=$b.GeneratedL1Sha256;$csha=$b.GeneratedCSha256;Require166 $b.Source $b.SourceSha256}
  elseif($dir -in @('constants-167','method-167','machine-167')){$stem="$stage/$dir/$($b.Case)-$($b.Tier)-$($b.Mode)";$graph=$b.GraphSha256;$csha=$b.CSha256;$source=switch($b.Case){text{"$repo/dev/l2src_sandbox/tests/unit_define_ccall.lm2"} shadow{"$stage/constant-shadow.lm2"} method{"$repo/buold_temp/codex_places152_method_address_09.lm2"} machine_nested{"$stage/machine-values.lm2"} default{throw 'Unknown actual comparative source'}};Require166 $source $b.SourceSha256}
  else{$stem="$stage/$dir/$($b.Mode)";$graph=$b.L1Sha256;$csha=$b.CSha256;Require166 "$stage/$dir/source.lm2" $b.SourceSha256}
  Require166 "$stem.lm1" $graph;Require166 "$stem.c" $csha;Require166 "$stem.o" $b.ObjectSha256
  $matching=@($runs|Where-Object {$_.Mode -eq $b.Mode -and (-not $b.Case -or $_.Case -eq $b.Case) -and (-not $b.Tier -or $_.Tier -eq $b.Tier)})
  foreach($run in $matching){if(-not $run.Success){throw 'Actual value changed'};Require166 "$stem-$($run.Runtime).exe" $run.ExeSha256}
  if($b.CompilerSha256 -ceq $e.FrontendExeSha256){$currentUnits++;$currentRuns+=$matching.Count}elseif($b.CompilerSha256 -ceq $oldCompiler){$oldUnits++;$oldRuns+=$matching.Count}else{throw 'Different comparative compiler'}
 }
}
if($currentUnits -ne $e.CurrentCompilerUnits -or $currentRuns -ne $e.CurrentCompilerRuntimeExecutions -or $oldUnits -ne $e.BaselineCompilerUnits -or $oldRuns -ne $e.BaselineCompilerRuns){throw 'Do not count baseline programs as current'}
foreach($row in $r.callRoute){$lanes=[regex]::Matches($row.Diagnostic,'(?m)^CALL162 (\S+) calls=(\d+) adapters=(\d+) fields=(\d+) old-spans=(\d+) synthetic-copies=(\d+) legacy-callables=(\d+) depth=(-?\d+)\r?$');if($lanes.Count -ne 6){throw 'Missing wrapper lanes'};foreach($lane in $lanes){foreach($i in 3..8){if([long]$lane.Groups[$i].Value){throw 'Original selected wrapper reparse'}}}}
$newReceiving=0;$parentCheck=0;$openCheck=0
foreach($row in $r.receiveRoute){$lanes=[regex]::Matches($row.Diagnostic,'(?m)^RECEIVE165 (\S+) calls=(\d+) raw-receiving=(\d+)\r?$');if($lanes.Count -ne 6){throw 'Missing receiving lanes'};foreach($lane in $lanes){$newReceiving+=[long]$lane.Groups[2].Value;if([long]$lane.Groups[3].Value){throw 'Held receiving reentered raw statement boundary'}};$check=[regex]::Match($row.Diagnostic,'(?m)^CALL162 CHECK calls=\d+ adapters=(\d+) fields=(\d+)');$openCheck+=[long]$check.Groups[1].Value}
foreach($row in $r.receiveParent){$check=[regex]::Match($row.Diagnostic,'(?m)^CALL162 CHECK calls=\d+ adapters=(\d+) fields=(\d+)');$parentCheck+=[long]$check.Groups[1].Value;Require166 "$repo/build2/codex_reference_receive165/frontend-02/frontend.c" $row.FrontendCSha256}
if($newReceiving -ne 24 -or $parentCheck -ne 8 -or $openCheck -ne 0){throw 'Measure24 held receiving calls and parent8/current0 CHECK adapters'}
foreach($row in $r.receiveRoute){$lanes=[regex]::Matches($row.Diagnostic,'(?m)^CALL162 (\S+) calls=(\d+) adapters=(\d+) fields=(\d+) old-spans=(\d+) synthetic-copies=(\d+) legacy-callables=(\d+) depth=(-?\d+)\r?$');if($lanes.Count -ne 6){throw 'Extended wrapper lanes'};foreach($lane in $lanes){foreach($i in 3..8){if([long]$lane.Groups[$i].Value){throw 'Extended wrapper reparse/fallback'}}}}
Require166 "$dest/receiving165-history.json" $e.ParentHistorySha256
foreach($extra in $r.additional){
 if($extra.ExpectedEntry -ne 7 -or $extra.RefusalOracle){throw 'Preserve the positive expectation'}
 Require166 "$stage/$($extra.Source)" $extra.SourceSha256;Require166 "$stage/$($extra.Label)/source.lm2" $extra.SourceSha256
 if($extra.AllFullPositive){if(@($extra.Runs).Count -ne 8 -or @($extra.Runs|Where-Object {-not $_.Success}).Count -or $extra.StillOpen){throw 'A full positive needs all8 actual value/body observations'}}
 else{if(-not $extra.StillOpen -or -not @($extra.Runs|Where-Object {-not $_.Success}).Count){throw 'Open is not a refusal oracle or missing evidence'}}
 foreach($b in $extra.Compilation){$stem="$stage/$($extra.Label)/$($b.Mode)";if($b.CompilerSha256 -cne $e.FrontendExeSha256){throw 'Additional compiler identity'};Require166 "$stem.lm1" $b.L1Sha256;Require166 "$stem.c" $b.CSha256;Require166 "$stem.o" $b.ObjectSha256;foreach($run in @($extra.Runs|Where-Object Mode -eq $b.Mode)){Require166 "$stem-$($run.Runtime).exe" $run.ExeSha256}}
}
if($r.namedRefusals.Count -ne 44 -or @($r.namedRefusals|Where-Object {-not $_.ExactOldClassification}).Count -or $r.refusals.Count -ne 24 -or @($r.refusals|Where-Object {-not $_.OracleMatched}).Count){throw 'Original refusals changed'}
if($e.AllApplicationConsumers -or $e.AllPathClosure -or $e.FullKernelGate -or $e.SelfBuild -or $e.Mail -or $e.PublicDevIntegrated){throw 'Local slice is not whole closure'}
$sourceCalls=0;$sourceProjections=0
foreach($row in $r.sourceRoute){$m=[regex]::Match($row.Diagnostic,'(?m)^SOURCE163 calls=(\d+) projections=(\d+) raw=(\d+) adapters=(\d+) fields=(\d+) depth=(-?\d+)\r?$');if(-not $m.Success){throw 'Missing source counts'};foreach($i in 3..6){if([long]$m.Groups[$i].Value){throw 'Source query reparse/fallback'}};$sourceCalls+=[int]$m.Groups[1].Value;$sourceProjections+=[int]$m.Groups[2].Value}
if($sourceCalls -ne $e.SourceQueryCalls -or $sourceProjections -ne $e.SourceCoreProjections){throw 'Source query coverage identity'}
[pscustomobject]@{Audit='PASS';ArtifactPins=$pins.Count;Inputs=$inputs.Count;CurrentCompilerUnits=$currentUnits;CurrentRuns=$currentRuns;BaselineUnits=$oldUnits;BaselineRuns=$oldRuns;PreparedReceivingCalls=$newReceiving;ParentCheckAdapters=$parentCheck;CurrentCheckAdapters=$openCheck;FullGate=$false}|ConvertTo-Json
