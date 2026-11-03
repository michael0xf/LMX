try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 269. tp131-suite-04 uses tool131, rt131 and fe131d from the staged candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$p\cold-boot130a\quick130a"
$tool="$p\cold-tp131\tool131\lmxtool-tool.exe"
$term="$p\pins\tp131-suite-04.terminal.txt"
$run="$p\tp131-suite-04-run-01"
$out="$P2/tp131-suite/focus131-04"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp131-suite\focus131-04") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Select-String -LiteralPath "$p\pins\boot130a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot130a did not pass' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, "$p\cold-tp131\fe131d\l2trans.exe", "$p\cold-tp131\rt131\driver.o", "$p\cold-tp131\rt131\driver-observe.o", "$p\pins\focus131-first.tsv")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus131-first.tsv" -Destination "$p\cold-tp131\tests\focus131-first.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp "$p\cold-tp131\fe131d\l2trans.exe") + ' prod ' + (ShaTp "$p\cold-tp131\rt131\driver.o") + ' obs ' + (ShaTp "$p\cold-tp131\rt131\driver-observe.o") + ' list ' + (ShaTp "$p\pins\focus131-first.tsv") + ' fixture ' + (ShaTp "$p\cold-tp131\tests\dyn\unary_complement.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp131/tests/focus131-first.tsv" $R "$P2/cold-tp131" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp131/fe131d/l2trans.exe" "$P2/cold-tp131/rt131/driver.o" $out "$P2/cold-tp131/rt131/driver-observe.o" *> "$p\pins\tp131-suite-04.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp131-suite\focus131-04\failures.tsv") { Get-Content -LiteralPath "$p\tp131-suite\focus131-04\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp131-suite-04.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE131 exit=' + $e)
exit $e
