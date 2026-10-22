param([ValidatePattern('^routes-[0-9]+$')][string]$Label='routes-01',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-04')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_child_records156";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve source-route attempt'}
# Read-only L2 translation may run beside the sole GCC pipeline.
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Rebase154([string]$Text){
 if($Text -match '^[A-Za-z]:[/\\]'){$p=[IO.Path]::GetFullPath($Text);$prefix=[IO.Path]::GetFullPath("$repo/build")+'\';if($p.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){return "$base/"+$p.Substring($prefix.Length).Replace('\','/')}}
 return $Text
}
$inventory=Get-Content -LiteralPath "$base/codex_native122_values_03/inventory.json" -Raw|ConvertFrom-Json
if($inventory.Count -ne 85){throw 'Exact85 inputs'}
$rows=@();$u=0
foreach($case in $inventory){
 $args154=@($case.L2Args|ForEach-Object {Rebase154 $_});$args154[$args154.Count-1]="$out/unit$u.lm1";$cwd=Rebase154 $case.L2Cwd
 $saved=[Environment]::CurrentDirectory;Push-Location $cwd
 try{[Environment]::CurrentDirectory=$cwd;$r=Invoke-ProcBounded -Exe "$stage/$Frontend/l2trans.exe" -Argv $args154 -TimeoutSec 180 -Log "$out/unit$u.log"}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
 $hash=$null;$same=$false
 if($r.Started -and -not $r.TimedOut -and $r.Code -eq 0){$hash=(Get-FileHash -LiteralPath "$out/unit$u.lm1").Hash;$same=$hash -ceq (Get-FileHash -LiteralPath "$repo/build2/codex_places152_runtime_11/full85_final02/new/unit$u.lm1").Hash}
 $rows+=@{Unit=$u;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;GeneratedL1Sha256=$hash;Identical152L1=$same;CompilerSha256=(Get-FileHash -LiteralPath "$stage/$Frontend/l2trans.exe").Hash;Args=$args154;Cwd=$cwd;RuntimeRun=$false}
 $rows|ConvertTo-Json -Depth 5|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
 $u++;if($u%10 -eq 0){Write-Output "Sources=$u;translated=$(@($rows|Where-Object Exit -eq 0).Count);literal152=$(@($rows|Where-Object Identical152L1).Count)"}
}
$summary=@{Inputs=$rows.Count;Translated=@($rows|Where-Object Exit -eq 0).Count;Identical152L1=@($rows|Where-Object Identical152L1).Count;RuntimeRuns=0;FullGate=$false;AllPathClosure=$false}
$summary|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary|ConvertTo-Json
if($summary.Translated -ne 85){throw 'Inspect all new refusals; do not rewrite prior oracles'}
