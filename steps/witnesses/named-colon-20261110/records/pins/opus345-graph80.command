try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 345 (M6 4a). graph80: build-graph of source53 by tool46 and the boot344 G2 frontend with rt72: the graph
# tool whose interpreter and emitter take the named actual a: value and refuse :=.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool46\lmxtool-tool.exe"
$fe="$S/boot344/g2/frontend/l2trans.exe"
$term="$p\pins\opus345-graph80.terminal.txt"
$cwd="$p\runs\opus345"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\graph80")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'C357564A84E08139E230D78EC3579A5AE8C956C20FDA0670ED470D0C33BF2478') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start build-graph graph80 cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- build-graph $R $S $B $fe "$S/rt72" graph80 *> "$p\pins\opus345-graph80.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('GRAPH80 exit=' + $e)
exit $e
