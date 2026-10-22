#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_unevaluated169";$dest="$repo/steps/witnesses/used-scope-20261020"
function Require169([string]$Path,[string]$Expected){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};$full=[IO.Path]::GetFullPath($Path);if($full.StartsWith([IO.Path]::GetFullPath("$repo/build")+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Old build IO forbidden'};if(-not $Expected -or (Get-FileHash -LiteralPath $full).Hash -cne $Expected){throw "Identity mismatch: $Path"}}
$e=Get-Content -LiteralPath "$dest/unevaluated169-evidence.json" -Raw|ConvertFrom-Json
foreach($p in @(@{Name='u0.patch';Sha=$e.SourcePatchSha256},@{Name='inputs.json';Sha=$e.ManifestSha256},@{Name='results.json';Sha=$e.ResultsSha256},@{Name='artifacts.json';Sha=$e.ArtifactsSha256})){Require169 "$dest/unevaluated169-$($p.Name)" $p.Sha}
Require169 "$dest/storage168-evidence.json" $e.ParentReceiptSha256
foreach($p in $e.PublishedFiles.PSObject.Properties){Require169 "$dest/$($p.Value.Path)" $p.Value.Sha256;Require169 "$stage/$($p.Name)" $p.Value.Sha256}
$inputs=Get-Content -LiteralPath "$dest/unevaluated169-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281 -or -not $e.U0ReplayExact -or -not $e.HeaderReplayExact -or @($e.ChangedInputs).Count -ne 3){throw 'Exact source closure/replay required'}
foreach($p in $inputs){Require169 "$stage/$($p.Path)" $p.Sha256}
Require169 "$stage/src/l2src/l2trans.lm1" $e.SourceSha256;Require169 "$stage/$($e.Frontend)/frontend-source.lm1" $e.SourceSha256;Require169 "$stage/$($e.Frontend)/frontend.c" $e.FrontendCSha256;Require169 "$stage/$($e.Frontend)/l2trans.exe" $e.FrontendExeSha256
Require169 "$repo/build2/codex_primary_contract168/src/l2src/l2trans.lm1" $e.ParentSourceSha256
$pins=Get-Content -LiteralPath "$dest/unevaluated169-artifacts.json" -Raw|ConvertFrom-Json
if($pins.Count -ne $e.ArtifactPins){throw 'Artifact count mismatch'}
foreach($p in $pins){Require169 $p.Path $p.Sha256}
$r=Get-Content -LiteralPath "$dest/unevaluated169-results.json" -Raw|ConvertFrom-Json
foreach($p in $e.ExactResultSources.PSObject.Properties){$actual=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json;if(($actual|ConvertTo-Json -Depth 24 -Compress) -cne ($r.PSObject.Properties[$p.Name].Value|ConvertTo-Json -Depth 24 -Compress)){throw "Exact result source mismatch $($p.Name)"}}
# The SAME unevaluated fixture: current169 green, the eager parent168 red on the SAME oracles.
$current=$r.unevaluated;$parent=$r.unevaluatedParent;$tag=$e.ExactResultSources.unevaluated.Split('/')[0]
Require169 "$stage/unevaluated-test.c" $current.FixtureSha256;Require169 "$stage/$tag/fixture.c" $current.FixtureSha256;Require169 "$stage/$($e.ExactResultSources.unevaluatedParent.Split('/')[0])/fixture.c" $current.FixtureSha256
if($current.Exit -ne 0 -or $current.FrontendCSha256 -cne $e.FrontendCSha256 -or $parent.Exit -ne 1 -or $parent.FrontendCSha256 -ceq $e.FrontendCSha256 -or $parent.FixtureSha256 -cne $current.FixtureSha256){throw 'Exact same-source current/parent observation required'}
$lines=[regex]::Matches($current.Diagnostic,'(?m)^UNEVALUATED169 (check|native|count|emit) case=\d+ status=0 .*?parsers=(\d+) roots=(\d+) folds=(\d+) raw=(\d+).*$')
if($lines.Count -ne 40 -or $current.Diagnostic -notmatch 'UNEVALUATED169: 100 checks, 0 failures'){throw 'All held unevaluated observations required'}
foreach($line in $lines){foreach($i in 2..5){if([int]$line.Groups[$i].Value){throw 'A held projection retried source parsing/resolution'}}}
if([regex]::Matches($current.Diagnostic,'native case=\d+ status=0 output-bytes=0 evaluations=1 temps=0 new-temp-numbers=0 publications=0 ').Count -ne 10){throw 'The C operator must write no statement, temporary or publication'}
if([regex]::Matches($parent.Diagnostic,'native case=\d+ status=0 output-bytes=[1-9]').Count -lt 1 -or $parent.Diagnostic -notmatch 'UNEVALUATED169: 60 checks, 20 failures'){throw 'Preserve the measured eager counterfactual'}
foreach($kind in 'sizeof','address'){$rec=$r.PSObject.Properties[$kind].Value;Require169 "$stage/$kind-test.c" $rec.FixtureSha256;if($rec.Exit -ne 0 -or $rec.FrontendCSha256 -cne $e.FrontendCSha256){throw "Inherited $kind fixture"}}
if($r.corpusBuilds.Count -ne 85 -or $r.corpusRuns.Count -ne 170 -or @($r.corpusRuns|Where-Object {-not $_.ObservationMatched}).Count -or @($r.corpusRuns|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Original corpus values and8oldRED must remain explicit'}
foreach($b in $r.corpusBuilds){if($b.CompilerSha256 -cne $e.FrontendExeSha256 -or -not $b.FreshStrictO2){throw 'Exact corpus compiler required'};Require169 "$($b.Stem).lm1" $b.GraphSha256;Require169 "$($b.Stem).c" $b.CSha256;Require169 "$($b.Stem).o" $b.ObjectSha256;Require169 "$($b.Stem).exe" $b.ExeSha256}
$counts=@{current=@{Units=0;Runs=0};old152=@{Units=0;Runs=0};parent168=@{Units=0;Runs=0}}
$compilers=@{current=$e.FrontendExeSha256;old152=(Get-FileHash -LiteralPath "$repo/build2/codex_places152_runtime_11/frontend-values-02/l2trans.exe").Hash;parent168=(Get-FileHash -LiteralPath "$repo/build2/codex_primary_contract168/frontend-06/l2trans.exe").Hash}
function Count169($Build,$Runs){if(-not $Build.FreshStrictO2 -and -not $Build.FreshStrictO2Unit){throw 'Fresh strictO2 required'};foreach($run in $Runs){if(-not $run.Success){throw 'Actual value/body observation failed'}};$tier=@($compilers.Keys|Where-Object {$compilers[$_] -ceq $Build.CompilerSha256});if($tier.Count -ne 1){throw 'Unknown comparative compiler'};$counts[$tier[0]].Units++;$counts[$tier[0]].Runs+=@($Runs).Count}
$counts.current.Units+=$r.corpusBuilds.Count;$counts.current.Runs+=$r.corpusRuns.Count
# A comparative directory is named by the evidence, not by a name prefix:
# the program directory machine-unevaluated-open-* is a positive one.
$comparative=@($e.ComparativeValueDirectories)
foreach($dir in @($e.PositiveValueDirectories)+$comparative){
 $runs=@($r.PSObject.Properties[$dir+'Runs'].Value)
 foreach($b in $r.PSObject.Properties[$dir+'Builds'].Value){
  if($dir -in $comparative -and $dir -like 'aux-*'){$stem="$stage/$dir/$($b.Case)-$($b.Mode)";$graph=$b.GeneratedL1Sha256;$csha=$b.GeneratedCSha256;Require169 $b.Source $b.SourceSha256}
  elseif($dir -in $comparative){$stem="$stage/$dir/$($b.Case)-$($b.Tier)-$($b.Mode)";$graph=$b.GraphSha256;$csha=$b.CSha256;$source=switch($b.Case){text{"$repo/dev/l2src_sandbox/tests/unit_define_ccall.lm2"} shadow{"$stage/constant-shadow.lm2"} method{"$repo/buold_temp/codex_places152_method_address_09.lm2"} machine_nested{"$stage/machine-values.lm2"} default{throw 'Unknown comparative source'}};Require169 $source $b.SourceSha256}
  else{$stem="$stage/$dir/$($b.Mode)";$graph=$b.L1Sha256;$csha=$b.CSha256;Require169 "$stage/$dir/source.lm2" $b.SourceSha256}
  Require169 "$stem.lm1" $graph;Require169 "$stem.c" $csha;Require169 "$stem.o" $b.ObjectSha256
  $matching=@($runs|Where-Object {$_.Mode -eq $b.Mode -and (-not $b.Case -or $_.Case -eq $b.Case) -and (-not $b.Tier -or $_.Tier -eq $b.Tier)})
  foreach($run in $matching){Require169 "$stem-$($run.Runtime).exe" $run.ExeSha256};Count169 $b $matching
 }
}
foreach($dir in $e.ProgramDirectories){$src=$dir -replace '-\d+$','';if($dir -like 'machine-unevaluated-open-*'){$src='machine-unevaluated-open'};Require169 "$stage/$src.lm2" (Get-FileHash -LiteralPath "$stage/$dir/source.lm2").Hash}
foreach($b in $r.controlBuilds){Require169 $b.Source $b.SourceSha256;foreach($p in @(@{Ext='lm1';Hash=$b.L1Sha256},@{Ext='c';Hash=$b.CSha256},@{Ext='o';Hash=$b.ObjectSha256},@{Ext='exe';Hash=$b.ExeSha256})){Require169 "$($b.Stem).$($p.Ext)" $p.Hash};$matching=@($r.controlRuns|Where-Object {$_.Case -eq $b.Case -and $_.Tier -eq $b.Tier -and $_.Mode -eq $b.Mode -and $_.Success});Count169 $b $matching}
if($counts.current.Units -ne $e.CurrentCompilerUnits -or $counts.current.Runs -ne $e.CurrentCompilerRuntimeExecutions -or $counts.old152.Units -ne $e.Baseline152CompilerUnits -or $counts.old152.Runs -ne $e.Baseline152Runs -or $counts.parent168.Units -ne $e.Parent168CompilerUnits -or $counts.parent168.Runs -ne $e.Parent168Runs){throw 'Do not mix current and baseline results or OPEN failures'}
# Historical controls: no positive regression; a shared refusal keeps its text.
foreach($group in $r.controlRoutes|Group-Object Case,Mode){$old=@($group.Group|Where-Object Tier -eq 'parent168');$now=@($group.Group|Where-Object Tier -eq 'current169');if($old.Count -ne 1 -or $now.Count -ne 1 -or ($old[0].Exit -eq 0 -and $now[0].Exit -ne 0) -or ($old[0].Exit -ne 0 -and $now[0].Exit -ne 0 -and $old[0].Diagnostic -cne $now[0].Diagnostic)){throw 'A historical source regressed; never rewrite a positive as a refusal'}}
foreach($group in $r.controlRuns|Group-Object Case,Mode,Root){$old=@($group.Group|Where-Object Tier -eq 'parent168');$now=@($group.Group|Where-Object Tier -eq 'current169');if($old.Count -ne 1 -or $now.Count -ne 1 -or ($old[0].Success -and -not $now[0].Success)){throw 'Historical positive execution regressed'}}
foreach($row in $r.controls){Require169 $row.Source $row.SourceSha256}
if(@($r.mutants).Count -ne 73 -or @($r.mutants|Where-Object MustBeRed).Count -ne 10 -or @($r.mutants|Where-Object {$_.MustBeRed -and -not $_.Red}).Count -or @($r.mutants|Where-Object Tier -eq 'real').Count -ne 12 -or @($r.mutants|Where-Object {$_.Tier -eq 'real' -and ($_.Red -or $_.CompilerSha256 -cne $e.FrontendExeSha256)}).Count){throw 'Mutants must reach and redden; the real frontend must keep the witnesses green'}
$mutantDir=$e.ExactResultSources.mutants.Split('/')[0]
foreach($row in $r.mutants){Require169 "$stage/$($row.Witness).lm2" $row.WitnessSha256;if($row.Tier -ne 'real'){Require169 "$stage/$mutantDir/$($row.Mutant)/l2trans.exe" $row.CompilerSha256}}
# The SAME program and its c.sizeof(c.int) control: equal on current169, measurably unequal on the eager parent168.
$controlDir=$e.ExactResultSources.shapes.Split('/')[0]
if(@($r.shapes).Count -ne 12 -or @($r.shapes|Where-Object Tier -eq 'current169').Count -ne 6 -or @($r.shapes|Where-Object {$_.Tier -eq 'current169' -and (-not $_.Same -or $_.CompilerSha256 -cne $e.FrontendExeSha256)}).Count -or @($r.shapes|Where-Object {$_.Tier -eq 'parent168' -and ($_.Same -or $_.CompilerSha256 -cne $compilers.parent168)}).Count){throw 'No unevaluated call may reach a formal on current169'}
foreach($row in $r.shapes){Require169 "$stage/$controlDir/cases/$($row.Case).lm2" $row.ProgramSha256;Require169 "$stage/$controlDir/cases/$($row.Case)-control.lm2" $row.ControlSha256}
if(@($r.l1Classes).Count -ne 20 -or @($r.l1Classes|Where-Object {$_.Unexplained.Count -gt 0}).Count -or @($r.l1Classes|Where-Object {-not $_.Identical}).Count -ne 16){throw 'Every changed historical L1 line must stay classified'}
foreach($row in $r.l1Classes){$old=@($r.controlRoutes|Where-Object {$_.Case -eq $row.Case -and $_.Mode -eq $row.Mode -and $_.Tier -eq 'parent168'});$now=@($r.controlRoutes|Where-Object {$_.Case -eq $row.Case -and $_.Mode -eq $row.Mode -and $_.Tier -eq 'current169'});if($old[0].L1Sha256 -cne $row.ParentL1Sha256 -or $now[0].L1Sha256 -cne $row.CurrentL1Sha256){throw 'Classified bytes are not the routed bytes'}}
foreach($pair in @($r.controls|Where-Object Side -eq 'form'|Select-Object -ExpandProperty Pair|Sort-Object -Unique)){$form=@($r.controls|Where-Object {$_.Pair -eq $pair -and $_.Side -eq 'form' -and $_.Tier -eq 'current169'});$twins=@($r.controls|Where-Object {$_.Pair -eq $pair -and $_.Side -eq 'twin'});if($form.Count -ne 1 -or $form[0].Phase -notin @('L2','COMPILE') -or $twins.Count -ne 2 -or @($twins|Where-Object {$_.Phase -notin @('L2','COMPILE')}).Count){throw "Negative pair $pair"}}
foreach($dir in $e.ProgramDirectories){$runs=@($r.PSObject.Properties[$dir+'Runs'].Value);$want=8;if($dir -like 'unevaluated-entry-*'){$want=4};if($runs.Count -ne $want -or @($runs|Where-Object {-not $_.Success}).Count){throw "Unevaluated program $dir"}}
foreach($o in $r.parentObservations){if($o.SuccessfulRuns -eq $o.Runs -and -not @($o.FailedPhases).Count){throw 'A parent observation must stay OPEN,not green'};if($o.CompilerSha256 -cne $compilers.parent168){throw 'Parent observation compiler'}}
if($e.CDoorClosure -or $e.MacroActualsP4 -or $e.AllPrimaryClosure -or $e.AllApplicationConsumers -or $e.AllPathClosure -or $e.FullKernelGate -or $e.PublicDevIntegrated -or $e.SelfBuild -or $e.Mail){throw 'A local slice is not whole closure'}
[pscustomobject]@{Audit='PASS';ArtifactPins=$pins.Count;Inputs=$inputs.Count;UnevaluatedObservations=40;MutantRows=@($r.mutants).Count;ShapeRows=@($r.shapes).Count;CurrentUnits=$e.CurrentCompilerUnits;CurrentRuns=$e.CurrentCompilerRuntimeExecutions;Parent168Units=$e.Parent168CompilerUnits;Parent168Runs=$e.Parent168Runs;CDoorClosure=$false;FullGate=$false}|ConvertTo-Json
