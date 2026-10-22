#requires -Version 7.0
param([string]$Frontend='frontend-05',[string]$Label='sizeof-01',[switch]$Baseline)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_unevaluated169";$base="$repo/buold_temp";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve storage query observation'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
Copy-Item -LiteralPath "$stage/sizeof-test.c" -Destination "$out/fixture.c"
. "$repo/tools/ps51_proc.ps1"
$frontendC="$stage/$Frontend/frontend.c";$includeStage=$stage;$extra=@('-DSIZEOF168_CURRENT=1')
if($Baseline){$includeStage="$repo/build2/codex_primary_projection167";$frontendC="$includeStage/frontend-05/frontend.c";$extra=@()}
$define='-DL2_FRONTEND_SOURCE="'+$frontendC+'"'
$flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$includeStage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$includeStage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$r=Invoke-ProcBounded -Exe 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Argv ($flags+$extra+@($define,"$out/fixture.c","$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o",'-o',"$out/fixture.exe")) -TimeoutSec 180 -Log "$out/COMPILE.log"
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Storage query fixture strict compile failed'}
$r=Invoke-ProcBounded -Exe "$out/fixture.exe" -Argv @("$out/emission.lm1") -TimeoutSec 60 -Log "$out/RUN.log"
$result=@{Started=$r.Started;TimedOut=$r.TimedOut;Exit=$r.Code;Diagnostic=$r.Text;Baseline=[bool]$Baseline;FrontendCSha256=(Get-FileHash -LiteralPath $frontendC).Hash;FixtureSha256=(Get-FileHash -LiteralPath "$out/fixture.c").Hash;ExeSha256=(Get-FileHash -LiteralPath "$out/fixture.exe").Hash;AllPrimaryClosure=$false;FullGate=$false}
[IO.File]::WriteAllText("$out/results.json",(($result|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
$r.Text
if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Storage query fixture failed'}
