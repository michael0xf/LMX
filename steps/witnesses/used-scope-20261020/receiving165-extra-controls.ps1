param([ValidatePattern('^extra-[0-9]+$')][string]$Label='extra-02',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-05')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_reference_receive165";$out="$stage/$Label";$cwd="$stage/src"
if(Test-Path -LiteralPath $out){throw 'Preserve extra source controls'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One compiler pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$rows=@()
foreach($name in 'unit_define','unit_define_actual','unit_define_ccall','entry_own_array_define','unit_array_field_sizet','known_gap_prefix_load_live_chain','unit_upper_undeclared_refused'){
 foreach($tier in @(@{Name='old152';Exe="$repo/build2/codex_places152_runtime_11/frontend-values-02/l2trans.exe"},@{Name='new159';Exe="$stage/$Frontend/l2trans.exe"})){
  $stem="$out/$name-$($tier.Name)";$input="$repo/dev/l2src_sandbox/tests/$name.lm2"
  $saved=[Environment]::CurrentDirectory;Push-Location $cwd
  try{[Environment]::CurrentDirectory=$cwd;$r=Invoke-ProcBounded -Exe $tier.Exe -Argv @($input,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$stem.lm1") -TimeoutSec 60 -Log "$stem.log"}
  finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
  $hash=$null;if($r.Code -eq 0){$hash=(Get-FileHash -LiteralPath "$stem.lm1").Hash}
  $rows+=@{Name=$name;Tier=$tier.Name;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;L1Sha256=$hash}
  $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
  Write-Output "$($tier.Name) $name exit=$($r.Code)";if($r.Code -ne 0){$r.Text}
 }
}
