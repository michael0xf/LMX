try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot115c (fable_pc, third attempt after fix03 -- boot115b's G1 runtime step translated every module and failed the C compile of driver.c, a cast to @@: Lmx rendered void **; the short L3+L2 bootstrap of the optimization line after tp115 (design 4.4: the kernel's code links and
# the native reset on a write of code, the arena passed to lmx_arena_ref_store by every actual and generated caller, the
# driver's start-up self-check) -- the fresh source-only stage cold-boot115c (boot115c-prepare: exactly source-tp115): runtime,
# frontend, smoke list, G1 built by G0, G2 built by G1, the working binary. G0 = tool115 (tp115's tools/build.lm2: the
# LmxCodeLink record, the LmxRange side fields, the lmx_range/lmx_arena_refs exports, the program-text scan; built with
# boot114's G2 frontend and runtime), BASE full48/g2/frontend as for every FE of the line, the previous frontend = boot114's
# G2 frontend (the landed source-tp114's self-built frontend, with its backend and libc). The point: G1's runtime is the
# first build with the tp115 kernel headers, G1's frontend is translated by the previous frontend, G2's by G1 itself; the
# fixed point G1 = G2 is the self-build check of tp115 on top of the landed source-tp114. Outer bound 48 h. One pipeline.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$term="$p\pins\boot115c-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-tp115\tool115\lmxtool-tool.exe", '39A0019C130258A3A0D652B4B4EE5178DB158FB026075EC7B3145551B53F2678'),
  @("$p\cold-boot114\quick114\g2\frontend\l2trans.exe", '17DFEEA955FACD7615002E45CF40995811D780739DA300B04F7AFA74DCE72990'),
  @("$p\cold-boot114\quick114\g2\frontend\l1trans.exe", '9311308078CA36AEBA866FEBA0324F64EB832C62EF3B33E36FC511D61B9AE860'),
  @("$p\cold-boot114\quick114\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
  @("$p\cold-candidate48\full48\g2\frontend\l2trans.exe", 'E9873EBE8EFF797200A6EB75B5211D88E1B708F742B19BCE19608A7E63B3C246'),
  @("$p\cold-candidate48\full48\g2\frontend\l1trans.exe", '519A37A453B372427B70CA599F3DFB16F76FA552F2069AD4795BBF53A3D70AEC'),
  @("$p\cold-candidate48\full48\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
  @('C:\Qt\Tools\mingw1310_64\bin\gcc.exe', '920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1'),
  @('C:\Git\usr\bin\timeout.exe', '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4')
)
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
foreach ($pin in $pinsIn) { if ((Get-FileHash -Algorithm SHA256 -LiteralPath $pin[0]).Hash -ne $pin[1]) { throw ('changed bootstrap input: ' + $pin[0]) } }
if (-not (Test-Path -LiteralPath "$p\pins\boot115c-prepare.terminal.txt")) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\boot115c-prepare.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage not verified' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot115c.sha256").Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp115.sha256").Hash) { throw 'source-boot115c is not source-tp115' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp115.sha256").Hash -ne '41B19DFD7483D3D3D2B4C53591C1424BB5A20312A34F0ED4BCDC7E97FAB2BF37') { throw 'source-tp115 manifest hash' }
foreach ($g in @("$p\cold-boot115c\headers", "$p\cold-boot115c\src\l2src\lmx.h.lm1", "$p\cold-boot115c\src\l1src\libc_abi.lm1", "$p\cold-boot115c\quick115c", "$p\pins\boot115c-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot115c-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-tp115\tool115\lmxtool-tool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/cold-boot115c" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot114/quick114/g2/frontend/l2trans.exe" quick115c "$P2/cold-boot115c/tests/smoke-kernel225.tsv" *> "$p\pins\boot115c-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT115C exit=' + $e)
exit $e
