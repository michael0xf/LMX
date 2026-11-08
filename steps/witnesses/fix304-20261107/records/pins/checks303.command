try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 303 (:=). Runs one list of tool commands (pins/<TP_LIST>, tab lists) by `lmxtool checks` with the verified
# boot164a tool, from a fresh run directory; the log is the receipt. Parameters TP_TRY (receipt label), TP_LIST (file under
# pins), optional TP_OUT (a private output directory under P to make before the run, for `docs check`).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
$listName=$env:TP_LIST
if (-not $try -or -not $listName) { throw 'TP_TRY TP_LIST' }
$tool="$p\cold-boot164a\quick164a\lmxtool.exe"
$list="$p\pins\$listName"
$term="$p\pins\$try.terminal.txt"
$run="$p\$try-run"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (-not (Test-Path -LiteralPath $list)) { throw 'list missing' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8b106da588fad35dc7b0139d963867f7087fae657b601e38920a0e8d1543f07e') { throw 'tool hash' }
if ($env:TP_OUT) { if (Test-Path -LiteralPath "$p\$env:TP_OUT") { throw 'output exists' }; New-Item -ItemType Directory -Path "$p\$env:TP_OUT" | Out-Null }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' list ' + (ShaTp $list)) -Encoding utf8
& $tool 0 entry 0 -- checks "$P2/pins/$listName" *> "$p\pins\$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('end ' + [DateTime]::UtcNow.ToString('o') + ' ChecksExit ' + $e) -Encoding utf8
Write-Output ('CHECKS303 ' + $try + ' exit=' + $e)
exit 0
