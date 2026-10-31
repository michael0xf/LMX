try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Short L3+L2 bootstrap of the green line (Codex CODEX-OPUS-87V63-20261031-ANSWER,
# option B), relaunched after boot88's G1 runtime blocker (lmx_pool.lm2:150:12
# "assignment value has unknown type"; CODEX-OPUS-85FIND-20261031-ANSWER: fix a
# required-path blocker and continue): the fresh source-only stage cold-boot89
# (boot89-prepare: source-candidate84 with walker86 and green89's resolve) --
# runtime, frontend, smoke list, G1 built by G0, G2 built by G1, the working
# binary. G0 = tool84, BASE full48/g2/frontend and the previous frontend 49c
# (with its backend and libc), unchanged from boot88. Outer bound 48 h.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$term="$p\pins\boot89-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-generator84\tool84-parts\lmxtool-tool.exe", 'B9A2D857776B7BB3D8BFFFB386518CC05FB4F5D2651B77E4BD6ACBC5676A4D62'),
  @("$p\cold-candidate49c\fe49c\l2trans.exe", 'F646DD0754B1761E0405A1D9D7024631276CD5DFE6B3197026059C89F8EBEFCC'),
  @("$p\cold-candidate49c\fe49c\l1trans.exe", 'B68E4DD248A2513299D764D8B83BDE87505308F4C1D21928A4D2020F9DEE46FE'),
  @("$p\cold-candidate49c\fe49c\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
  @("$p\cold-candidate48\full48\g2\frontend\l2trans.exe", 'E9873EBE8EFF797200A6EB75B5211D88E1B708F742B19BCE19608A7E63B3C246'),
  @("$p\cold-candidate48\full48\g2\frontend\l1trans.exe", '519A37A453B372427B70CA599F3DFB16F76FA552F2069AD4795BBF53A3D70AEC'),
  @("$p\cold-candidate48\full48\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
  @('C:\Qt\Tools\mingw1310_64\bin\gcc.exe', '920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1'),
  @('C:\Git\usr\bin\timeout.exe', '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4'),
  @("$p\pins\source-boot89.sha256", '9A5C12AC46199B8038F39496846D4B3D91113C2CF838D601468648EB810C5FA5')
)
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
foreach ($pin in $pinsIn) { if ((Get-FileHash -Algorithm SHA256 -LiteralPath $pin[0]).Hash -ne $pin[1]) { throw ('changed bootstrap input: ' + $pin[0]) } }
if (-not (Test-Path -LiteralPath "$p\pins\boot89-prepare.terminal.txt")) { throw 'stage not prepared' }
foreach ($g in @("$p\cold-boot89\headers", "$p\cold-boot89\src\l2src\lmx.h.lm1", "$p\cold-boot89\src\l1src\libc_abi.lm1", "$p\cold-boot89\quick89", "$p\pins\boot89-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot89-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-generator84\tool84-parts\lmxtool-tool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/cold-boot89" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-candidate49c/fe49c/l2trans.exe" quick89 "$P2/cold-boot89/tests/smoke-kernel225.tsv" *> "$p\pins\boot89-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT89 exit=' + $e)
exit $e
