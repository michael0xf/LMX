try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 278. Runs a named row list of fixtures with the verified boot139a tuple on the stage cold-tp140: the existing
# language suite, no compiler change. Parameters: TP_TRY (attempt label), TP_LIST (a file under pins). TP_FE and TP_RT are
# optional overrides of the frontend executable and the runtime directory (paths relative to P), for a candidate tuple.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$P2/cold-boot139a/quick139a"
$try=$env:TP_TRY
$listName=$env:TP_LIST
if (-not $try -or -not $listName) { throw 'TP_TRY TP_LIST' }
$tool=$env:TP_TOOL
if (-not $tool) { $tool="$p\cold-boot139a\quick139a\lmxtool.exe" } else { $tool=$p + '\' + ($tool -replace '/','\') }
$fe="$Q/g2/frontend/l2trans.exe"
if ($env:TP_FE) { $fe="$P2/" + $env:TP_FE }
$rt="$Q/g2/runtime"
if ($env:TP_RT) { $rt="$P2/" + $env:TP_RT }
$term="$p\pins\tp140-probe-$try.terminal.txt"
$run="$p\tp140-probe-$try-run"
$out="$P2/tp140-probe/$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $run) -or (Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\tp140-probe\$try")) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
foreach ($f in @($tool, $fe, "$rt/driver.o", "$rt/driver-observe.o", "$p\pins\$listName")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
Copy-Item -LiteralPath "$p\pins\$listName" -Destination "$p\cold-tp140\tests\$listName"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp "$rt/driver.o") + ' obs ' + (ShaTp "$rt/driver-observe.o") + ' list ' + (ShaTp "$p\pins\$listName")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp140/tests/$listName" $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" $fe "$rt/driver.o" $out "$rt/driver-observe.o" *> "$p\pins\tp140-probe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
Get-Content -LiteralPath "$p\pins\tp140-probe-$try.log" | Select-String -Pattern '^(PASS|FAIL|SUITE)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('PROBE140 exit=' + $e)
exit 0
