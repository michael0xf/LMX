try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp118 suite (fable_pc, slice 256 focus checks before the bootstrap): `lmxtool suite` of the focus list pins/focus118.tsv --
# the two hidden-input twins of full-suite.tsv (forward_header, hidden_input), the walked-values smoke row, the slice-254 fixture
# dyn/free_name_chain.lm2, the slice-255 witness dyn/free_value_types.lm2 and the slice's witness dyn/free_value_consumers.lm2 --
# on the candidate's isolated frontend (TP_FE: fe118, ...) and isolated runtime objects (TP_RT: rt118, ...), run by boot117a's G2
# working tool from the stage cold-tp118 (its src/ gives the programs' predef sources and the headers rt118 and fe118
# regenerated).  The list is copied into the stage's tests/ so that its rows resolve beside the smoke list's (a list's rows are
# relative to the list's directory); the copy is not an input of the stage and is not landed.  Every row runs natively (n) and
# forced-walked (f).  Fresh CWD.  Parameters: TP_FE, TP_RT, TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$feLabel=$env:TP_FE; $rtLabel=$env:TP_RT; $try=$env:TP_TRY
if (-not $feLabel -or -not $rtLabel -or -not $try) { throw 'parameters TP_FE TP_RT TP_TRY' }
$tool="$p\cold-boot117a\quick117a\lmxtool.exe"
$fe="$p\cold-tp118\$feLabel\l2trans.exe"
$prod="$p\cold-tp118\$rtLabel\driver.o"
$obs="$p\cold-tp118\$rtLabel\driver-observe.o"
$term="$p\pins\tp118-suite-$try.terminal.txt"
$run="$p\tp118-suite-$try-run-01"
$out="$P2/tp118-suite/focus118-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp118-suite\focus118-$try") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4e1d96d4c939ceaa2721abd1413efaa93feb4cc5bb7e318eeaff87bb3af5aa68') { throw 'working tool hash' }
foreach ($f in @($fe, $prod, $obs, "$p\pins\focus118.tsv", "$p\cold-tp118\tests\dyn\free_value_consumers.lm2")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\focus118.tsv" -Destination "$p\cold-tp118\tests\focus118.tsv"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp $prod) + ' obs ' + (ShaTp $obs) + ' list ' + (ShaTp "$p\pins\focus118.tsv") + ' fixture ' + (ShaTp "$p\cold-tp118\tests\dyn\free_value_consumers.lm2") + ' chain65 ' + (ShaTp "$p\cold-tp118\tests\dyn\free_name_chain.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp118/tests/focus118.tsv" $R "$P2/cold-tp118" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp118/$feLabel/l2trans.exe" "$P2/cold-tp118/$rtLabel/driver.o" $out "$P2/cold-tp118/$rtLabel/driver-observe.o" *> "$p\pins\tp118-suite-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp118-suite\focus118-$try\failures.tsv") { Get-Content -LiteralPath "$p\tp118-suite\focus118-$try\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp118-suite-$try.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE118 ' + $try + ' exit=' + $e)
exit $e
