$ErrorActionPreference='Stop'
if((Get-Location).Path.Replace([char]92,[char]47) -ne 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-cc'){throw 'Seed03 GCC CWD mismatch'}
$taskSeedCCBusy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskSeedCCBusy.Count -ne 0){throw 'Compiler pipeline active'}
$taskSeedCCFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskSeedCCFree -lt 838861){throw 'Below compiler memory guard'}
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.o'){throw 'Seed03 obj output exists'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.c' -Algorithm SHA256).Hash -ne '5BFFD842EC2DC6126C7ABDEBBE3F1309835CD4F8432CCE1DBF45D92737EB6B3A'){throw 'C bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Algorithm SHA256).Hash -ne '920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1'){throw 'GCC bytes changed'}
Write-Output ('FreeVirtualKiB '+$taskSeedCCFree)
Write-Output ('StartUTC '+[DateTime]::UtcNow.ToString('o'))
& 'C:/Git/usr/bin/timeout.exe' --kill-after=10s 900s 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -pipe -std=c99 -O0 -DLMX_OBSERVE_WALK=0 -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/headers' -I 'C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes' -I 'C:/Nyasha_Planet/LMX/build2/includes' -I 'C:/Nyasha_Planet/LMX' -I 'C:/Nyasha_Planet/LMX/lm1/build' -I 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/src' --param ggc-min-heapsize=16384 --param ggc-min-expand=20 -Dmain=l2_generated_main -Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned -Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned -Dlmx_merge_used_owned=l2_driver_merge_used_owned -Dlmx_service_post=l2_driver_service_post -c 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.c' -o 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.o' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03.CC.log'
$taskSeedCCExit=$LASTEXITCODE
Write-Output ('EndUTC '+[DateTime]::UtcNow.ToString('o'))
Write-Output ('ManualSeed03CCExit '+$taskSeedCCExit)
exit $taskSeedCCExit
