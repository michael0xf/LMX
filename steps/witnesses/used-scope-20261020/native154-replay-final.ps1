param([string]$Label='replay-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_native_records154";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve exact final replay'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$builds=Get-Content -LiteralPath "$stage/values-01/builds.json" -Raw|ConvertFrom-Json
$observations=Get-Content -LiteralPath "$stage/values-01/results.json" -Raw|ConvertFrom-Json
$routes=Get-Content -LiteralPath "$stage/routes-02/results.json" -Raw|ConvertFrom-Json
$deps=Get-Content -LiteralPath "$repo/steps/witnesses/used-scope-20261020/check153-inputs.json" -Raw|ConvertFrom-Json
if($builds.Count -ne 85 -or $observations.Count -ne 170 -or $routes.Count -ne 85 -or $deps.Count -ne 281){throw 'Exact existing scope'}
$same=0
foreach($pin in $deps){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 if($pin.Path -eq 'src/l2src/l2trans.lm1'){continue}
 if((Get-FileHash -LiteralPath "$stage/$($pin.Path)").Hash -cne $pin.Sha256){throw 'Consuming dependency changed;cannot reuse any unit'}
 $same++
}
if($same -ne 280){throw 'Exact280 unchanged consuming dependencies'}
$compilerHash=(Get-FileHash -LiteralPath "$stage/frontend-03/l2trans.exe").Hash
$graphs=@();$runs=@();$saved=[Environment]::CurrentDirectory;Push-Location "$stage/src"
try{
 [Environment]::CurrentDirectory=(Get-Location).Path
 foreach($unit in $builds){
  $known=@($routes|Where-Object Unit -eq $unit.Unit)[0];$graph="$stage/routes-02/unit$($unit.Unit).lm1"
  if($known.CompilerSha256 -cne $compilerHash -or (Get-FileHash -LiteralPath $graph).Hash -cne $unit.GraphSha256){throw 'Final03 L1 changed;fresh unit required'}
  $r=Invoke-ProcBounded -Exe "$repo/bin/l1trans.exe" -Argv @($graph,"$out/derived.c") -TimeoutSec 60 -Log "$out/unit$($unit.Unit).L1.log"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or (Get-FileHash -LiteralPath "$out/derived.c").Hash -cne $unit.CSha256){throw 'Final03 literal generated C changed'}
  foreach($pin in @(@{Ext='lm1';Hash=$unit.GraphSha256},@{Ext='c';Hash=$unit.CSha256},@{Ext='o';Hash=$unit.ObjectSha256},@{Ext='exe';Hash=$unit.ExeSha256})){
   if((Get-FileHash -LiteralPath "$($unit.Stem).$($pin.Ext)").Hash -cne $pin.Hash){throw 'Executed fresh02 unit bytes changed'}
  }
  $graphs+=@{Unit=$unit.Unit;FinalCompilerSha256=$compilerHash;GraphSha256=$unit.GraphSha256;CSha256=$unit.CSha256;ExeSha256=$unit.ExeSha256;UnchangedConsumerFiles=280;FreshCCompile=$false;PriorFreshStrictO2=$true}
  foreach($prior in @($observations|Where-Object Unit -eq $unit.Unit)){
   [Environment]::CurrentDirectory="$stage/values-01";Push-Location "$stage/values-01"
   try{$r=Invoke-ProcBounded -Exe "$($unit.Stem).exe" -Argv @($prior.Args) -TimeoutSec 60 -Log "$out/unit$($unit.Unit).RUN$($runs.Count).log"}
   finally{Pop-Location;[Environment]::CurrentDirectory="$stage/src"}
   $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq $prior.ActualExit
   if($prior.Positive){$oracle=[regex]::Match($prior.Diagnostic,'l2_eternal_driver: [0-9]+ checks, 0 roots').Value;if(-not $oracle){throw 'Prior driver oracle missing'};$okay=$okay -and $r.Text.Contains($oracle)}
   $runs+=@{Unit=$unit.Unit;Args=@($prior.Args);Positive=$prior.Positive;ActualExit=$r.Code;ExpectedExit=$prior.ActualExit;ObservationMatched=$okay;Diagnostic=$r.Text;ExeSha256=$unit.ExeSha256;ActualNewExecution=$true;FreshCCompile=$false}
   $runs|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
   if(-not $okay){throw 'Final03 exact-byte actual replay differs'}
  }
 }
}finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
$graphs|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/graphs.json" -Encoding UTF8
$summary=@{Final03LiteralL1AndCMatchesFresh02=85;UnchangedConsumerFiles=280;ActualRuns=$runs.Count;PositiveRuns=@($runs|Where-Object Positive).Count;SameCopyRed=@($runs|Where-Object {-not $_.Positive}).Count;FreshCCompilesThisReplay=0;AllPathClosure=$false;FullGate=$false}
$summary|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary|ConvertTo-Json
