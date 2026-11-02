try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp116 suite-fix03 (fable_pc): the focus list again after fix09 (the fixture's name int throughout) -- the stage cold-tp116's
# tests (the list copied there; its rows resolve beside the stage's fixtures) with boot116b's G2 frontend, runtime objects and
# working tool; the stage argument cold-tp116 (the same sources). suite-fix01 (same intent) copied the list into the wrong
# tests directory and read no list -- a clone slip, kept as it is.  The tp116-suite text follows.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$p\cold-boot116b\quick116b"
$tool="$Q\lmxtool.exe"
$term="$p\pins\tp116-suite-fix03.terminal.txt"
$run="$p\tp116-suite-fix03-run-01"
$out="$P2/tp116-suite/focus116d"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp116-suite\focus116d") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Select-String -LiteralPath "$p\pins\boot116b-detached.terminal.txt" -Pattern '^done ' -Quiet)) { throw 'boot116 not done' }
if (-not (Select-String -LiteralPath "$p\pins\boot116b-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot116 did not pass' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, "$Q\g2\frontend\l2trans.exe", "$Q\g2\runtime\driver.o", "$Q\g2\runtime\driver-observe.o", "$p\pins\focus116.tsv")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus116.tsv" -Destination "$p\cold-tp116\tests\focus116.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp "$Q\g2\frontend\l2trans.exe") + ' prod ' + (ShaTp "$Q\g2\runtime\driver.o") + ' obs ' + (ShaTp "$Q\g2\runtime\driver-observe.o") + ' list ' + (ShaTp "$p\pins\focus116.tsv") + ' fixture ' + (ShaTp "$p\cold-tp116\tests\dyn\free_name_chain.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp116/tests/focus116.tsv" $R "$P2/cold-tp116" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot116b/quick116b/g2/frontend/l2trans.exe" "$P2/cold-boot116b/quick116b/g2/runtime/driver.o" $out "$P2/cold-boot116b/quick116b/g2/runtime/driver-observe.o" *> "$p\pins\tp116-suite-fix03.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp116-suite\focus116d\failures.tsv") { Get-Content -LiteralPath "$p\tp116-suite\focus116d\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp116-suite-fix03.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE116FIX03 exit=' + $e)
exit $e
