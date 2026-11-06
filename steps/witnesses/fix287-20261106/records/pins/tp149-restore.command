try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 287. After a mutant: the stage file cold-tp140/src/l2src/l2_frontend_emit.lm2 restored by a copy from the clean
# variant variants/tp149, then the whole stage checked against pins/source-tp149.sha256 by the verified boot148b tool.
# Parameter TP_TRY (the mutant's label).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot148b\quick148b\lmxtool.exe"
$term="$p\pins\tp149-restore-$try.terminal.txt"
$cwd="$p\tp149-restore-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd)) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '17afcadc9661d54a1fa6d4e3d52916c66fe20957ffc5083482844dad7be53a69') { throw 'tool hash' }
$stageFile="$p\cold-tp140\src\l2src\l2_frontend_emit.lm2"
$clean="$p\variants\tp149\src\l2src\l2_frontend_emit.lm2"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' before ' + (ShaTp $stageFile) + ' clean ' + (ShaTp $clean)) -Encoding utf8
Copy-Item -LiteralPath $clean -Destination $stageFile -Force
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
& $tool 0 entry 0 -- verify "$P2/pins/source-tp149.sha256" "$P2/cold-tp140" *> "$p\pins\tp149-restore-$try-01.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after ' + (ShaTp $stageFile) + " verify exit=$e") -Encoding utf8
if ($e -ne 0) { throw "verify exit $e" }
Write-Output ('RESTORED ' + $try + ' verify exit=' + $e)
