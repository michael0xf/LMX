try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot112 (fable_pc): the short L3+L2 bootstrap of the optimization line after S1-S3 -- the fresh source-only stage
# cold-boot112 (boot112-prepare: exactly source-tp112, the sources of fe112 with the G1 full100 kernel): runtime,
# frontend, smoke list, G1 built by G0, G2 built by G1, the working binary. G0 = tool112 (tp112's tools/build.lm2 with
# the 49 state cells of tp110-tp112, the host of fe112), BASE full48/g2/frontend as for every FE of the line, the
# previous frontend fe112 (with its backend and libc). The point: G1's frontend is translated by fe112 (the indexes
# and memos), G2's by G1 itself -- the fixed point G1 = G2 is the self-build check of S1-S3. Outer bound 48 h.
# One pipeline.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$term="$p\pins\boot112-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-tp112\tool112\lmxtool-tool.exe", 'A9E9A139B49A3BF14F2A6221B6D26D820B10E7D10BF3310F41D05DBD741A2710'),
  @("$p\cold-tp112\fe112\l2trans.exe", '46F3A97471E26CE2A1587826FFB80DEEB41F1BF039533D0611EFD8076A03D207'),
  @("$p\cold-tp112\fe112\l1trans.exe", '158B1E8AF5F327BADE8D6FC82BF369097EEB5E7C30C284167754D1F96A7609D4'),
  @("$p\cold-tp112\fe112\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
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
if (-not (Test-Path -LiteralPath "$p\pins\boot112-prepare.terminal.txt")) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\boot112-prepare.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage not verified' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot112.sha256").Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp112.sha256").Hash) { throw 'source-boot112 is not source-tp112' }
foreach ($g in @("$p\cold-boot112\headers", "$p\cold-boot112\src\l2src\lmx.h.lm1", "$p\cold-boot112\src\l1src\libc_abi.lm1", "$p\cold-boot112\quick112", "$p\pins\boot112-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot112-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-tp112\tool112\lmxtool-tool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/cold-boot112" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp112/fe112/l2trans.exe" quick112 "$P2/cold-boot112/tests/smoke-kernel225.tsv" *> "$p\pins\boot112-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT112 exit=' + $e)
exit $e
