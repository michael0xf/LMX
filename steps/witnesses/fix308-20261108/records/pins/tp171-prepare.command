try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 308 (CALL-WHOLE-ARGUMENTS-STRUCTURE: one Structure actual as the whole of the arguments, its fields bound to the formals of their names). Runs the
# prepare list of a candidate (pins/tp171-prepare-$TP_TRY.tsv: manifest of the changed files, their copy into variants/tp170 and into
# the stage cold-tp140, the stage's source manifest, its check) by `lmxtool steps` with the working boot164a tool. Parameter TP_TRY
# (the candidate label, aNN).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot164a\quick164a\lmxtool.exe"
$list="$p\pins\tp171-prepare-$try.tsv"
$term="$p\pins\tp171-prepare-$try.terminal.txt"
$run="$p\tp171-prepare-$try-run"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Test-Path -LiteralPath $list)) { throw 'list missing' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8b106da588fad35dc7b0139d963867f7087fae657b601e38920a0e8d1543f07e') { throw 'tool hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' list ' + (ShaTp $list)) -Encoding utf8
& $tool 0 entry 0 -- steps "$P2/pins/tp171-prepare-$try.tsv" *> "$p\pins\tp171-prepare-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('end ' + [DateTime]::UtcNow.ToString('o') + ' StepsExit ' + $e) -Encoding utf8
Write-Output ('PREPARE171 ' + $try + ' exit=' + $e)
exit 0
