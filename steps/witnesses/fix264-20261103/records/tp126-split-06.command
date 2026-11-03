try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 263. tp126-split-06 uses the tp125 checked source and coherent boot125a G2 frontend.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$p\cold-boot125a\quick125a"
$tool="$p\cold-tp126\tool126c\lmxtool-tool.exe"
$term="$p\pins\tp126-split-06.terminal.txt"
$run="$p\tp126-split-06-run-01"
$out="$P2/tp126-split-baseline-01/split-06"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp126-split-baseline-01\split-06") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Select-String -LiteralPath "$p\pins\boot125a-detached.terminal.txt" -Pattern '^done ' -Quiet)) { throw 'boot125a not done' }
if (-not (Select-String -LiteralPath "$p\pins\boot125a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot125a did not pass' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, "$p\cold-tp126\fe126e\l2trans.exe", "$p\cold-tp126\rt126d\driver.o", "$p\cold-tp126\rt126d\driver-observe.o", "$p\tp126-split-baseline-01\focus.tsv")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp "$p\cold-tp126\fe126e\l2trans.exe") + ' prod ' + (ShaTp "$p\cold-tp126\rt126d\driver.o") + ' obs ' + (ShaTp "$p\cold-tp126\rt126d\driver-observe.o") + ' list ' + (ShaTp "$p\tp126-split-baseline-01\focus.tsv") + ' fixture ' + (ShaTp "$p\tp126-split-baseline-01\split_selected_code.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/tp126-split-baseline-01/focus.tsv" $R "$P2/cold-tp126" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp126/fe126e/l2trans.exe" "$P2/cold-tp126/rt126d/driver.o" $out "$P2/cold-tp126/rt126d/driver-observe.o" *> "$p\pins\tp126-split-06.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp126-split-baseline-01\split-06\failures.tsv") { Get-Content -LiteralPath "$p\tp126-split-baseline-01\split-06\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp126-split-06.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('SUITE125G2 exit=' + $e)
exit $e
