param([string]$Label='receipt-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$prior="$repo/build2/codex_index_children157";$stage="$repo/build2/codex_analysis_children158";$dest="$repo/steps/witnesses/used-scope-20261020";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve receipt attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src","$out/replay/headers/l2src","$out/replay/src/l1src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Json157([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 14).Replace([string][char]13,'')+[char]10),$utf8)}
$parent=Get-Content -LiteralPath "$dest/index157-evidence.json" -Raw|ConvertFrom-Json
if((Get-FileHash -LiteralPath "$dest/index157-u0.patch").Hash -cne $parent.SourcePatchSha256){throw 'Published parent patch changed'}
$before=Get-Content -LiteralPath "$dest/index157-inputs.json" -Raw|ConvertFrom-Json
if($before.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changed=@()
foreach($pin in $before){
 $rel=$pin.Path;if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if((Get-FileHash -LiteralPath "$prior/$rel").Hash -cne $pin.Sha256){throw 'Frozen parent source changed'}
 $hash=(Get-FileHash -LiteralPath "$stage/$rel").Hash
 if($hash -cne $pin.Sha256){$changed+=$rel}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
$expected=@('src/l2src/l2trans.lm1')
if($changed.Count -ne 1 -or @($changed|Where-Object {$_ -notin $expected}).Count){throw 'Only compiler changes; source and generated application headers unchanged'}
if((Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash -cne (Get-FileHash -LiteralPath "$stage/frontend-01/frontend-source.lm1").Hash){throw 'Frozen final frontend source differs'}
$parts=@()
foreach($rel in 'l2src/l2trans.lm1'){
 $piece="$out/$([IO.Path]::GetFileName($rel)).patch"
 & git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/$rel" "$stage/src/$rel"
 if($LASTEXITCODE -ne 1){throw 'Need actual exact-file source diff'}
 $parts+=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_index_children157/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_analysis_children158/src/','b/src/').Replace('a/build2/codex_index_children157/src/','a/src/').Replace('b/build2/codex_analysis_children158/src/','b/src/')
 Copy-Item -LiteralPath "$prior/src/$rel" -Destination "$out/replay/src/$rel"
}
[IO.File]::WriteAllText("$dest/analysis158-u0.patch",(($parts -join '').Replace([string][char]13,'')),$utf8)
& git.exe apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$dest/analysis158-u0.patch"
if($LASTEXITCODE -ne 0){throw 'Source replay failed'}
foreach($rel in 'l2src/l2trans.lm1'){if((Get-FileHash -LiteralPath "$out/replay/src/$rel").Hash -cne (Get-FileHash -LiteralPath "$stage/src/$rel").Hash){throw 'Replayed source differs'}}
Copy-Item -LiteralPath "$stage/src/l2src/l2_application.h.lm1" -Destination "$out/replay/src/l2src/l2_application.h.lm1"
Copy-Item -LiteralPath "$stage/src/l1src/p0.h.lm1" -Destination "$out/replay/src/l1src/p0.h.lm1"
. "$repo/tools/ps51_proc.ps1"
$saved=[Environment]::CurrentDirectory;Push-Location "$out/replay/src"
try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$repo/bin/l1trans.exe" -Argv @("$out/replay/src/l2src/l2_application.h.lm1","$out/replay/headers/l2src/l2_application.lm1.h") -TimeoutSec 60 -Log "$out/HEADER.log"}
finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or (Get-FileHash -LiteralPath "$out/replay/headers/l2src/l2_application.lm1.h").Hash -cne (Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash){throw 'Regenerated C header differs'}
Copy-Item -LiteralPath "$stage/fixtures-05/analysis.c" -Destination "$dest/analysis158-test.c"
Copy-Item -LiteralPath "$stage/fixtures-05/owned.c" -Destination "$dest/analysis158-owned-test.c"
Copy-Item -LiteralPath "$stage/fixtures-04/analysis.c" -Destination "$dest/analysis158-primary-open-test.c"
Copy-Item -LiteralPath "$stage/fixtures-04/results.json" -Destination "$dest/analysis158-primary-open-results.json"
Copy-Item -LiteralPath "$stage/common-test.c" -Destination "$dest/analysis158-common-test.c"
Copy-Item -LiteralPath "$stage/machine-values.lm2" -Destination "$dest/analysis158-machine-values.lm2"
$recipes=@{}
foreach($name in 'build','routes','negatives','values','profiles','native-test','root-test','fixtures','receipt','constants','extra-controls','aux-values','method-values','machine-values','check-compat','verify'){
 $path="$dest/analysis158-$name.ps1";Copy-Item -LiteralPath "$stage/$name.ps1" -Destination $path;$recipes[$name]=@{Path="analysis158-$name.ps1";Sha256=(Get-FileHash -LiteralPath $path).Hash}
}
$records=@{};$sources=@{owned='frontend-01/results.json';routes='routes-01/results.json';refusals='negatives-01/results.json';lifetimes='fixtures-05/results.json';root='root-01/results.json';native='native-01/results.json';check='check-01/results.json';profiles='profiles-01/results.json';builds='values-01/builds.json';runs='values-01/results.json';auxBuilds='aux-01/builds.json';auxRuns='aux-01/results.json';constantBuilds='constants-01/builds.json';constantRuns='constants-01/results.json';methodBuilds='method-01/builds.json';methodRuns='method-01/results.json';machineBuilds='machine-01/builds.json';machineRuns='machine-01/results.json';extra='extra-01/results.json';primaryOpen='fixtures-04/results.json'}
foreach($key in $sources.Keys){$records[$key]=Get-Content -LiteralPath "$stage/$($sources[$key])" -Raw|ConvertFrom-Json}
foreach($key in 'profiles','auxRuns','constantRuns','methodRuns','machineRuns'){if(@($records[$key]|Where-Object {-not $_.Success}).Count){throw "Failed $key"}}
if(@($records.runs|Where-Object {-not $_.ObservationMatched}).Count -or @($records.refusals|Where-Object {-not $_.OracleMatched}).Count){throw 'Changed actual value/negative oracle'}
foreach($key in 'root','native','check','lifetimes'){if(@($records[$key]|Where-Object Exit -ne 0).Count){throw "Failed lifetime $key"}}
if(@($records.primaryOpen)[0].Exit -ne 1 -or @($records.primaryOpen)[0].Diagnostic -notmatch 'ANALYSIS158: 82 checks, 2 failures'){throw 'Do not hide or rewrite the open generic primary/body witness'}
if(@($records.lifetimes|Where-Object Name -eq 'analysis')[0].Diagnostic -notmatch 'ANALYSIS158: 82 checks, 0 failures'){throw 'Exact INDEX lifetime/COUNT-EMIT assertions required'}
if(@($records.lifetimes|Where-Object Name -eq 'owned')[0].Diagnostic -notmatch 'owned operand records: 2026 checks, 0 failures'){throw 'All actual recursive copy allocation sites must be exercised'}
if(@($records.lifetimes|Where-Object Name -eq 'child')[0].Diagnostic -notmatch 'CHILD156: 281 checks, 0 failures'){throw 'All actual child constructor allocation sites must be exercised'}
$previousRoutes=Get-Content -LiteralPath "$prior/routes-03/results.json" -Raw|ConvertFrom-Json
if(@($records.routes).Count -ne 85 -or @($previousRoutes).Count -ne 85){throw 'Exact85 sources'}
$changedL1=@();foreach($row in $records.routes){if($row.GeneratedL1Sha256 -cne $previousRoutes[$row.Unit].GeneratedL1Sha256){$changedL1+=$row.Unit}}
foreach($name in @($records.extra|Select-Object -ExpandProperty Name -Unique)){
 $pair=@($records.extra|Where-Object Name -eq $name);if($pair.Count -ne 2 -or $pair[0].Exit -ne $pair[1].Exit -or $pair[0].Diagnostic -cne $pair[1].Diagnostic){throw 'Additional classification changed'}
}
$fresh=@($records.builds).Count+@($records.auxBuilds).Count+@($records.constantBuilds).Count+@($records.methodBuilds).Count+@($records.machineBuilds).Count
$executions=@($records.runs).Count+@($records.auxRuns).Count+@($records.constantRuns).Count+@($records.methodRuns).Count+@($records.machineRuns).Count
if($fresh -ne 117 -or $executions -ne 278){throw 'Exact phase counts'}
Json157 "$dest/analysis158-results.json" $records;Json157 "$dest/analysis158-inputs.json" $pins
$summaries=@{};foreach($entry in @(@{Name='Values';Path='values-01'},@{Name='Aux';Path='aux-01'},@{Name='Constants';Path='constants-01'},@{Name='Method';Path='method-01'},@{Name='Machine';Path='machine-01'})){$summaries[$entry.Name]=Get-Content -LiteralPath "$stage/$($entry.Path)/summary.json" -Raw|ConvertFrom-Json}
$receipt=@{
 State='Private158LexicalAndEffectIndexChildrenNotAllConsumerClosure';Date='2026-10-22';BaseMain='f56fa7b4cc1aa76c34d2ad391fea574671e4860a';Candidate=$stage;Goal='active; full v3 objective unchanged'
 Parent157ReceiptSha256=(Get-FileHash -LiteralPath "$dest/index157-evidence.json").Hash;Parent157PatchSha256=$parent.SourcePatchSha256;Parent152SourceArchiveSha256=$parent.Parent152SourceArchiveSha256
 SourceHeaderFiles=281;UnchangedDependencies=280;ChangedImplementationSources=1;ChangedSourceHeaderComments=0;GeneratedCHeaderUnchanged=$true;U0ReplayExact=$true;HeaderReplayExact=$true
 SourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash;ApplicationSourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2_application.h.lm1").Hash;ApplicationHeaderSha256=(Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash;FrontendCSha256=(Get-FileHash -LiteralPath "$stage/frontend-01/frontend.c").Hash;FrontendExeSha256=(Get-FileHash -LiteralPath "$stage/frontend-01/l2trans.exe").Hash
 AnalysisAssertions=82;IndexCompatibilityAssertions=61;IndexCopyAllocationRefusals=7;TransactionalFactAllocationRefusals=6;ActualIndexNestedDepths=@(1,4,16);ChildCompatibilityAssertions=281;ChildConstructorAllocationRefusals=6;OwnedAssertions=2026;NativeCompatibilityAssertions=134;NativeAllocationRefusals=15;CheckCompatibilityAssertions=159;CheckAllocationRefusals=13;RootAssertions=124;CompilerProfiles=17;ClosedSliceFixtureFailures=0;OpenPrimaryWitnessFailures=2
 SemanticViewsResetNestedVerdicts=$true;CompletedCopiesPreserveNestedVerdicts=$true;AllActualIndexCopiesAvoidAdapters=$true;BoundArenaAddressesStable=$true;FactReplacementFailureLeavesExactOldOwnerAndVerdict=$true;MetadataOnlyCopiesDoNotPrepareExpressions=$true;MetadataOnlyFactReplacementDoesNotAllocate=$true;MachineNativeAndRetainedProjectSameIndexChildren=$true;NameAndFTPoisonPreservesTestedClosedChildren=$true
 All85FreshStrictO2=$true;ChangedL1UnitsFrom157=$changedL1;FreshStrictO2Units=$fresh;ActualRuntimeExecutions=$executions;Summaries=$summaries;ExactResultSources=$sources;RecipeFiles=$recipes
 FixtureSha256=(Get-FileHash -LiteralPath "$dest/analysis158-test.c").Hash;OwnedFixtureSha256=(Get-FileHash -LiteralPath "$dest/analysis158-owned-test.c").Hash;CommonFixtureSha256=(Get-FileHash -LiteralPath "$dest/analysis158-common-test.c").Hash;MachineSourceSha256=(Get-FileHash -LiteralPath "$dest/analysis158-machine-values.lm2").Hash;SourcePatchSha256=(Get-FileHash -LiteralPath "$dest/analysis158-u0.patch").Hash;ResultsSha256=(Get-FileHash -LiteralPath "$dest/analysis158-results.json").Hash;ManifestSha256=(Get-FileHash -LiteralPath "$dest/analysis158-inputs.json").Hash
 OpenPrimaryFixtureSha256=(Get-FileHash -LiteralPath "$dest/analysis158-primary-open-test.c").Hash;OpenPrimaryResultsSha256=(Get-FileHash -LiteralPath "$dest/analysis158-primary-open-results.json").Hash
 FailureHistory=@('fixtures02/03/04 compact P0 Frame with head backslash and flags2 has no owned body: lexical3/effect2 adapters,82checks2failures; preserved as open generic primary/body witness,not a language refusal oracle','fixtures05 canonical separated unary prefix backslash plus grouped address has owned operand:0adapters,82checks0failures;no compiler syntax guard or special backend branch was added');LexicalIndexTraversalBorrowsOwnedGrammar=$true;EffectsTakeFreshSemanticViewsWithoutAdapters=$true;EffectsRefusalDoesNotMutateClosedNativeVerdicts=$true;RawAddressEntryUsesSameLexicalRoleVisitor=$true;PrimaryControlBodyVisitorShared=$true
 Remaining=@('Array INDEX receiving/conversion helpers still take raw fields','General receiving/conversion/call-actual prepared plans','Own-storage ABI/descriptor/leaf projection audit','Pointer-type spelling queries','Raw indirect heads and callable/text clients','Public-dev/full kernel/Model/Shelf/K03/self-build/mail')
 NoOldBuildWrites=$true;ProtectedBasenameExcludedBeforeIO=$true;AllPathClosure=$false;PublicDevIntegrated=$false;FullKernelGate=$false;SelfBuild=$false;Mail=$false
}
Json157 "$dest/analysis158-evidence.json" $receipt
[pscustomobject]$receipt|Select-Object State,SourceSha256,ApplicationHeaderSha256,AnalysisAssertions,FreshStrictO2Units,ActualRuntimeExecutions,U0ReplayExact,HeaderReplayExact|ConvertTo-Json
