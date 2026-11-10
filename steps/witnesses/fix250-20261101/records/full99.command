try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# The ordinary whole FULL of the draft79 line (after slice249): the fresh
# source-only stage cold-full99 (full99-prepare: exactly source-candidate94,
# the 159 sources boot98 built) -- per generation frontend, runtime, the smoke
# list, the full list, OSWALK and the self-test, G1 built by G0, G2 built by
# G1, both promoted, then the tool comparisons. G0 = boot98's promoted working
# tool (quick98/lmxtool.exe = its G2 tool) and the previous frontend =
# boot98's G2 frontend, so this G1 is the next generation from boot98's G2
# (the direct test of the fixed point slice249 left open). BASE
# full48/g2/frontend as for every FE of the line. Outer bound 48 h. One
# pipeline.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$term="$p\pins\full99.terminal.txt"
$pinsIn=@(
  @("$p\cold-boot98\quick98\lmxtool.exe", 'B8B01381085C8ABC2A4596F28F5DC78C8BADA8D55675DC8B86B2B407A315CA0C'),
  @("$p\cold-boot98\quick98\g2\frontend\l2trans.exe", '8E56C1F343623018209D3BE57C2B282EA11B53A7466DB079E070F19CC866086C'),
  @("$p\cold-boot98\quick98\g2\frontend\l1trans.exe", '6C88097534F3687EF492F9B5B37B9AA5C88C85EE80E0BB611F18D4791709636D'),
  @("$p\cold-boot98\quick98\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
  @("$p\cold-candidate48\full48\g2\frontend\l2trans.exe", 'E9873EBE8EFF797200A6EB75B5211D88E1B708F742B19BCE19608A7E63B3C246'),
  @("$p\cold-candidate48\full48\g2\frontend\l1trans.exe", '519A37A453B372427B70CA599F3DFB16F76FA552F2069AD4795BBF53A3D70AEC'),
  @("$p\cold-candidate48\full48\g2\frontend\l2_libc.o", 'AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37'),
  @('C:\Qt\Tools\mingw1310_64\bin\gcc.exe', '920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1'),
  @('C:\Git\usr\bin\timeout.exe', '4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4'),
  @("$p\pins\source-full99.sha256", '1F374773C376E18D6D0129606408413BE30CF3F389844BF7C82B156C4CEBB9A4')
)
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
foreach ($pin in $pinsIn) { if ((Get-FileHash -Algorithm SHA256 -LiteralPath $pin[0]).Hash -ne $pin[1]) { throw ('changed bootstrap input: ' + $pin[0]) } }
if (-not (Test-Path -LiteralPath "$p\pins\full99-prepare.terminal.txt")) { throw 'stage not prepared' }
foreach ($g in @("$p\cold-full99\headers", "$p\cold-full99\src\l2src\lmx.h.lm1", "$p\cold-full99\src\l1src\libc_abi.lm1", "$p\cold-full99\full99", "$p\pins\full99.log")) {
  if (Test-Path -LiteralPath $g) { throw ('output or generated input exists: ' + $g) }
}
foreach ($t in @("$p\cold-full99\tests\smoke-kernel225.tsv", "$p\cold-full99\tests\full-suite.tsv")) {
  if (-not (Test-Path -LiteralPath $t)) { throw ('missing list: ' + $t) }
}
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 838861) { throw 'insufficient VM' }
$cwd="$p\full99-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' "$p\cold-boot98\quick98\lmxtool.exe" 0 entry 0 -- bootstrap full $repo "$P2/cold-full99" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot98/quick98/g2/frontend/l2trans.exe" full99 "$P2/cold-full99/tests/smoke-kernel225.tsv" "$P2/cold-full99/tests/full-suite.tsv" *> "$p\pins\full99.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('FULL99 exit=' + $e)
exit $e
