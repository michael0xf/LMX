CWD C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/src
$ErrorActionPreference='Stop'
$taskBusy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskBusy.Count -ne 0){throw 'Compiler pipeline active'}
if((Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory -lt 838861){throw 'Below memory guard'}
if((Get-FileHash -Algorithm SHA256 -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/boot-quick-01/runtime/driver.c').Hash -ne '3C116AAA2FBA4919DD90B667F17DBA9AA17E91C6E93AC24EF5585724FF793DAC'){throw 'Actual compile input changed'}
& 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '-MM' '-pipe' '-std=c99' '-O2' '-fstrict-aliasing' '-DLMX_OBSERVE_WALK=0' '-Wall' '-Wextra' '-Werror=implicit-function-declaration' '-Werror=implicit-int' '-Werror=incompatible-pointer-types' '-Werror=discarded-qualifiers' '-I' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/headers' '-I' 'C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes' '-I' 'C:/Nyasha_Planet/LMX' '-I' 'C:/Nyasha_Planet/LMX/lm1/build' '-I' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/src' '--param' 'ggc-min-heapsize=16384' '--param' 'ggc-min-expand=20' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/boot-quick-01/runtime/driver.c' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/postterminal-deps-runtime-production.log'
$taskMMExit=$LASTEXITCODE
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/postterminal-deps-runtime-production.log' -Raw
exit $taskMMExit
