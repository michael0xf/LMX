#requires -Version 7.0
param([string]$Frontend='frontend-08',[string]$Label='model-classes-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_pointer_receive166";$out="$stage/$Label";$base="$repo/buold_temp"
if(Test-Path -LiteralPath $out){throw 'Preserve classification observation'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$rows=@();$utf8=[Text.UTF8Encoding]::new($false)
foreach($name in 'primitive-call-model','primitive-root-model'){
 $source=[IO.File]::ReadAllText("$stage/$name.lm2")
 foreach($grouped in $false,$true){
  $case="$name-$grouped";$input="$out/$case.lm2";$text=$source
  if($grouped){$text=$text.Replace('consume(number())','consume((number()))').Replace('consume(value)','consume((value))')}
  [IO.File]::WriteAllText($input,$text,$utf8)
  foreach($tier in @(@{Name='parent163';Compiler="$repo/build2/codex_reference_values163/frontend-05/l2trans.exe"},@{Name='early07';Compiler="$stage/frontend-07/l2trans.exe"},@{Name='current';Compiler="$stage/$Frontend/l2trans.exe"})){
   foreach($mode in 'native','forced'){
    $extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
    $stem="$out/$case-$($tier.Name)-$mode";$saved=[Environment]::CurrentDirectory;Push-Location "$stage/src"
    try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe $tier.Compiler -Argv ($extra+@($input,"$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$stem.lm1")) -TimeoutSec 60 -Log "$stem.log"}
    finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
    $correct=$r.Started -and -not $r.TimedOut -and $r.Code -eq 1 -and $r.Text -match 'implements is false in function argument'
    $rows+=@{Case=$name;Grouped=$grouped;Tier=$tier.Name;Mode=$mode;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;RefusedKnownNumericAsGraph=$correct;Diagnostic=$r.Text;Source=$input;SourceSha256=(Get-FileHash -LiteralPath $input).Hash;CompilerSha256=(Get-FileHash -LiteralPath $tier.Compiler).Hash;RuntimeProof=$false}
    [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),$utf8)
    if($tier.Name -eq 'current' -and -not $correct){throw 'Known numeric value was accepted as a graph reference'}
   }
  }
 }
}
if($rows.Count -ne 24 -or @($rows|Where-Object {$_.Tier -eq 'current' -and $_.RefusedKnownNumericAsGraph}).Count -ne 8){throw 'Exact Model/value-kind classification scope'}
$rows|Group-Object Tier,RefusedKnownNumericAsGraph|Select-Object Name,Count|ConvertTo-Json
