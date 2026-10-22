#requires -Version 7.0
param([string]$Label='named-refusals-01',[string]$Frontend='frontend-05')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_contract168";$out="$stage/$Label";$base="$repo/buold_temp"
if(Test-Path -LiteralPath $out){throw 'Preserve actual refusal comparison'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$cases=@('unit_named_actual_again_refused','unit_named_actual_unknown_refused','unit_named_actual_order_refused','unit_named_actual_twice_refused','unit_named_actual_missing_refused','unit_named_actual_long_unknown_refused','unit_named_actual_held_name_refused','unit_named_actual_head_index_name_refused','unit_named_actual_head_index_free_refused','unit_named_actual_free_name_refused','unit_named_actual_held_missing_refused','unit_named_actual_address_statement_refused','unit_named_actual_held_again_refused','unit_indexed_actual_depth_refused','unit_indexed_actual_type_refused','unit_pointer_actual_const_refused','unit_cf_actual_call_result_refused','unit_held_actual_signature_refused','unit_held_actual_reference_refused','unit_call_named_known_refused','unit_call_named_unknown_refused','unit_call_named_below_refused')
$rows=@();$matched=0
foreach($name in $cases){
 $source="$repo/dev/l2src_sandbox/tests/$name.lm2";$pair=@()
 foreach($tier in 'old160','new161'){
  $compiler="$repo/build2/codex_primary_children160/frontend-04/l2trans.exe";if($tier -eq 'new161'){$compiler="$stage/$Frontend/l2trans.exe"}
  $saved=[Environment]::CurrentDirectory;Push-Location "$stage/src"
  try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe $compiler -Argv @($source,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$out/$name-$tier.lm1") -TimeoutSec 60 -Log "$out/$name-$tier.log"}
  finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
  $pair+=@{Case=$name;Tier=$tier;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;CompilerSha256=(Get-FileHash -LiteralPath $compiler).Hash;SourceSha256=(Get-FileHash -LiteralPath $source).Hash;Phase='L2';RuntimeRun=$false}
 }
 $same=$pair[0].Started -and $pair[1].Started -and -not $pair[0].TimedOut -and -not $pair[1].TimedOut -and $pair[0].Exit -eq $pair[1].Exit -and $pair[0].Diagnostic -ceq $pair[1].Diagnostic
 foreach($row in $pair){$row['ExactOldClassification']=$same;$rows+=$row}
 if($same){$matched++}
 [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 6).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
 if(-not $same){throw "Actual argument classification changed: $name"}
}
[pscustomobject]@{SourceCases=$cases.Count;TranslatorObservations=$rows.Count;ExactOldClassifications=$matched;RuntimeRuns=0;NewNormativeOracles=$false}|ConvertTo-Json
