#requires -Version 7.0
# Negative mutants of the 169 contract, on isolated bytes (a copy of the
# compiler source; the stage inputs are never edited). Each mutant must turn
# its named witnesses red while the real frontend keeps them green:
#  L2    the witness translates on the real frontend; the mutant refuses it.
#  Shape the program and its control (the operand replaced by c.sizeof(c.int))
#        agree on method headers, merge-site constructors and receiving facts
#        on the real frontend; under the mutant they disagree.
#  Run   the native program returns 7 on the real frontend; under the mutant
#        it does not.
#  Text  the real L1 keeps the program's literal as written (a retained
#        symbol, no narrowed cell); the mutant's L1 does not.
param([string]$Label='mutants-01',[string]$Frontend='frontend-03')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_unevaluated169"
$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve mutant attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out,"$out/real"|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run169([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){$saved=[Environment]::CurrentDirectory;Push-Location $Cwd;try{[Environment]::CurrentDirectory=$Cwd;Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 300 -Log $Log}finally{[Environment]::CurrentDirectory=$saved;Pop-Location}}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o";$driver="$repo/build2/codex_places152_runtime_11/actual-02/driver.o"
$includes=@('-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$flags=@('-pipe','-std=c99','-O0','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers')+$includes
$programFlags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers')+$includes
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$parts=@("$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2")
$source=[IO.File]::ReadAllText("$stage/src/l2src/l2trans.lm1")
if((Get-FileHash -LiteralPath "$stage/src/l2src/l2trans.lm1").Hash -cne (Get-Content -LiteralPath "$stage/$Frontend/results.json" -Raw|ConvertFrom-Json).SourceSha256){throw 'Mutate the exact final source'}
$realExe="$stage/$Frontend/l2trans.exe"
$mutants=@(
 @{Name='M1-role5-check-evaluated';Old="    if: role = 5`n        saved: l2_check_unevaluated`n        l2_check_unevaluated: 1`n";New="    if: role = 5`n        saved: l2_check_unevaluated`n";Red=@('unevaluated-obligations','unevaluated-entry','unevaluated-deferred')},
 @{Name='M2-site-drops-context';Old="    l2_check_unevaluated: saved\unevaluated`n";New='';Red=@('unevaluated-deferred')},
 @{Name='M3-merge-class-recorded';Old='                if: l2_check_unevaluated = 0 && l2_cfl_note(idx, mi, fi, actual_i, 5, ';New='                if: l2_cfl_note(idx, mi, fi, actual_i, 5, ';Red=@('unevaluated-callable-class')},
 @{Name='M4-method-reaches-formal';Old='                if: l2_check_unevaluated = 0 && cf_kind = 1 && l2_cfl_note(';New='                if: cf_kind = 1 && l2_cfl_note(';Shape=@('unevaluated-callable-input')},
 @{Name='M5-merge-site-built';Old="    if: kind = 2 && l2_check_unevaluated != 0`n        l2_t7h_n: h_save`n        l2_t7b_n: b_save`n        return: 0`n";New='';Shape=@('unevaluated-callable-class')},
 @{Name='M6-actual-received';Old='        if: l2_check_unevaluated = 0 && l2_use_receiver(';New='        if: l2_use_receiver(';Shape=@('unevaluated-receiver')},
 @{Name='M7-literal-keeps-c-type';Old="            if: type != 8 && l2_prim_code_name(type) != 0 && leaf != 0 && leaf\kind = c.LM_P0_NODE_ATOM && leaf\as != 0 && (l2_rw_num_lit(leaf\as\atom, @ neg, @ magnitude, @ uns) != 0 || l2_rw_char_lit(leaf\as\atom, @ ch) != 0)`n                if: l2_tx_join(type_text, `"(cast: (`", l2_prim_code_name(type), `") `", piece\data, `")`") != 0 || l2_tx_set(piece, type_text\data) != 0`n                    return: 1`n            ---`n";New='';Run=@('unevaluated-values')},
 @{Name='M8-source-literal-narrowed';Old="    if: scalar = 2 && ((suffix = 0 && ((neg = 0 && magnitude > 2147483647U) || (neg != 0 && magnitude > 2147483648U))) || (suffix != 0 && (neg != 0 || magnitude > 4294967295U)))`n        scalar: 0`n";New='';Text=@('unevaluated-values')}
)
$witnesses=@('unevaluated-obligations','unevaluated-entry','unevaluated-deferred','unevaluated-values','unevaluated-callable-class','unevaluated-callable-input','unevaluated-receiver')
$shapeWitnesses=@('unevaluated-callable-class','unevaluated-callable-input','unevaluated-receiver')
$rows=@()
function Row169($Mutant,$Witness,$Kind,$Tier,$Exe,$Code,$Text,$Red,$MustBeRed,$Detail){@{Mutant=$Mutant;Witness=$Witness;Kind=$Kind;Tier=$Tier;Exit=$Code;Diagnostic=$Text;Red=$Red;MustBeRed=$MustBeRed;Detail=$Detail;WitnessSha256=(Get-FileHash -LiteralPath "$stage/$Witness.lm2").Hash;CompilerSha256=(Get-FileHash -LiteralPath $Exe).Hash}}
# Program and control of a shape witness, native: headers, merge-site
# constructors, receiving facts without their pointers.
function Shape169([string]$Exe,[string]$Witness,[string]$Dir){
 $text=[IO.File]::ReadAllText("$stage/$Witness.lm2").Replace([string][char]13,'')
 $control=[regex]::Replace($text,'(?m)^(    size_t: r )c\.sizeof\(.*\)$','${1}c.sizeof(c.int)')
 if($control -ceq $text){throw "No unevaluated operand line in $Witness"}
 [IO.File]::WriteAllText("$Dir/$Witness-control.lm2",$control,[Text.UTF8Encoding]::new($false))
 $sig=@{};$codes=@{}
 foreach($side in 'program','control'){
  $src="$stage/$Witness.lm2";if($side -eq 'control'){$src="$Dir/$Witness-control.lm2"}
  $stem="$Dir/$Witness-shape-$side"
  $env:L2_PATH_FACTS="$stem.facts"
  try{$r=Run169 $Exe (@($src)+$parts+@("$stem.lm1")) "$stem.L2.log" "$stage/src"}finally{Remove-Item Env:L2_PATH_FACTS}
  if(-not $r.Started -or $r.TimedOut){throw 'Shape translation must terminate'}
  $codes[$side]=$r.Code;$sig[$side]="exit=$($r.Code)"
  if($r.Code -eq 0){$l1=[IO.File]::ReadAllText("$stem.lm1");$sig[$side]=(@([regex]::Matches($l1,'(?m)^ *fn: l2_m\d+ \(.*$')|ForEach-Object Value)+@("merge-constructors=$([regex]::Matches($l1,'(?m)^fn: l2_t7_(make|construct)_').Count)")) -join "`n"}
  if(Test-Path -LiteralPath "$stem.facts"){$sig[$side]+="`n"+((@([regex]::Matches([IO.File]::ReadAllText("$stem.facts"),'(?m)^receiving method=(-?\d+) key=(-?\d+) current-input=(-?\d+) selector=(-?\d+) ')|ForEach-Object {"receiving method=$($_.Groups[1].Value) key=$($_.Groups[2].Value) input=$($_.Groups[3].Value) selector=$($_.Groups[4].Value)"}|Sort-Object)) -join "`n")}else{$sig[$side]+="`nno-facts"}
 }
 return @{Code=$codes.program;Same=($codes.program -eq 0 -and $codes.control -eq 0 -and $sig.program -ceq $sig.control);Detail="program:`n$($sig.program)`ncontrol:`n$($sig.control)"}
}
# The native program built and run at root 0 on the production driver.
function Run169Program([string]$Exe,[string]$Witness,[string]$Dir){
 $stem="$Dir/$Witness-run"
 $r=Run169 $Exe (@("$stage/$Witness.lm2")+$parts+@("$stem.lm1")) "$stem.L2.log" "$stage/src";if($r.Code -ne 0){return @{Code=$r.Code;Exit=$null;Detail="L2 $($r.Text)"}}
 $r=Run169 "$repo/bin/l1trans.exe" @("$stem.lm1","$stem.c") "$stem.L1.log" "$stage/src";if($r.Code -ne 0){return @{Code=$r.Code;Exit=$null;Detail="L1 $($r.Text)"}}
 $r=Run169 $gcc ($programFlags+$hooks+@('-c',"$stem.c",'-o',"$stem.o")) "$stem.COMPILE.log" "$stage/src";if($r.Code -ne 0){return @{Code=$r.Code;Exit=$null;Detail="COMPILE $($r.Text)"}}
 $r=Run169 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',"$stem.exe") "$stem.LINK.log" "$stage/src";if($r.Code -ne 0){throw "Mutant program link $Witness"}
 $r=Run169 "$stem.exe" @('0','entry','7') "$stem.RUN0.log" $Dir
 if(-not $r.Started -or $r.TimedOut){throw 'Mutant program run must terminate'}
 return @{Code=0;Exit=$r.Code;Green=($r.Code -eq 0 -and $r.Text -match 'l2_eternal_driver: 13 checks, 0 roots');Detail=$r.Text}
}
function Text169([string]$L1){$l1=[IO.File]::ReadAllText($L1);$sym=[regex]::Matches($l1,'lmx_source_name_set\(l2_program_arena, \(cast: \(@: void\) l2_rw\d+\), "3000000000", 10U\)').Count;$narrow=[regex]::Matches($l1,'_store_known\(\(cast: \(@: void\) l2_rw\d+\), 3000000000U?\)').Count;return @{Kept=($sym -ge 1 -and $narrow -eq 0);Detail="symbols=$sym narrowed=$narrow"}}
$tiers=@(@{Name='real';Exe=$realExe;Dir="$out/real";Mutant=$null})
foreach($m in $mutants){
 if(([regex]::Matches($source,[regex]::Escape($m.Old))).Count -ne 1){throw "Mutation $($m.Name) must match once"}
 $dir="$out/$($m.Name)";New-Item -ItemType Directory -Path $dir|Out-Null
 [IO.File]::WriteAllText("$dir/frontend-source.lm1",$source.Replace($m.Old,$m.New),[Text.UTF8Encoding]::new($false))
 $r=Run169 "$repo/bin/l1trans.exe" @("$dir/frontend-source.lm1","$dir/frontend.c") "$dir/L1.log" "$stage/src";if($r.Code -ne 0){throw "Mutant L1 $($m.Name)"}
 $r=Run169 $gcc ($flags+@("$dir/frontend.c",$lib,'-o',"$dir/l2trans.exe")) "$dir/COMPILE.log" "$stage/src";if($r.Code -ne 0){throw "Mutant compile $($m.Name)"}
 $tiers+=@{Name=$m.Name;Exe="$dir/l2trans.exe";Dir=$dir;Mutant=$m}
}
foreach($tier in $tiers){
 $m=$tier.Mutant;$name='real';if($m){$name=$m.Name}
 foreach($w in $witnesses){
  $stem="$($tier.Dir)/$w"
  $r=Run169 $tier.Exe (@("$stage/$w.lm2")+$parts+@("$stem.lm1")) "$stem.L2.log" "$stage/src"
  if(-not $r.Started -or $r.TimedOut){throw 'Witness translation must terminate'}
  $rows+=Row169 $name $w 'L2' $tier.Name $tier.Exe $r.Code $r.Text ($r.Code -ne 0) ($m -and $w -in $m.Red) ''
  if($w -eq 'unevaluated-values' -and $r.Code -eq 0 -and (-not $m -or $w -in $m.Text)){$t=Text169 "$stem.lm1";$rows+=Row169 $name $w 'Text' $tier.Name $tier.Exe 0 '' (-not $t.Kept) ($m -and $w -in $m.Text) $t.Detail}
  if((-not $m -and $w -in $shapeWitnesses) -or ($m -and $w -in $m.Shape)){$s=Shape169 $tier.Exe $w $tier.Dir;$rows+=Row169 $name $w 'Shape' $tier.Name $tier.Exe $s.Code '' (-not $s.Same) ($m -and $w -in $m.Shape) $s.Detail}
  if((-not $m -and $w -eq 'unevaluated-values') -or ($m -and $w -in $m.Run)){$p=Run169Program $tier.Exe $w $tier.Dir;$rows+=Row169 $name $w 'Run' $tier.Name $tier.Exe $p.Code $p.Detail (-not $p.Green) ($m -and $w -in $m.Run) "exit=$($p.Exit)"}
 }
}
[IO.File]::WriteAllText("$out/mutants.json",(($rows|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
foreach($row in $rows){Write-Output ("{0,-27} {1,-27} {2,-5} exit {3} red {4} must {5} {6} {7}" -f $row.Mutant,$row.Witness,$row.Kind,$row.Exit,$row.Red,$row.MustBeRed,($row.Detail -split "`n" | Select-Object -First 1),(($row.Diagnostic -split "`n")|Where-Object {$_ -match 'error'}|Select-Object -First 1))}
foreach($row in $rows){if($row.Tier -eq 'real' -and $row.Red){throw "The real frontend does not keep $($row.Witness) green ($($row.Kind))"};if($row.MustBeRed -and -not $row.Red){throw "Mutant $($row.Mutant) does not reach $($row.Witness) ($($row.Kind))"}}
foreach($m in $mutants){if(-not @($rows|Where-Object {$_.Mutant -eq $m.Name -and $_.MustBeRed}).Count){throw "Mutant $($m.Name) names no witness"}}
Write-Output 'MUTANTS169 every mutant reaches and reddens its witnesses; the real frontend keeps them green'
