#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_candidate_values164";$dest="$repo/steps/witnesses/used-scope-20261020"
function Pin164([string]$Path,[string]$Sha){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};if(-not $Sha -or (Get-FileHash -LiteralPath $Path).Hash -cne $Sha){throw "Pin mismatch: $Path"}}
$e=Get-Content -LiteralPath "$dest/candidate164-evidence.json" -Raw|ConvertFrom-Json
foreach($p in @(@{Name='results';Sha=$e.ResultsSha256},@{Name='inputs';Sha=$e.ManifestSha256},@{Name='artifacts';Sha=$e.ArtifactsSha256},@{Name='history';Sha=$e.HistorySha256})){Pin164 "$dest/candidate164-$($p.Name).json" $p.Sha}
Pin164 "$dest/candidate164-u0.patch" $e.SourcePatchSha256;Pin164 "$dest/reference163-evidence.json" $e.Parent163ReceiptSha256
$r=Get-Content -LiteralPath "$dest/candidate164-results.json" -Raw|ConvertFrom-Json
$inputs=Get-Content -LiteralPath "$dest/candidate164-inputs.json" -Raw|ConvertFrom-Json
$artifacts=Get-Content -LiteralPath "$dest/candidate164-artifacts.json" -Raw|ConvertFrom-Json
foreach($p in $inputs){Pin164 "$stage/$($p.Path)" $p.Sha256}
foreach($p in $artifacts){Pin164 $p.Path $p.Sha256}
foreach($p in $e.PublishedFiles.PSObject.Properties){Pin164 "$dest/$($p.Value.Path)" $p.Value.Sha256}
foreach($p in $e.ExactResultSources.PSObject.Properties){$actual=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json;if(($actual|ConvertTo-Json -Depth 24 -Compress) -cne ($r.($p.Name)|ConvertTo-Json -Depth 24 -Compress)){throw "Observed result changed: $($p.Name)"}}
if($inputs.Count -ne 281 -or $artifacts.Count -ne $e.ArtifactPins -or @($artifacts|Where-Object Role -eq 'corpus85').Count -ne 340){throw 'Independent source/generated artifact count'}
if($r.routes.Count -ne 85 -or $r.builds.Count -ne 85 -or $r.runs.Count -ne 170 -or @($r.runs|Where-Object {-not $_.ObservationMatched}).Count -or @($r.runs|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Exact selected corpus expectations'}
foreach($b in $r.builds){$route=@($r.routes|Where-Object Unit -eq $b.Unit);if($route.Count -ne 1 -or $route[0].CompilerSha256 -cne $e.FrontendExeSha256 -or $b.CompilerSha256 -cne $e.FrontendExeSha256 -or $route[0].GeneratedL1Sha256 -cne $b.GraphSha256 -or -not $b.FreshStrictO2){throw 'Generated program detached from the current compiler'}}
if($r.sourceValue.Exit -ne 0 -or $r.sourceValue.Diagnostic -notmatch 'held values: 27 checks, 0 failures' -or $r.sourceRecord.Exit -ne 0 -or $r.sourceRecord.Diagnostic -notmatch 'record projection: 26 checks, 0 failures'){throw 'New source semantics/lifetime assertions'}
if($r.site.Diagnostic -notmatch '322 checks, 0 failures' -or $r.primary.Diagnostic -notmatch '291 checks, 0 failures' -or $r.application.Diagnostic -notmatch '197 checks, 0 failures' -or $r.root.Diagnostic -notmatch '150 checks, 0 failures' -or $r.lifetimes.Count -ne 5){throw 'Original and strengthened compiler assertions'}
if($r.profiles.Count -ne 17 -or @($r.profiles|Where-Object {-not $_.Success}).Count -or $r.callRoute.Count -ne 14 -or $r.sourceRoute.Count -ne 22 -or $r.namedRefusals.Count -ne 44 -or @($r.namedRefusals|Where-Object {-not $_.ExactOldClassification}).Count){throw 'Profiles/routes/classifications'}
foreach($row in $r.callRoute){$lanes=[regex]::Matches($row.Diagnostic,'(?m)^CALL162 (\S+) calls=(\d+) adapters=(\d+) fields=(\d+) old-spans=(\d+) synthetic-copies=(\d+) legacy-callables=(\d+) depth=(-?\d+)\r?$');if($lanes.Count -ne 6){throw 'Missing call wrapper observation'};foreach($lane in $lanes){foreach($k in 3..8){if([long]$lane.Groups[$k].Value){throw 'Old call/parser fallback observed'}}}}
$calls=0;$projections=0
$modelCalls=0
foreach($row in $r.callRoute){$lanes=[regex]::Matches($row.Diagnostic,'(?m)^MODEL164 (\S+) calls=(\d+) raw-models=(\d+) raw-reference-values=(\d+) raw-reference-roots=(\d+)\r?$');if($lanes.Count -ne 6){throw 'Missing Model wrapper observations'};foreach($lane in $lanes){$modelCalls+=[long]$lane.Groups[2].Value;foreach($k in 3..5){if([long]$lane.Groups[$k].Value){throw 'A prepared argument repeated raw Model/reference/root selection'}}}}
if($modelCalls -lt 1 -or $r.oldModelRoute.Diagnostic -notmatch 'raw-reference-values=4 raw-reference-roots=4'){throw 'Independent exercised before/after duplicate-root evidence'}
if($r.model.Exit -ne 0 -or $r.model.Diagnostic -notmatch 'MODEL164: 45 checks, 0 failures' -or $r.referenceSpan.Exit -ne 0 -or $r.referenceSpan.Diagnostic -notmatch 'REFSPAN164: 21 checks, 0 failures'){throw 'Candidate and reference projection assertions'}
if($r.modelClasses.Count -ne 24 -or @($r.modelClasses|Where-Object {$_.Tier -eq 'current' -and $_.RefusedKnownNumericAsGraph}).Count -ne 8 -or @($r.modelClasses|Where-Object {$_.Tier -eq 'early07' -and $_.Exit -eq 0}).Count -ne 8 -or @($r.modelClasses|Where-Object {$_.Tier -eq 'parent163' -and $_.RefusedKnownNumericAsGraph}).Count -ne 4){throw 'Keep measured early regression and general typed scalar correction'}
foreach($key in 'extraOpaqueCurrent','extraOpaqueParent'){if(@($r.($key)).Count -ne 4 -or @($r.($key)|Where-Object {-not $_.Success -or $_.Root -ne 0}).Count){throw 'Extra actual opaque value/body observations'}}
if(@($r.extraOpaqueRootComparison).Count -ne 2 -or @($r.extraOpaqueRootComparison|Where-Object {-not $_.KnownCapabilityRed -or $_.NormativeSuccess}).Count){throw 'The old/current forced-root positive remains OPEN'}
foreach($row in $r.sourceRoute){$m=[regex]::Match($row.Diagnostic,'(?m)^SOURCE163 calls=(\d+) projections=(\d+) raw=(\d+) adapters=(\d+) fields=(\d+) depth=(-?\d+)\r?$');if(-not $row.Success -or -not $m.Success){throw 'Source routing observation failed'};foreach($k in 3..6){if([long]$m.Groups[$k].Value){throw 'Raw source retry observed'}};$calls+=[long]$m.Groups[1].Value;$projections+=[long]$m.Groups[2].Value}
if($calls -lt 1 -or $projections -lt 1){throw 'Source result API was not actually exercised'}
$fresh=85;$actual=170;$currentUnits=85;$currentRuns=170
foreach($p in $r.PSObject.Properties){
 if($p.Name.EndsWith('Builds')){
  $fresh+=@($p.Value).Count;$runs=@($r.($p.Name.Substring(0,$p.Name.Length-6)+'Runs'))
  foreach($b in $p.Value){$isCurrent=$p.Name -eq 'aux-165Builds' -or $b.CompilerSha256 -ceq $e.FrontendExeSha256;if($isCurrent){++$currentUnits;$currentRuns+=@($runs|Where-Object {$_.Mode -eq $b.Mode -and (-not $b.Case -or $_.Case -eq $b.Case) -and (-not $b.Tier -or $_.Tier -eq $b.Tier)}).Count}}
 }
 if($p.Name.EndsWith('Runs')){$actual+=@($p.Value).Count;if(@($p.Value|Where-Object {-not $_.Success}).Count){throw 'Selected real value observation failed'}}
}
if($fresh -ne 145 -or $actual -ne 390 -or $currentUnits -ne 137 -or $currentRuns -ne 358 -or $currentUnits -ne $e.CurrentCompilerUnits -or $currentRuns -ne $e.CurrentCompilerRuntimeExecutions){throw 'Independent comparative/current execution inventory'}
if($r.auxRefusals.Count -ne 2 -or @($r.auxRefusals|Where-Object {-not $_.Success}).Count){throw 'Located genuine Array refusal'}
Pin164 "$stage/checkpoint-01/replay/src/l2src/l2trans.lm1" $e.SourceSha256
Pin164 "$stage/frontend-08/frontend-source.lm1" $e.SourceSha256
Pin164 "$stage/frontend-08/frontend.c" $e.FrontendCSha256
Pin164 "$stage/frontend-08/l2trans.exe" $e.FrontendExeSha256
if($e.AllPathClosure -or $e.AllApplicationConsumers -or $e.FullKernelGate -or $e.PublicDevIntegrated -or $e.SelfBuild -or $e.Mail -or -not $e.OldSyntheticCopierStillPresent){throw 'Do not promote this incremental source API to whole closure'}
[pscustomobject]@{Verified=$true;SourceInputs=$inputs.Count;ArtifactPins=$artifacts.Count;ComparativeUnits=$fresh;ComparativeRuns=$actual;CurrentCompilerUnits=$currentUnits;CurrentCompilerRuns=$currentRuns;SourceQueries=$calls;SourceProjections=$projections;AllPathClosure=$false}|ConvertTo-Json
