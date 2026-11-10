try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 344 (M6). census344 = build-frontend-host of the stage with a census-only diagnostic in
# lm_compiler_head_is_call (prints M6CENSUS <kind> <head> <line> for a call decided without the compact
# call mark). Behaviour is unchanged; the stage is restored afterwards.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\boot342\lmxtool.exe"
$fe="$S/boot342/g2/frontend/l2trans.exe"
$term="$p\pins\opus344-census-fe.terminal.txt"
$cwd="$p\runs\opus344"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\census344")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '22D4F0EA6818B303994EFB9783F83D7660CC6F392772FA5C2CCD6D8D517F3692') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $fe).Hash -ne '979C2A1ED6F882113F6F4B5E1AEDA1FAC2DF133ABD20FD48F9CC0D12550615EA') { throw 'fe hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath $cwd)) { New-Item -ItemType Directory -Path $cwd | Out-Null }
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start build-frontend-host census344') -Encoding utf8
& $tool 0 entry 0 -- build-frontend-host $R $S $B $fe "$S/rt68" census344 *> "$p\pins\opus344-census-fe.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('CENSUSFE exit=' + $e)
exit $e
