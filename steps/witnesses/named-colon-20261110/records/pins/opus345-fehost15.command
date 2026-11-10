try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 345 (M6 4a). fehost15 = build-frontend-host of the stage source58 (the named actual a: value in the lowering
# binder, := refused, the stage of a written Structure tail; the graph emitter with the named actual), by tool47 and the
# boot344 G2 frontend, with rt73.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool47\lmxtool-tool.exe"
$fe="$S/boot344/g2/frontend/l2trans.exe"
$term="$p\pins\opus345-fehost15.terminal.txt"
$cwd="$p\runs\opus345"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\fehost15")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '4C9F7B184EA7B7F24A55D1727F7D2F4ECEFEA40FE11C6B96F05BB9DF273328DD') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath $cwd)) { New-Item -ItemType Directory -Path $cwd | Out-Null }
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start build-frontend-host fehost15') -Encoding utf8
& $tool 0 entry 0 -- build-frontend-host $R $S $B $fe "$S/rt73" fehost15 *> "$p\pins\opus345-fehost15.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('FEHOST15 exit=' + $e)
exit $e
