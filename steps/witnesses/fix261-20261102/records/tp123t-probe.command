try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp123t probe (fable_pc, slice 261): `lmxtool suite` of the probe list pins/focus123-probe.tsv -- the seven small fixtures of slice
# 260 copied into the scratch stage cold-tp123/tests/dyn (not inputs, not landed) -- on the candidate's isolated frontend (TP_FE)
# and runtime objects (TP_RT) by tool123 (573B37F0).  The two graph-pointer probes (probe_graph_address, probe_graph_deref) are
# the before/after picture of P1-PTR-COVERAGE: they failed on the landed code (tp123t-probe-03, walk error: UNSUPPORTED).
# Parameters: TP_FE, TP_RT, TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$feLabel=$env:TP_FE; $rtLabel=$env:TP_RT; $try=$env:TP_TRY
if (-not $feLabel -or -not $rtLabel -or -not $try) { throw 'parameters TP_FE TP_RT TP_TRY' }
$tool="$p\cold-tp123\tool123\lmxtool-tool.exe"
$fe="$p\cold-tp123\$feLabel\l2trans.exe"
$prod="$p\cold-tp123\$rtLabel\driver.o"
$obs="$p\cold-tp123\$rtLabel\driver-observe.o"
$term="$p\pins\tp123t-probe-$try.terminal.txt"
$run="$p\tp123t-probe-$try-run-01"
$out="$P2/tp123t-probe/focus123-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp123t-probe\focus123-$try") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '573b37f0211119d874c8bea82eca3509ea294faa1dfd0739d7611fdc6066716f') { throw 'working tool hash' }
foreach ($f in @($fe, $prod, $obs, "$p\pins\focus123-probe.tsv", "$p\cold-tp123\tests\dyn\probe_model_own.lm2")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus123-probe.tsv" -Destination "$p\cold-tp123\tests\focus123-probe.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp $prod) + ' obs ' + (ShaTp $obs) + ' list ' + (ShaTp "$p\pins\focus123-probe.tsv") + ' fixture ' + (ShaTp "$p\cold-tp123\tests\dyn\free_machine_ops.lm2") + ' bits ' + (ShaTp "$p\cold-tp123\tests\bits\bit_values.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp123/tests/focus123-probe.tsv" $R "$P2/cold-tp123" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp123/$feLabel/l2trans.exe" "$P2/cold-tp123/$rtLabel/driver.o" $out "$P2/cold-tp123/$rtLabel/driver-observe.o" *> "$p\pins\tp123t-probe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp123t-probe\focus123-$try\failures.tsv") { Get-Content -LiteralPath "$p\tp123t-probe\focus123-$try\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp123t-probe-$try.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('PROBE123 ' + $try + ' exit=' + $e)
exit $e
