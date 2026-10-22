#requires -Version 7.0
param([string]$Frontend='frontend-07',[string]$Label='receive-span-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_primary_contract168";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve source projection observation'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
Copy-Item -LiteralPath "$stage/receive-span-test.c" -Destination "$out/fixture.c"
. "$repo/tools/ps51_proc.ps1"
$flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$c="$stage/$Frontend/frontend.c";$define='-DL2_FRONTEND_SOURCE="'+$c+'"'
$r=Invoke-ProcBounded -Exe 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Argv ($flags+@($define,"$out/fixture.c","$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o",'-o',"$out/fixture.exe")) -TimeoutSec 180 -Log "$out/COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Strict source projection fixture compilation failed'}
$r=Invoke-ProcBounded -Exe "$out/fixture.exe" -Argv @("$out/emission.lm1") -TimeoutSec 60 -Log "$out/RUN.log"
[IO.File]::WriteAllText("$out/results.json",((@{Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;FixtureSha256=(Get-FileHash -LiteralPath "$out/fixture.c").Hash;ExeSha256=(Get-FileHash -LiteralPath "$out/fixture.exe").Hash;FrontendCSha256=(Get-FileHash -LiteralPath $c).Hash;AllPathClosure=$false;FullGate=$false}|ConvertTo-Json).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
$r.Text
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or $r.Text -notmatch 'RECEIVE165: [0-9]+ checks, 0 failures'){throw 'Source projection witness changed'}
