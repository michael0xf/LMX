param([string]$Label='receive-values-01',[string]$Frontend='frontend-04',[string]$CompilerPath='',[ValidateSet('receive-values.lm2','receive-hidden.lm2','receive-actual.lm2','receive-foreign.lm2')][string]$SourceFile='receive-values.lm2',[int]$ForcedBodies=6)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_children160";$out="$stage/$Label";$base="$repo/buold_temp"
if(Test-Path -LiteralPath $out){throw 'Preserve actual receiving attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run159([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){
 $saved=[Environment]::CurrentDirectory;Push-Location $Cwd
 try{[Environment]::CurrentDirectory=$Cwd;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$compiler="$stage/$Frontend/l2trans.exe";$source="$stage/$SourceFile"
if($CompilerPath){$compiler=$CompilerPath}
Copy-Item -LiteralPath $source -Destination "$out/source.lm2"
$source="$out/source.lm2"
$prior="$repo/build2/codex_places152_runtime_11";$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$rows=@();$builds=@()
foreach($mode in 'native','forced'){
 $stem="$out/$mode";$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
 foreach($phase in @(
  @{Name='L2';Tool=$compiler;Args=($extra+@($source,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$stem.lm1"))},
  @{Name='L1';Tool="$repo/bin/l1trans.exe";Args=@("$stem.lm1","$stem.c")},
  @{Name='COMPILE';Tool=$gcc;Args=($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o"))}
 )){
  $r=Run159 $phase.Tool $phase.Args "$stem.$($phase.Name).log" "$stage/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual receiving $mode $($phase.Name) failed"}
 }
 $builds+=@{Mode=$mode;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $compiler).Hash;L1Sha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;CSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;FreshStrictO2=$true}
 $builds|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/builds.json" -Encoding UTF8
 foreach($runtime in 'production','observed'){
  $driver="$prior/actual-02/driver.o";if($runtime -eq 'observed'){$driver="$prior/observed-02/driver.o"}
  $exe="$stem-$runtime.exe"
  $r=Run159 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',$exe) "$stem-$runtime.LINK.log" "$stage/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Receiving value link failed'}
  foreach($root in 0,1){
   $argv159=@('0','entry','7');if($root){$argv159+=@('walkroot','1')}
   $r=Run159 $exe $argv159 "$stem-$runtime.RUN$root.log" $out
   $bodies=[regex]::Matches($r.Text,'PLACES152 WALK_BODY').Count
   $expected=0;if($runtime -eq 'observed'){$expected=$root;if($mode -eq 'forced'){$expected+=$ForcedBodies}}
   $checks=13;if($root){$checks=17}
   $ok=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $r.Text -match "l2_eternal_driver: $checks checks, 0 roots" -and $bodies -eq $expected
   $rows+=@{Mode=$mode;Runtime=$runtime;Root=$root;Exit=$r.Code;Bodies=$bodies;ExpectedBodies=$expected;Success=$ok;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;DriverSha256=(Get-FileHash -LiteralPath $driver).Hash}
   $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
   $r.Text
   if(-not $ok){throw 'Actual receiving value/order/body witness failed'}
  }
 }
}
@{FreshStrictO2Units=$builds.Count;ActualRuns=$rows.Count;MatchingRuns=@($rows|Where-Object Success).Count;AllPathClosure=$false;FullGate=$false}|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
