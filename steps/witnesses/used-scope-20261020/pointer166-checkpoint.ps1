#requires -Version 7.0
param([string]$Frontend='frontend-06',[string]$Label='checkpoint-03')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_pointer_receive166";$prior="$repo/build2/codex_reference_receive165";$published="$repo/steps/witnesses/used-scope-20261020";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve checkpoint; use a fresh label'}
New-Item -ItemType Directory -Path "$out/replay/src/l2src","$out/replay/headers/l2src","$out/replay/src/l1src"|Out-Null
$utf8=[Text.UTF8Encoding]::new($false)
function Hash166([string]$Path){if([IO.Path]::GetFileName($Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'};return (Get-FileHash -LiteralPath $Path).Hash}
function Json166([string]$Path,$Data){[IO.File]::WriteAllText($Path,(($Data|ConvertTo-Json -Depth 12).Replace([string][char]13,'')+[char]10),$utf8)}
$parent=Get-Content -LiteralPath "$published/receiving165-evidence.json" -Raw|ConvertFrom-Json
if((Hash166 "$published/receiving165-u0.patch") -cne $parent.SourcePatchSha256){throw 'Published parent source patch changed'}
$before=Get-Content -LiteralPath "$published/receiving165-inputs.json" -Raw|ConvertFrom-Json
if($before.Count -ne 281){throw 'Exact281 source/header closure'}
$pins=@();$changed=@()
foreach($pin in $before){
 $rel=$pin.Path;if([IO.Path]::GetFileName($rel) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if((Hash166 "$prior/$rel") -cne $pin.Sha256){throw 'Frozen165 input changed'}
 $hash=Hash166 "$stage/$rel";if($hash -cne $pin.Sha256){$changed+=$rel}
 $pins+=@{Path=$rel;Sha256=$hash;Bytes=(Get-Item -LiteralPath "$stage/$rel").Length}
}
$expected=@('src/l2src/l2trans.lm1')
if($changed.Count -ne 1 -or @($changed|Where-Object {$_ -notin $expected}).Count){throw 'Unexpected source/header changes'}
$built=Get-Content -LiteralPath "$stage/$Frontend/results.json" -Raw|ConvertFrom-Json
if($built.Exit -ne 0 -or (Hash166 "$stage/src/l2src/l2trans.lm1") -cne $built.SourceSha256 -or (Hash166 "$stage/$Frontend/frontend-source.lm1") -cne $built.SourceSha256 -or (Hash166 "$stage/$Frontend/frontend.c") -cne $built.FrontendCSha256 -or (Hash166 "$stage/$Frontend/l2trans.exe") -cne $built.FrontendExeSha256){throw 'Candidate differs from the observed immutable frontend'}
$parts=@()
foreach($rel in 'l2src/l2trans.lm1'){
 $piece="$out/$([IO.Path]::GetFileName($rel)).patch"
 & git.exe -c core.autocrlf=false diff --no-index --no-ext-diff --unified=0 --output=$piece -- "$prior/src/$rel" "$stage/src/$rel"
 if($LASTEXITCODE -ne 1){throw 'Need exact-file source diff'}
 $parts+=[IO.File]::ReadAllText($piece).Replace('a/C:/Nyasha_Planet/LMX/build2/codex_reference_receive165/src/','a/src/').Replace('b/C:/Nyasha_Planet/LMX/build2/codex_pointer_receive166/src/','b/src/').Replace('a/build2/codex_reference_receive165/src/','a/src/').Replace('b/build2/codex_pointer_receive166/src/','b/src/')
 Copy-Item -LiteralPath "$prior/src/$rel" -Destination "$out/replay/src/$rel"
}
[IO.File]::WriteAllText("$out/pointer166-u0.patch",(($parts -join '').Replace([string][char]13,'')),$utf8)
& git.exe apply --unidiff-zero --unsafe-paths --directory="$out/replay" "$out/pointer166-u0.patch"
if($LASTEXITCODE -ne 0){throw 'Exact source replay failed'}
foreach($rel in 'l2src/l2trans.lm1'){if((Hash166 "$out/replay/src/$rel") -cne (Hash166 "$stage/src/$rel")){throw 'Replayed source differs'}}
Copy-Item -LiteralPath "$stage/src/l2src/l2_application.h.lm1" -Destination "$out/replay/src/l2src/l2_application.h.lm1"
Copy-Item -LiteralPath "$stage/src/l1src/p0.h.lm1" -Destination "$out/replay/src/l1src/p0.h.lm1"
. "$repo/tools/ps51_proc.ps1"
$saved=[Environment]::CurrentDirectory;Push-Location "$out/replay/src"
try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$repo/bin/l1trans.exe" -Argv @("$out/replay/src/l2src/l2_application.h.lm1","$out/replay/headers/l2src/l2_application.lm1.h") -TimeoutSec 60 -Log "$out/HEADER.log"}
finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or (Hash166 "$out/replay/headers/l2src/l2_application.lm1.h") -cne (Hash166 "$stage/headers/l2src/l2_application.lm1.h")){throw 'Application header replay differs'}
Json166 "$out/pointer166-inputs.json" $pins
$receipt=@{State='WIP checkpoint, not a completed regression or dependency-closed publication';BaseMain='8a84e6ea1fc296fef838a889cc192dd3fa3a832c';Frontend=$Frontend;SourceSha256=$built.SourceSha256;FrontendCSha256=$built.FrontendCSha256;FrontendExeSha256=$built.FrontendExeSha256;Inputs=281;ChangedInputs=$changed;UnchangedInputs=280;SourcePatchSha256=(Hash166 "$out/pointer166-u0.patch");ManifestSha256=(Hash166 "$out/pointer166-inputs.json");ParentReceiptSha256=(Hash166 "$published/receiving165-evidence.json");SourceReplayExact=$true;HeaderReplayExact=$true;AllApplicationConsumers=$false;SyntheticP0CopierRemoved=$false;AllPathClosure=$false;FullGate=$false;SelfBuild=$false;Mail=$false;ProtectedBasenameExcludedBeforeIO=$true;OldBuildUntouched=$true}
Json166 "$out/checkpoint.json" $receipt
$receipt|ConvertTo-Json -Depth 5
