try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 305. After a mutant: the changed files of the stage cold-tp140 come back from the variant tp168 and the
# whole stage is verified against the a01 source manifest (pins/mut305-restore.tsv) by `lmxtool steps` with the verified boot164a tool.
# Parameter TP_TRY (the mutant label).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot164a\quick164a\lmxtool.exe"
$term="$p\pins\mut305-restore-$try.terminal.txt"
$run="$p\mut305-restore-$try-run"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8b106da588fad35dc7b0139d963867f7087fae657b601e38920a0e8d1543f07e') { throw 'tool hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' walk_values.lm2 before ' + (ShaTp "$p\cold-tp140\src\l2src\lmx_walk_values.lm2") + ' emit.lm2 before ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_emit.lm2")) -Encoding utf8
& $tool 0 entry 0 -- steps "$P2/pins/mut305-restore.tsv" *> "$p\pins\mut305-restore-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('end ' + [DateTime]::UtcNow.ToString('o') + ' StepsExit ' + $e + ' walk_values.lm2 after ' + (ShaTp "$p\cold-tp140\src\l2src\lmx_walk_values.lm2") + ' emit.lm2 after ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_emit.lm2")) -Encoding utf8
Write-Output ('RESTORE305 ' + $try + ' exit=' + $e)
exit 0
