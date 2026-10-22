#requires -Version 7.0
param([string]$Frontend='frontend-05',[string]$Label='storage-controls-01',[switch]$TranslateOnly)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_contract168";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve historical storage controls'}
if(-not $TranslateOnly -and (Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue)){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run168([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){$saved=[Environment]::CurrentDirectory;Push-Location $Cwd;try{[Environment]::CurrentDirectory=$Cwd;Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}finally{[Environment]::CurrentDirectory=$saved;Pop-Location}}
function Json168([string]$Name,$Data){[IO.File]::WriteAllText("$out/$Name",(($Data|ConvertTo-Json -Depth 8).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))}
$cases=@(
 @{Name='unit_sizeof_type_int';Value=0},@{Name='unit_sizeof_struct_ref';Value=0},@{Name='unit_sizeof_own_local';Value=0},@{Name='unit_sizeof_array_bytes';Value=0},
 @{Name='unit_sizeof_type_frame';Value=7},@{Name='unit_sizeof_long_name';Value=7},@{Name='unit_exprtext_sizeof_frame';Value=7},@{Name='unit_own_find_last_sizeof';Value=7},@{Name='unit_site_sizeof_hidden';Value=7},@{Name='unit_csizeof_operand_lowered';Value=7},@{Name='unit_sizeof_c_door_arena';Value=0},
 @{Name='unit_sizeof_arg';Inspect=$true},@{Name='unit_sizeof_element';Inspect=$true},@{Name='library_sizeof_ptr_forms';Inspect=$true},
 @{Name='unit_sizeof_unknown_refused';Inspect=$true},@{Name='unit_sizeof_type_frame_refused';Inspect=$true},@{Name='unit_csizeof_type_frame_refused';Inspect=$true},@{Name='unit_k03_empty_sizeof_assign_refused';Inspect=$true},@{Name='unit_k03_empty_sizeof_stmt_refused';Inspect=$true}
)
$flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o";$driver="$repo/build2/codex_places152_runtime_11/actual-02/driver.o";$routes=@();$builds=@();$runs=@()
foreach($case in $cases){
 $source="$repo/dev/l2src_sandbox/tests/$($case.Name).lm2"
 foreach($tier in @(@{Name='parent167';Exe="$repo/build2/codex_primary_projection167/frontend-05/l2trans.exe"},@{Name='current168';Exe="$stage/$Frontend/l2trans.exe"})){
  foreach($mode in 'native','forced'){
   $stem="$out/$($case.Name)-$($tier.Name)-$mode";$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
   $r=Run168 $tier.Exe ($extra+@($source,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$stem.lm1")) "$stem.L2.log" "$stage/src"
   $routes+=@{Case=$case.Name;Tier=$tier.Name;Mode=$mode;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;Source=$source;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash;DeclaredPositive=(-not $case.Inspect)};Json168 'routes.json' $routes
   if(-not $r.Started -or $r.TimedOut){throw 'Need terminal historical translation'}
   if($case.Inspect -or $TranslateOnly){continue}
   if($r.Code -ne 0){
    $old=@($routes|Where-Object {$_.Case -eq $case.Name -and $_.Mode -eq $mode -and $_.Tier -eq 'parent167'})
    if($tier.Name -eq 'current168' -and $old.Count -eq 1 -and $old[0].Exit -eq 0){throw "New positive regression: $($case.Name) $mode"}
    Write-Output "OPEN historical positive $($case.Name) $($tier.Name) $mode remains RED,not a refusal oracle"
    continue
   }
   $r=Run168 "$repo/bin/l1trans.exe" @("$stem.lm1","$stem.c") "$stem.L1.log" "$stage/src";if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Historical L1 generation failed'}
   $r=Run168 $gcc ($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o")) "$stem.COMPILE.log" "$stage/src";if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Historical strictO2 failed'}
   $exe="$stem.exe";$r=Run168 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',$exe) "$stem.LINK.log" "$stage/src";if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Historical link failed'}
   $builds+=@{Case=$case.Name;Tier=$tier.Name;Mode=$mode;Stem=$stem;Source=$source;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash;L1Sha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;CSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;FreshStrictO2=$true};Json168 'builds.json' $builds
   foreach($root in 0,1){$argv168=@('0','entry',"$($case.Value)");if($root){$argv168+=@('walkroot','1')};$r=Run168 $exe $argv168 "$stem.RUN$root.log" $out;$okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $r.Text -match 'checks, 0 roots';$runs+=@{Case=$case.Name;Tier=$tier.Name;Mode=$mode;Root=$root;ExpectedValue=$case.Value;Exit=$r.Code;Success=$okay;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash};Json168 'results.json' $runs;if(-not $r.Started -or $r.TimedOut){throw 'Historical execution must terminate'};if(-not $okay){Write-Output "OPEN historical positive $($case.Name) $($tier.Name) $mode root$root remains RED,not a new expected result"}}
  }
 }
 Write-Output "$($case.Name): preserved positive value or explicit observation only"
}
foreach($case in $cases){foreach($mode in 'native','forced'){$rows=@($routes|Where-Object {$_.Case -eq $case.Name -and $_.Mode -eq $mode});if($rows.Count -ne 2 -or ($rows[0].Exit -eq 0 -and $rows[1].Exit -ne 0)){throw 'New historical translation regression'}}}
foreach($group in $runs|Group-Object Case,Mode,Root){$old=@($group.Group|Where-Object Tier -eq 'parent167');$now=@($group.Group|Where-Object Tier -eq 'current168');if($old.Count -ne 1 -or $now.Count -ne 1 -or ($old[0].Success -and -not $now[0].Success)){throw 'New historical runtime regression'};if(-not $old[0].Success -and -not $now[0].Success -and ($old[0].Exit -ne $now[0].Exit -or $old[0].Diagnostic -cne $now[0].Diagnostic)){throw 'Inspect changed historical OPEN failure;do not assume equivalence'}}
Write-Output 'STORAGE168 historical controls TERMINAL;observed refusals are not language rules'
