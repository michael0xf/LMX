try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 344 (M6). probes-old2: the M6 probe rows (runs/opus344/m6/probes.tsv) by the boot342 G2 frontend (before M6) with rt68, to compare:
# the call forms f(args), f(): args, the block f(): that call, the colon Frames that must not.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\boot342\lmxtool.exe"
$fe="$S/boot342/g2/frontend/l2trans.exe"
$term="$p\pins\opus344-probes-old2.terminal.txt"
$cwd="$p\runs\opus344"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\m6probes-old2")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '22D4F0EA6818B303994EFB9783F83D7660CC6F392772FA5C2CCD6D8D517F3692') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start suite m6 probes-old2') -Encoding utf8
& $tool 0 entry 0 -- suite "$P2/runs/opus344/m6/probes.tsv" $R $S $B $fe "$S/rt68/driver.o" "$S/m6probes-old2" "$S/rt68/driver-observe.o" *> "$p\pins\opus344-probes-old2.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('PROBESOLD2 exit=' + $e)
exit $e
