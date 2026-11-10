try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 346 (M6 4c). rt75: build-runtime of source60 (the written application of the int receiver kept by the builder;
# the int contract in lmx_graph_run) by tool48 and the boot346 G2 frontend (expected: rt74 apart from
# lmx_graph_run, its header and the driver).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool48\lmxtool-tool.exe"
$fe="$S/boot346/g2/frontend/l2trans.exe"
$term="$p\pins\opus346-rt75.terminal.txt"
$cwd="$p\runs\opus346"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\rt75")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'E395CA70BE82C82663D1D3381BD4F059D1A1CB390563ADC57378C7AFC52D9953') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start build-runtime rt75 cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- build-runtime $R $S $B $fe rt75 *> "$p\pins\opus346-rt75.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('RT75 exit=' + $e)
exit $e
