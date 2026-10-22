param([ValidatePattern('^check-[0-9]+$')][string]$Label='check-01',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-05',[switch]$OnlyCurrent)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_primary_projection167";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve CHECK observations'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
Copy-Item -LiteralPath "$stage/check-test.c" -Destination "$out/fixture.c"
. "$repo/tools/ps51_proc.ps1"
$rows=@();$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$tiers=@(@{Name='old152';Stage="$repo/build2/codex_places152_runtime_11";C="$repo/build2/codex_places152_runtime_11/frontend-values-02/frontend.c";Define=@()},@{Name='new153';Stage=$stage;C="$stage/$Frontend/frontend.c";Define=@('-DCHECK153_CURRENT=1')})
if($OnlyCurrent){$tiers=@($tiers|Where-Object Name -eq 'new153')}
foreach($tier in $tiers){
 $flags=@('-pipe','-std=c99','-O0','-finstrument-functions','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$($tier.Stage)/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$($tier.Stage)/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
 $define='-DL2_FRONTEND_SOURCE="'+$tier.C+'"'
 $r=Invoke-ProcBounded -Exe $gcc -Argv ($flags+$tier.Define+@($define,"$out/fixture.c",$lib,'-o',"$out/$($tier.Name).exe")) -TimeoutSec 180 -Log "$out/$($tier.Name).COMPILE.log"
 if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw 'Source-linked CHECK fixture compile failed'}
 $r=Invoke-ProcBounded -Exe "$out/$($tier.Name).exe" -Argv @("$out/constant-emission.lm1") -TimeoutSec 60 -Log "$out/$($tier.Name).RUN.log"
 $rows+=@{Tier=$tier.Name;Exit=$r.Code;Started=$r.Started;TimedOut=$r.TimedOut;Diagnostic=$r.Text;FrontendCSha256=(Get-FileHash -LiteralPath $tier.C).Hash;FixtureSha256=(Get-FileHash -LiteralPath "$out/fixture.c").Hash;ExeSha256=(Get-FileHash -LiteralPath "$out/$($tier.Name).exe").Hash}
 $rows|ConvertTo-Json -Depth 4|Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
 $r.Text
 if(-not $r.Started -or $r.TimedOut){throw 'A terminal CHECK observation is required'}
 if($tier.Name -eq 'new153' -and $r.Code -ne 0){throw 'Current positive/ownership assertion failed; baseline retained for comparison'}
}
