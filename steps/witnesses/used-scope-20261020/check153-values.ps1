param([ValidatePattern('^values-[0-9]+$')][string]$Label='values-03',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-07',[ValidatePattern('^routes-[0-9]+$')][string]$Routes='routes-04')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$prior="$repo/build2/codex_places152_runtime_11";$stage="$repo/build2/codex_check_records153";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve actual replay attempt'}
# No GCC is launched here: exact executed binaries follow literal L1/C verification.
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run153([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){
 $saved=[Environment]::CurrentDirectory;Push-Location $Cwd
 try{[Environment]::CurrentDirectory=$Cwd;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
$builds=Get-Content -LiteralPath "$prior/full85_final02/builds.json" -Raw|ConvertFrom-Json
$corpus=@($builds|Where-Object Tier -eq 'new');if($corpus.Count -ne 85){throw 'Exact85 current152 units'}
$inventory=Get-Content -LiteralPath "$base/codex_native122_values_03/inventory.json" -Raw|ConvertFrom-Json
$aux=Get-Content -LiteralPath "$prior/aux-01/builds.json" -Raw|ConvertFrom-Json
$plan=@()
foreach($unit in $corpus){$plan+=@{Name="unit$($unit.Unit)";Graph="$stage/$Routes/unit$($unit.Unit).lm1";PreviousGraph="$($unit.Stem).lm1";C="$($unit.Stem).c";Unit=$unit.Unit;Kind='corpus'}}
foreach($unit in $aux){$name="$($unit.Case)-$($unit.Mode)";$extra=@();if($unit.Mode -eq 'forced'){$extra=@('--walk-methods')};$plan+=@{Name=$name;Source=$unit.Source;Args=$extra;PreviousGraph="$prior/aux-01/$name.lm1";C="$prior/aux-01/$name.c";Kind='aux'}}
foreach($mode in 'native','forced'){$extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')};$plan+=@{Name="method-$mode";Source="$base/codex_places152_method_address_09.lm2";Args=$extra;PreviousGraph="$prior/frontend-values-02/method-$mode.lm1";C="$prior/frontend-values-02/method-$mode.c";Kind='method'}}
$graphs=@();$runs=@()
foreach($unit in $plan){
 $graph=$unit.Graph
 if($unit.Kind -ne 'corpus'){
  $graph="$out/$($unit.Name).lm1";$args153=@($unit.Args)+@($unit.Source,'convert.lm2','primitive.lm2',$graph)
  $r=Run153 "$stage/$Frontend/l2trans.exe" $args153 "$out/$($unit.Name).L2.log" "$base/l2_harness/codex_consumer49_full_01/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Current $($unit.Name) translation failed"}
 }
 $graphHash=(Get-FileHash -LiteralPath $graph).Hash
 if($graphHash -cne (Get-FileHash -LiteralPath $unit.PreviousGraph).Hash){throw 'Literal current L1 changed; cannot substitute prior executable'}
 # One generated C buffer bounds disk use. Every current L1 and all phase logs
 # remain;the identical152 C is retained beside its executed object/executable.
 $r=Run153 "$repo/bin/l1trans.exe" @($graph,"$out/derived.c") "$out/$($unit.Name).L1.log" "$stage/src"
 if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Current literal L1 to C failed'}
 $cHash=(Get-FileHash -LiteralPath "$out/derived.c").Hash
 if($cHash -cne (Get-FileHash -LiteralPath $unit.C).Hash){throw 'Current generated C changed; a fresh C unit is required'}
 $graphs+=@{Name=$unit.Name;Kind=$unit.Kind;CurrentGraph=$graph;PreviousGraph=$unit.PreviousGraph;GeneratedL1Sha256=$graphHash;GeneratedCSha256=$cHash;IdenticalL1AndC=$true;ReusedStrictO2Unit=$true}
 $graphs|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/graphs.json" -Encoding UTF8
}
# The identical runtime dependency closure and production/observer objects.
foreach($dir in 'headers','src'){
 foreach($file in Get-ChildItem -LiteralPath "$prior/$dir" -Recurse -File){
  if($file.Name -ieq 'l2_driver_launch.err'){continue}
  $rel=$file.FullName.Substring(([IO.Path]::GetFullPath($prior)).Length+1).Replace('\','/')
  if($rel -eq 'src/l2src/l2trans.lm1'){continue}
  if($rel -eq 'src/l2src/l2_application.h.lm1'){
   $r=Run153 "$repo/bin/l1trans.exe" @("$stage/$rel","$out/application-regenerated.h") "$out/application-header.log" "$stage/src"
   if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Comment-only source header must regenerate'}
   $hash=(Get-FileHash -LiteralPath "$out/application-regenerated.h").Hash
   if($hash -cne (Get-FileHash -LiteralPath "$stage/headers/l2src/l2_application.lm1.h").Hash -or $hash -cne (Get-FileHash -LiteralPath "$prior/headers/l2src/l2_application.lm1.h").Hash){throw 'Generated application header changed; fresh C units required'}
   continue
  }
  if((Get-FileHash -LiteralPath $file.FullName).Hash -cne (Get-FileHash -LiteralPath "$stage/$rel").Hash){throw 'A consuming header/runtime source changed; rebuild rather than reuse'}
 }
}
foreach($bundle in @(@{Name='corpus';Path="$prior/full85_final02/results.json"},@{Name='aux';Path="$prior/aux-01/results.json"},@{Name='method-production';Path="$prior/actual-02/results.json"},@{Name='method-observed';Path="$prior/observed-02/results.json"})){
 $observations=Get-Content -LiteralPath $bundle.Path -Raw|ConvertFrom-Json
 if($bundle.Name -eq 'corpus'){$observations=@($observations|Where-Object Tier -eq 'new')}
 foreach($known in $observations){
  $args153=@('0','entry','7');$exe=$null;$expectedBodies=0;$isPositive=$true
  if($bundle.Name -eq 'corpus'){
   $entry=@($corpus|Where-Object Unit -eq $known.Unit)[0];$exe="$($entry.Stem).exe";$args153=@($known.Args);$isPositive=$known.PriorSuccess
  }elseif($bundle.Name -eq 'aux'){
   $exe="$prior/aux-01/$($known.Case)-$($known.Mode)-$($known.Runtime).exe";if($known.Root){$args153+=@('walkroot','1')};$expectedBodies=$known.ExpectedBodies;$isPositive=$known.ExpectedExit -eq 0
  }else{
   $dir='actual-02';$exe="$prior/$dir/method-$($known.Mode).exe";if($bundle.Name -eq 'method-observed'){$dir='observed-02';$exe="$prior/$dir/$($known.Mode).exe";$expectedBodies=$known.ExpectedBodies};if($known.Root){$args153+=@('walkroot','1')}
  }
  $hash=(Get-FileHash -LiteralPath $exe).Hash;if($hash -cne $known.ExeSha256){throw 'Executed152 bytes changed'}
  $r=Run153 $exe $args153 "$out/RUN$($runs.Count).log" $out
  $bodies=[regex]::Matches($r.Text,'PLACES152 WALK_BODY').Count
  $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq $known.ActualExit -and $bodies -eq $expectedBodies
  if($bundle.Name -eq 'corpus' -and $isPositive){$okay=$okay -and $r.Text -match ("l2_eternal_driver: "+$known.Checks+" checks, 0 roots")}
  $runs+=@{Bundle=$bundle.Name;Unit=$known.Unit;Case=$known.Case;Mode=$known.Mode;Root=$known.Root;Exe=$exe;Args=$args153;ExeSha256=$hash;PriorExit=$known.ActualExit;ActualExit=$r.Code;Positive=$isPositive;ExpectedBodies=$expectedBodies;ActualBodies=$bodies;ObservationMatched=$okay;Diagnostic=$r.Text;ActualNewExecution=$true;FreshCCompile=$false}
  $runs|ConvertTo-Json -Depth 5|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
  if(-not $okay){throw 'Exact-executable actual values or body entries changed'}
 }
 Write-Output "$($bundle.Name): current literal L1/C verified, exact152 executables rehashed and actually rerun"
}
$summary=@{CurrentL1Units=$graphs.Count;CurrentL1AndCIdentical152=@($graphs|Where-Object IdenticalL1AndC).Count;FreshCCompiles=0;ActualNewRuns=$runs.Count;MatchingObservations=@($runs|Where-Object ObservationMatched).Count;PositiveRuns=@($runs|Where-Object Positive).Count;SameCopyRed=@($runs|Where-Object {$_.Bundle -eq 'corpus' -and -not $_.Positive}).Count;ExpectedWriteDropRuns=@($runs|Where-Object {$_.Bundle -eq 'aux' -and -not $_.Positive}).Count;FullGate=$false;AllPathClosure=$false}
$summary|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary|ConvertTo-Json
