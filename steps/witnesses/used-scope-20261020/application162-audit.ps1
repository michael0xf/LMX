#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_application_sites162";$dest="$repo/steps/witnesses/used-scope-20261020"
function Pin162([string]$Path,[string]$Sha){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};if(-not $Sha -or (Get-FileHash -LiteralPath $Path).Hash -cne $Sha){throw "Pin mismatch: $Path"}}
$e=Get-Content -LiteralPath "$dest/application162-evidence.json" -Raw|ConvertFrom-Json
foreach($pair in @(@{Name='results';Sha=$e.ResultsSha256},@{Name='inputs';Sha=$e.ManifestSha256},@{Name='artifacts';Sha=$e.ArtifactsSha256},@{Name='history';Sha=$e.HistorySha256})){Pin162 "$dest/application162-$($pair.Name).json" $pair.Sha}
Pin162 "$dest/application162-u0.patch" $e.SourcePatchSha256;Pin162 "$dest/application161-evidence.json" $e.Parent161ReceiptSha256
$r=Get-Content -LiteralPath "$dest/application162-results.json" -Raw|ConvertFrom-Json
$inputs=Get-Content -LiteralPath "$dest/application162-inputs.json" -Raw|ConvertFrom-Json
$artifacts=Get-Content -LiteralPath "$dest/application162-artifacts.json" -Raw|ConvertFrom-Json
foreach($p in $inputs){Pin162 "$stage/$($p.Path)" $p.Sha256}
foreach($p in $artifacts){Pin162 $p.Path $p.Sha256}
foreach($p in $e.PublishedFiles.PSObject.Properties){Pin162 "$dest/$($p.Value.Path)" $p.Value.Sha256}
foreach($p in $e.ExactResultSources.PSObject.Properties){$original=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json;if(($original|ConvertTo-Json -Depth 24 -Compress) -cne ($r.($p.Name)|ConvertTo-Json -Depth 24 -Compress)){throw "Observed result changed: $($p.Name)"}}
if($inputs.Count -ne 281 -or $artifacts.Count -ne $e.ArtifactPins -or @($artifacts|Where-Object Role -eq 'corpus85/focus').Count -ne 344){throw 'Independent input/generated artifact count'}
if($r.builds.Count -ne 85 -or $r.runs.Count -ne 170 -or @($r.runs|Where-Object {-not $_.ObservationMatched}).Count -or @($r.runs|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Actual selected corpus expectations'}
if($r.auxRefusals.Count -ne 2 -or @($r.auxRefusals|Where-Object {-not $_.Success}).Count){throw 'Genuine Array refusal observations'}
if($r.heldReference.Count -ne 5 -or $r.heldReferenceComparison.Count -ne 8 -or @($r.heldReferenceComparison|Where-Object {-not $_.NormativeSuccess}).Count -ne 4){throw 'Keep extra held-reference observations separate from the successful selected gate'}
if($r.currentValueBaseline.Exit -ne 1 -or $r.currentValueBaseline.Diagnostic -notmatch 'exit 82, expected 7' -or $r.currentValueBaseline.Success){throw 'Old current-value positive remains a real measured RED'}
$fresh=85;$actual=170
foreach($p in $r.PSObject.Properties){if($p.Name.EndsWith('Builds') -and $p.Name -ne 'focusBuilds'){$fresh+=@($p.Value).Count};if($p.Name.EndsWith('Runs') -and $p.Name -ne 'focusRuns'){$actual+=@($p.Value).Count;if(@($p.Value|Where-Object {-not $_.Success}).Count){throw 'A selected real value observation failed'}}}
if($fresh -ne 145 -or $actual -ne 390 -or $fresh -ne $e.FreshStrictO2Units -or $actual -ne $e.ActualRuntimeExecutions){throw 'Independent selected actual inventory'}
if($r.site.Diagnostic -notmatch '322 checks, 0 failures' -or $r.primary.Diagnostic -notmatch '291 checks, 0 failures' -or $r.application.Diagnostic -notmatch '197 checks, 0 failures' -or $r.root.Diagnostic -notmatch '150 checks, 0 failures'){throw 'Original and strengthened compiler assertions'}
if($r.profiles.Count -ne 17 -or @($r.profiles|Where-Object {-not $_.Success}).Count -or $r.callRoute.Count -ne 18 -or $r.namedRefusals.Count -ne 44 -or @($r.namedRefusals|Where-Object {-not $_.ExactOldClassification}).Count){throw 'Profiles/call routes/located classifications'}
foreach($row in $r.callRoute){$lanes=[regex]::Matches($row.Diagnostic,'(?m)^CALL162 (\S+) calls=(\d+) adapters=(\d+) fields=(\d+) old-spans=(\d+) synthetic-copies=(\d+) legacy-callables=(\d+) depth=(-?\d+)\r?$');if($lanes.Count -ne 6){throw 'Missing wrapper observations'};foreach($lane in $lanes){foreach($field in 3..8){if([long]$lane.Groups[$field].Value){throw 'Old callable/parser fallback observed'}}}}
Pin162 "$stage/checkpoint-03/replay/src/l2src/l2trans.lm1" $e.SourceSha256
Pin162 "$stage/frontend-24/frontend-source.lm1" $e.SourceSha256
Pin162 "$stage/frontend-24/frontend.c" $e.FrontendCSha256
Pin162 "$stage/frontend-24/l2trans.exe" $e.FrontendExeSha256
$history=Get-Content -LiteralPath "$dest/application162-history.json" -Raw|ConvertFrom-Json
if(@($history.candidate22RuntimeRed|Where-Object {$_.Unit -eq 27 -and $_.ActualExit -eq 3 -and -not $_.ObservationMatched}).Count -ne 1){throw 'Preserve the actual early-map regression,not a replacement oracle'}
if($e.AllPathClosure -or $e.AllApplicationConsumers -or $e.FullKernelGate -or $e.PublicDevIntegrated -or $e.SelfBuild -or $e.Mail -or -not $e.OldSyntheticCopierStillPresent){throw 'Do not promote this verified slice to whole closure'}
[pscustomobject]@{Verified=$true;SourceInputs=$inputs.Count;ArtifactPins=$artifacts.Count;FreshStrictO2Units=$fresh;ActualRuntimeExecutions=$actual;RootAssertions=150;AllPathClosure=$false}|ConvertTo-Json
