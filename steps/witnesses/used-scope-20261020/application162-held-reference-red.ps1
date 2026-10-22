#requires -Version 7.0
param([string]$Label='held-reference-red-01',[string]$Current='held-reference-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_application_sites162";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve RED observation'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o";$runtime="$repo/build2/codex_places152_runtime_11"
$rows=@()
foreach($tier in @(@{Name='old161';Dir='held-reference-old-01'},@{Name='current162';Dir=$Current})){
 $builds=Get-Content -LiteralPath "$stage/$($tier.Dir)/builds.json" -Raw|ConvertFrom-Json
 $build=@($builds|Where-Object Mode -eq 'forced')
 $object="$stage/$($tier.Dir)/forced.o"
 if($build.Count -ne 1 -or (Get-FileHash -LiteralPath $object).Hash -cne $build[0].ObjectSha256 -or (Get-FileHash -LiteralPath "$stage/$($tier.Dir)/source.lm2").Hash -cne $build[0].SourceSha256){throw 'Forced object/source no longer matches its observed build'}
 foreach($mode in 'production','observed'){
  $driver="$runtime/actual-02/driver.o";if($mode -eq 'observed'){$driver="$runtime/observed-02/driver.o"}
  $stem="$out/$($tier.Name)-$mode"
  $r=Invoke-ProcBounded -Exe $gcc -Argv @($object,$driver,$lib,'-Wl,--strip-debug','-o',"$stem.exe") -TimeoutSec 60 -Log "$stem.LINK.log"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'RED comparison link failed'}
  foreach($root in 0,1){
   $argv162=@('0','entry','7');if($root){$argv162+=@('walkroot','1')}
   $r=Invoke-ProcBounded -Exe "$stem.exe" -Argv $argv162 -TimeoutSec 60 -Log "$stem.RUN$root.log"
   $bodies=[regex]::Matches($r.Text,'PLACES152 WALK_BODY').Count;$checks=13;if($root){$checks=17}
   $positive=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $r.Text -match "l2_eternal_driver: $checks checks, 0 roots"
   $disposition='OPEN RED, not a replacement refusal oracle';if($positive){$disposition='Original positive value witness passed'}
   $rows+=@{Tier=$tier.Name;Mode='forced';Runtime=$mode;Root=$root;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;Bodies=$bodies;ObjectSha256=$build[0].ObjectSha256;SourceSha256=$build[0].SourceSha256;ExeSha256=(Get-FileHash -LiteralPath "$stem.exe").Hash;DriverSha256=(Get-FileHash -LiteralPath $driver).Hash;NormativePositiveExpected=$true;NormativeSuccess=$positive;Disposition=$disposition}
   [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 6).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
   if(-not $positive -and (-not $r.Started -or $r.TimedOut -or $r.Code -ne 3 -or $r.Text -notmatch 'walk error: INVALID')){throw 'Additional held-reference observation changed; inspect actual result'}
   if($positive -and $mode -eq 'observed' -and $bodies -ne (9+$root)){throw 'Forced held-reference positive did not enter the actual method bodies'}
  }
 }
}
foreach($mode in 'production','observed'){foreach($root in 0,1){$pair=@($rows|Where-Object {$_.Runtime -eq $mode -and $_.Root -eq $root});if($pair.Count -ne 2 -or $pair[0].Exit -ne $pair[1].Exit -or $pair[0].Diagnostic -cne $pair[1].Diagnostic){throw 'Old/current held-reference RED differs'}}}
@{Observations=$rows.Count;SameOldObservedResults=$true;PositiveRuns=@($rows|Where-Object NormativeSuccess).Count;OpenRedRuns=@($rows|Where-Object {-not $_.NormativeSuccess}).Count;NormativePositiveStillRed=$true;FullGate=$false}|ConvertTo-Json
