try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 288. After a mutant: the named stage file restored by a copy from the clean variant variants/tp150, then the
# whole stage checked against pins/source-tp150.sha256 by the verified boot149b tool. Parameters TP_TRY (the mutant's label)
# and TP_FILE (a path of pins/tp150-changed.list).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY; $rel=$env:TP_FILE
if (-not $try -or -not $rel) { throw 'parameters TP_TRY TP_FILE' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp150-changed.list" | Where-Object { $_ -ne '' })
if ($ok -notcontains $rel) { throw ('not a changed file: ' + $rel) }
$tool="$p\cold-boot149b\quick149b\lmxtool.exe"
$term="$p\pins\tp150-restore-$try.terminal.txt"
$cwd="$p\tp150-restore-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd)) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '3ffac1a49ddc133799bf13bd63f766e3ffb6c2de383825b815be7c3214161792') { throw 'tool hash' }
$stageFile=$p + '\cold-tp140\' + ($rel -replace '/','\')
$clean=$p + '\variants\tp150\' + ($rel -replace '/','\')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' ' + $rel + ' before ' + (ShaTp $stageFile) + ' clean ' + (ShaTp $clean)) -Encoding utf8
Copy-Item -LiteralPath $clean -Destination $stageFile -Force
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
& $tool 0 entry 0 -- verify "$P2/pins/source-tp150.sha256" "$P2/cold-tp140" *> "$p\pins\tp150-restore-$try-01.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after ' + (ShaTp $stageFile) + " verify exit=$e") -Encoding utf8
if ($e -ne 0) { throw "verify exit $e" }
Write-Output ('RESTORED ' + $try + ' verify exit=' + $e)
