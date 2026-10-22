#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_numeric_receiving159";$dest="$repo/steps/witnesses/used-scope-20261020"
function Pin159([string]$Path,[string]$Sha){
 if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if(-not $Sha -or (Get-FileHash -LiteralPath $Path).Hash -cne $Sha){throw "Artifact pin mismatch: $Path"}
}
$e=Get-Content -LiteralPath "$dest/receive159-evidence.json" -Raw|ConvertFrom-Json
$r=Get-Content -LiteralPath "$dest/receive159-results.json" -Raw|ConvertFrom-Json
Pin159 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1'
Pin159 "$repo/bin/l1trans.exe" '601D350E853CA16A35EC4B7ED7C2B5B82248A63E96B72A545329B1D8C6AA2196'
Pin159 "$repo/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o" '1EDAE70A026B25652420E7ECD2FF8361D848D476B78CDC448A5DE0FEC55576D7'
Pin159 "$repo/build2/codex_places152_runtime_11/actual-02/driver.o" 'C026245020CC2E54538EF9BBAA39C9878460358C3788A2FC3DEE6DAA45A293A4'
Pin159 "$repo/build2/codex_places152_runtime_11/observed-02/driver.o" '97566328E3D9FEF3069BB431B644025986CD32EBE3FE16844736E96070196731'
Pin159 "$dest/operand-places152-inputs.tar.xz" $e.Parent152SourceArchiveSha256
Pin159 "$dest/analysis158-evidence.json" $e.Parent158ReceiptSha256
Pin159 "$dest/analysis158-u0.patch" $e.Parent158PatchSha256
Pin159 "$dest/receive159-test.c" $e.FixtureSha256
Pin159 "$dest/receive159-values.lm2" $e.ValueSourceSha256
Pin159 "$dest/receive159-hidden.lm2" $e.HiddenSourceSha256
Pin159 "$dest/receive159-actual.lm2" $e.ActualSourceSha256
Pin159 "$dest/receive159-foreign.lm2" $e.ForeignSourceSha256
Pin159 "$dest/receive159-actual-open-results.json" $e.ActualOpenResultsSha256
Pin159 "$dest/receive159-u0.patch" $e.SourcePatchSha256
Pin159 "$dest/receive159-inputs.json" $e.ManifestSha256
Pin159 "$dest/receive159-results.json" $e.ResultsSha256
$inputs=Get-Content -LiteralPath "$dest/receive159-inputs.json" -Raw|ConvertFrom-Json
foreach($p in $inputs){Pin159 "$stage/$($p.Path)" $p.Sha256}
foreach($p in $e.RecipeFiles.PSObject.Properties){Pin159 "$dest/$($p.Value.Path)" $p.Value.Sha256}
Pin159 "$stage/frontend-16/frontend.c" $e.FrontendCSha256
Pin159 "$stage/frontend-16/l2trans.exe" $e.FrontendExeSha256
Pin159 "$stage/frontend-16/frontend-source.lm1" $e.SourceSha256
$unitPins=0
foreach($b in $r.builds){
 Pin159 "$($b.Stem).lm1" $b.GraphSha256;Pin159 "$($b.Stem).c" $b.CSha256
 Pin159 "$($b.Stem).o" $b.ObjectSha256;Pin159 "$($b.Stem).exe" $b.ExeSha256
 if($b.CompilerSha256 -cne $e.FrontendExeSha256){throw 'Corpus frontend identity'}
 $unitPins+=4
}
foreach($b in $r.auxBuilds){
 $stem="$stage/aux-04/$($b.Case)-$($b.Mode)"
 Pin159 "$stem.lm1" $b.GeneratedL1Sha256;Pin159 "$stem.c" $b.GeneratedCSha256;Pin159 "$stem.o" $b.ObjectSha256
 foreach($row in @($r.auxRuns|Where-Object {$_.Case -eq $b.Case -and $_.Mode -eq $b.Mode})){Pin159 "$stem-$($row.Runtime).exe" $row.ExeSha256}
}
foreach($kind in @(@{Builds='constantBuilds';Runs='constantRuns';Dir='constants-03'},@{Builds='methodBuilds';Runs='methodRuns';Dir='method-03'},@{Builds='machineBuilds';Runs='machineRuns';Dir='machine-03'})){
 foreach($b in $r.($kind.Builds)){
  $stem="$stage/$($kind.Dir)/$($b.Case)-$($b.Tier)-$($b.Mode)"
  Pin159 "$stem.lm1" $b.GraphSha256;Pin159 "$stem.c" $b.CSha256;Pin159 "$stem.o" $b.ObjectSha256
  foreach($row in @($r.($kind.Runs)|Where-Object {$_.Case -eq $b.Case -and $_.Tier -eq $b.Tier -and $_.Mode -eq $b.Mode})){Pin159 "$stem-$($row.Runtime).exe" $row.ExeSha256}
 }
}
foreach($b in $r.receivingBuilds){
 $stem="$stage/receive-values-08/$($b.Mode)"
 Pin159 "$stem.lm1" $b.L1Sha256;Pin159 "$stem.c" $b.CSha256;Pin159 "$stem.o" $b.ObjectSha256
 if($b.CompilerSha256 -cne $e.FrontendExeSha256 -or $b.SourceSha256 -cne $e.ValueSourceSha256){throw 'Receiving source/frontend identity'}
 foreach($row in @($r.receivingRuns|Where-Object Mode -eq $b.Mode)){Pin159 "$stem-$($row.Runtime).exe" $row.ExeSha256}
}
Pin159 "$stage/receive-values-08/source.lm2" $e.ValueSourceSha256
Pin159 "$stage/receive-hidden-02/source.lm2" $e.HiddenSourceSha256
foreach($b in $r.hiddenBuilds){
 $stem="$stage/receive-hidden-02/$($b.Mode)"
 Pin159 "$stem.lm1" $b.L1Sha256;Pin159 "$stem.c" $b.CSha256;Pin159 "$stem.o" $b.ObjectSha256
 if($b.CompilerSha256 -cne $e.FrontendExeSha256 -or $b.SourceSha256 -cne $e.HiddenSourceSha256){throw 'Hidden receiver source/frontend identity'}
 foreach($row in @($r.hiddenRuns|Where-Object Mode -eq $b.Mode)){Pin159 "$stem-$($row.Runtime).exe" $row.ExeSha256}
}
$parent=Get-Content -LiteralPath "$dest/analysis158-evidence.json" -Raw|ConvertFrom-Json
foreach($case in @(@{Builds='actualBuilds';Runs='actualRuns';Dir='receive-actual-03';Source=$e.ActualSourceSha256;Compiler=$e.FrontendExeSha256},@{Builds='oldActualBuilds';Runs='oldActualRuns';Dir='receive-actual-old-01';Source=$e.ActualSourceSha256;Compiler=$parent.FrontendExeSha256},@{Builds='foreignBuilds';Runs='foreignRuns';Dir='receive-foreign-01';Source=$e.ForeignSourceSha256;Compiler=$e.FrontendExeSha256},@{Builds='oldForeignBuilds';Runs='oldForeignRuns';Dir='receive-foreign-old-01';Source=$e.ForeignSourceSha256;Compiler=$parent.FrontendExeSha256})){
 Pin159 "$stage/$($case.Dir)/source.lm2" $case.Source
 foreach($b in $r.($case.Builds)){
  $stem="$stage/$($case.Dir)/$($b.Mode)"
  Pin159 "$stem.lm1" $b.L1Sha256;Pin159 "$stem.c" $b.CSha256;Pin159 "$stem.o" $b.ObjectSha256
  if($b.CompilerSha256 -cne $case.Compiler -or $b.SourceSha256 -cne $case.Source){throw 'Actual-formal source/frontend identity'}
  foreach($row in @($r.($case.Runs)|Where-Object Mode -eq $b.Mode)){Pin159 "$stem-$($row.Runtime).exe" $row.ExeSha256}
 }
}
$open=Get-Content -LiteralPath "$dest/receive159-actual-open-results.json" -Raw|ConvertFrom-Json
if(@($open).Count -ne 1 -or $open.Success -or $open.Diagnostic -notmatch 'exit 0, expected 7'){throw 'Do not hide the fixed formal-receiving regression'}
Pin159 "$stage/receive-actual-open-01/source.lm2" $e.ActualSourceSha256
Pin159 "$stage/receive-actual-open-01/native-production.exe" $open.ExeSha256
foreach($f in $r.lifetimes){Pin159 "$stage/fixtures-09/$($f.Name).c" $f.FixtureSha256;Pin159 "$stage/fixtures-09/$($f.Name).exe" $f.ExeSha256;if($f.FrontendCSha256 -cne $e.FrontendCSha256){throw 'Fixture frontend C identity'}}
foreach($f in $r.profiles){Pin159 "$stage/profiles-05/$($f.Name).exe" $f.ExeSha256;if($f.FrontendSha256 -cne $e.FrontendCSha256){throw 'Profile frontend C identity'}}
foreach($f in $r.root){Pin159 "$stage/root-04/$($f.Tier).exe" $f.ExeSha256}
foreach($f in $r.native){Pin159 "$stage/native-04/$($f.Tier).exe" $f.ExeSha256}
foreach($f in $r.check){Pin159 "$stage/check-04/$($f.Tier).exe" $f.ExeSha256}
if($inputs.Count -ne 281 -or $r.builds.Count -ne 85 -or $r.runs.Count -ne 170 -or $r.receivingRuns.Count -ne 8 -or $r.hiddenRuns.Count -ne 8){throw 'Independent phase inventory'}
[pscustomobject]@{SourceInputs=$inputs.Count;RecipeFiles=@($e.RecipeFiles.PSObject.Properties).Count;CorpusArtifactPins=$unitPins;ActualRuntimeExecutions=$e.ActualRuntimeExecutions;Verified=$true}|ConvertTo-Json
