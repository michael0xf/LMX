try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 350 (M6 4b, part 2). boot351: bootstrap quick of source72 by tool50 and fehost21 (the operator := removed:
# P0 refuses it, no branch of it in the frontend, the graph builder or the executors): runtime, frontend, the
# smoke list, G1, G2 and their sha256 checks.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool50\lmxtool-tool.exe"
$fe="$S/fehost21/l2trans.exe"
$term="$p\pins\opus350-boot351.terminal.txt"
$cwd="$p\runs\opus350"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\boot351")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '6FCB73B4E8F8F7493D377A428FDC59C6B6189D4A93134B3FA07E819FD3E3F04F') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start bootstrap quick boot351') -Encoding utf8
& $tool 0 entry 0 -- bootstrap quick $R $S $B $fe boot351 "$S/tests/smoke.tsv" *> "$p\pins\opus350-boot351.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('BOOT351 exit=' + $e)
exit $e
