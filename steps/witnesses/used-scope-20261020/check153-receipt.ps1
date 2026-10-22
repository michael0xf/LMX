$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$prior="$repo/build2/codex_places152_runtime_11";$stage="$repo/build2/codex_check_records153";$dest="$repo/steps/witnesses/used-scope-20261020";$out="$stage/receipt-03"
if(Test-Path -LiteralPath $out){throw 'Preserve receipt attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'No overlapping pipeline'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Json153([string]$Path,$Value){[IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 12).Replace("`r`n","`n")+"`n"),$utf8)}
$parent=Get-Content -LiteralPath "$dest/operand-places152-evidence.json" -Raw|ConvertFrom-Json
if((Get-FileHash -LiteralPath "$dest/operand-places152-inputs.tar.xz").Hash -cne $parent.InputArchiveSha256){throw 'Published source/input bundle changed'}
$manifest=Get-Content -LiteralPath "$dest/operand-places152-inputs.json" -Raw|ConvertFrom-Json
$sourcePins=@($manifest|Where-Object Path -like 'candidate152/*');if($sourcePins.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changes=0
foreach($pin in $sourcePins){
 $rel=$pin.Path.Substring('candidate152/'.Length);if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename BEFORE IO'}
 $hash=(Get-FileHash -LiteralPath "$stage/$rel").Hash
 if($hash -cne $pin.Sha256){$changes++;if($rel -notin @('src/l2src/l2trans.lm1','src/l2src/l2_application.h.lm1')){throw 'Unexpected dependency change'}}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
if($changes -ne 2){throw 'Expected compiler plus comment-only source header'}
# Diff only these exact sources,never directories containing protected logs.
$parts=@()
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){
 $piece="$out/$([IO.Path]::GetFileName($rel)).patch"
 & git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/$rel" "$stage/src/$rel"
 if($LASTEXITCODE -ne 1){throw 'Need actual exact-file source diffs'}
 $text=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_places152_runtime_11/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_check_records153/src/','b/src/')
 $parts+=$text.Replace('a/build2/codex_places152_runtime_11/src/','a/src/').Replace('b/build2/codex_check_records153/src/','b/src/')
 Copy-Item -LiteralPath "$prior/src/$rel" -Destination "$out/replay/src/$rel"
}
$text=$parts -join ''
if([regex]::Matches($text,'(?m)^diff --git ').Count -ne 2){throw 'Exactly two patched sources required'}
[IO.File]::WriteAllText("$dest/check153-u0.patch",$text.Replace("`r`n","`n"),$utf8)
& git.exe apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$dest/check153-u0.patch"
if($LASTEXITCODE -ne 0){throw 'Exact source replay failed'}
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){
 if((Get-FileHash -LiteralPath "$out/replay/src/$rel").Hash -cne (Get-FileHash -LiteralPath "$stage/src/$rel").Hash){throw 'Source replay differs'}
}
Copy-Item -LiteralPath "$stage/check-09/fixture.c" -Destination "$dest/check153-test.c"
Copy-Item -LiteralPath "$stage/constant-shadow.lm2" -Destination "$dest/check153-constant-shadow.lm2"
$recipes=@{}
foreach($entry in @(@{From='build';To='build'},@{From='routes';To='routes'},@{From='negatives';To='negatives'},@{From='reuse-values';To='values'},@{From='profiles';To='profiles'},@{From='check-test';To='probe'},@{From='receipt';To='receipt'},@{From='constants';To='constants'},@{From='extra-controls';To='extra-controls'})){
 $path="$dest/check153-$($entry.To).ps1";Copy-Item -LiteralPath "$stage/$($entry.From).ps1" -Destination $path
 $recipes[$entry.To]=@{Path="check153-$($entry.To).ps1";Sha256=(Get-FileHash -LiteralPath $path).Hash}
}
$records=@{}
foreach($entry in @(@{Name='constructor-owned';Path='frontend-07/results.json'},@{Name='source-routes';Path='routes-04/results.json'},@{Name='located-refusals';Path='negatives-03/results.json'},@{Name='check-probe';Path='check-09/results.json'},@{Name='profiles';Path='profiles-03/results.json'},@{Name='literal-graphs';Path='values-03/graphs.json'},@{Name='actual-values';Path='values-03/results.json'},@{Name='external-constant-values';Path='constants-01/results.json'},@{Name='external-constant-builds';Path='constants-01/builds.json'},@{Name='additional-source-controls';Path='extra-02/results.json'})){$records[$entry.Name]=Get-Content -LiteralPath "$stage/$($entry.Path)" -Raw|ConvertFrom-Json}
if(@($records['profiles']|Where-Object {-not $_.Success}).Count -or @($records['actual-values']|Where-Object {-not $_.ObservationMatched}).Count -or @($records['located-refusals']|Where-Object {-not $_.OracleMatched}).Count){throw 'Do not publish failed gates'}
if(@($records['check-probe']|Where-Object Exit -ne 0).Count){throw 'Both lifetime owners must pass the final fixture'}
$current=@($records['check-probe']|Where-Object Tier -eq 'new153')[0]
if($current.Diagnostic -notmatch 'CHECK153: 153 checks, 0 failures' -or $current.Diagnostic -notmatch 'allocation sites=10'){throw 'Exact current CHECK result required'}
if(@($records['external-constant-values']|Where-Object {-not $_.Success}).Count){throw 'Constant values failed'}
foreach($name in @($records['additional-source-controls']|Select-Object -ExpandProperty Name -Unique)){
 $pair=@($records['additional-source-controls']|Where-Object Name -eq $name)
 if($pair.Count -ne 2 -or $pair[0].Exit -ne $pair[1].Exit -or $pair[0].Diagnostic -cne $pair[1].Diagnostic -or $pair[0].L1Sha256 -cne $pair[1].L1Sha256){throw 'Additional old/new classification changed'}
}
Json153 "$dest/check153-results.json" $records
Json153 "$dest/check153-inputs.json" $pins
$receipt=@{
 State='Private153CheckBorrowsPreparedOperandsNotAllPathClosure';BaseMain='b792b8d1f09cf68be5c1a6528ab612b803fe54dd';Date='2026-10-22';Candidate=$stage;Goal='active; unchanged full v3 objective'
 Parent152SourceArchiveSha256=$parent.InputArchiveSha256;Parent152ReceiptSha256=(Get-FileHash -LiteralPath "$dest/operand-places152-evidence.json").Hash;SourceHeaderFiles=281;UnchangedDependencies=279;ChangedImplementationSources=1;CommentOnlySourceHeaderChanges=1;PatchedSourceFiles=2;GeneratedApplicationHeaderIdentical152=$true;U0ReplayExact=$true
 SourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash;FrontendCSha256=(Get-FileHash -LiteralPath "$stage/frontend-07/frontend.c").Hash;FrontendExeSha256=(Get-FileHash -LiteralPath "$stage/frontend-07/l2trans.exe").Hash
 OwnedAssertions=398;MetadataAssertions=336;CommonIndexAssertions=420;DispatchAssertions=200;ReceivingAssertions=114;CheckAssertions=153;CheckAllocationSitesRefused=10;BaselineCheckAssertions=40;BaselineAndCurrentFailures=0
 SourceRouteInputs=85;All85LiteralL1Identical152=$true;LocatedCheckControls=12;ActualNegativeTranslatorRuns=24;ChangedOracles=0
 ExternalConstants=(Get-Content -LiteralPath "$stage/constants-01/summary.json" -Raw|ConvertFrom-Json);ExtraSourceControlPairs=7;DeclaredConstantRoleSelectedOnlyAtCommonRoot=$true
 Values=(Get-Content -LiteralPath "$stage/values-03/summary.json" -Raw|ConvertFrom-Json)
 WholeCheckRoots=@{Before=2;After=1};WholeCheckFolds=@{Before=2;After=1};Rank129Adapters=@{Before=@(526,529);After=131};HeldCheckRootFoldBindingQueries=0;IndependentIndexOperandAdaptersAtRank129=129
 UnpreparedOperandsRefusedWithoutLookup=$true;ActualCommands=@(
  'pwsh.exe -NoProfile -File build2/codex_check_records153/build.ps1 -Label frontend-07',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/routes.ps1 -Label routes-04 -Frontend frontend-07',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/negatives.ps1 -Label negatives-03 -Frontend frontend-07',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/check-test.ps1 -Label check-09 -Frontend frontend-07',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/reuse-values.ps1',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/profiles.ps1',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/constants.ps1',
  'pwsh.exe -NoProfile -File build2/codex_check_records153/extra-controls.ps1'
 );RecipeFiles=$recipes;FixtureSha256=(Get-FileHash -LiteralPath "$dest/check153-test.c").Hash;SourcePatchSha256=(Get-FileHash -LiteralPath "$dest/check153-u0.patch").Hash;ResultsSha256=(Get-FileHash -LiteralPath "$dest/check153-results.json").Hash;ManifestSha256=(Get-FileHash -LiteralPath "$dest/check153-inputs.json").Hash
 FailureHistory=@('Initial01/03 C compilations caught unparenthesized dotted L1 actuals;source syntax fixed,not generated C','Initial04 exact source comparison rejected two hidden Array values via the legacy primitive-kind filter;05 consumes the completed exact FT,not a descriptor-kind exception','Additional source controls caught06 rejecting a declared C constant;07 selects its source role in the common root and native/RW project that role', 'A synthetic EMIT fixture aborted at tmpfile;replaced by an explicit output argument in its own build2 directory', 'Initial fixture lifetime oracle omitted bound-use metadata and compilation-owned type interning;final accounts for each real owner and both old/new balance')
 Remaining=@('Independent index/group/Frame child preparation lifetime','Native raw-expression names-only route','Indirect/callable/text clients','Redundant declaration projections and first-fold type interning lookups','Public-dev,full kernel,Model/Shelf,K03,self-build,mail')
 ExplicitReceiptIOExcludesProtectedBasename=$true;NoOldBuildWrites=$true;AllPathClosure=$false;PublicDevIntegrated=$false;FullKernelGate=$false;SelfBuild=$false;Mail=$false
}
Json153 "$dest/check153-evidence.json" $receipt
$receipt|ConvertTo-Json -Depth 6
