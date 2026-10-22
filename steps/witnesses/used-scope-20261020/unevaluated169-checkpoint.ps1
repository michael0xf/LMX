#requires -Version 7.0
param([string]$Frontend='frontend-02',[string]$Label='checkpoint-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_unevaluated169";$prior="$repo/build2/codex_primary_contract168";$published="$repo/steps/witnesses/used-scope-20261020";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve checkpoint; use a fresh label'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src","$out/replay/headers/l2src","$out/replay/src/l1src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Hash169([string]$Path){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};$full=[IO.Path]::GetFullPath($Path);if($full.StartsWith([IO.Path]::GetFullPath("$repo/build")+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Old build IO forbidden'};return (Get-FileHash -LiteralPath $full).Hash}
function Json169([string]$Path,$Data){[IO.File]::WriteAllText($Path,(($Data|ConvertTo-Json -Depth 12).Replace([string][char]13,'')+[char]10),$utf8)}
$parent=Get-Content -LiteralPath "$published/storage168-evidence.json" -Raw|ConvertFrom-Json
if((Hash169 "$published/storage168-u0.patch") -cne $parent.SourcePatchSha256){throw 'Published parent source patch changed'}
if((Hash169 "$published/storage168-inputs.json") -cne $parent.ManifestSha256){throw 'Published parent manifest changed'}
$before=Get-Content -LiteralPath "$published/storage168-inputs.json" -Raw|ConvertFrom-Json
if($before.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changed=@()
foreach($pin in $before){
 $rel=$pin.Path;if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if((Hash169 "$prior/$rel") -cne $pin.Sha256){throw 'Frozen168 input changed'}
 $hash=Hash169 "$stage/$rel";if($hash -cne $pin.Sha256){$changed+=$rel}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
# The two edited sources and the application header generated from one of them.
$expected=@('src/l2src/l2trans.lm1','src/l2src/l2_application.h.lm1','headers/l2src/l2_application.lm1.h')
if($changed.Count -ne 3 -or @($changed|Where-Object {$_ -notin $expected}).Count){throw 'Unexpected source/header changes'}
if((Hash169 "$prior/src/l2src/l2trans.lm1") -cne $parent.SourceSha256){throw 'Parent source is not the published frozen168 source'}
$built=Get-Content -LiteralPath "$stage/$Frontend/results.json" -Raw|ConvertFrom-Json
if($built.Exit -ne 0 -or (Hash169 "$stage/src/l2src/l2trans.lm1") -cne $built.SourceSha256 -or (Hash169 "$stage/$Frontend/frontend-source.lm1") -cne $built.SourceSha256 -or (Hash169 "$stage/$Frontend/frontend.c") -cne $built.FrontendCSha256 -or (Hash169 "$stage/$Frontend/l2trans.exe") -cne $built.FrontendExeSha256){throw 'Candidate differs from the observed immutable frontend'}
$parts=@()
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){
 $piece="$out/$([IO.Path]::GetFileName($rel)).patch"
 & git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/$rel" "$stage/src/$rel"
 if($LASTEXITCODE -ne 1){throw 'Need exact-file source diff'}
 $parts+=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_primary_contract168/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_unevaluated169/src/','b/src/').Replace('a/build2/codex_primary_contract168/src/','a/src/').Replace('b/build2/codex_unevaluated169/src/','b/src/')
 Copy-Item -LiteralPath "$prior/src/$rel" -Destination "$out/replay/src/$rel"
}
[IO.File]::WriteAllText("$out/unevaluated169-u0.patch",(($parts -join '').Replace([string][char]13,'')),$utf8)
# From the repository root: run from a subdirectory, git apply silently
# ignores paths outside it.
& git.exe -C $repo apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$out/unevaluated169-u0.patch"
if($LASTEXITCODE -ne 0){throw 'Exact source replay failed'}
foreach($rel in 'l2src/l2trans.lm1','l2src/l2_application.h.lm1'){if((Hash169 "$out/replay/src/$rel") -cne (Hash169 "$stage/src/$rel")){throw 'Replayed source differs'}}
# The header is generated from the REPLAYED application source; p0 is unchanged.
Copy-Item -LiteralPath "$stage/src/l1src/p0.h.lm1" -Destination "$out/replay/src/l1src/p0.h.lm1"
. "$repo/tools/ps51_proc.ps1"
$saved=[Environment]::CurrentDirectory;Push-Location "$out/replay/src"
try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$repo/bin/l1trans.exe" -Argv @("$out/replay/src/l2src/l2_application.h.lm1","$out/replay/headers/l2src/l2_application.lm1.h") -TimeoutSec 60 -Log "$out/HEADER.log"}
finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or (Hash169 "$out/replay/headers/l2src/l2_application.lm1.h") -cne (Hash169 "$stage/headers/l2src/l2_application.lm1.h")){throw 'Application header replay differs'}
Json169 "$out/unevaluated169-inputs.json" $pins
$baseMain=(& git.exe -C $repo rev-parse HEAD).Trim()
$receipt=@{State='WIP checkpoint, not a completed regression or dependency-closed publication';BaseMain=$baseMain;Frontend=$Frontend;SourceSha256=$built.SourceSha256;FrontendCSha256=$built.FrontendCSha256;FrontendExeSha256=$built.FrontendExeSha256;Inputs=281;ChangedInputs=$changed;UnchangedInputs=278;SourcePatchSha256=(Hash169 "$out/unevaluated169-u0.patch");ManifestSha256=(Hash169 "$out/unevaluated169-inputs.json");ParentReceiptSha256=(Hash169 "$published/storage168-evidence.json");ParentSourceSha256=$parent.SourceSha256;SourceReplayExact=$true;HeaderReplayExact=$true;CDoorClosure=$false;AllApplicationConsumers=$false;AllPathClosure=$false;FullGate=$false;SelfBuild=$false;Mail=$false;ProtectedBasenameExcludedBeforeIO=$true;OldBuildUntouched=$true}
Json169 "$out/checkpoint.json" $receipt
$receipt|ConvertTo-Json -Depth 5
