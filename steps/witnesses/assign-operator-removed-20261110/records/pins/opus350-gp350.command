try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 350 (M6 4b, part 2) measurement. gp350: the graph checks opus350-gp.tsv (the := removal) on tool50, rt77, graph85
# and fehost21 (source71): interp, native, forced.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-graph309-codex01\tool50\lmxtool-tool.exe"
$term="$p\pins\opus350-gp350.terminal.txt"
$cwd="$p\runs\opus350"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\pins\opus350-gp350.log")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '6FCB73B4E8F8F7493D377A428FDC59C6B6189D4A93134B3FA07E819FD3E3F04F') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start checks gp350 cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- checks "$P2/pins/opus350-gp.tsv" *> "$p\pins\opus350-gp350.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('GP350 exit=' + $e)
exit $e
