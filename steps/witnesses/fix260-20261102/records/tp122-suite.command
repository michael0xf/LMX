try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp122 suite (fable_pc, slice 260 focus checks before the bootstrap): `lmxtool suite` of the focus list pins/focus122.tsv --
# the two hidden-input twins of full-suite.tsv, the walked-values smoke row, the three bits rows, the implements rows of
# full-suite.tsv (os_implements, lib_owner), the fixtures of slices 254 to 259 (free_machine_ops extended) and the slice's
# witness dyn/free_model_admit.lm2 -- on the candidate's isolated frontend (TP_FE) and runtime objects (TP_RT), run by boot121a's
# promoted working tool from the stage cold-tp122.  The list is copied into the stage's tests/ (not an input, not landed).
# Every row runs natively (n) and forced-walked (f).  Fresh CWD.  Parameters: TP_FE, TP_RT, TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$feLabel=$env:TP_FE; $rtLabel=$env:TP_RT; $try=$env:TP_TRY
if (-not $feLabel -or -not $rtLabel -or -not $try) { throw 'parameters TP_FE TP_RT TP_TRY' }
$tool="$p\cold-boot121a\quick121a\lmxtool.exe"
$fe="$p\cold-tp122\$feLabel\l2trans.exe"
$prod="$p\cold-tp122\$rtLabel\driver.o"
$obs="$p\cold-tp122\$rtLabel\driver-observe.o"
$term="$p\pins\tp122-suite-$try.terminal.txt"
$run="$p\tp122-suite-$try-run-01"
$out="$P2/tp122-suite/focus122-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp122-suite\focus122-$try") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4dd5d70602596afcec73902eb83a8a986ffcd13b85f59f2e693ae44920138485') { throw 'working tool hash' }
foreach ($f in @($fe, $prod, $obs, "$p\pins\focus122.tsv", "$p\cold-tp122\tests\dyn\free_model_admit.lm2")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus122.tsv" -Destination "$p\cold-tp122\tests\focus122.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp $prod) + ' obs ' + (ShaTp $obs) + ' list ' + (ShaTp "$p\pins\focus122.tsv") + ' fixture ' + (ShaTp "$p\cold-tp122\tests\dyn\free_model_admit.lm2") + ' machine_ops ' + (ShaTp "$p\cold-tp122\tests\dyn\free_machine_ops.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp122/tests/focus122.tsv" $R "$P2/cold-tp122" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp122/$feLabel/l2trans.exe" "$P2/cold-tp122/$rtLabel/driver.o" $out "$P2/cold-tp122/$rtLabel/driver-observe.o" *> "$p\pins\tp122-suite-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp122-suite\focus122-$try\failures.tsv") { Get-Content -LiteralPath "$p\tp122-suite\focus122-$try\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp122-suite-$try.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE122 ' + $try + ' exit=' + $e)
exit $e
