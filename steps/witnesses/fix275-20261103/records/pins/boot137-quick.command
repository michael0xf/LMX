try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 275. Whole bootstrap quick of the checked source of cold-tp137: G0 = tool137a, previous frontend = G2 of boot136a.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot137$try"
$label="quick137$try"
$term="$p\pins\boot137$try-quick.terminal.txt"
$pinsIn=@(
  @("$p\cold-tp137\tool137a\lmxtool-tool.exe", 'D47770DB3F567B943B3DE29D66041DFB653E272424EBDE60B6EC39FBB3B40CB9'),
  @("$p\cold-boot136a\quick136a\g2\frontend\l2trans.exe", '0DFCE2C902CA26646C5938E26F6109ADCAA91C1170B9A13A89A635092B39E0C4'),
  @("$p\cold-boot136a\quick136a\g2\frontend\l1trans.exe", 'B99C7084062C525B6C919B99DAD588029DF63E0A0C1F617360E1335A8E928C40'),
  @("$p\cold-boot136a\quick136a\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
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
if (-not (Test-Path -LiteralPath "$p\pins\boot137$try-prepare.terminal.txt")) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\boot137$try-prepare.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage not verified' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot137$try.sha256").Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp137.sha256").Hash) { throw 'source-boot137 is not source-tp137' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\$label", "$p\pins\boot137$try-quick.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\boot137$try-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' source-tp137 ' + (Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp137.sha256").Hash) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-tp137\tool137a\lmxtool-tool.exe" 0 entry 0 -- bootstrap quick $repo "$P2/$stage" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot136a/quick136a/g2/frontend/l2trans.exe" $label "$P2/$stage/tests/smoke-kernel225.tsv" *> "$p\pins\boot137$try-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT137' + $try + ' exit=' + $e)
exit $e
