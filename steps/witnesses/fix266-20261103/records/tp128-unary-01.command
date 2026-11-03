try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 265. tp128-unary-01 uses the tp127 source candidate, component frontend and boot127b G2 runtime.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$p\cold-boot127b\quick127b"
$tool="$Q\lmxtool.exe"
$term="$p\pins\tp128-unary-01.terminal.txt"
$run="$p\tp128-unary-01-run-01"
$out="$P2/tp128-suite/unary-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp128-suite\unary-01") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Select-String -LiteralPath "$p\pins\boot127b-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot127b not done' }
if (-not (Select-String -LiteralPath "$p\pins\boot127b-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot127b did not pass' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, "$p\cold-tp128\fe128a\l2trans.exe", "$p\cold-tp128\rt128a\driver.o", "$p\cold-tp128\rt128a\driver-observe.o", "$p\pins\focus128-unary-01.tsv")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus128-unary-01.tsv" -Destination "$p\cold-tp128\tests\focus128-unary-01.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp "$p\cold-tp128\fe128a\l2trans.exe") + ' prod ' + (ShaTp "$p\cold-tp128\rt128a\driver.o") + ' obs ' + (ShaTp "$p\cold-tp128\rt128a\driver-observe.o") + ' list ' + (ShaTp "$p\pins\focus128-unary-01.tsv") + ' fixture ' + (ShaTp "$p\cold-tp128\tests\dyn\unary_data_selection.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp128/tests/focus128-unary-01.tsv" $R "$P2/cold-tp128" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp128/fe128a/l2trans.exe" "$P2/cold-tp128/rt128a/driver.o" $out "$P2/cold-tp128/rt128a/driver-observe.o" *> "$p\pins\tp128-unary-01.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp128-suite\unary-01\failures.tsv") { Get-Content -LiteralPath "$p\tp128-suite\unary-01\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp128-unary-01.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE127 exit=' + $e)
exit $e
