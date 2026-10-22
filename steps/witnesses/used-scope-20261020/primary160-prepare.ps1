$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$prior="$repo/build2/codex_numeric_receiving159";$stage="$repo/build2/codex_primary_children160"
if(Test-Path -LiteralPath $stage){throw 'Preserve any existing primary160 work'}
git -C $repo merge-base --is-ancestor dae8d7a7ca2b2a2fa4056cf113f17f26e99360b6 HEAD
if($LASTEXITCODE -ne 0){throw 'Inspect changed base'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'Do not duplicate a live GCC pipeline'}
$pins=Get-Content -LiteralPath "$repo/steps/witnesses/used-scope-20261020/receive159-inputs.json" -Raw|ConvertFrom-Json
if($pins.Count -ne 281){throw 'Exact281 inputs required'}
New-Item -ItemType Directory -Path $stage|Out-Null
$prefix=[IO.Path]::GetFullPath($stage)+'\'
foreach($pin in $pins){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source=[IO.Path]::GetFullPath("$prior/$($pin.Path)");$target=[IO.Path]::GetFullPath("$stage/$($pin.Path)")
 if(-not $source.StartsWith(([IO.Path]::GetFullPath($prior)+'\'),[StringComparison]::OrdinalIgnoreCase) -or -not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'Manifest path outside the frozen source closure'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $pin.Sha256){throw 'Frozen159 source changed'}
 New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force|Out-Null
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $pin.Sha256){throw 'Copied bytes differ'}
}
Copy-Item -LiteralPath "$repo/steps/witnesses/used-scope-20261020/primary160-baseline-test.c" -Destination "$stage/primary-test.c"
Copy-Item -LiteralPath "$prior/owned-test.c" -Destination "$stage/owned-test.c"
[pscustomobject]@{Stage=$stage;SourceHeaderFiles=$pins.Count;SourceSha256=(Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash;ImplementationChanged=$false;FullGate=$false}|ConvertTo-Json
