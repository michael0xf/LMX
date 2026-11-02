try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp118 suite-g2 (fable_pc, slice 256 focus checks after boot118a): `lmxtool suite` of the focus list pins/focus118.tsv -- the
# two hidden-input twins of full-suite.tsv (forward_header, hidden_input), the walked-values smoke row, the fixtures of slices
# 254 and 255 (dyn/free_name_chain.lm2, dyn/free_value_types.lm2) and the slice's witness dyn/free_value_consumers.lm2 -- on
# boot118a's G2 frontend and G2 runtime objects, run by the promoted working tool (G2's lmxtool.exe) from the bootstrap stage
# cold-boot118a (its src/ gives the programs' predef sources).  The list is copied into the stage's tests/ so that its rows
# resolve beside the smoke list's (a list's rows are relative to the list's directory); the copy is not an input of the stage
# (not in source-tp118) and is not landed.  Every row runs natively (n) and forced-walked (f).  Fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$p\cold-boot118a\quick118a"
$tool="$Q\lmxtool.exe"
$term="$p\pins\tp118-suite-g2.terminal.txt"
$run="$p\tp118-suite-g2-run-01"
$out="$P2/tp118-suite/focus118-g2"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp118-suite\focus118-g2") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Select-String -LiteralPath "$p\pins\boot118a-detached.terminal.txt" -Pattern '^done ' -Quiet)) { throw 'boot118a not done' }
if (-not (Select-String -LiteralPath "$p\pins\boot118a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot118a did not pass' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, "$Q\g2\frontend\l2trans.exe", "$Q\g2\runtime\driver.o", "$Q\g2\runtime\driver-observe.o", "$p\pins\focus118.tsv")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus118.tsv" -Destination "$p\cold-boot118a\tests\focus118.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp "$Q\g2\frontend\l2trans.exe") + ' prod ' + (ShaTp "$Q\g2\runtime\driver.o") + ' obs ' + (ShaTp "$Q\g2\runtime\driver-observe.o") + ' list ' + (ShaTp "$p\pins\focus118.tsv") + ' fixture ' + (ShaTp "$p\cold-boot118a\tests\dyn\free_name_chain.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-boot118a/tests/focus118.tsv" $R "$P2/cold-boot118a" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot118a/quick118a/g2/frontend/l2trans.exe" "$P2/cold-boot118a/quick118a/g2/runtime/driver.o" $out "$P2/cold-boot118a/quick118a/g2/runtime/driver-observe.o" *> "$p\pins\tp118-suite-g2.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp118-suite\focus118-g2\failures.tsv") { Get-Content -LiteralPath "$p\tp118-suite\focus118-g2\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp118-suite-g2.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE118G2 exit=' + $e)
exit $e
