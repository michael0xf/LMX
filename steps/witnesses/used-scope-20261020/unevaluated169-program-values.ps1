#requires -Version 7.0
# named-values.ps1's phases and oracles, with the roots to run as a parameter
# and an -Observe mode that records a failing phase or run instead of throwing
# (a parent observation is OPEN evidence, never a green execution).
param([string]$Label='program-values-01',[string]$Frontend='frontend-02',[string]$CompilerPath='',[string]$SourceFile='unevaluated-values.lm2',[int]$ForcedBodies=0,[int]$NativeBodies=0,[int[]]$Roots=@(0,1),[switch]$Observe)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_unevaluated169";$out="$stage/$Label";$base="$repo/buold_temp"
if(Test-Path -LiteralPath $out){throw 'Preserve program attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run169([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){
 $saved=[Environment]::CurrentDirectory;Push-Location $Cwd
 try{[Environment]::CurrentDirectory=$Cwd;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
function Json169([string]$Name,$Data){[IO.File]::WriteAllText("$out/$Name",(($Data|ConvertTo-Json -Depth 6).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$compiler="$stage/$Frontend/l2trans.exe";$source="$stage/$SourceFile"
if($CompilerPath){$compiler=$CompilerPath}
Copy-Item -LiteralPath $source -Destination "$out/source.lm2"
$source="$out/source.lm2"
$prior="$repo/build2/codex_places152_runtime_11";$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$rows=@();$builds=@();$phases=@()
foreach($mode in 'native','forced'){
 $stem="$out/$mode";$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
 $built=$true
 foreach($phase in @(
  @{Name='L2';Tool=$compiler;Args=($extra+@($source,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$stem.lm1"))},
  @{Name='L1';Tool="$repo/bin/l1trans.exe";Args=@("$stem.lm1","$stem.c")},
  @{Name='COMPILE';Tool=$gcc;Args=($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o"))}
 )){
  $r=Run169 $phase.Tool $phase.Args "$stem.$($phase.Name).log" "$stage/src"
  $phases+=@{Mode=$mode;Phase=$phase.Name;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text};Json169 'phases.json' $phases
  if(-not $r.Started -or $r.TimedOut){throw "Program $mode $($phase.Name) did not terminate"}
  if($r.Code -ne 0){if($Observe){Write-Output "OBSERVED $mode $($phase.Name) exit $($r.Code)";$built=$false;break};throw "Program $mode $($phase.Name) failed"}
 }
 if(-not $built){continue}
 $builds+=@{Mode=$mode;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $compiler).Hash;L1Sha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;CSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;FreshStrictO2=$true}
 Json169 'builds.json' $builds
 foreach($runtime in 'production','observed'){
  $driver="$prior/actual-02/driver.o";if($runtime -eq 'observed'){$driver="$prior/observed-02/driver.o"}
  $exe="$stem-$runtime.exe"
  $r=Run169 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',$exe) "$stem-$runtime.LINK.log" "$stage/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Program link failed'}
  foreach($root in $Roots){
   $argv169=@('0','entry','7');if($root){$argv169+=@('walkroot','1')}
   $r=Run169 $exe $argv169 "$stem-$runtime.RUN$root.log" $out
   $bodies=[regex]::Matches($r.Text,'PLACES152 WALK_BODY').Count
   $expected=0;if($runtime -eq 'observed'){$expected=$root+$NativeBodies;if($mode -eq 'forced'){$expected=$root+$ForcedBodies}}
   $checks=13;if($root){$checks=17}
   $ok=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $r.Text -match "l2_eternal_driver: $checks checks, 0 roots" -and $bodies -eq $expected
   $rows+=@{Mode=$mode;Runtime=$runtime;Root=$root;Exit=$r.Code;Bodies=$bodies;ExpectedBodies=$expected;Success=$ok;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;DriverSha256=(Get-FileHash -LiteralPath $driver).Hash}
   Json169 'results.json' $rows
   $r.Text
   if(-not $r.Started -or $r.TimedOut){throw 'Program run did not terminate'}
   if(-not $ok -and -not $Observe){throw 'Program value/body witness failed'}
  }
 }
}
Json169 'summary.json' @{Observe=[bool]$Observe;Roots=$Roots;FreshStrictO2Units=$builds.Count;ActualRuns=$rows.Count;MatchingRuns=@($rows|Where-Object Success).Count;AllPathClosure=$false;FullGate=$false}
