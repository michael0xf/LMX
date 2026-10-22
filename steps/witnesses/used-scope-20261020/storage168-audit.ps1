#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_contract168";$dest="$repo/steps/witnesses/used-scope-20261020"
function Require168([string]$Path,[string]$Expected){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};$full=[IO.Path]::GetFullPath($Path);if($full.StartsWith([IO.Path]::GetFullPath("$repo/build")+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Old build IO forbidden'};if(-not $Expected -or (Get-FileHash -LiteralPath $full).Hash -cne $Expected){throw "Identity mismatch: $Path"}}
$e=Get-Content -LiteralPath "$dest/storage168-evidence.json" -Raw|ConvertFrom-Json
foreach($p in @(@{Name='u0.patch';Sha=$e.SourcePatchSha256},@{Name='inputs.json';Sha=$e.ManifestSha256},@{Name='results.json';Sha=$e.ResultsSha256},@{Name='artifacts.json';Sha=$e.ArtifactsSha256})){Require168 "$dest/storage168-$($p.Name)" $p.Sha}
Require168 "$dest/primary167-evidence.json" $e.ParentReceiptSha256
foreach($p in $e.PublishedFiles.PSObject.Properties){Require168 "$dest/$($p.Value.Path)" $p.Value.Sha256;Require168 "$stage/$($p.Name)" $p.Value.Sha256}
$inputs=Get-Content -LiteralPath "$dest/storage168-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281 -or -not $e.U0ReplayExact -or -not $e.HeaderReplayExact){throw 'Exact source closure/replay required'}
foreach($p in $inputs){Require168 "$stage/$($p.Path)" $p.Sha256}
Require168 "$stage/src/l2src/l2trans.lm1" $e.SourceSha256;Require168 "$stage/frontend-06/frontend-source.lm1" $e.SourceSha256;Require168 "$stage/frontend-06/frontend.c" $e.FrontendCSha256;Require168 "$stage/frontend-06/l2trans.exe" $e.FrontendExeSha256
$pins=Get-Content -LiteralPath "$dest/storage168-artifacts.json" -Raw|ConvertFrom-Json
if($pins.Count -ne $e.ArtifactPins){throw 'Artifact count mismatch'}
foreach($p in $pins){Require168 $p.Path $p.Sha256}
$r=Get-Content -LiteralPath "$dest/storage168-results.json" -Raw|ConvertFrom-Json
foreach($p in $e.ExactResultSources.PSObject.Properties){$actual=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json;if(($actual|ConvertTo-Json -Depth 24 -Compress) -cne ($r.PSObject.Properties[$p.Name].Value|ConvertTo-Json -Depth 24 -Compress)){throw "Exact result source mismatch $($p.Name)"}}
foreach($kind in 'sizeof','address'){
 $current=$r.PSObject.Properties[$kind].Value;$parent=$r.PSObject.Properties[$kind+'Parent'].Value;$label=if($kind -eq 'sizeof'){'sizeof-07'}else{'address-06'}
 $parentLabel=if($kind -eq 'sizeof'){'sizeof-parent167-02'}else{'address-parent167-01'}
 Require168 "$stage/$kind-test.c" $current.FixtureSha256;Require168 "$stage/$label/fixture.c" $current.FixtureSha256;Require168 "$stage/$parentLabel/fixture.c" $current.FixtureSha256
 if($current.Exit -ne 0 -or $parent.Exit -ne 0 -or $current.FixtureSha256 -cne $parent.FixtureSha256 -or $current.FrontendCSha256 -cne $e.FrontendCSha256 -or $parent.FrontendCSha256 -ceq $e.FrontendCSha256){throw 'Exact same-source current/parent observation required'}
 $tag=$kind.ToUpper()+'168';$suffix=if($kind -eq 'sizeof'){'case=\d+'}else{'depth=\d+ spelling=\d+'};$wanted=if($kind -eq 'sizeof'){48}else{36};$checks=if($kind -eq 'sizeof'){72}else{54}
 $lines=[regex]::Matches($current.Diagnostic,"(?m)^$tag (check|native|count|emit) $suffix .*?parsers=(\d+) roots=(\d+) folds=(\d+) raw=(\d+)\r?$")
 if($lines.Count -ne $wanted -or $current.Diagnostic -notmatch "$tag`: $checks checks, 0 failures"){throw 'All strengthened held observations required'}
 foreach($line in $lines){foreach($i in 2..5){if([int]$line.Groups[$i].Value){throw 'A held projection retried source parsing/resolution'}}}
 if($kind -eq 'sizeof'){
  if([regex]::Matches($current.Diagnostic,'native case=\d+ status=0 output-bytes=0 evaluations=1').Count -ne 12 -or $parent.Diagnostic -notmatch 'parsers=[1-9]'){throw 'Storage query must NOT emit operand evaluation; preserve measured parser counterfactual'}
 }elseif($parent.Diagnostic -notmatch 'check depth=16 spelling=2 status=1 .*roots=1') {throw 'Ordinary deep address counterfactual required'}
}
if($r.early01.Exit -ne 1 -or $r.early01.Diagnostic -notmatch '42 checks, 20 failures' -or $r.early02.Exit -ne 1 -or $r.early02.Diagnostic -notmatch '42 checks, 3 failures' -or $r.intermediate03.FrontendCSha256 -ceq $e.FrontendCSha256){throw 'Do not hide earlier failures or count intermediate bytes as final'}
Require168 "$stage/opaque-address-test.c" $r.opaque.FixtureSha256
foreach($label in 'opaque-address-06','opaque-address-parent167-01','opaque-address-early04'){Require168 "$stage/$label/fixture.c" $r.opaque.FixtureSha256}
if($r.opaque.Exit -ne 0 -or $r.opaqueParent.Exit -ne 0 -or $r.opaque.FrontendCSha256 -cne $e.FrontendCSha256 -or $r.earlyOpaque04.Exit -ne 1 -or $r.earlyOpaque04.Diagnostic -notmatch '18 checks, 6 failures'){throw 'The SAME opaque-machine address fixture must preserve the04 regression and05 repair'}
foreach($key in 'opaque','opaqueParent'){$record=$r.PSObject.Properties[$key].Value;$lines=[regex]::Matches($record.Diagnostic,'(?m)^OPAQUE_ADDRESS168 (check|native|count|emit) case=\d+ status=0 .*?parsers=(\d+) roots=(\d+) folds=(\d+) raw=(\d+)\r?$');if($lines.Count -ne 12 -or $record.Diagnostic -notmatch '18 checks, 0 failures'){throw 'All opaque address projections required'};foreach($line in $lines){foreach($i in 2..5){if([int]$line.Groups[$i].Value){throw 'Opaque address reparsed or resolved again'}}}}
if($r.corpusBuilds.Count -ne 85 -or $r.corpusRuns.Count -ne 170 -or @($r.corpusRuns|Where-Object {-not $_.ObservationMatched}).Count -or @($r.corpusRuns|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Original corpus values and8oldRED must remain explicit'}
foreach($b in $r.corpusBuilds){if($b.CompilerSha256 -cne $e.FrontendExeSha256 -or -not $b.FreshStrictO2){throw 'Exact corpus compiler required'};Require168 "$($b.Stem).lm1" $b.GraphSha256;Require168 "$($b.Stem).c" $b.CSha256;Require168 "$($b.Stem).o" $b.ObjectSha256;Require168 "$($b.Stem).exe" $b.ExeSha256}
$counts=@{current=@{Units=85;Runs=170};old152=@{Units=0;Runs=0};parent167=@{Units=0;Runs=0}}
$compilers=@{current=$e.FrontendExeSha256;old152=(Get-FileHash -LiteralPath "$repo/build2/codex_places152_runtime_11/frontend-values-02/l2trans.exe").Hash;parent167=(Get-FileHash -LiteralPath "$repo/build2/codex_primary_projection167/frontend-05/l2trans.exe").Hash}
function Count168($Build,$Runs){if(-not $Build.FreshStrictO2 -and -not $Build.FreshStrictO2Unit){throw 'Fresh strictO2 required'};foreach($run in $Runs){if(-not $run.Success){throw 'Actual value/body observation failed'}};$tier=@($compilers.Keys|Where-Object {$compilers[$_] -ceq $Build.CompilerSha256});if($tier.Count -ne 1){throw 'Unknown comparative compiler'};$counts[$tier[0]].Units++;$counts[$tier[0]].Runs+=@($Runs).Count}
foreach($dir in @($e.PositiveValueDirectories)+@($e.ComparativeValueDirectories)){
 $runs=@($r.PSObject.Properties[$dir+'Runs'].Value)
 foreach($b in $r.PSObject.Properties[$dir+'Builds'].Value){
  if($dir -eq 'aux-106'){$stem="$stage/$dir/$($b.Case)-$($b.Mode)";$graph=$b.GeneratedL1Sha256;$csha=$b.GeneratedCSha256;Require168 $b.Source $b.SourceSha256}
  elseif($dir -in @('constants-106','method-106','machine-106')){$stem="$stage/$dir/$($b.Case)-$($b.Tier)-$($b.Mode)";$graph=$b.GraphSha256;$csha=$b.CSha256;$source=switch($b.Case){text{"$repo/dev/l2src_sandbox/tests/unit_define_ccall.lm2"} shadow{"$stage/constant-shadow.lm2"} method{"$repo/buold_temp/codex_places152_method_address_09.lm2"} machine_nested{"$stage/machine-values.lm2"} default{throw 'Unknown comparative source'}};Require168 $source $b.SourceSha256}
  else{$stem="$stage/$dir/$($b.Mode)";$graph=$b.L1Sha256;$csha=$b.CSha256;Require168 "$stage/$dir/source.lm2" $b.SourceSha256}
  Require168 "$stem.lm1" $graph;Require168 "$stem.c" $csha;Require168 "$stem.o" $b.ObjectSha256
  $matching=@($runs|Where-Object {$_.Mode -eq $b.Mode -and (-not $b.Case -or $_.Case -eq $b.Case) -and (-not $b.Tier -or $_.Tier -eq $b.Tier)})
  foreach($run in $matching){Require168 "$stem-$($run.Runtime).exe" $run.ExeSha256};Count168 $b $matching
 }
}
foreach($b in $r.storageBuilds){Require168 $b.Source $b.SourceSha256;foreach($p in @(@{Ext='lm1';Hash=$b.L1Sha256},@{Ext='c';Hash=$b.CSha256},@{Ext='o';Hash=$b.ObjectSha256},@{Ext='exe';Hash=$b.ExeSha256})){Require168 "$($b.Stem).$($p.Ext)" $p.Hash};$matching=@($r.storageRuns|Where-Object {$_.Case -eq $b.Case -and $_.Tier -eq $b.Tier -and $_.Mode -eq $b.Mode -and $_.Success});Count168 $b $matching}
if($counts.current.Units -ne $e.CurrentCompilerUnits -or $counts.current.Runs -ne $e.CurrentCompilerRuntimeExecutions -or $counts.old152.Units -ne $e.Baseline152CompilerUnits -or $counts.old152.Runs -ne $e.Baseline152Runs -or $counts.parent167.Units -ne $e.Parent167CompilerUnits -or $counts.parent167.Runs -ne $e.Parent167Runs){throw 'Do not mix current and baseline results or OPEN failures'}
if($r.storageRoutes.Count -ne 76){throw 'Historical translations missing'}
$aliasBefore=Get-Content -LiteralPath "$stage/storage-controls-01/routes.json" -Raw|ConvertFrom-Json
$aliasOld=@($aliasBefore|Where-Object {$_.Case -eq 'unit_sizeof_own_local' -and $_.Tier -eq 'current168' -and $_.Mode -eq 'native'})
$aliasNow=@($r.storageRoutes|Where-Object {$_.Case -eq 'unit_sizeof_own_local' -and $_.Tier -eq 'current168' -and $_.Mode -eq 'native'})
if($aliasOld.Count -ne 1 -or $aliasNow.Count -ne 1 -or $aliasOld[0].SourceSha256 -cne $aliasNow[0].SourceSha256 -or $aliasOld[0].CompilerSha256 -ceq $e.FrontendExeSha256 -or (Get-Content -LiteralPath "$stage/storage-controls-01/unit_sizeof_own_local-current168-native.COMPILE.log" -Raw) -notmatch 'error: .ulong. undeclared' -or @($r.storageRuns|Where-Object {$_.Case -eq 'unit_sizeof_own_local' -and -not $_.Success}).Count){throw 'Preserve the actual05 alias regression and06 strictO2/value repair on the SAME source'}
foreach($group in $r.storageRuns|Group-Object Case,Mode,Root){$old=@($group.Group|Where-Object Tier -eq 'parent167');$now=@($group.Group|Where-Object Tier -eq 'current168');if($old.Count -ne 1 -or $now.Count -ne 1 -or ($old[0].Success -and -not $now[0].Success)){throw 'Historical positive execution regressed'};if(-not $old[0].Success -and -not $now[0].Success -and ($old[0].Exit -ne $now[0].Exit -or $old[0].Diagnostic -cne $now[0].Diagnostic)){throw 'Changed historical OPEN failure is not certified equivalent'}}
if(@($r.storageRuns|Where-Object {$_.Tier -eq 'current168' -and -not $_.Success}).Count -ne $e.HistoricalOpenCurrentRuns -or @($r.storageRuns|Where-Object {$_.Tier -eq 'parent167' -and -not $_.Success}).Count -ne $e.HistoricalOpenParentRuns){throw 'Do not count historical OPEN failures as positive executions'}
foreach($group in $r.storageRoutes|Group-Object Case,Mode){$old=@($group.Group|Where-Object Tier -eq 'parent167');$now=@($group.Group|Where-Object Tier -eq 'current168');if($old.Count -ne 1 -or $now.Count -ne 1 -or ($old[0].Exit -eq 0 -and $now[0].Exit -ne 0)){throw 'A historical source regressed; never rewrite a positive as a refusal'}}
foreach($key in 'openParentRuns','openCurrentRuns'){if(@($r.PSObject.Properties[$key].Value).Count -ne 1 -or $r.PSObject.Properties[$key].Value[0].Success -or $r.PSObject.Properties[$key].Value[0].Diagnostic -notmatch 'UNEVALUATED168 result=88 touches=1'){throw 'The positive C-door counterexample must remain OPEN,not green'}}
if(@($r.'sizeof-values-06Runs').Count -ne 8 -or @($r.'sizeof-values-06Runs'|Where-Object {-not $_.Success}).Count -or @($r.'sizeof-values-06Runs'|Where-Object {$_.Runtime -eq 'observed' -and $_.Bodies -ne $_.Root}).Count){throw 'Need actual storage/address/no-evaluation values;machine-only methods are NOT walked proof'}
if(@($r.'projection-length-168-06Runs'|Where-Object {$_.Runtime -eq 'observed' -and $_.Mode -eq 'forced' -and $_.Bodies -ne $_.Root+1}).Count){throw 'Pure Array mapped/address program must actually walk'}
if($e.AllPrimaryClosure -or $e.AllApplicationConsumers -or $e.AllPathClosure -or $e.FullKernelGate -or $e.PublicDevIntegrated -or $e.SelfBuild -or $e.Mail){throw 'A local slice is not whole closure'}
[pscustomobject]@{Audit='PASS';ArtifactPins=$pins.Count;Inputs=$inputs.Count;StorageObservations=48;OrdinaryAddressObservations=36;CurrentUnits=$e.CurrentCompilerUnits;CurrentRuns=$e.CurrentCompilerRuntimeExecutions;AllPrimaryClosure=$false;FullGate=$false}|ConvertTo-Json
