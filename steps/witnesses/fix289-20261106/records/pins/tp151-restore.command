try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. After a mutant: the named stage file restored by a copy from the clean variant variants/tp151, then the
# whole stage checked by `lmxtool verify` against the source manifest TP_SOURCE (a path under P) with the working boot150a tool.
# Parameters TP_TRY (the mutant's label), TP_FILE (a stage-relative path that variants/tp151 holds), TP_SOURCE.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY; $rel=$env:TP_FILE; $source=$env:TP_SOURCE
if (-not $try -or -not $rel -or -not $source) { throw 'parameters TP_TRY TP_FILE TP_SOURCE' }
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
$term="$p\pins\tp151-restore-$try.terminal.txt"
$cwd="$p\tp151-restore-$try-run-01"
$stageFile=$p + '\cold-tp140\' + ($rel -replace '/','\')
$clean=$p + '\variants\tp151\' + ($rel -replace '/','\')
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd)) { throw 'exists' }
if ((Test-Path -LiteralPath $clean,$stageFile,($P2 + '/' + $source)) -contains $false) { throw 'an input is missing' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'eb11e493de980d1339cb9caa11236054adae37b63c78a07240d211b977bc3a2a') { throw 'tool hash' }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' ' + $rel + ' before ' + (ShaTp $stageFile) + ' clean ' + (ShaTp $clean)) -Encoding utf8
Copy-Item -LiteralPath $clean -Destination $stageFile -Force
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
& $tool 0 entry 0 -- verify ($P2 + '/' + $source) "$P2/cold-tp140" *> "$p\pins\tp151-restore-$try-01.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after ' + (ShaTp $stageFile) + " verify exit=$e") -Encoding utf8
if ($e -ne 0) { throw "verify exit $e" }
Write-Output ('RESTORED151 ' + $try + ' verify exit=' + $e)
