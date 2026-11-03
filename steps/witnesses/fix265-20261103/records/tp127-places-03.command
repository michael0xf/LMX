try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 265. tp127-places-03 uses the tp127 source candidate, component frontend and boot126a G2 runtime.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$p\cold-boot126a\quick126a"
$tool="$Q\lmxtool.exe"
$term="$p\pins\tp127-places-03.terminal.txt"
$run="$p\tp127-places-03-run-01"
$out="$P2/tp127-suite/places-03"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp127-suite\places-03") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Select-String -LiteralPath "$p\pins\boot126a-detached.terminal.txt" -Pattern '^done ' -Quiet)) { throw 'boot126a not done' }
if (-not (Select-String -LiteralPath "$p\pins\boot126a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot126a did not pass' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, "$p\cold-tp127\fe127c\l2trans.exe", "$Q\g2\runtime\driver.o", "$Q\g2\runtime\driver-observe.o", "$p\pins\focus127-places-03.tsv")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus127-places-03.tsv" -Destination "$p\cold-tp127\tests\focus127-places-03.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp "$p\cold-tp127\fe127c\l2trans.exe") + ' prod ' + (ShaTp "$Q\g2\runtime\driver.o") + ' obs ' + (ShaTp "$Q\g2\runtime\driver-observe.o") + ' list ' + (ShaTp "$p\pins\focus127-places-03.tsv") + ' fixture ' + (ShaTp "$p\cold-tp127\tests\dyn\held_structure_places.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp127/tests/focus127-places-03.tsv" $R "$P2/cold-tp127" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp127/fe127c/l2trans.exe" "$P2/cold-boot126a/quick126a/g2/runtime/driver.o" $out "$P2/cold-boot126a/quick126a/g2/runtime/driver-observe.o" *> "$p\pins\tp127-places-03.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp127-suite\places-03\failures.tsv") { Get-Content -LiteralPath "$p\tp127-suite\places-03\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp127-places-03.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE127 exit=' + $e)
exit $e
