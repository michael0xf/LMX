try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 346 (M6 4c). suite347: the full suite list (source61) by the boot347 G2 frontend and its G2 runtime,
# tool48: every row after the int receiver kept by the graph builder.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool48\lmxtool-tool.exe"
$fe="$S/boot347/g2/frontend/l2trans.exe"
$term="$p\pins\opus346-suite347.terminal.txt"
$cwd="$p\runs\opus346"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\suite347")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'E395CA70BE82C82663D1D3381BD4F059D1A1CB390563ADC57378C7AFC52D9953') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start suite full suite347') -Encoding utf8
& $tool 0 entry 0 -- suite "$S/tests/full-suite.tsv" $R $S $B $fe "$S/boot347/g2/runtime/driver.o" "$S/suite347" "$S/boot347/g2/runtime/driver-observe.o" *> "$p\pins\opus346-suite347.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('SUITE347 exit=' + $e)
exit $e
