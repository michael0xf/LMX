CWD C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/src
$ErrorActionPreference='Stop'
$taskBusy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskBusy.Count -ne 0){throw 'Compiler pipeline active'}
if((Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory -lt 838861){throw 'Below memory guard'}
if((Get-FileHash -Algorithm SHA256 -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/boot-quick-01/frontend/backend.c').Hash -ne '680C186F15BC573CB4C505E2954864FD27ED687FD253C8A7DB458AB0AF428258'){throw 'Actual compile input changed'}
& 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' '-MM' '-pipe' '-std=c99' '-O0' '-Wall' '-Wextra' '-Werror=implicit-function-declaration' '-Werror=implicit-int' '-Werror=incompatible-pointer-types' '-Werror=discarded-qualifiers' '--param' 'ggc-min-heapsize=16384' '--param' 'ggc-min-expand=20' '-I' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/headers' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/boot-quick-01/frontend/backend.c' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/postterminal-deps-backend.log'
$taskMMExit=$LASTEXITCODE
Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129cold04/pins/postterminal-deps-backend.log' -Raw
exit $taskMMExit
