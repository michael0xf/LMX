try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 344 (M6). ccr80: graph-check of tests/graph/colon_call_refused (source52) by graph79 on rt71, expected
# exit 1, interpreter answer 5: the interpreter refuses `a: 5` (a colon Frame on a function writes its place, the int is
# not admitted); this run tells what the native and forced translations do (the forced one runs the graph when the
# program runs).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool45\lmxtool-tool.exe"
$fe="$S/fehost12/l2trans.exe"
$term="$p\pins\opus344-ccr80.terminal.txt"
$cwd="$p\runs\opus344"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\check80-colon_call_refused")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '9378BE3E54549CD6FFACB40183945528D0F9D99985CA533062680DB2F1803ED8') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start graph-check ccr80 cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- graph-check $R $S $B $fe "$S/rt71" "$S/graph79/graph_trans-prod.exe" "$S/check80-colon_call_refused" "$S/tests/graph/colon_call_refused.lm2" "$S/tests/graph/call_layout.expected" 1 1 5 *> "$p\pins\opus344-ccr80.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('CCR80 exit=' + $e)
exit $e
