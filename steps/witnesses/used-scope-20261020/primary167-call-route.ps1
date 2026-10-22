#requires -Version 7.0
param([string]$Frontend='frontend-09',[string]$Label='call-route-01',[string[]]$Sources=@('named-order','named-prefix','named-held','named-callable','pending-call','pending-composite','source-mapped'),[switch]$ObserveRemaining,[string]$CompilerC='',[switch]$Baseline)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_projection167";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve call-route evidence'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
Copy-Item -LiteralPath "$stage/call-route-test.c" -Destination "$out/fixture.c"
. "$repo/tools/ps51_proc.ps1"
$flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$frontendC="$stage/$Frontend/frontend.c";$define='-DL2_FRONTEND_SOURCE="'+$frontendC+'"'
if($CompilerC){$frontendC=$CompilerC;$define='-DL2_FRONTEND_SOURCE="'+$frontendC+'"'}
if($Baseline){$flags+=@('-DRECEIVE165_BASELINE=1')}
$r=Invoke-ProcBounded -Exe 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Argv ($flags+@($define,"$out/fixture.c","$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o",'-o',"$out/fixture.exe")) -TimeoutSec 180 -Log "$out/COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Call-route probe strict compile failed'}
$rows=@();$modelCalls164=0;$receiving165=0
foreach($name in $Sources){
 foreach($mode in 'native','forced'){
  $extra=@();if($mode -eq 'forced'){$extra=@('--walk-methods')}
  $argv162=$extra+@("$stage/$name.lm2","$base/l2_harness/codex_consumer49_full_01/src/convert.lm2","$base/l2_harness/codex_consumer49_full_01/src/primitive.lm2","$out/$name-$mode.lm1")
  $saved=[Environment]::CurrentDirectory;Push-Location "$stage/src"
  try{[Environment]::CurrentDirectory=(Get-Location).Path;$r=Invoke-ProcBounded -Exe "$out/fixture.exe" -Argv $argv162 -TimeoutSec 180 -Log "$out/$name-$mode.log"}
  finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
  $rows+=@{Source=$name;Mode=$mode;Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;SourceSha256=(Get-FileHash -LiteralPath "$stage/$name.lm2").Hash;FrontendCSha256=(Get-FileHash -LiteralPath $frontendC).Hash;ProbeSha256=(Get-FileHash -LiteralPath "$out/fixture.exe").Hash;RuntimeProof=$false}
  [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
  $r.Text
  if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Call-route translation failed'}
  $lanes=[regex]::Matches($r.Text,'(?m)^CALL162 (\S+) calls=(\d+) adapters=(\d+) fields=(\d+) old-spans=(\d+) synthetic-copies=(\d+) legacy-callables=(\d+) depth=(-?\d+)\r?$')
  if($lanes.Count -ne 6){throw 'Missing call-consumer instrumentation'}
  if(-not $ObserveRemaining){foreach($lane in $lanes){foreach($field in 3..8){if([long]$lane.Groups[$field].Value -ne 0){throw 'Call consumer retried raw grammar/legacy callable selection or unbalanced its instrumented phase'}}}}
  $models164=[regex]::Matches($r.Text,'(?m)^MODEL164 (\S+) calls=(\d+) raw-models=(\d+) raw-reference-values=(\d+) raw-reference-roots=(\d+)\r?$')
  if($models164.Count -ne 6){throw 'Missing Model consumer instrumentation'}
  foreach($lane164 in $models164){$modelCalls164+=[long]$lane164.Groups[2].Value;if(-not $ObserveRemaining){foreach($k164 in 3..5){if([long]$lane164.Groups[$k164].Value){throw 'A prepared argument retried a raw Model/reference-value route'}}}}
  $receive165=[regex]::Matches($r.Text,'(?m)^RECEIVE165 (\S+) calls=(\d+) raw-receiving=(\d+)\r?$')
  if($receive165.Count -ne 6){throw 'Missing receiving instrumentation'}
  foreach($lane165 in $receive165){$receiving165+=[long]$lane165.Groups[2].Value;if(-not $Baseline -and [long]$lane165.Groups[3].Value){throw 'A held argument reentered the raw receiving boundary'}}
  $offset=0;if($name -eq 'named-held'){$offset=3}
  foreach($lane in $lanes[$offset..($offset+2)]){if([long]$lane.Groups[2].Value -le 0){throw 'Selected call-consumer route was not actually entered'}}
 }
}
if(-not $ObserveRemaining -and $modelCalls164 -lt 1){throw 'The candidate Model route was not exercised'}
if($ObserveRemaining -and -not $Baseline -and $receiving165 -lt 1){throw 'The new prepared receiving route was not exercised'}
