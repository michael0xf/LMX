try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot119 (fable_pc, the short L3+L2 bootstrap of the optimization line after tp119 = design 4.5 B2b, P1-RET; after the
# isolated runtime and frontend builds and the focus suite on them) -- the fresh source-only stage cold-boot119<TP_TRY>
# (boot119-prepare: exactly source-tp119): runtime, frontend, smoke list, G1 built by G0, G2 built by G1, the working binary.
# G0 = boot118a's G2 working tool (3E5F1A18; tools/build.lm2 is the landed one, so no new tool), BASE full48/g2/frontend as for
# every FE of the line, the previous frontend = boot118a's G2 frontend (the landed source-tp119's self-built frontend, with its
# backend and libc).  The fixed point G1 = G2 is the self-build check of tp119 on top of the landed source-tp119.  Outer bound
# 48 h.  One pipeline.  Parameter: TP_TRY (a, b, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot119$try"
$label="quick119$try"
$term="$p\pins\boot119$try-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-boot118a\quick118a\lmxtool.exe", '3E5F1A186EA1A548DDC81A2F8CD47B88750543B4A4B7FA20EA3716504420C0B2'),
  @("$p\cold-boot118a\quick118a\g2\frontend\l2trans.exe", '2A279AE64AD3D83E47D9C20C0A0946366DDF436D2674FB335172C760DCE7F363'),
  @("$p\cold-boot118a\quick118a\g2\frontend\l1trans.exe", '4EC39A620624F1D5184F419062DCAC2FC500668943700C1B3CE19A76351C0E56'),
  @("$p\cold-boot118a\quick118a\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
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
if (-not (Test-Path -LiteralPath "$p\pins\boot119$try-prepare.terminal.txt")) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\boot119$try-prepare.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage not verified' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot119$try.sha256").Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp119.sha256").Hash) { throw 'source-boot119 is not source-tp119' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\$label", "$p\pins\boot119$try-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot119$try-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' source-tp119 ' + (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp119.sha256").Hash) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-boot118a\quick118a\lmxtool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/$stage" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot118a/quick118a/g2/frontend/l2trans.exe" $label "$P2/$stage/tests/smoke-kernel225.tsv" *> "$p\pins\boot119$try-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT119' + $try + ' exit=' + $e)
exit $e
