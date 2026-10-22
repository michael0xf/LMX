param([ValidatePattern('^frontend-[0-9]+$')][string]$Label='frontend-01')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_pointer_receive166";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve build attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
function Run154([string]$Tool,[string[]]$Argv,[string]$Log){
 $saved=[Environment]::CurrentDirectory;Push-Location "$stage/src"
 try{[Environment]::CurrentDirectory=(Get-Location).Path;return Invoke-ProcBounded -Exe $Tool -Argv $Argv -TimeoutSec 180 -Log $Log}
 finally{[Environment]::CurrentDirectory=$saved;Pop-Location}
}
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$flags=@('-pipe','-std=c99','-O0','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$r=Run154 "$repo/bin/l1trans.exe" @("$stage/src/l2src/l2_application.h.lm1","$stage/headers/l2src/l2_application.lm1.h") "$out/HEADER.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Application source header generation failed'}
Copy-Item -LiteralPath "$stage/src/l2src/l2trans.lm1" -Destination "$out/frontend-source.lm1"
$r=Run154 "$repo/bin/l1trans.exe" @("$out/frontend-source.lm1","$out/frontend.c") "$out/L1.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Current L1 translation failed'}
$r=Run154 $gcc ($flags+@("$out/frontend.c",$lib,'-o',"$out/l2trans.exe")) "$out/COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Current strict frontend compilation failed'}
$define='-DL2_FRONTEND_SOURCE="'+$out+'/frontend.c"'
$r=Run154 $gcc ($flags+@('-finstrument-functions',$define,"$stage/owned-test.c",$lib,'-o',"$out/owned.exe")) "$out/owned.COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Source-linked owned fixture compile failed'}
$r=Run154 "$out/owned.exe" @() "$out/owned.RUN.log"
@{Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;SourceSha256=(Get-FileHash -LiteralPath "$out/frontend-source.lm1").Hash;FrontendCSha256=(Get-FileHash -LiteralPath "$out/frontend.c").Hash;FrontendExeSha256=(Get-FileHash -LiteralPath "$out/l2trans.exe").Hash;AllPathClosure=$false;FullGate=$false}|ConvertTo-Json|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
$r.Text
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0 -or $r.Text -notmatch 'owned operand records: [0-9]+ checks, 0 failures'){throw 'Existing owned fixture changed'}
