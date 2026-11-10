try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 346 (M6 4c). check83: the graph checks opus346-graph-check83.tsv (stage source60) on tool48, rt75, graph83
# and the boot346 G2 bundle: interp, native, forced.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-graph309-codex01\tool48\lmxtool-tool.exe"
$term="$p\pins\opus346-check83.terminal.txt"
$cwd="$p\runs\opus346"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\pins\opus346-check83.log")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'E395CA70BE82C82663D1D3381BD4F059D1A1CB390563ADC57378C7AFC52D9953') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start checks check83 cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- checks "$P2/pins/opus346-graph-check83.tsv" *> "$p\pins\opus346-check83.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('CHECK83 exit=' + $e)
exit $e
