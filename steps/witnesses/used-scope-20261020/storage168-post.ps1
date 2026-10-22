#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_contract168"
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
if((Get-Content -LiteralPath "$stage/storage-controls03.log" -Raw) -notmatch 'STORAGE168 historical controls TERMINAL'){throw 'Historical controls03 must finish first'}
$observations=@()
foreach($tier in @(@{Name='parent167';Exe="$repo/build2/codex_primary_projection167/frontend-05/l2trans.exe"},@{Name='current168';Exe="$stage/frontend-06/l2trans.exe"})){
 $label="machine-unevaluated-$($tier.Name)-02"
 & pwsh.exe -NoProfile -File "$stage/named-values.ps1" -Frontend frontend-06 -Label $label -SourceFile machine-unevaluated-open.lm2 -ForcedBodies 0 -CompilerPath $tier.Exe *> "$stage/$label.log"
 $processExit=$LASTEXITCODE
 if($processExit -ne 1 -or -not(Test-Path -LiteralPath "$stage/$label/results.json")){throw 'Unevaluated C-door probe needs an inspectable terminal runtime observation'}
 $builds=@(Get-Content -LiteralPath "$stage/$label/builds.json" -Raw|ConvertFrom-Json);$runs=@(Get-Content -LiteralPath "$stage/$label/results.json" -Raw|ConvertFrom-Json)
 if($builds.Count -ne 1 -or $runs.Count -ne 1 -or $runs[0].Success -or $runs[0].Diagnostic -notmatch 'UNEVALUATED168 result=88 touches=1'){throw 'Unexpected open witness; inspect,do not recast failure as an oracle'}
 $observations+=@{Tier=$tier.Name;Label=$label;ProcessExit=$processExit;State='OPEN positive requires value7 and no touch,actual88 is an implementation defect';SourceSha256=(Get-FileHash -LiteralPath "$stage/machine-unevaluated-open.lm2").Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash;ActualRuns=1;NotPositiveGate=$true}
}
[IO.File]::WriteAllText("$stage/machine-unevaluated-open.json",(($observations|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
Write-Output 'POST168 historical values and explicit OPEN C-door counterexample TERMINAL'
