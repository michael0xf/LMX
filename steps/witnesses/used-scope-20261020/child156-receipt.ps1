param([string]$Label='receipt-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$prior="$repo/build2/codex_root_contract155";$stage="$repo/build2/codex_child_records156";$dest="$repo/steps/witnesses/used-scope-20261020";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve root receipt attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src","$out/replay/headers/l2src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Json155([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 12).Replace([string][char]13,'')+[char]10),$utf8)}
$parent=Get-Content -LiteralPath "$dest/root155-evidence.json" -Raw|ConvertFrom-Json
if((Get-FileHash -LiteralPath "$dest/root155-u0.patch").Hash -cne $parent.SourcePatchSha256){throw 'Published154 patch changed'}
$before=Get-Content -LiteralPath "$dest/root155-inputs.json" -Raw|ConvertFrom-Json
if($before.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changed=@()
foreach($pin in $before){
 $rel=$pin.Path;if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if((Get-FileHash -LiteralPath "$prior/$rel").Hash -cne $pin.Sha256){throw 'Frozen154 source changed'}
 $hash=(Get-FileHash -LiteralPath "$stage/$rel").Hash
 if($hash -cne $pin.Sha256){$changed+=$rel}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
$expected=@('src/l2src/l2trans.lm1','src/l2src/l2_application.h.lm1','headers/l2src/l2_application.lm1.h')
if($changed.Count -ne 3 -or @($changed|Where-Object {$_ -notin $expected}).Count){throw 'Compiler/source header/regenerated header only'}
if((Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash -cne (Get-FileHash -LiteralPath "$stage/frontend-01/frontend-source.lm1").Hash){throw 'Frozen final frontend source differs'}
$parts=@()
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){
 $piece="$out/$([IO.Path]::GetFileName($rel)).patch"
 & git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/$rel" "$stage/src/$rel"
 if($LASTEXITCODE -ne 1){throw 'Need actual exact-file source diff'}
 $parts+=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_root_contract155/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_child_records156/src/','b/src/').Replace('a/build2/codex_root_contract155/src/','a/src/').Replace('b/build2/codex_child_records156/src/','b/src/')
 Copy-Item -LiteralPath "$prior/src/$rel" -Destination "$out/replay/src/$rel"
}
[IO.File]::WriteAllText("$dest/child156-u0.patch",(($parts -join '').Replace([string][char]13,'')),$utf8)
& git.exe apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$dest/child156-u0.patch"
if($LASTEXITCODE -ne 0){throw 'Root source replay failed'}
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){if((Get-FileHash -LiteralPath "$out/replay/src/$rel").Hash -cne (Get-FileHash -LiteralPath "$stage/src/$rel").Hash){throw 'Replayed source differs'}}
# The replayed header's real predef import must live under the SAME unit
# root. It is one unchanged pinned input,not a restored historical tree.
New-Item -ItemType Directory -Path "$out/replay/src/l1src"|Out-Null
Copy-Item -LiteralPath "$stage/src/l1src/p0.h.lm1" -Destination "$out/replay/src/l1src/p0.h.lm1"
. "$repo/tools/ps51_proc.ps1"
$saved=[Environment]::CurrentDirectory;Push-Location "$out/replay/src"
try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$repo/bin/l1trans.exe" -Argv @("$out/replay/src/l2src/l2_application.h.lm1","$out/replay/headers/l2src/l2_application.lm1.h") -TimeoutSec 60 -Log "$out/HEADER.log"}
finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or (Get-FileHash -LiteralPath "$out/replay/headers/l2src/l2_application.lm1.h").Hash -cne (Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash){throw 'Regenerated C header differs'}
Copy-Item -LiteralPath "$stage/child-02/fixture.c" -Destination "$dest/child156-test.c"
$recipes=@{}
foreach($name in 'build','routes','negatives','values','profiles','native-test','root-test','child-test','receipt','constants','extra-controls','aux-values','method-values','check-compat'){
 $path="$dest/child156-$name.ps1";Copy-Item -LiteralPath "$stage/$name.ps1" -Destination $path;$recipes[$name]=@{Path="child156-$name.ps1";Sha256=(Get-FileHash -LiteralPath $path).Hash}
}
$records=@{};$sources=@{owned='frontend-01/results.json';routes='routes-01/results.json';refusals='negatives-01/results.json';child='child-02/results.json';root='root-01/results.json';native='native-01/results.json';check='check-01/results.json';profiles='profiles-01/results.json';builds='values-01/builds.json';runs='values-01/results.json';auxBuilds='aux-01/builds.json';auxRuns='aux-01/results.json';constantBuilds='constants-02/builds.json';constantRuns='constants-02/results.json';methodBuilds='method-02/builds.json';methodRuns='method-02/results.json';extra='extra-02/results.json'}
foreach($key in $sources.Keys){$records[$key]=Get-Content -LiteralPath "$stage/$($sources[$key])" -Raw|ConvertFrom-Json}
foreach($key in 'profiles','auxRuns','constantRuns','methodRuns'){if(@($records[$key]|Where-Object {-not $_.Success}).Count){throw "Failed $key"}}
if(@($records.runs|Where-Object {-not $_.ObservationMatched}).Count -or @($records.refusals|Where-Object {-not $_.OracleMatched}).Count){throw 'Changed actual value/negative oracle'}
foreach($key in 'root','native','check','child'){if(@($records[$key]|Where-Object Exit -ne 0).Count){throw "Failed lifetime $key"}}
if(@($records.child|Where-Object Tier -eq 'new156')[0].Diagnostic -notmatch 'CHILD156: 279 checks, 0 failures'){throw 'Exact child lifetime/COUNT-EMIT assertions required'}
if($records.root.Diagnostic -notmatch 'ROOT155: 124 checks, 0 failures' -or $records.root.Diagnostic -notmatch 'allocation sites=3'){throw 'Exact root closure assertions required'}
$previousRoutes=Get-Content -LiteralPath "$prior/routes-03/results.json" -Raw|ConvertFrom-Json
if(@($records.routes).Count -ne 85){throw 'Exact85 sources'}
foreach($row in $records.routes){if($row.GeneratedL1Sha256 -cne $previousRoutes[$row.Unit].GeneratedL1Sha256){throw 'Claimed final155/154 literal source equivalence differs'}}
foreach($name in @($records.extra|Select-Object -ExpandProperty Name -Unique)){
 $pair=@($records.extra|Where-Object Name -eq $name);if($pair.Count -ne 2 -or $pair[0].Exit -ne $pair[1].Exit -or $pair[0].Diagnostic -cne $pair[1].Diagnostic){throw 'Additional classification changed'}
}
$fresh=@($records.builds).Count+@($records.auxBuilds).Count+@($records.constantBuilds).Count+@($records.methodBuilds).Count
$executions=@($records.runs).Count+@($records.auxRuns).Count+@($records.constantRuns).Count+@($records.methodRuns).Count
if($fresh -ne 113 -or $executions -ne 262){throw 'Exact phase counts'}
Json155 "$dest/child156-results.json" $records;Json155 "$dest/child156-inputs.json" $pins
$summaries=@{};foreach($entry in @(@{Name='Values';Path='values-01'},@{Name='Aux';Path='aux-01'},@{Name='Constants';Path='constants-02'},@{Name='Method';Path='method-02'})){$summaries[$entry.Name]=Get-Content -LiteralPath "$stage/$($entry.Path)/summary.json" -Raw|ConvertFrom-Json}
$receipt=@{
 State='Private156EmbeddedExpressionChildrenOwnPreparedValuesNotAllPathClosure';Date='2026-10-22';BaseMain='2bc76b08203da2a16a59949ac172c2f3259dc105';Candidate=$stage;Goal='active; full v3 objective unchanged'
 Parent155ReceiptSha256=(Get-FileHash -LiteralPath "$dest/root155-evidence.json").Hash;Parent155PatchSha256=$parent.SourcePatchSha256;Parent152SourceArchiveSha256=$parent.Parent152SourceArchiveSha256
 SourceHeaderFiles=281;UnchangedDependencies=278;ChangedImplementationSources=2;RegeneratedCHeaders=1;U0ReplayExact=$true;HeaderReplayExact=$true
 SourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash;ApplicationSourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2_application.h.lm1").Hash;ApplicationHeaderSha256=(Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash;FrontendCSha256=(Get-FileHash -LiteralPath "$stage/frontend-01/frontend.c").Hash;FrontendExeSha256=(Get-FileHash -LiteralPath "$stage/frontend-01/l2trans.exe").Hash
 ChildAssertions=279;BaselineChildAssertions=36;ChildConstructorAllocationRefusals=5;ActualNestedGroupDepths=@(1,4,16,65);RootAssertions=124;RootAllocationRefusals=3;NativeCompatibilityAssertions=126;CheckCompatibilityAssertions=153;OwnedAssertions=398;MetadataAssertions=336;CommonIndexAssertions=420;DispatchAssertions=200;ReceivingAssertions=114;CompilerProfiles=17;FinalFixtureFailures=0
 FormalTypeAndNamePoisonPreservesLiteralNativeExpressionAndPointerContext=$true;OwnContractAndTypeGettersPreserveHeldVerdict=$true;MachineSlotAndConstantRootTypesClosed=$true;PreparedViewsResetRootMetadata=$true;RecordViewsAndCopiesPreserveRootMetadata=$true;NoRootSourceTableRereadsDuringTestedNativeProjection=$true
 All85L1Identical155=$true;All85FreshStrictO2=$true;FreshStrictO2Units=$fresh;ActualRuntimeExecutions=$executions;Summaries=$summaries;ExactResultSources=$sources;RecipeFiles=$recipes
 FixtureSha256=(Get-FileHash -LiteralPath "$dest/child156-test.c").Hash;SourcePatchSha256=(Get-FileHash -LiteralPath "$dest/child156-u0.patch").Hash;ResultsSha256=(Get-FileHash -LiteralPath "$dest/child156-results.json").Hash;ManifestSha256=(Get-FileHash -LiteralPath "$dest/child156-inputs.json").Hash
 FailureHistory=@();CommentOnlySourceClarificationRegeneratesSameCompiledHeader=$true;IndexStepChildrenOwned=$false;ReceivingConversionCallActualClosure=$false;IndependentIndexExpressionPreparationStillPresent=$true
 Remaining=@('INDEX operand child ownership with every path record/view/fact copy and release','Receiving/conversion/call-actual helpers still take raw fields','Own-storage ABI/descriptor/leaf projection audit','Pointer-type spelling queries','Raw indirect heads and callable/text clients','Public-dev/full kernel/Model/Shelf/K03/self-build/mail')
 NoOldBuildWrites=$true;ProtectedBasenameExcludedBeforeIO=$true;AllPathClosure=$false;PublicDevIntegrated=$false;FullKernelGate=$false;SelfBuild=$false;Mail=$false
}
Json155 "$dest/child156-evidence.json" $receipt
$receipt|Select-Object State,SourceSha256,ApplicationHeaderSha256,RootAssertions,FreshStrictO2Units,ActualRuntimeExecutions,U0ReplayExact,HeaderReplayExact|ConvertTo-Json
