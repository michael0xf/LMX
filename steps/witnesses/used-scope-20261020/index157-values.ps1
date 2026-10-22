param([ValidatePattern('^values-[0-9]+$')][string]$Label='values-01',[string]$Frontend='frontend-03',[string]$Routes='routes-03',[int]$First=0,[int]$Last=84)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$prior="$repo/build2/codex_places152_runtime_11";$stage="$repo/build2/codex_index_children157";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve value attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
if($First -lt 0 -or $Last -gt 84 -or $First -gt $Last){throw 'Exact corpus range'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run154([string]$Tool,[string[]]$Argv,[string]$Log,[string]$Cwd){
 $saved=[Environment]::CurrentDirectory;Push-Location $Cwd
 try{[Environment]::CurrentDirectory=$Cwd;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
function Rebase154([string]$Text){
 if($Text -match '^[A-Za-z]:[/\\]'){$p=[IO.Path]::GetFullPath($Text);$prefix=[IO.Path]::GetFullPath("$repo/build")+'\';if($p.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){return "$base/"+$p.Substring($prefix.Length).Replace('\','/')}}
 return $Text
}
$inventory=Get-Content -LiteralPath "$base/codex_native122_values_03/inventory.json" -Raw|ConvertFrom-Json
$baseline=Get-Content -LiteralPath "$prior/full85_final02/builds.json" -Raw|ConvertFrom-Json
$routesRows=Get-Content -LiteralPath "$stage/$Routes/results.json" -Raw|ConvertFrom-Json
if($inventory.Count -ne 85 -or $routesRows.Count -ne 85){throw 'Exact85 source corpus'}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o";$runtime="$prior/actual-02/driver.o"
$compilerHash=(Get-FileHash -LiteralPath "$stage/$Frontend/l2trans.exe").Hash
if((Get-FileHash -LiteralPath $runtime).Hash -cne 'C026245020CC2E54538EF9BBAA39C9878460358C3788A2FC3DEE6DAA45A293A4'){throw 'Runtime byte identity'}
$rows=@();$builds=@()
for($u=$First;$u -le $Last;$u++){
 $case=$inventory[$u];$source="$stage/$Routes/unit$u.lm1";$stem="$out/unit$u";$cwd=Rebase154 $case.L2Cwd
 $known=@($routesRows|Where-Object Unit -eq $u)
 if($known.Count -ne 1 -or $known[0].CompilerSha256 -cne $compilerHash -or (Get-FileHash -LiteralPath $source).Hash -cne $known[0].GeneratedL1Sha256){throw 'Current L2 artifact not bound to exact frontend'}
 Copy-Item -LiteralPath $source -Destination "$stem.lm1"
 $flags=@('-pipe','-std=c99','-O2','-fstrict-aliasing','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'-I',$cwd,'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
 foreach($phase in @(
  @{Name='L1';Tool="$repo/bin/l1trans.exe";Args=@("$stem.lm1","$stem.c")},
  @{Name='COMPILE';Tool=$gcc;Args=($flags+@($case.Hooks)+@('-c',"$stem.c",'-o',"$stem.o"))},
  @{Name='LINK';Tool=$gcc;Args=@("$stem.o",$runtime,$lib,'-Wl,--strip-debug','-o',"$stem.exe")}
 )){
  $r=Run154 $phase.Tool $phase.Args "$stem.$($phase.Name).log" "$stage/src"
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual unit$u $($phase.Name) failed"}
 }
 $bindings=@(Select-String -LiteralPath "$stem.lm1" -Pattern 'l2_entry_leaf\\native:.*l2_m[0-9]+_tr').Count
 $old=@($baseline|Where-Object {$_.Unit -eq $u -and $_.Tier -eq 'new'})
 if($old.Count -ne 1 -or $bindings -ne $old[0].MachineBindings){throw "Native eligibility changed at unit$u"}
 $build=@{Unit=$u;Stem=$stem;CompilerSha256=$compilerHash;GraphSha256=(Get-FileHash -LiteralPath "$stem.lm1").Hash;CSha256=(Get-FileHash -LiteralPath "$stem.c").Hash;ObjectSha256=(Get-FileHash -LiteralPath "$stem.o").Hash;ExeSha256=(Get-FileHash -LiteralPath "$stem.exe").Hash;RuntimeSha256=(Get-FileHash -LiteralPath $runtime).Hash;MachineBindings=$bindings;FreshStrictO2=$true}
 $builds+=$build;$builds|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/builds.json" -Encoding UTF8
 foreach($previous in $case.Rows){
  $r=Run154 "$stem.exe" @($previous.Args) "$stem.RUN$($rows.Count).log" $out
  $okay=$r.Started -and -not $r.TimedOut -and $r.Code -eq $previous.ActualExit
  if($previous.Success){$okay=$okay -and $r.Text -match ("l2_eternal_driver: "+$previous.Checks+" checks, 0 roots")}
  $rows+=@{Unit=$u;Case=$previous.Case;Args=@($previous.Args);ActualExit=$r.Code;PriorExit=$previous.ActualExit;Positive=$previous.Success;ObservationMatched=$okay;Diagnostic=$r.Text;ExeSha256=$build.ExeSha256;FreshCCompile=$true}
  $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
  if(-not $okay){throw "Real values changed at unit$u; preserve old oracle"}
 }
 if(($u+1)%5 -eq 0){Write-Output "Actual values: through unit$u;fresh units=$($builds.Count);runs=$($rows.Count);same eligibility/exits"}
}
$summary=@{First=$First;Last=$Last;FreshStrictO2Units=$builds.Count;ActualRuns=$rows.Count;PositiveRuns=@($rows|Where-Object Positive).Count;SameBaselineRed=@($rows|Where-Object {-not $_.Positive}).Count;Matched=@($rows|Where-Object ObservationMatched).Count;SameNativeEligibility=$true;AllPathClosure=$false;FullGate=$false}
$summary|ConvertTo-Json|Set-Content -LiteralPath "$out/summary.json" -Encoding UTF8
$summary|ConvertTo-Json
