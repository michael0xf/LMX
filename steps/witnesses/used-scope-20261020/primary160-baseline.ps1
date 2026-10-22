#requires -Version 7.0
param([string]$Label='baseline-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_children160";$out="$stage/$Label";$base="$repo/buold_temp"
$frontend="$repo/build2/codex_numeric_receiving159/frontend-16/frontend.c"
if(Test-Path -LiteralPath $out){throw 'Preserve observed baseline'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
if((Get-FileHash -LiteralPath $frontend).Hash -cne 'C841E862F6EADC4816ED0AC3F8DCD4729D44A655D2566C64CB79ADAFDF3231DC'){throw 'Frozen159 frontend changed'}
New-Item -ItemType Directory -Path $out|Out-Null
Copy-Item -LiteralPath "$stage/primary-test.c" -Destination "$out/fixture.c"
. "$repo/tools/ps51_proc.ps1"
$flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$define='-DL2_FRONTEND_SOURCE="'+$frontend+'"'
$r=Invoke-ProcBounded -Exe 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Argv ($flags+@($define,"$out/fixture.c","$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o",'-o',"$out/fixture.exe")) -TimeoutSec 180 -Log "$out/COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Baseline fixture strict compile failed'}
$r=Invoke-ProcBounded -Exe "$out/fixture.exe" -Argv @("$out/emission.lm1") -TimeoutSec 60 -Log "$out/RUN.log"
$record=@{BaseMain='dae8d7a7ca2b2a2fa4056cf113f17f26e99360b6';Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;FixtureSha256=(Get-FileHash -LiteralPath "$out/fixture.c").Hash;FrontendCSha256=(Get-FileHash -LiteralPath $frontend).Hash;ExeSha256=(Get-FileHash -LiteralPath "$out/fixture.exe").Hash;CompilerChanged=$false;AllPathClosure=$false;FullGate=$false}
[IO.File]::WriteAllText("$out/results.json",(($record|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
$r.Text
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 1 -or $r.Text -notmatch 'ANALYSIS158: 82 checks, 2 failures'){throw 'Investigate changed baseline rather than adjusting its positive oracle'}
