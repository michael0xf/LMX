try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 348 (M6 4c lowering) measurements. low348d: the probe rows of opus348-low4.tsv by fehost18 (source66, try 2)
# with rt76, tool49.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool49\lmxtool-tool.exe"
$fe="$S/fehost18/l2trans.exe"
$term="$p\pins\opus348-low348d.terminal.txt"
$cwd="$p\runs\opus348"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\low348d")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '77FAE3E582FED968509DB2FD68F0FD788F8783D76C639E48928680E8E3FF7D79') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start suite low348d cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- suite "$P2/pins/opus348-low4.tsv" $R $S $B $fe "$S/rt76/driver.o" "$S/low348d" "$S/rt76/driver-observe.o" *> "$p\pins\opus348-low348d.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('LOW348D exit=' + $e)
exit $e
