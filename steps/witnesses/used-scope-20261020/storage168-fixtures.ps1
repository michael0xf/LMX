param([string]$Label='fixtures-01',[string]$Frontend='frontend-05')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_primary_contract168";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve fixture attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$define='-DL2_FRONTEND_SOURCE="'+$stage+'/'+$Frontend+'/frontend.c"'
$cases=@(@{Name='receive';Source="$stage/receive-test.c";Extra=@()},@{Name='analysis';Source="$stage/analysis-test.c";Extra=@()},@{Name='index';Source="$stage/index-test.c";Extra=@()},@{Name='owned';Source="$stage/owned-test.c";Extra=@()},@{Name='child';Source="$repo/steps/witnesses/used-scope-20261020/child156-test.c";Extra=@('-DCHILD156_CURRENT=1')})
$rows=@()
foreach($case in $cases){
 $name=$case.Name
 Copy-Item -LiteralPath $case.Source -Destination "$out/$name.c"
 $r=Invoke-ProcBounded -Exe $gcc -Argv ($flags+@($case.Extra)+@($define,"$out/$name.c",$lib,'-o',"$out/$name.exe")) -TimeoutSec 180 -Log "$out/$name.COMPILE.log"
 if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual fixture $name strict compile failed"}
 $r=Invoke-ProcBounded -Exe "$out/$name.exe" -Argv @("$out/$name-emission.lm1") -TimeoutSec 60 -Log "$out/$name.RUN.log"
 $rows+=@{Name=$name;Exit=$r.Code;Started=$r.Started;TimedOut=$r.TimedOut;Diagnostic=$r.Text;FrontendCSha256=(Get-FileHash -LiteralPath "$stage/$Frontend/frontend.c").Hash;FixtureSha256=(Get-FileHash -LiteralPath "$out/$name.c").Hash;ExeSha256=(Get-FileHash -LiteralPath "$out/$name.exe").Hash}
 $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
 $r.Text
 if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual fixture $name failed; preserve exact observation"}
}
