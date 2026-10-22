#requires -Version 7.0
# A: every sandbox fixture that uses sizeof (44), on parent168 and current169,
#    native and forced, against its harness row; positives are built and run.
# B: negative pairs -- the c.sizeof operand and its EVALUATED twin -- and OPEN
#    rows. An unevaluated operand must stay as invalid as its twin: it is still
#    checked (L2) or still judged by C (COMPILE). Observed refusals and OPEN
#    rows are not language rules.
# C: programs whose unevaluated operand names calls, against the same program
#    with the operand replaced by c.sizeof(c.int).
param([string]$Frontend='frontend-02',[string]$Label='controls-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_unevaluated169";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve unevaluated controls'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out,"$out/cases"|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run169([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){$saved=[Environment]::CurrentDirectory;Push-Location $Cwd;try{[Environment]::CurrentDirectory=$Cwd;Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}finally{[Environment]::CurrentDirectory=$saved;Pop-Location}}
function Json169([string]$Name,$Data){[IO.File]::WriteAllText("$out/$Name",(($Data|ConvertTo-Json -Depth 8).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))}
$flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$hooks=@('-Dmain=l2_generated_main','-Dlmx_root_launch=l2_driver_root_launch','-Dlmx_merge_owned=l2_driver_merge_owned','-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned','-Dlmx_merge_used_owned=l2_driver_merge_used_owned','-Dlmx_service_post=l2_driver_service_post')
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o";$driver="$repo/build2/codex_places152_runtime_11/actual-02/driver.o"
$parts=@("$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2")
$tiers=@(@{Name='parent168';Exe="$repo/build2/codex_primary_contract168/frontend-06/l2trans.exe"},@{Name='current169';Exe="$stage/$Frontend/l2trans.exe"})
# Expectations copied from tools/l2_harness.ps1 rows; 'ungated' has no row.
$historical=@(
 @{Name='library_sizeof_ptr_forms';Expect='ungated'},
 @{Name='repro_fnptr_value';Expect='ungated'},
 @{Name='repro_memcmp';Expect='ungated'},
 @{Name='unit_bad_sizeof';Expect='translates'},
 @{Name='unit_c_member_len';Expect='eternal-runs'},
 @{Name='unit_c_member_twohop';Expect='eternal-runs'},
 @{Name='unit_c_member_write';Expect='eternal-runs'},
 @{Name='unit_const_foreign_return';Expect='ungated'},
 @{Name='unit_csizeof_operand_lowered';Expect='eternal-runs';Entry=7},
 @{Name='unit_csizeof_type_frame_refused';Expect='l2trans-refuses';Needle='unit_csizeof_type_frame_refused.lm2:5:19: unresolved addressable name'},
 @{Name='unit_exprtext_raw_path';Expect='eternal-runs';Entry=7},
 @{Name='unit_exprtext_sizeof_frame';Expect='eternal-runs';Entry=7},
 @{Name='unit_fnptr_prototype_value';Expect='ungated'},
 @{Name='unit_indent_stack_field_index';Expect='translates'},
 @{Name='unit_k03_bare_sizeof_assign_refused';Expect='l2trans-refuses';Needle='unit_k03_bare_sizeof_assign_refused.lm2:14:8: sizeof: requires one operand'},
 @{Name='unit_k03_def_bare_sizeof_refused';Expect='l2trans-refuses';Needle='unit_k03_def_bare_sizeof_refused.lm2:8:4: sizeof: requires one operand'},
 @{Name='unit_k03_empty_sizeof_assign_refused';Expect='l2trans-refuses';Needle='unit_k03_empty_sizeof_assign_refused.lm2:14:8: sizeof: requires one operand'},
 @{Name='unit_k03_empty_sizeof_stmt_refused';Expect='l2trans-refuses';Needle='unit_k03_empty_sizeof_stmt_refused.lm2:7:5: sizeof: requires one operand'},
 @{Name='unit_lm_own_actual_span';Expect='eternal-runs';Entry=10;LinkSources=$true},
 @{Name='unit_named_actual_machine';Expect='eternal-runs';Entry=7},
 @{Name='unit_native_activation';Expect='eternal-runs';Entry=7},
 @{Name='unit_own_find_last_sizeof';Expect='eternal-runs';Entry=7},
 @{Name='unit_p0_document_field';Expect='ungated'},
 @{Name='unit_p0_with_include';Expect='eternal-runs'},
 @{Name='unit_p0_without_include';Expect='toolchain-refuses'},
 @{Name='unit_ptr_grow';Expect='eternal-runs';Entry=7},
 @{Name='unit_raw_root_c_control_compound';Expect='eternal-runs'},
 @{Name='unit_rhs_pointer_contract';Expect='eternal-runs';Entry=7},
 @{Name='unit_rn_char_pointer_refused';Expect='l2trans-refuses';Needle='unit_rn_char_pointer_refused.lm2:6:13: sizeof is a word of the language: a program cannot bind it'},
 @{Name='unit_site_foreign_index';Expect='eternal-runs';Entry=7},
 @{Name='unit_site_name_projection';Expect='eternal-runs';Entry=7},
 @{Name='unit_site_sizeof_hidden';Expect='eternal-runs';Entry=7},
 @{Name='unit_sizeof_arg';Expect='ungated'},
 @{Name='unit_sizeof_array_bytes';Expect='eternal-runs'},
 @{Name='unit_sizeof_c_door_arena';Expect='eternal-runs'},
 @{Name='unit_sizeof_element';Expect='ungated'},
 @{Name='unit_sizeof_long_name';Expect='eternal-runs';Entry=7},
 @{Name='unit_sizeof_own_local';Expect='eternal-runs'},
 @{Name='unit_sizeof_struct_ref';Expect='eternal-runs'},
 @{Name='unit_sizeof_type_frame';Expect='eternal-runs';Entry=7},
 @{Name='unit_sizeof_type_frame_refused';Expect='l2trans-refuses';Needle='sizeof: a type frame names a primitive type'},
 @{Name='unit_sizeof_type_int';Expect='eternal-runs'},
 @{Name='unit_sizeof_unknown_refused';Expect='l2trans-refuses';Needle='unit_sizeof_unknown_refused.lm2:8:1: unbound dynamic input unknownName'},
 @{Name='unit_uniform_foreign_results';Expect='eternal-runs';Entry=7}
)
$routes=@();$builds=@();$runs=@()
foreach($case in $historical){
 $source="$repo/dev/l2src_sandbox/tests/$($case.Name).lm2"
 foreach($tier in $tiers){
  foreach($mode in 'native','forced'){
   $stem="$out/$($case.Name)-$($tier.Name)-$mode";$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
   $r=Run169 $tier.Exe ($extra+@($source)+$parts+@("$stem.lm1")) "$stem.L2.log" "$stage/src"
   if(-not $r.Started -or $r.TimedOut){throw 'Need terminal historical translation'}
   $needle=$null;if($case.Needle){$needle=$r.Text.Contains($case.Needle)}
   $routes+=@{Part='historical';Case=$case.Name;Expect=$case.Expect;Tier=$tier.Name;Mode=$mode;Exit=$r.Code;Diagnostic=$r.Text;NeedleMatched=$needle;Source=$source;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash;L1Sha256=$(if($r.Code -eq 0){(Get-FileHash -LiteralPath "$stem.lm1").Hash}else{$null})};Json169 'routes.json' $routes
   if($r.Code -ne 0 -or $case.Expect -ne 'eternal-runs' -or $case.LinkSources){continue}
   $r=Run169 "$repo/bin/l1trans.exe" @("$stem.lm1","$stem.c") "$stem.L1.log" "$stage/src";if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Historical L1 generation failed'}
   $r=Run169 $gcc ($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o")) "$stem.COMPILE.log" "$stage/src";if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Historical strictO2 failed'}
   $exe="$stem.exe";$r=Run169 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',$exe) "$stem.LINK.log" "$stage/src";if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Historical link failed'}
   $builds+=@{Part='historical';Case=$case.Name;Tier=$tier.Name;Mode=$mode;Stem=$stem;Source=$source;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash;L1Sha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;CSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;FreshStrictO2=$true};Json169 'builds.json' $builds
   $entry=0;if($case.Entry){$entry=$case.Entry}
   foreach($root in 0,1){$argv169=@('0','entry',"$entry");if($root){$argv169+=@('walkroot','1')};$r=Run169 $exe $argv169 "$stem.RUN$root.log" $out;$okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $r.Text -match 'checks, 0 roots';$runs+=@{Part='historical';Case=$case.Name;Tier=$tier.Name;Mode=$mode;Root=$root;ExpectedValue=$entry;Exit=$r.Code;Success=$okay;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash};Json169 'results.json' $runs;if(-not $r.Started -or $r.TimedOut){throw 'Historical execution must terminate'};if(-not $okay){Write-Output "OPEN historical $($case.Name) $($tier.Name) $mode root$root exit $($r.Code), not a new expected result"}}
  }
 }
 Write-Output "$($case.Name): observed on both tiers"
}
# Every positive translation and execution of parent168 holds on current169;
# a refusal shared by both tiers keeps its diagnostic.
foreach($group in $routes|Where-Object Part -eq 'historical'|Group-Object Case,Mode){$old=@($group.Group|Where-Object Tier -eq 'parent168');$now=@($group.Group|Where-Object Tier -eq 'current169');if($old.Count -ne 1 -or $now.Count -ne 1){throw 'Need one route per tier'};if($old[0].Exit -eq 0 -and $now[0].Exit -ne 0){throw "New translation regression $($group.Name)"};if($old[0].Exit -ne 0 -and $now[0].Exit -ne 0 -and $old[0].Diagnostic -cne $now[0].Diagnostic){throw "Changed shared refusal $($group.Name)"};if($old[0].NeedleMatched -and -not $now[0].NeedleMatched){throw "Lost harness needle $($group.Name)"}}
foreach($group in $runs|Group-Object Case,Mode,Root){$old=@($group.Group|Where-Object Tier -eq 'parent168');$now=@($group.Group|Where-Object Tier -eq 'current169');if($old.Count -ne 1 -or $now.Count -ne 1){throw 'Need one run per tier'};if($old[0].Success -and -not $now[0].Success){throw "New runtime regression $($group.Name)"};if(-not $old[0].Success -and -not $now[0].Success -and ($old[0].Exit -ne $now[0].Exit -or $old[0].Diagnostic -cne $now[0].Diagnostic)){throw "Changed shared runtime failure $($group.Name)"}}
# B. The SAME probe() frame; only the operand line differs between a form and
#    its twin. Sources are written here, pinned by hash.
$touch=@'
fn: touch () int
    return: 1
end: touch
'@+"`n"
$wide=@'
fn: wide () ulong
    return: 5U
end: wide
'@+"`n"
$sub=@'
int: y 0
sub: s ()
    y: 3
end: s
'@+"`n"
$pairs=@(
 @{Name='neg_void';Prelude=$sub;Form='    size_t: n c.sizeof(s())';Twin='    int: n s()'},
 @{Name='neg_void_bare';Prelude=$sub;Form='    size_t: n sizeof: s()';Twin='    int: n s()'},
 @{Name='neg_index_text';Prelude='';Form="    []: int cells 3`n    size_t: n c.sizeof(cells[`"x`"])";Twin="    []: int cells 3`n    int: n cells[`"x`"]"},
 @{Name='neg_index_convert';Prelude=$touch;Form="    []: int cells 3`n    size_t: n c.sizeof(cells[touch()])";Twin="    []: int cells 3`n    int: n cells[touch()]"},
 @{Name='neg_mixed_numeric';Prelude=$touch+$wide;Form='    size_t: n c.sizeof(touch() + wide())';Twin='    ulong: n touch() + wide()'},
 @{Name='neg_operator_binding';Prelude='';Form="    int: x 5`n    size_t: n c.sizeof(x * `"s`")";Twin="    int: x 5`n    int: n x * `"s`""},
 @{Name='neg_operator_call';Prelude=$touch;Form='    size_t: n c.sizeof(touch() * "s")';Twin='    int: n touch() * "s"'},
 @{Name='neg_unknown_name';Prelude='';Form='    size_t: n c.sizeof(nosuch)';Twin='    int: n nosuch'},
 @{Name='neg_scalar_member';Prelude='';Form="    int: x 5`n    size_t: n c.sizeof(x\field)";Twin="    int: x 5`n    int: n x\field"},
 @{Name='neg_scalar_deref';Prelude='';Form="    int: x 5`n    size_t: n c.sizeof(\x)";Twin="    int: x 5`n    int: n \x"},
 @{Name='neg_call_address';Prelude=$touch;Form='    size_t: n c.sizeof(@ touch())';Twin='    @: chosen int (@ touch())'}
)
$open=@(
 @{Name='open_nested_call';Run=$true;Text=@'
int: touches 0
fn: touch () int
    node\touches: node\touches + 1
    return: 1
end: touch
fn: probe () int
    size_t: n c.sizeof(c.abs(touch()))
    if: n != c.sizeof(c.int)
        return: 81
    if: node\touches != 0
        return: 88
    return: 7
end: probe
sendMessage: exit(exit_code: probe(); stdout: ""; stderr: "")
return
'@},
 @{Name='open_eager_member';Run=$false;Text=@'
predef: "l2src/tests/unit_uniform_aggregate.h.lm1"
fn: show (c.L2DispatchPair: value) int
    c.printf("%zu\n", value\wide)
    return: 7
end: show
fn: run () int
    return: show(c.l2_dispatch_pair_make())
end: run
sendMessage: exit(exit_code: run(); stdout: ""; stderr: "")
return
'@}
)
$cases=@()
foreach($pair in $pairs){foreach($side in 'form','twin'){$line=$pair.Form;if($side -eq 'twin'){$line=$pair.Twin};$cases+=@{Name="$($pair.Name)-$side";Pair=$pair.Name;Side=$side;Run=$false;Text=($pair.Prelude+"fn: probe () int`n$line`n    return: 7`nend: probe`nsendMessage: exit(exit_code: probe(); stdout: `"`"; stderr: `"`")`nreturn`n")}}}
foreach($row in $open){$cases+=@{Name=$row.Name;Pair=$null;Side='open';Run=$row.Run;Text=$row.Text}}
$controls=@()
foreach($case in $cases){
 $body=$case.Text.Replace([string][char]13,'');if(-not $body.EndsWith("`n")){$body+="`n"}
 $source="$out/cases/$($case.Name).lm2";[IO.File]::WriteAllText($source,$body,[Text.UTF8Encoding]::new($false))
 foreach($tier in $tiers){
  $stem="$out/$($case.Name)-$($tier.Name)";$phase='L2';$exit=0;$text=''
  $r=Run169 $tier.Exe (@($source)+$parts+@("$stem.lm1")) "$stem.L2.log" "$stage/src";$exit=$r.Code;$text=$r.Text
  if($r.Code -eq 0){$phase='L1';$r=Run169 "$repo/bin/l1trans.exe" @("$stem.lm1","$stem.c") "$stem.L1.log" "$stage/src";$exit=$r.Code;$text=$r.Text}
  if($r.Code -eq 0){$phase='COMPILE';$r=Run169 $gcc ($flags+$hooks+@('-c',"$stem.c",'-o',"$stem.o")) "$stem.COMPILE.log" "$stage/src";$exit=$r.Code;$text=$r.Text}
  $runExit=$null;$runText=$null
  if($r.Code -eq 0){$phase='BUILT';if($case.Run){$r=Run169 $gcc @("$stem.o",$driver,$lib,'-Wl,--strip-debug','-o',"$stem.exe") "$stem.LINK.log" "$stage/src";if($r.Code -ne 0){throw 'OPEN row link failed'};$r=Run169 "$stem.exe" @('0','entry','7') "$stem.RUN0.log" $out;$phase='RAN';$runExit=$r.Code;$runText=$r.Text}}
  if(-not $r.Started -or $r.TimedOut){throw 'Control must terminate'}
  $controls+=@{Case=$case.Name;Pair=$case.Pair;Side=$case.Side;Tier=$tier.Name;Phase=$phase;Exit=$exit;Diagnostic=$text;RunExit=$runExit;RunDiagnostic=$runText;Source=$source;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash};Json169 'controls.json' $controls
  Write-Output "$($case.Name) $($tier.Name): $phase exit $exit"
 }
}
# A negative form is rejected on current169 (L2 or COMPILE), and its twin is
# rejected on BOTH tiers: the unevaluated context hides no invalid operand.
foreach($pair in $pairs){
 $form=@($controls|Where-Object {$_.Case -eq "$($pair.Name)-form" -and $_.Tier -eq 'current169'})
 $twins=@($controls|Where-Object {$_.Case -eq "$($pair.Name)-twin"})
 if($form.Count -ne 1 -or $form[0].Phase -notin @('L2','COMPILE')){throw "Unevaluated operand hid an invalid form: $($pair.Name)"}
 if($twins.Count -ne 2 -or @($twins|Where-Object {$_.Phase -notin @('L2','COMPILE')}).Count){throw "The evaluated twin is not a refusal: $($pair.Name)"}
}
$nested=@($controls|Where-Object {$_.Case -eq 'open_nested_call' -and $_.Tier -eq 'current169'})
if($nested.Count -ne 1 -or $nested[0].Phase -ne 'L2' -or $nested[0].Diagnostic -notmatch 'not supported yet \(OPEN'){throw 'An L2 call in a nested C call must stay a located OPEN refusal'}
# C. No actual of an unevaluated call reaches a formal: every method header
#    (its inputs, its hidden inputs), every merge-site constructor and every
#    receiving fact of a checked occurrence (the L2_PATH_FACTS observation,
#    without its pointers) is the one the program has when the operand names
#    no call at all.
$shapes=@()
foreach($flow in @(@{Name='flow_callable_class';Source='unevaluated-callable-class.lm2'},@{Name='flow_callable_input';Source='unevaluated-callable-input.lm2'},@{Name='flow_receiver';Source='unevaluated-receiver.lm2'})){
 $text=[IO.File]::ReadAllText("$stage/$($flow.Source)").Replace([string][char]13,'')
 $control=[regex]::Replace($text,'(?m)^(    size_t: r )c\.sizeof\(.*\)$','${1}c.sizeof(c.int)')
 if($control -ceq $text){throw "No unevaluated operand line in $($flow.Source)"}
 $pair=@{program="$out/cases/$($flow.Name).lm2";control="$out/cases/$($flow.Name)-control.lm2"}
 [IO.File]::WriteAllText($pair.program,$text,[Text.UTF8Encoding]::new($false));[IO.File]::WriteAllText($pair.control,$control,[Text.UTF8Encoding]::new($false))
 foreach($tier in $tiers){
  foreach($mode in 'native','forced'){
   $extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
   $headers=@{};$exits=@{};$t7=@{};$receivers=@{}
   foreach($side in 'program','control'){
    $stem="$out/$($flow.Name)-$side-$($tier.Name)-$mode"
    $env:L2_PATH_FACTS="$stem.facts"
    try{$r=Run169 $tier.Exe ($extra+@($pair[$side])+$parts+@("$stem.lm1")) "$stem.L2.log" "$stage/src"}finally{Remove-Item Env:L2_PATH_FACTS}
    if(-not $r.Started -or $r.TimedOut){throw 'Shape translation must terminate'}
    $exits[$side]=$r.Code
    $headers[$side]=@();$t7[$side]=-1;$receivers[$side]=@()
    if($r.Code -eq 0){$l1=[IO.File]::ReadAllText("$stem.lm1");$headers[$side]=@([regex]::Matches($l1,'(?m)^ *fn: l2_m\d+ \(.*$')|ForEach-Object Value);$t7[$side]=[regex]::Matches($l1,'(?m)^fn: l2_t7_(make|construct)_').Count}
    if(Test-Path -LiteralPath "$stem.facts"){$receivers[$side]=@([regex]::Matches([IO.File]::ReadAllText("$stem.facts"),'(?m)^receiving method=(-?\d+) key=(-?\d+) current-input=(-?\d+) selector=(-?\d+) ')|ForEach-Object {"method=$($_.Groups[1].Value) key=$($_.Groups[2].Value) input=$($_.Groups[3].Value) selector=$($_.Groups[4].Value)"}|Sort-Object)}
   }
   $sameHeaders=($exits.program -eq 0 -and $exits.control -eq 0 -and (($headers.program -join "`n") -ceq ($headers.control -join "`n")))
   $sameT7=($exits.program -eq 0 -and $t7.program -eq $t7.control)
   $sameReceivers=($exits.program -eq 0 -and (Test-Path -LiteralPath "$out/$($flow.Name)-program-$($tier.Name)-$mode.facts") -and (($receivers.program -join "`n") -ceq ($receivers.control -join "`n")))
   $shapes+=@{Case=$flow.Name;Tier=$tier.Name;Mode=$mode;ProgramExit=$exits.program;ControlExit=$exits.control;Headers=$headers.program.Count;SameHeaders=$sameHeaders;MergeConstructors=$t7.program;ControlMergeConstructors=$t7.control;SameMergeConstructors=$sameT7;Receivings=$receivers.program.Count;ControlReceivings=$receivers.control.Count;SameReceivings=$sameReceivers;Same=($sameHeaders -and $sameT7 -and $sameReceivers);ProgramSha256=(Get-FileHash -LiteralPath $pair.program).Hash;ControlSha256=(Get-FileHash -LiteralPath $pair.control).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Exe).Hash};Json169 'shapes.json' $shapes
   Write-Output "$($flow.Name) $($tier.Name) $mode`: program $($exits.program) control $($exits.control) same headers $sameHeaders merge constructors $($t7.program)/$($t7.control) receivings $($receivers.program.Count)/$($receivers.control.Count) same $($sameHeaders -and $sameT7 -and $sameReceivers)"
  }
 }
}
if(@($shapes|Where-Object {$_.Tier -eq 'current169' -and -not $_.Same}).Count){throw 'An unevaluated call reached a formal: a method header, merge constructor or receiving fact changed'}
Write-Output 'CONTROLS169 historical and unevaluated controls TERMINAL;observed refusals are not language rules'
