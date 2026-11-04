try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 276. Whole bootstrap quick of the checked source of cold-tp138: G0 = tool138d, previous frontend = G2 of boot137b.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot138$try"
$label="quick138$try"
$term="$p\pins\boot138$try-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-tp138\tool138d\lmxtool-tool.exe", 'A4B1F7DB8032BC6C2D1D8E55121EC0860E73F1E9A2852C48EFF1798B1A035705'),
  @("$p\cold-boot137b\quick137b\g2\frontend\l2trans.exe", '549D1D4D82EDBB0CEE008DF0A28F86ADC1BC4D11B1F9BF14C5ED8F0A4AA5326E'),
  @("$p\cold-boot137b\quick137b\g2\frontend\l1trans.exe", '6E2CB52852C01E45270D332BC3F4D17F5882A31408E7CB269B941E8ADD3DF709'),
  @("$p\cold-boot137b\quick137b\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
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
if (-not (Test-Path -LiteralPath "$p\pins\boot138$try-prepare.terminal.txt")) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\boot138$try-prepare.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage not verified' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot138$try.sha256").Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp138.sha256").Hash) { throw 'source-boot138 is not source-tp138' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\$label", "$p\pins\boot138$try-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot138$try-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' source-tp138 ' + (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp138.sha256").Hash) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-tp138\tool138d\lmxtool-tool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/$stage" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot137b/quick137b/g2/frontend/l2trans.exe" $label "$P2/$stage/tests/smoke-kernel225.tsv" *> "$p\pins\boot138$try-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT138' + $try + ' exit=' + $e)
exit $e
