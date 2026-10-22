#requires -Version 7.0
param([string]$Label='opaque-root-open-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_candidate_values164";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve open root observation'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$rows=@()
foreach($tier in 'parent','current'){
 $exe="$stage/opaque-$tier-08/native-production.exe"
 $r=Invoke-ProcBounded -Exe $exe -Argv @('0','entry','7','walkroot','1') -TimeoutSec 60 -Log "$out/$tier.log"
 $rows+=@{Tier=$tier;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;Exe=$exe;ExeSha256=(Get-FileHash -LiteralPath $exe).Hash;PositiveExpectedEntry=7;NormativeSuccess=($r.Started -and -not $r.TimedOut -and $r.Code -eq 0);KnownCapabilityRed=($r.Code -eq 3 -and $r.Text -match 'UNSUPPORTED')}
 [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
}
if(@($rows|Where-Object {-not $_.Started -or $_.TimedOut -or -not $_.KnownCapabilityRed}).Count){throw 'Open forced-root capability changed;inspect instead of replacing the positive oracle'}
$rows|Select-Object Tier,Exit,NormativeSuccess,KnownCapabilityRed|ConvertTo-Json
