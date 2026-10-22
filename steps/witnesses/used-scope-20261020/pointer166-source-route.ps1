#requires -Version 7.0
param([string]$Frontend='frontend-05',[string]$Label='source-route-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_pointer_receive166";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve source route observation'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
Copy-Item -LiteralPath "$stage/source-route-test.c" -Destination "$out/fixture.c"
. "$repo/tools/ps51_proc.ps1"
$c="$stage/$Frontend/frontend.c";$define='-DL2_FRONTEND_SOURCE="'+$c+'"'
$flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$r=Invoke-ProcBounded -Exe 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Argv ($flags+@($define,"$out/fixture.c","$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o",'-o',"$out/fixture.exe")) -TimeoutSec 180 -Log "$out/COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Source route strict compilation failed'}
$rows=@();$totalCalls=0;$totalProjections=0
foreach($name in 'named-order','named-held','named-callable','callable-current','callable-path','callable-deep','held-free-names','receive-hidden','receive-actual','receive-values','source-mapped'){
 foreach($mode in 'native','forced'){
  $extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
  $saved=[Environment]::CurrentDirectory;Push-Location "$stage/src"
  try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$out/fixture.exe" -Argv ($extra+@("$stage/$name.lm2","$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$out/$name-$mode.lm1")) -TimeoutSec 180 -Log "$out/$name-$mode.log"}
  finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
  $match=[regex]::Match($r.Text,'(?m)^SOURCE163 calls=(\d+) projections=(\d+) raw=(\d+) adapters=(\d+) fields=(\d+) depth=(-?\d+)\r?$')
  $ok=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $match.Success
  if($match.Success){foreach($k in 3..6){if([long]$match.Groups[$k].Value){$ok=$false}};$totalCalls+=[long]$match.Groups[1].Value;$totalProjections+=[long]$match.Groups[2].Value}
  $rows+=@{Source=$name;Mode=$mode;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Success=$ok;Diagnostic=$r.Text;SourceSha256=(Get-FileHash -LiteralPath "$stage/$name.lm2").Hash;FrontendCSha256=(Get-FileHash -LiteralPath $c).Hash;ProbeSha256=(Get-FileHash -LiteralPath "$out/fixture.exe").Hash;RuntimeProof=$false}
  [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
  $r.Text
  if(-not $ok){throw 'Prepared source query retried raw grammar or failed translation'}
 }
}
if($rows.Count -ne 22 -or $totalCalls -lt 1 -or $totalProjections -lt 1){throw 'The source projection was not actually exercised'}
