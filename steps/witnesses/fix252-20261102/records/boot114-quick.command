try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot114 (fable_pc): the short L3+L2 bootstrap of the optimization line after tp113/tp114 -- the fresh source-only stage
# cold-boot114 (boot114-prepare: exactly source-tp114, the sources of fe114 with the G1 full100 kernel): runtime, frontend,
# smoke list, G1 built by G0, G2 built by G1, the working binary. G0 = tool114 (tp114's tools/build.lm2 with the 85 state
# cells of tp110-tp114, the host of fe114; built with boot112's G2 frontend and runtime), BASE full48/g2/frontend as for
# every FE of the line, the previous frontend fe114 (with its backend and libc). The point: G1's frontend is translated by
# fe114, G2's by G1 itself -- the fixed point G1 = G2 is the self-build check of tp113/tp114 on top of the landed source-tp112.
# Outer bound 48 h. One pipeline.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$term="$p\pins\boot114-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-tp114\tool114\lmxtool-tool.exe", '46D20AA9A82A5643309906B9EC642B1CB6ECA6F94133AA731A291D7F1E51F6EA'),
  @("$p\cold-tp114\fe114\l2trans.exe", '0DB4B5D142C9C91AAF73AAB02F7FE94A49603EE446CB239BEB1CF1E601009B5C'),
  @("$p\cold-tp114\fe114\l1trans.exe", '2C4D9B0DD402B4B76575E4EE973527891887FB7DFD7EA60F57B834407E508500'),
  @("$p\cold-tp114\fe114\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
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
if (-not (Test-Path -LiteralPath "$p\pins\boot114-prepare.terminal.txt")) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\boot114-prepare.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage not verified' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot114.sha256").Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp114.sha256").Hash) { throw 'source-boot114 is not source-tp114' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp114.sha256").Hash -ne 'FE3FDA29B2B6029DB640717BAF88E812F75F6AD3B8E64C54FF5BCF27BF31D6CF') { throw 'source-tp114 manifest hash' }
foreach ($g in @("$p\cold-boot114\headers", "$p\cold-boot114\src\l2src\lmx.h.lm1", "$p\cold-boot114\src\l1src\libc_abi.lm1", "$p\cold-boot114\quick114", "$p\pins\boot114-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot114-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-tp114\tool114\lmxtool-tool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/cold-boot114" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp114/fe114/l2trans.exe" quick114 "$P2/cold-boot114/tests/smoke-kernel225.tsv" *> "$p\pins\boot114-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT114 exit=' + $e)
exit $e
