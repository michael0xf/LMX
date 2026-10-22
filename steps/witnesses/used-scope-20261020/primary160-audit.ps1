#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_children160";$dest="$repo/steps/witnesses/used-scope-20261020"
function Pin160([string]$Path,[string]$Sha){
 if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if(-not $Sha -or (Get-FileHash -LiteralPath $Path).Hash -cne $Sha){throw "Artifact pin mismatch: $Path"}
}
$e=Get-Content -LiteralPath "$dest/primary160-evidence.json" -Raw|ConvertFrom-Json
Pin160 "$dest/primary160-results.json" $e.ResultsSha256
Pin160 "$dest/primary160-inputs.json" $e.ManifestSha256
Pin160 "$dest/primary160-artifacts.json" $e.ArtifactsSha256
Pin160 "$dest/primary160-u0.patch" $e.SourcePatchSha256
Pin160 "$dest/receive159-evidence.json" $e.Parent159ReceiptSha256
Pin160 "$dest/receive159-u0.patch" $e.Parent159PatchSha256
$r=Get-Content -LiteralPath "$dest/primary160-results.json" -Raw|ConvertFrom-Json
$inputs=Get-Content -LiteralPath "$dest/primary160-inputs.json" -Raw|ConvertFrom-Json
$artifacts=Get-Content -LiteralPath "$dest/primary160-artifacts.json" -Raw|ConvertFrom-Json
foreach($p in $inputs){Pin160 "$stage/$($p.Path)" $p.Sha256}
foreach($p in $artifacts){Pin160 $p.Path $p.Sha256}
foreach($p in $e.RecipeFiles.PSObject.Properties){Pin160 "$dest/$($p.Value.Path)" $p.Value.Sha256}
foreach($p in $e.PublishedSources.PSObject.Properties){Pin160 "$dest/$($p.Value.Path)" $p.Value.Sha256}
Pin160 "$stage/src/l2src/l2trans.lm1" $e.SourceSha256
Pin160 "$stage/frontend-04/frontend-source.lm1" $e.SourceSha256
Pin160 "$stage/frontend-04/frontend.c" $e.FrontendCSha256
Pin160 "$stage/frontend-04/l2trans.exe" $e.FrontendExeSha256
Pin160 "$stage/src/l2src/l2_application.h.lm1" $e.ApplicationSourceSha256
Pin160 "$stage/headers/l2src/l2_application.lm1.h" $e.ApplicationHeaderSha256
foreach($p in $e.ExactResultSources.PSObject.Properties){
 $original=Get-Content -LiteralPath "$stage/$($p.Value)" -Raw|ConvertFrom-Json
 if(($original|ConvertTo-Json -Depth 24 -Compress) -cne ($r.($p.Name)|ConvertTo-Json -Depth 24 -Compress)){throw "Packaged actual observation differs: $($p.Name)"}
}
if($inputs.Count -ne 281 -or $artifacts.Count -ne $e.ArtifactPins -or @($artifacts|Where-Object Role -eq 'corpus85').Count -ne 340){throw 'Independent input/artifact inventory'}
if($r.primary.Exit -ne 0 -or $r.primary.Diagnostic -notmatch 'ANALYSIS158: 199 checks, 0 failures' -or $r.primary.Diagnostic -notmatch 'constructor-sites=22 recursive-copy-sites=21'){throw 'Primary oracle'}
if($r.baseline.Exit -ne 1 -or $r.baseline.Diagnostic -notmatch 'ANALYSIS158: 82 checks, 2 failures'){throw 'Do not replace old positive assertions with refusals'}
if($r.profiles.Count -ne 17 -or @($r.profiles|Where-Object {-not $_.Success}).Count -or @($r.lifetimes|Where-Object Exit -ne 0).Count){throw 'Actual compiler assertions'}
if($r.builds.Count -ne 85 -or $r.runs.Count -ne 170 -or @($r.runs|Where-Object {-not $_.ObservationMatched}).Count -or @($r.runs|Where-Object {-not $_.Positive}).Count -ne 8){throw 'Actual corpus oracles'}
foreach($key in 'auxRuns','constantRuns','methodRuns','machineRuns','receivingRuns','hiddenRuns','actualRuns','oldActualRuns','foreignRuns','oldForeignRuns'){if(@($r.$key|Where-Object {-not $_.Success}).Count){throw "Actual value observation failed: $key"}}
if(@($r.refusals|Where-Object {-not $_.OracleMatched}).Count -or $r.refusals.Count -ne 24){throw 'Located negative oracles'}
$fresh=0;$actual=0;foreach($key in 'builds','auxBuilds','constantBuilds','methodBuilds','machineBuilds','receivingBuilds','hiddenBuilds','actualBuilds','oldActualBuilds','foreignBuilds','oldForeignBuilds'){$fresh+=@($r.$key).Count};foreach($key in 'runs','auxRuns','constantRuns','methodRuns','machineRuns','receivingRuns','hiddenRuns','actualRuns','oldActualRuns','foreignRuns','oldForeignRuns'){$actual+=@($r.$key).Count}
if($fresh -ne 129 -or $actual -ne 326 -or $e.AllPathClosure -or $e.FullKernelGate -or $e.SelfBuild -or $e.Mail){throw 'Do not promote a foundation to full closure'}
[pscustomobject]@{SourceInputs=$inputs.Count;RecipeFiles=@($e.RecipeFiles.PSObject.Properties).Count;PublishedSources=@($e.PublishedSources.PSObject.Properties).Count;ArtifactPins=$artifacts.Count;CorpusArtifactPins=340;PrimaryAssertions=199;FreshStrictO2Units=$fresh;ActualRuntimeExecutions=$actual;Verified=$true}|ConvertTo-Json
