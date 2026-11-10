try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 349 (M6 4b). boot350: bootstrap quick of source70 by tool49 and fehost20 (`place: value` writes every
# known place := wrote, a callable formal and a binding holding a method included): runtime, frontend, the
# smoke list, G1, G2 and their sha256 checks.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool49\lmxtool-tool.exe"
$fe="$S/fehost20/l2trans.exe"
$term="$p\pins\opus349-boot350.terminal.txt"
$cwd="$p\runs\opus349"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\boot350")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '77FAE3E582FED968509DB2FD68F0FD788F8783D76C639E48928680E8E3FF7D79') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start bootstrap quick boot350') -Encoding utf8
& $tool 0 entry 0 -- bootstrap quick $R $S $B $fe boot350 "$S/tests/smoke.tsv" *> "$p\pins\opus349-boot350.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('BOOT350 exit=' + $e)
exit $e
