param([ValidatePattern('^aux-[0-9]+$')][string]$Label='aux-01',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-05')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_application_values161";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve actual auxiliary observations'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out | Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run154([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){
 $saved=[Environment]::CurrentDirectory;Push-Location $Cwd
 try{[Environment]::CurrentDirectory=$Cwd;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$compiler="$stage/$Frontend/l2trans.exe";$cwd="$base/l2_harness/codex_consumer49_full_01/src"
$production="$repo/build2/codex_places152_runtime_11/actual-02/driver.o";$observed="$repo/build2/codex_places152_runtime_11/observed-02/driver.o";$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$compilerHash=(Get-FileHash -LiteralPath $compiler).Hash
if((Get-FileHash -LiteralPath $production).Hash -cne 'C026245020CC2E54538EF9BBAA39C9878460358C3788A2FC3DEE6DAA45A293A4'){throw 'Wrong production runtime'}
if((Get-FileHash -LiteralPath $observed).Hash -cne '97566328E3D9FEF3069BB431B644025986CD32EBE3FE16844736E96070196731'){throw 'Wrong body observer'}
$flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'-I',$cwd,'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$cases=@(
 @{Name='mixed';Source='codex_address148_mixed_frame_01.lm2';Bodies=10;Roots=@(0,1);Exit=0},
 @{Name='mapped';Source='codex_address148_mapped_frame_01.lm2';Bodies=1;Roots=@(0,1);Exit=0},
 @{Name='hidden';Source='codex_hidden79_indexed_01.lm2';Bodies=2;Roots=@(0,1);Exit=0},
 @{Name='offsets';Source='codex_paths149_offsets_01.lm2';Bodies=0;Roots=@(0);Exit=0},
 @{Name='foreign';Source='codex_address148_foreign_frame_06.lm2';Bodies=0;Roots=@(0);Exit=0},
 @{Name='mixed_drop';Source='codex_address148_mixed_drop_01.lm2';Bodies=10;Roots=@(0);Exit=1},
 @{Name='mapped_drop';Source='codex_address148_mapped_drop_01.lm2';Bodies=1;Roots=@(0);Exit=1},
 @{Name='offsets_drop';Source='codex_paths149_offsets_drop_01.lm2';Bodies=0;Roots=@(0);Exit=1}
)
$rows=@();$builds=@()
foreach($case in $cases){
 foreach($mode in 'native','forced'){
  $stem="$out/$($case.Name)-$mode";$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
  $input="$base/$($case.Source)"
  foreach($phase in @(
   @{Name='L2';Tool=$compiler;Args=($extra+@($input,'convert.lm2','primitive.lm2',"$stem.lm1"));Cwd=$cwd},
   @{Name='L1';Tool="$repo/bin/l1trans.exe";Args=@("$stem.lm1","$stem.c");Cwd="$stage/src"},
   @{Name='COMPILE';Tool=$gcc;Args=($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o"));Cwd="$stage/src"}
  )){
   $r=Run154 $phase.Tool $phase.Args "$stem.$($phase.Name).log" $phase.Cwd
   if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual $($case.Name) $mode $($phase.Name) failed"}
  }
  $builds+=@{Case=$case.Name;Mode=$mode;Source=$input;SourceSha256=(Get-FileHash -LiteralPath $input).Hash;GeneratedL1Sha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;GeneratedCSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;FreshStrictO2=$true}
  $builds | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$out/builds.json" -Encoding UTF8
  foreach($runtime in 'production','observed'){
   $obj=$production;if($runtime -eq 'observed'){$obj=$observed}
   $exe="$stem-$runtime.exe"
   $r=Run154 $gcc @("$stem.o",$obj,$lib,'-Wl,--strip-debug','-o',$exe) "$stem-$runtime.LINK.log" "$stage/src"
   if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Actual auxiliary link failed'}
   foreach($root in $case.Roots){
    $argv154=@('0','entry','7');if($root){$argv154+=@('walkroot','1')}
    $expected=0;if($runtime -eq 'observed'){$expected=$root;if($mode -eq 'forced'){$expected+=$case.Bodies}}
    $r=Run154 $exe $argv154 "$stem-$runtime.RUN$root.log" $out
    $bodies=[regex]::Matches($r.Text,'PLACES152 WALK_BODY').Count
    $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq $case.Exit -and $bodies -eq $expected
    $rows+=@{Case=$case.Name;Mode=$mode;Runtime=$runtime;Root=$root;ActualExit=$r.Code;ExpectedExit=$case.Exit;ActualBodies=$bodies;ExpectedBodies=$expected;Success=$okay;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;RuntimeSha256=(Get-FileHash -LiteralPath $obj).Hash}
    $rows | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
    if(-not $okay){throw "Actual value/entry-count mismatch: $($case.Name) $mode $runtime root$root"}
   }
  }
 }
 Write-Output "$($case.Name): native/forced production/observed unchanged value and body-entry oracles matched"
}
$negative=@()
foreach($name in 'levels','value'){
 $input="$repo/dev/l2src_sandbox/tests/unit_array_binding_$($name)_refused.lm2"
 $r=Run154 $compiler @($input,'convert.lm2','primitive.lm2',"$out/refused-$name.lm1") "$out/refused-$name.log" $cwd
 $oracle="a binding's levels are not the value's";if($name -eq 'value'){$oracle='an Array binding needs an Array value'}
 $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq 1 -and $r.Text -match [regex]::Escape($oracle)
 $negative+=@{Name=$name;ActualExit=$r.Code;SourceSha256=(Get-FileHash -LiteralPath $input).Hash;Oracle=$oracle;Diagnostic=$r.Text;Success=$okay}
 $negative | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$out/refusals.json" -Encoding UTF8
 if(-not $okay){throw 'Legitimate Array mismatch must still refuse'}
}
$summary=@{Programs=$cases.Count;FreshStrictO2Units=$builds.Count;ActualPositiveRuns=@($rows|Where-Object ExpectedExit -eq 0).Count;ActualCounterfactualRuns=@($rows|Where-Object ExpectedExit -eq 1).Count;MatchingRuns=@($rows|Where-Object Success).Count;LocatedCheckRefusals=$negative.Count;AllPathClosure=$false;FullKernelGate=$false}
$summary | ConvertTo-Json | Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary | ConvertTo-Json
