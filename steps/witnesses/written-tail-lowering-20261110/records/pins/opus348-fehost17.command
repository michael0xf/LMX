try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 348 (M6 4c lowering, route (a)). fehost17 = build-frontend-host of the stage source65 (try 1 of the ready
# written Structure tail) by tool49 and the boot348 G2 frontend, with rt76.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool49\lmxtool-tool.exe"
$fe="$S/boot348/g2/frontend/l2trans.exe"
$term="$p\pins\opus348-fehost17.terminal.txt"
$cwd="$p\runs\opus348"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\fehost17")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '77FAE3E582FED968509DB2FD68F0FD788F8783D76C639E48928680E8E3FF7D79') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath $cwd)) { New-Item -ItemType Directory -Path $cwd | Out-Null }
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start build-frontend-host fehost17') -Encoding utf8
& $tool 0 entry 0 -- build-frontend-host $R $S $B $fe "$S/rt76" fehost17 *> "$p\pins\opus348-fehost17.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('FEHOST17 exit=' + $e)
exit $e
