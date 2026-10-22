param([string]$Label='receipt-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$prior="$repo/build2/codex_check_records153";$stage="$repo/build2/codex_native_records154";$dest="$repo/steps/witnesses/used-scope-20261020";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve receipt attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'No overlapping GCC pipeline'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Json154([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 12).Replace([string][char]13,'')+[char]10),$utf8)}
$parent=Get-Content -LiteralPath "$dest/check153-evidence.json" -Raw|ConvertFrom-Json
if((Get-FileHash -LiteralPath "$dest/check153-u0.patch").Hash -cne $parent.SourcePatchSha256){throw 'Published153 patch changed'}
if((Get-FileHash -LiteralPath "$dest/operand-places152-inputs.tar.xz").Hash -cne $parent.Parent152SourceArchiveSha256){throw 'Published152 source bundle changed'}
$before=Get-Content -LiteralPath "$dest/check153-inputs.json" -Raw|ConvertFrom-Json
if($before.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changed=@()
foreach($pin in $before){
 $rel=$pin.Path;if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if((Get-FileHash -LiteralPath "$prior/$rel").Hash -cne $pin.Sha256){throw 'Frozen153 source changed'}
 $hash=(Get-FileHash -LiteralPath "$stage/$rel").Hash
 if($hash -cne $pin.Sha256){$changed+=$rel}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
if($changed.Count -ne 1 -or $changed[0] -cne 'src/l2src/l2trans.lm1'){throw 'Exactly one compiler source changes'}
if((Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash -cne (Get-FileHash -LiteralPath "$stage/frontend-03/frontend-source.lm1").Hash){throw 'Final compiler source not frozen for build'}
$piece="$out/source.patch"
& git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/l2src/l2trans.lm1" "$stage/src/l2src/l2trans.lm1"
if($LASTEXITCODE -ne 1){throw 'Actual exact-file source diff required'}
$text=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_check_records153/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_native_records154/src/','b/src/').Replace('a/build2/codex_check_records153/src/','a/src/').Replace('b/build2/codex_native_records154/src/','b/src/')
if([regex]::Matches($text,'(?m)^diff --git ').Count -ne 1){throw 'Exactly one patched source'}
[IO.File]::WriteAllText("$dest/native154-u0.patch",$text.Replace([string][char]13,''),$utf8)
Copy-Item -LiteralPath "$prior/src/l2src/l2trans.lm1" -Destination "$out/replay/src/l2src/l2trans.lm1"
& git.exe apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$dest/native154-u0.patch"
if($LASTEXITCODE -ne 0 -or (Get-FileHash -LiteralPath "$out/replay/src/l2src/l2trans.lm1").Hash -cne (Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash){throw 'Exact source replay differs'}
Copy-Item -LiteralPath "$stage/native-04/fixture.c" -Destination "$dest/native154-test.c"
$recipes=@{}
foreach($name in 'build','routes','negatives','values','replay-final','profiles','native-test','receipt','constants','extra-controls','aux-values','method-values','check-compat'){
 $path="$dest/native154-$name.ps1";Copy-Item -LiteralPath "$stage/$name.ps1" -Destination $path
 $recipes[$name]=@{Path="native154-$name.ps1";Sha256=(Get-FileHash -LiteralPath $path).Hash}
}
$records=@{}
$sources=@{
 owned='frontend-03/results.json';routes='routes-02/results.json';refusals='negatives-02/results.json';native='native-04/results.json';check='check-01/results.json';profiles='profiles-01/results.json';
 freshBuilds='values-01/builds.json';freshRuns='values-01/results.json';finalGraphs='replay-02/graphs.json';finalRuns='replay-02/results.json';
 auxBuilds='aux-01/builds.json';auxRuns='aux-01/results.json';constantBuilds='constants-02/builds.json';constantRuns='constants-02/results.json';methodBuilds='method-01/builds.json';methodRuns='method-01/results.json';extra='extra-01/results.json'
}
foreach($key in $sources.Keys){$records[$key]=Get-Content -LiteralPath "$stage/$($sources[$key])" -Raw|ConvertFrom-Json}
foreach($key in 'profiles','auxRuns','constantRuns','methodRuns'){if(@($records[$key]|Where-Object {-not $_.Success}).Count){throw "Failed $key"}}
foreach($key in 'freshRuns','finalRuns'){if(@($records[$key]|Where-Object {-not $_.ObservationMatched}).Count){throw "Changed actual $key"}}
if(@($records.native|Where-Object Exit -ne 0).Count -or @($records.check|Where-Object Exit -ne 0).Count){throw 'Failed lifetime fixture'}
if(@($records.native|Where-Object Tier -eq 'new154')[0].Diagnostic -notmatch 'NATIVE154: 126 checks, 0 failures'){throw 'Exact native fixture required'}
if(@($records.refusals|Where-Object {-not $_.OracleMatched}).Count){throw 'Changed negative oracle'}
foreach($name in @($records.extra|Select-Object -ExpandProperty Name -Unique)){
 $pair=@($records.extra|Where-Object Name -eq $name)
 if($pair.Count -ne 2 -or $pair[0].Exit -ne $pair[1].Exit -or $pair[0].Diagnostic -cne $pair[1].Diagnostic){throw 'Additional classification changed'}
}
Json154 "$dest/native154-results.json" $records
Json154 "$dest/native154-inputs.json" $pins
$summaries=@{};foreach($entry in @(@{Name='Fresh02';Path='values-01'},@{Name='Final03';Path='replay-02'},@{Name='Aux';Path='aux-01'},@{Name='Constants';Path='constants-02'},@{Name='Method';Path='method-01'})){$summaries[$entry.Name]=Get-Content -LiteralPath "$stage/$($entry.Path)/summary.json" -Raw|ConvertFrom-Json}
$receipt=@{
 State='Private154NativeBorrowsPreparedOperandsNotAllPathClosure';Date='2026-10-22';BaseMain='d2fe5a8b7e2658b441172a825791c06185f504f2';Candidate=$stage;Goal='active; unchanged full v3 objective'
 Parent153ReceiptSha256=(Get-FileHash -LiteralPath "$dest/check153-evidence.json").Hash;Parent153PatchSha256=$parent.SourcePatchSha256;Parent152SourceArchiveSha256=$parent.Parent152SourceArchiveSha256
 SourceHeaderFiles=281;UnchangedDependencies=280;ChangedImplementationSources=1;U0ReplayExact=$true
 SourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash;FrontendCSha256=(Get-FileHash -LiteralPath "$stage/frontend-03/frontend.c").Hash;FrontendExeSha256=(Get-FileHash -LiteralPath "$stage/frontend-03/l2trans.exe").Hash
 NativeAssertions=126;NativeAllocationRefusals=11;BaselineNativeAssertions=20;OwnedAssertions=398;MetadataAssertions=336;CommonIndexAssertions=420;DispatchAssertions=200;ReceivingAssertions=114;CheckCompatibilityAssertions=153;FinalFixtureFailures=0
 NativeWholePathRoots=@{Before=@(2,3);After=1};NativeWholePathFolds=@{Before=1;After=1};Rank129Adapters=@{Before=@(140,144);After=131};HeldNativePathRoots=0;HeldNativePathFolds=0;HeldNativePathBindingQueries=0
 HeldRank129IndependentIndexAdapters=129;HeldRank129UnqualifiedPointerTypeSpellingQueries=504;PointerTypeQueriesExplicitlySeparate=$true;RootPhysicalTypeTablePoisonClosure=$false
 Summaries=$summaries;FreshStrictO2CUnitsAcrossRecordedAttempts=113;ActualRuntimeExecutionsAcrossRecordedAttempts=432;LocatedNegativeCases=12;ActualNegativeTranslatorRuns=24;AdditionalSourceClassificationPairs=7
 ExactResultSources=$sources;RecipeFiles=$recipes;FixtureSha256=(Get-FileHash -LiteralPath "$dest/native154-test.c").Hash;SourcePatchSha256=(Get-FileHash -LiteralPath "$dest/native154-u0.patch").Hash;ResultsSha256=(Get-FileHash -LiteralPath "$dest/native154-results.json").Hash;ManifestSha256=(Get-FileHash -LiteralPath "$dest/native154-inputs.json").Hash
 FailureHistory=@('Frontend01 rejected missing new-helper prototype;02 fixes source declaration','Native01 counted literal name probes and pointer-type spelling together;03 recognizes literals before lexical lookup;final fixture separately counts pointer-type queries,poisons value spelling,does not claim FT poison closure','Initial replay oracle wrongly assumed13/17 checks;an unchanged throw case requires15;final02 uses the exact successful prior per-case oracle and CWD')
 Remaining=@('Group/Frame/index child ownership','Redundant physical root/declaration/type spelling projections','Indirect raw heads and callable/text clients','Public-dev/full kernel/Model/Shelf/K03/self-build/mail')
 NoOldBuildWrites=$true;ProtectedBasenameExcludedBeforeIO=$true;AllPathClosure=$false;PublicDevIntegrated=$false;FullKernelGate=$false;SelfBuild=$false;Mail=$false
}
Json154 "$dest/native154-evidence.json" $receipt
$receipt|Select-Object State,SourceSha256,FrontendCSha256,FrontendExeSha256,SourceHeaderFiles,UnchangedDependencies,NativeAssertions,FreshStrictO2CUnitsAcrossRecordedAttempts,ActualRuntimeExecutionsAcrossRecordedAttempts,U0ReplayExact|ConvertTo-Json
