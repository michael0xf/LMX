try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, the review of slice 304 (an unfilled formal of the args part holds no value). Stages the whole quick bootstrap boot167<TP_TRY> from the
# checked source of the stage cold-tp140 (pins/boot167<TP_TRY>-prepare.tsv: verify, stage-copy, manifest, verify, same) by `lmxtool steps` with
# the verified boot164a tool. Parameter TP_TRY (the bootstrap letter, a).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot164a\quick164a\lmxtool.exe"
$list="$p\pins\boot167$try-prepare.tsv"
$term="$p\pins\boot167$try-prepare.terminal.txt"
$run="$p\boot167$try-prepare-run"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (Test-Path -LiteralPath "$p\cold-boot167$try") { throw 'stage exists' }
if (-not (Test-Path -LiteralPath $list)) { throw 'list missing' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8b106da588fad35dc7b0139d963867f7087fae657b601e38920a0e8d1543f07e') { throw 'tool hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' list ' + (ShaTp $list)) -Encoding utf8
& $tool 0 entry 0 -- steps "$P2/pins/boot167$try-prepare.tsv" *> "$p\pins\boot167$try-prepare.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('end ' + [DateTime]::UtcNow.ToString('o') + ' StepsExit ' + $e) -Encoding utf8
Write-Output ('BOOTPREP167 ' + $try + ' exit=' + $e)
exit 0
