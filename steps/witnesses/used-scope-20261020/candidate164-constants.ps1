param([ValidatePattern('^constants-[0-9]+$')][string]$Label='constants-01',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-05')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$prior="$repo/build2/codex_places152_runtime_11";$stage="$repo/build2/codex_candidate_values164";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve constant value witnesses'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run154([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){
 $saved=[Environment]::CurrentDirectory;Push-Location $Cwd
 try{[Environment]::CurrentDirectory=$Cwd;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$cases=@(@{Name='text';Source="$repo/dev/l2src_sandbox/tests/unit_define_ccall.lm2";Entry=11;Bodies=0},@{Name='shadow';Source="$stage/constant-shadow.lm2";Entry=7;Bodies=1})
$tiers=@(@{Name='old152';Stage=$prior;Compiler="$prior/frontend-values-02/l2trans.exe"},@{Name='new159';Stage=$stage;Compiler="$stage/$Frontend/l2trans.exe"})
$rows=@();$builds=@()
foreach($case in $cases){foreach($tier in $tiers){foreach($mode in 'native','forced'){
 $stem="$out/$($case.Name)-$($tier.Name)-$mode";$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
 $flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$($tier.Stage)/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$($tier.Stage)/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
 foreach($phase in @(
  @{Name='L2';Tool=$tier.Compiler;Args=($extra+@($case.Source,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$stem.lm1"))},
  @{Name='L1';Tool="$repo/bin/l1trans.exe";Args=@("$stem.lm1","$stem.c")},
  @{Name='COMPILE';Tool=$gcc;Args=($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o"))}
 )){
  $r=Run154 $phase.Tool $phase.Args "$stem.$($phase.Name).log" "$($tier.Stage)/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual $($case.Name) $($tier.Name) $mode $($phase.Name) failed"}
 }
 $builds+=@{Case=$case.Name;Tier=$tier.Name;Mode=$mode;SourceSha256=(Get-FileHash -LiteralPath $case.Source).Hash;GraphSha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;CSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Compiler).Hash;FreshStrictO2Unit=$true}
 $builds|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/builds.json" -Encoding UTF8
 foreach($runtime in 'production','observed'){
  $driver="$prior/actual-02/driver.o";if($runtime -eq 'observed'){$driver="$prior/observed-02/driver.o"}
  $exe="$stem-$runtime.exe"
  $r=Run154 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',$exe) "$stem-$runtime.LINK.log" "$($tier.Stage)/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Actual constant link failed'}
  foreach($root in 0,1){
   $args154=@('0','entry',[string]$case.Entry);if($root){$args154+=@('walkroot','1')}
   $r=Run154 $exe $args154 "$stem-$runtime.RUN$root.log" $out
   $bodies=[regex]::Matches($r.Text,'PLACES152 WALK_BODY').Count;$expected=0;if($runtime -eq 'observed'){$expected=$root;if($mode -eq 'forced'){$expected+=$case.Bodies}}
   $checks=13;if($root){$checks=17}
   $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $bodies -eq $expected -and $r.Text -match "l2_eternal_driver: $checks checks, 0 roots"
   $rows+=@{Case=$case.Name;Tier=$tier.Name;Mode=$mode;Runtime=$runtime;Root=$root;Entry=$case.Entry;ActualExit=$r.Code;ActualBodies=$bodies;ExpectedBodies=$expected;Success=$okay;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;DriverSha256=(Get-FileHash -LiteralPath $driver).Hash}
   $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
   if(-not $okay){throw 'Actual constant value, shadowed binding or walked body count failed'}
  }
 }
 Write-Output "$($case.Name) $($tier.Name) ${mode}: actual production/observer root0/1 matched"
}}}
$summary=@{Programs=2;FreshStrictO2Units=$builds.Count;ActualRuns=$rows.Count;Green=@($rows|Where-Object Success).Count;NonzeroTextResult=11;ShadowedFormalResult=7;TextMethodRemainsNativeOnly=$true;PureShadowMethodActuallyWalked=$true;FullGate=$false;AllPathClosure=$false}
$summary|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary|ConvertTo-Json
