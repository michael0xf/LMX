$ErrorActionPreference='Stop'
if((Get-Location).Path.Replace([char]92,[char]47) -ne 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/runs/seed03-ld'){throw 'Seed03 link CWD mismatch'}
$taskSeedLDBusy=@(Get-CimInstance Win32_Process -Filter "Name='gcc.exe' OR Name='cc1.exe' OR Name='collect2.exe' OR Name='ld.exe' OR Name='l2trans.exe' OR Name='l1trans.exe'")
if($taskSeedLDBusy.Count -ne 0){throw 'Compiler pipeline active'}
$taskSeedLDFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskSeedLDFree -lt 838861){throw 'Below compiler memory guard'}
if(Test-Path -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool-tool.exe'){throw 'Seed03 EXE output exists'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.o' -Algorithm SHA256).Hash -ne 'D553F5A4FB88EBCDB4076DC705D232473962E1EC175831453AA9F9464FDD74E7'){throw 'Object bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix236front265cold01/boot-quick-01/runtime/driver.o' -Algorithm SHA256).Hash -ne '120A09810A60415003EB2376B2C44171137CBF32A9A018D196A2CEC1B06FFE7A'){throw 'Historical runtime bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l2_libc.o' -Algorithm SHA256).Hash -ne '1EDAE70A026B25652420E7ECD2FF8361D848D476B78CDC448A5DE0FEC55576D7'){throw 'Historical support bytes changed'}
if((Get-FileHash -LiteralPath 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' -Algorithm SHA256).Hash -ne '920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1'){throw 'GCC bytes changed'}
Write-Output ('FreeVirtualKiB '+$taskSeedLDFree)
Write-Output ('StartUTC '+[DateTime]::UtcNow.ToString('o'))
& 'C:/Git/usr/bin/timeout.exe' --kill-after=10s 900s 'C:/Qt/Tools/mingw1310_64/bin/gcc.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool.o' 'C:/Nyasha_Planet/LMX/build2/codex_fix236front265cold01/boot-quick-01/runtime/driver.o' 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-bundle/l2_libc.o' -lshell32 -lbcrypt -Wl,--strip-debug -o 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/seed-03/lmxtool-tool.exe' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix237front112backend129plan01/pins/seed03.LD.log'
$taskSeedLDExit=$LASTEXITCODE
Write-Output ('EndUTC '+[DateTime]::UtcNow.ToString('o'))
Write-Output ('ManualSeed03LDExit '+$taskSeedLDExit)
exit $taskSeedLDExit
