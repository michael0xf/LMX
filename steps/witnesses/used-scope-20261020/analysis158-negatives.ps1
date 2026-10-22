param([ValidatePattern('^negatives-[0-9]+$')][string]$Label='negatives-01',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-05')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_analysis_children158";$out="$stage/$Label";$cwd="$base/l2_harness/codex_consumer49_full_01/src"
if(Test-Path -LiteralPath $out){throw 'Preserve located refusals'}
# These translator-only controls do not start another GCC pipeline.
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
# Literal needles from committed tools/l2_harness.ps1,not inferred from filenames.
$cases=@(
 @{Name='unit_array_binding_levels_refused';Needle="unit_array_binding_levels_refused.lm2:3:5: a binding's levels are not the value's"},
 @{Name='unit_array_binding_value_refused';Needle='unit_array_binding_value_refused.lm2:3:5: an Array binding needs an Array value'},
 @{Name='unit_arr_path_untyped_refused';Needle='unit_arr_path_untyped_refused.lm2:7:7: field path goes through a slot with no Structure'},
 @{Name='unit_bare_callable_numeric_refused';Needle='a reference where a number is asked'},
 @{Name='unit_bare_unknown_refused';Needle='unresolved name'},
 @{Name='unit_body_path_absent_refused';Needle='unit_body_path_absent_refused.lm2:12:12: unknown field path segment'},
 @{Name='unit_array_field_value_int_refused';Needle='a reference where a number is asked'},
 @{Name='unit_array_index_scalar_shadow_refused';Needle='unit_array_index_scalar_shadow_refused.lm2:5:16: an index needs an Array value'},
 @{Name='unit_array_index_dynamic_scalar_shadow_refused';Needle='unit_array_index_dynamic_scalar_shadow_refused.lm2:6:16: an index needs an Array value'},
 @{Name='unit_address_array_depth_refused';Needle='assignment value has incompatible type'},
 @{Name='unit_address_reference_depth_refused';Needle='reference depth does not match the receiving contract'},
 @{Name='unit_addr_unknown_type_refused';Needle='unknown type'}
)
$rows=@()
foreach($case in $cases){
 foreach($tier in @(@{Name='old152';Compiler="$repo/build2/codex_places152_runtime_11/frontend-values-02/l2trans.exe"},@{Name='new154';Compiler="$stage/$Frontend/l2trans.exe"})){
  $input="$repo/dev/l2src_sandbox/tests/$($case.Name).lm2";$stem="$out/$($case.Name)-$($tier.Name)";$saved=[Environment]::CurrentDirectory;Push-Location $cwd
  try{[Environment]::CurrentDirectory=$cwd;$r=Invoke-ProcBounded -Exe $tier.Compiler -Argv @($input,'convert.lm2','primitive.lm2',"$stem.lm1") -TimeoutSec 60 -Log "$stem.log"}
  finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
  $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq 1 -and $r.Text -match [regex]::Escape($case.Needle)
  $rows+=@{Case=$case.Name;Tier=$tier.Name;Exit=$r.Code;Started=$r.Started;TimedOut=$r.TimedOut;Needle=$case.Needle;OracleMatched=$okay;Diagnostic=$r.Text;SourceSha256=(Get-FileHash -LiteralPath $input).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Compiler).Hash}
  $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
  if(-not $okay){Write-Output "$($tier.Name) $($case.Name): unchanged located CHECK oracle NOT matched";$r.Text}
 }
}
$summary=@{Cases=$cases.Count;ActualTranslatorRuns=$rows.Count;OldMatched=@($rows|Where-Object {$_.Tier -eq 'old152' -and $_.OracleMatched}).Count;NewMatched=@($rows|Where-Object {$_.Tier -eq 'new154' -and $_.OracleMatched}).Count;ChangedOracles=0;RuntimeRuns=0;FullGate=$false}
$summary|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary|ConvertTo-Json
if($summary.OldMatched -ne $cases.Count -or $summary.NewMatched -ne $cases.Count){throw 'Inspect refusals without changing normative test expectations'}
