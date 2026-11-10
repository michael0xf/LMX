try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 345 (M6 4a). check81b: the graph checks opus345-graph-check81b.tsv (stage source56, the refreshed expected files) on tool47, rt73, graph81
# and the boot344 G2 bundle: interp, native, forced.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-graph309-codex01\tool47\lmxtool-tool.exe"
$term="$p\pins\opus345-check81b.terminal.txt"
$cwd="$p\runs\opus345"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\pins\opus345-check81b.log")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '4C9F7B184EA7B7F24A55D1727F7D2F4ECEFEA40FE11C6B96F05BB9DF273328DD') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start checks check81b cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- checks "$P2/pins/opus345-graph-check81b.tsv" *> "$p\pins\opus345-check81b.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('CHECK81B exit=' + $e)
exit $e
