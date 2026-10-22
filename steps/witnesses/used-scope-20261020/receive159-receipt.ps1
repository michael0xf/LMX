#requires -Version 7.0
param([string]$Label='receipt-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$prior="$repo/build2/codex_analysis_children158";$stage="$repo/build2/codex_numeric_receiving159";$dest="$repo/steps/witnesses/used-scope-20261020";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve receipt attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src","$out/replay/headers/l2src","$out/replay/src/l1src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Json159([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 16).Replace([string][char]13,'')+[char]10),$utf8)}
$parent=Get-Content -LiteralPath "$dest/analysis158-evidence.json" -Raw|ConvertFrom-Json
if((Get-FileHash -LiteralPath "$dest/analysis158-u0.patch").Hash -cne $parent.SourcePatchSha256){throw 'Published parent patch changed'}
$before=Get-Content -LiteralPath "$dest/analysis158-inputs.json" -Raw|ConvertFrom-Json
if($before.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changed=@()
foreach($pin in $before){
 $rel=$pin.Path;if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if((Get-FileHash -LiteralPath "$prior/$rel").Hash -cne $pin.Sha256){throw 'Frozen parent source changed'}
 $hash=(Get-FileHash -LiteralPath "$stage/$rel").Hash
 if($hash -cne $pin.Sha256){$changed+=$rel}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
$expected=@('src/l2src/l2trans.lm1','src/l2src/l2_application.h.lm1','headers/l2src/l2_application.lm1.h')
if($changed.Count -ne 3 -or @($changed|Where-Object {$_ -notin $expected}).Count){throw 'Only compiler and receiving-plan source/generated headers change'}
if((Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash -cne (Get-FileHash -LiteralPath "$stage/frontend-16/frontend-source.lm1").Hash){throw 'Frozen final frontend source differs'}
$parts=@()
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){
 $piece="$out/$([IO.Path]::GetFileName($rel)).patch"
 & git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/$rel" "$stage/src/$rel"
 if($LASTEXITCODE -ne 1){throw 'Need exact-file source diff'}
 $parts+=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_analysis_children158/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_numeric_receiving159/src/','b/src/').Replace('a/build2/codex_analysis_children158/src/','a/src/').Replace('b/build2/codex_numeric_receiving159/src/','b/src/')
 Copy-Item -LiteralPath "$prior/src/$rel" -Destination "$out/replay/src/$rel"
}
[IO.File]::WriteAllText("$dest/receive159-u0.patch",(($parts -join '').Replace([string][char]13,'')),$utf8)
& git.exe apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$dest/receive159-u0.patch"
if($LASTEXITCODE -ne 0){throw 'Source replay failed'}
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){if((Get-FileHash -LiteralPath "$out/replay/src/$rel").Hash -cne (Get-FileHash -LiteralPath "$stage/src/$rel").Hash){throw 'Replayed source differs'}}
Copy-Item -LiteralPath "$stage/src/l1src/p0.h.lm1" -Destination "$out/replay/src/l1src/p0.h.lm1"
. "$repo/tools/ps51_proc.ps1"
$saved=[Environment]::CurrentDirectory;Push-Location "$out/replay/src"
try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$repo/bin/l1trans.exe" -Argv @("$out/replay/src/l2src/l2_application.h.lm1","$out/replay/headers/l2src/l2_application.lm1.h") -TimeoutSec 60 -Log "$out/HEADER.log"}
finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or (Get-FileHash -LiteralPath "$out/replay/headers/l2src/l2_application.lm1.h").Hash -cne (Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash){throw 'Regenerated C header differs'}
Copy-Item -LiteralPath "$stage/fixtures-09/receive.c" -Destination "$dest/receive159-test.c"
Copy-Item -LiteralPath "$stage/receive-values.lm2" -Destination "$dest/receive159-values.lm2"
Copy-Item -LiteralPath "$stage/receive-hidden.lm2" -Destination "$dest/receive159-hidden.lm2"
Copy-Item -LiteralPath "$stage/receive-actual.lm2" -Destination "$dest/receive159-actual.lm2"
Copy-Item -LiteralPath "$stage/receive-foreign.lm2" -Destination "$dest/receive159-foreign.lm2"
Json159 "$dest/receive159-actual-open-results.json" (Get-Content -LiteralPath "$stage/receive-actual-open-01/results.json" -Raw|ConvertFrom-Json)
$recipes=@{}
foreach($name in 'build','routes','negatives','values','profiles','native-test','root-test','fixtures','receipt','constants','extra-controls','aux-values','method-values','machine-values','check-compat','verify','receive-values','audit'){
 $path="$dest/receive159-$name.ps1";Copy-Item -LiteralPath "$stage/$name.ps1" -Destination $path;$recipes[$name]=@{Path="receive159-$name.ps1";Sha256=(Get-FileHash -LiteralPath $path).Hash}
}
$records=@{};$sources=@{owned='frontend-16/results.json';routes='routes-05/results.json';refusals='negatives-04/results.json';lifetimes='fixtures-09/results.json';root='root-04/results.json';native='native-04/results.json';check='check-04/results.json';profiles='profiles-05/results.json';builds='values-04/builds.json';runs='values-04/results.json';auxBuilds='aux-04/builds.json';auxRuns='aux-04/results.json';constantBuilds='constants-03/builds.json';constantRuns='constants-03/results.json';methodBuilds='method-03/builds.json';methodRuns='method-03/results.json';machineBuilds='machine-03/builds.json';machineRuns='machine-03/results.json';receivingBuilds='receive-values-08/builds.json';receivingRuns='receive-values-08/results.json';hiddenBuilds='receive-hidden-02/builds.json';hiddenRuns='receive-hidden-02/results.json';extra='extra-04/results.json'}
$sources+=@{actualBuilds='receive-actual-03/builds.json';actualRuns='receive-actual-03/results.json';oldActualBuilds='receive-actual-old-01/builds.json';oldActualRuns='receive-actual-old-01/results.json';foreignBuilds='receive-foreign-01/builds.json';foreignRuns='receive-foreign-01/results.json';oldForeignBuilds='receive-foreign-old-01/builds.json';oldForeignRuns='receive-foreign-old-01/results.json'}
foreach($key in $sources.Keys){$records[$key]=Get-Content -LiteralPath "$stage/$($sources[$key])" -Raw|ConvertFrom-Json}
foreach($key in 'profiles','auxRuns','constantRuns','methodRuns','machineRuns','receivingRuns','hiddenRuns','actualRuns','oldActualRuns','foreignRuns','oldForeignRuns'){if(@($records[$key]|Where-Object {-not $_.Success}).Count){throw "Failed $key"}}
if(@($records.runs|Where-Object {-not $_.ObservationMatched}).Count -or @($records.refusals|Where-Object {-not $_.OracleMatched}).Count){throw 'Changed actual value/negative oracle'}
foreach($key in 'root','native','check','lifetimes'){if(@($records[$key]|Where-Object Exit -ne 0).Count){throw "Failed lifetime $key"}}
if(@($records.lifetimes|Where-Object Name -eq 'receive')[0].Diagnostic -notmatch 'RECEIVE159: 61 checks, 0 failures'){throw 'Exact numeric receiving assertions required'}
$previousRoutes=Get-Content -LiteralPath "$prior/routes-01/results.json" -Raw|ConvertFrom-Json
if(@($records.routes).Count -ne 85 -or @($previousRoutes).Count -ne 85){throw 'Exact85 sources'}
$changedL1=@();foreach($row in $records.routes){if($row.Exit -ne 0){throw 'New source refusal'};if($row.GeneratedL1Sha256 -cne $previousRoutes[$row.Unit].GeneratedL1Sha256){$changedL1+=$row.Unit}}
foreach($name in @($records.extra|Select-Object -ExpandProperty Name -Unique)){
 $pair=@($records.extra|Where-Object Name -eq $name);if($pair.Count -ne 2 -or $pair[0].Exit -ne $pair[1].Exit -or $pair[0].Diagnostic -cne $pair[1].Diagnostic){throw 'Additional classification changed'}
}
$fresh=@($records.builds).Count+@($records.auxBuilds).Count+@($records.constantBuilds).Count+@($records.methodBuilds).Count+@($records.machineBuilds).Count+@($records.receivingBuilds).Count+@($records.hiddenBuilds).Count
$executions=@($records.runs).Count+@($records.auxRuns).Count+@($records.constantRuns).Count+@($records.methodRuns).Count+@($records.machineRuns).Count+@($records.receivingRuns).Count+@($records.hiddenRuns).Count
$fresh+=@($records.actualBuilds).Count+@($records.oldActualBuilds).Count+@($records.foreignBuilds).Count+@($records.oldForeignBuilds).Count
$executions+=@($records.actualRuns).Count+@($records.oldActualRuns).Count+@($records.foreignRuns).Count+@($records.oldForeignRuns).Count
if($fresh -ne 129 -or $executions -ne 326){throw 'Exact selected phase counts'}
Json159 "$dest/receive159-results.json" $records;Json159 "$dest/receive159-inputs.json" $pins
$receipt=@{
 State='Private159NumericReceivingFromPreparedValuesNotAllConsumerClosure';Date='2026-10-22';BaseMain='b3e98cb7bc35cf99936bd32d8e61647675d6e499';Candidate=$stage;Goal='active; full v3 objective unchanged'
 Parent158ReceiptSha256=(Get-FileHash -LiteralPath "$dest/analysis158-evidence.json").Hash;Parent158PatchSha256=$parent.SourcePatchSha256;Parent152SourceArchiveSha256=$parent.Parent152SourceArchiveSha256
 SourceHeaderFiles=281;UnchangedDependencies=278;ChangedImplementationSources=1;ChangedApplicationSourceHeaders=1;GeneratedApplicationHeaderChanged=$true;U0ReplayExact=$true;HeaderReplayExact=$true
 SourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash;ApplicationSourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2_application.h.lm1").Hash;ApplicationHeaderSha256=(Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash;FrontendCSha256=(Get-FileHash -LiteralPath "$stage/frontend-16/frontend.c").Hash;FrontendExeSha256=(Get-FileHash -LiteralPath "$stage/frontend-16/l2trans.exe").Hash
 NumericReceivingAssertions=61;ReceivingConstructorAllocationRefusals=2;IdentityReceivingAllocations=0;AnalysisAssertions=82;IndexAssertions=61;ChildAssertions=281;OwnedAssertions=2026;RootAssertions=124;NativeAssertions=134;CheckAssertions=159;CompilerProfiles=17
 TypedSourceSurvivesNameAndFTPoison=$true;NativeCapturesConverterBeforeArgument=$true;RetainedUsesOrdinaryCallProducer=$true;CountEmitTopologyEqual=$true;CharacterLiteralUsesCommonContextualStorage=$true;OpaqueCContractCarriedByCommonFold=$true;UnknownLanguageValueDoesNotBecomeOpaqueC=$true
 ReceivingValueFreshStrictO2Units=2;ReceivingValueActualRuns=8;ReceivingValueForcedMethodBodies=6;ReceivingOriginalConverterAndOpaqueMethodNativeOnly=$true;ActualReceivingReadWriteAddressAndArgumentRebind=$true
 HiddenReceiverFreshStrictO2Units=2;HiddenReceiverActualRuns=8;HiddenReceiverForcedBodies=1;ConverterImplicitInputsUseOrdinaryCallRecordsAndAdmission=$true;ActualRefusalConvertedAndCaught=$true;GroupEvaluationDoesNotCreateReceivingOperation=$true;UntypedEvaluationInfersDefaultLiteralStorage=$true
 All85FreshStrictO2=$true;ChangedL1UnitsFrom158=$changedL1;FreshStrictO2Units=$fresh;ActualRuntimeExecutions=$executions;ExactResultSources=$sources;RecipeFiles=$recipes
 FixtureSha256=(Get-FileHash -LiteralPath "$dest/receive159-test.c").Hash;ValueSourceSha256=(Get-FileHash -LiteralPath "$dest/receive159-values.lm2").Hash;SourcePatchSha256=(Get-FileHash -LiteralPath "$dest/receive159-u0.patch").Hash;ResultsSha256=(Get-FileHash -LiteralPath "$dest/receive159-results.json").Hash;ManifestSha256=(Get-FileHash -LiteralPath "$dest/receive159-inputs.json").Hash
 HiddenSourceSha256=(Get-FileHash -LiteralPath "$dest/receive159-hidden.lm2").Hash
 ActualSourceSha256=(Get-FileHash -LiteralPath "$dest/receive159-actual.lm2").Hash;ForeignSourceSha256=(Get-FileHash -LiteralPath "$dest/receive159-foreign.lm2").Hash
 ActualOpenResultsSha256=(Get-FileHash -LiteralPath "$dest/receive159-actual-open-results.json").Hash;ActualFormalReceivingPreserved=$true;ExplicitForeignValueFormalUsesExactABI=$true;ForeignFormalCallerRemainsNativeOnly=$true;NestedConversionEdgesUseSelectedReceiverNotGlobalCursor=$true;Baseline158ComparisonUnits=4;Baseline158ComparisonActualRuns=16
 FailureHistory=@('Initial private harness used a boolean numeric classifier as the target type; corrected to the existing own-to-formal type projection','Receiving fake-program fixture exposed redundant identity compatibility lookup; exact selected primitive identity now requires no allocation','Character INDEX COUNT/EMIT refused a valid contextual literal; shared typed-literal projection fixes it,not an INDEX-only guard','Frontend06 routes translated83/85: raw C primary contract lost; common value/type fold now carries explicit -12,without a native source-head retry','Frontend07 prefix probe lost opaque-C type under signs; common prefix contract projector preserves it','Frontend07 foreign auxiliary refused because grouping replayed numeric receiving; pure child evaluation now borrows the same list without another receiving operation','Frontend09 hidden-converter witness exposed an artificial zero-implicit-input native guard; ordinary argument records and hidden-input admission remove it','Frontend09 nested C-pointer witness exposed missing default literal storage in pure evaluation; common inference restores ordinary literal typing without receiving','Frontend11 silently narrowed an int actual to a converter char formal: old158 returned7 while native returned0; held formal admission and selected conversion edges restore actual old/new parity','Frontend14 opaque foreign formal refusal used a numeric-only admission role; existing foreign-byvalue ABI classification and held evaluation preserve c.int without source reparse','Draft value fixture used a reserved length binding; renamed to extent without changing compiler/oracle','Parent158 compact primary/body82/2 RED remains open; not rerun or promoted by this slice')
 Remaining=@('General primary/Frame/application body and actual ownership','Nonnumeric receiving/conversion/call-actual prepared plans','Own-storage ABI/descriptor/leaf projection audit','Pointer-type spelling queries','Raw indirect heads and callable/text clients','Public-dev/full kernel/Model/Shelf/K03/self-build/mail')
 NoOldBuildWrites=$true;ProtectedBasenameExcludedBeforeIO=$true;AllPathClosure=$false;PublicDevIntegrated=$false;FullKernelGate=$false;SelfBuild=$false;Mail=$false
}
Json159 "$dest/receive159-evidence.json" $receipt
[pscustomobject]$receipt|Select-Object State,SourceSha256,ApplicationHeaderSha256,NumericReceivingAssertions,FreshStrictO2Units,ActualRuntimeExecutions,U0ReplayExact,HeaderReplayExact|ConvertTo-Json
