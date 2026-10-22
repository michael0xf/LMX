param([ValidatePattern('^profiles-[0-9]+$')][string]$Label='profiles-03',[ValidatePattern('^frontend-[0-9]+$')][string]$Frontend='frontend-07')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$base="$repo/buold_temp";$stage="$repo/build2/codex_child_records156";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve profiles attempt'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out | Out-Null
. "$repo/tools/ps51_proc.ps1"
$flags=@('-pipe','-std=c99','-O0','-Wall','-Wextra','-Werror=implicit-function-declaration','-Werror=implicit-int','-Werror=incompatible-pointer-types','-Werror=discarded-qualifiers','-I',"$stage/headers",'-I',"$base/codex_header98_source_control_06/includes",'-I',"$repo/build2/includes",'-I',$repo,'-I',"$repo/lm1/build",'-I',"$stage/src",'--param','ggc-min-heapsize=16384','--param','ggc-min-expand=20')
$define='-DL2_FRONTEND_SOURCE="'+$stage+'/'+$Frontend+'/frontend.c"'
$gcc='C:/Qt/Tools/mingw1310_64/bin/gcc.exe';$lib="$base/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o"
$cases=@(
 @{Name='owned';Source="$base/codex_places152_owned_test_06.c";Extra=@('-finstrument-functions');Oracle='owned operand records: '},
 @{Name='cursor';Source="$repo/tools/l2_use_roots_cursor_test.c";Oracle='bound source roots/cursors: 32 checks, 0 failures'},
 @{Name='roles';Source="$repo/tools/l2_use_roles_test.c";Oracle='source-use roles: 24 checks, 0 failures'},
 @{Name='ports';Source="$repo/tools/l2_use_receiver_ports_test.c";Oracle='bound receiver ports: 31 checks, 0 failures'},
 @{Name='pair';Source="$base/codex_pair74_test_01.c";Oracle='typed pair plan: 65 checks, 0 failures'},
 @{Name='scope';Source="$base/codex_consumer66_scope_test_02.c";Oracle='Consumer equations: 42 checks, 0 failures'},
 @{Name='projection';Source="$base/codex_source96_projection_test_01.c";Oracle='resolved source projection: 13 checks, 0 failures'},
 @{Name='retained';Source="$base/codex_source99_retained_path_test_01.c";Oracle='retained typed source path: 17 checks, 0 failures'},
 @{Name='verdict';Source="$base/codex_source100_verdict_test_01.c";Oracle='bound source verdict: 16 checks, 0 failures'},
 @{Name='query';Source="$base/codex_source103_query_test_02.c";Oracle='prepared query source: 16 checks, 0 failures'},
 @{Name='root_model';Source="$base/codex_root110_model_test_02.c";Oracle='bound whole Model anchor: 32 checks, 0 failures'},
 @{Name='status';Source="$base/codex_source101_status_test_01.c";Oracle='source query status: 10 checks, 0 failures'},
 @{Name='physical_origin';Source="$base/codex_copy109_token_test_02.c";Oracle='current physical token: 18 checks, 0 failures'},
 @{Name='effects';Source="$base/codex_effect104_scan_test_02.c";Oracle='single effects path: '},
 @{Name='common420';Source="$base/codex_path142_common_test_01.c";Extra=@('-DPATH142_COMMON=1');Oracle='common machine INDEX: 420 checks, 0 failures'},
 @{Name='dispatch200';Source="$base/codex_dispatch143_count_test_04.c";Extra=@('-DDISPATCH143_CURRENT=1','-finstrument-functions');Oracle='one INDEX dispatch: 200 checks, 0 failures'},
 @{Name='receiving114';Source="$repo/steps/witnesses/used-scope-20261020/path-consumers149-receiving-test.c";Extra=@('-finstrument-functions','-DRECEIVE147_COMMON=1');Oracle='closed receiving value: 114 checks, 0 failures'}
)
$rows=@()
foreach($case in $cases){
 $name=$case.Name;$extra=@();if($case.Extra){$extra=@($case.Extra)}
 $r=Invoke-ProcBounded -Exe $gcc -Argv ($flags+$extra+@($define,$case.Source,$lib,'-o',"$out/$name.exe")) -TimeoutSec 180 -Log "$out/$name.COMPILE.log"
 if(-not $r.Started -or $r.TimedOut -or $r.Code -ne 0){throw "Actual profile $name strict compile failed"}
 $argv152=@();if($name -eq 'pair'){$argv152=@("$out/catalog-fill.lm1")}
 $r=Invoke-ProcBounded -Exe "$out/$name.exe" -Argv $argv152 -TimeoutSec 60 -Log "$out/$name.RUN.log"
 $ok=$r.Started -and -not $r.TimedOut -and $r.Code -eq 0 -and $r.Text -match [regex]::Escape($case.Oracle)
 $rows+=@{Name=$name;Source=$case.Source;SourceSha256=(Get-FileHash -LiteralPath $case.Source).Hash;FrontendSha256=(Get-FileHash -LiteralPath "$stage/$Frontend/frontend.c").Hash;ActualExit=$r.Code;Success=$ok;Diagnostic=$r.Text;ExeSha256=(Get-FileHash -LiteralPath "$out/$name.exe").Hash}
 $rows | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$out/results.json" -Encoding UTF8
 $r.Text
 if(-not $ok){throw "Actual profile $name unchanged oracle failed"}
}
Write-Output 'All17 compiler profiles terminal; no full kernel/self-build/mail claim'
