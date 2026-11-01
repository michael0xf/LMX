try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# RED of the raw-route holder check (Codex CODEX-OPUS-THROWDEREF93-20261101-ANSWER01):
# no-candidate94 (no-candidate79 extended by one null holder read by a
# condition -- the raw native route -- and one stored into a cell -- the checked
# route --, each under its own catch: interpreter) on FE93 + RT92 with stage92,
# BEFORE the guard. Expected: forced gives 7; native fails in read_null_raw
# (the raw route dereferences the null holder). Tool: generator93.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator93\tool93-parts\lmxtool-tool.exe"
$term="$p\pins\red94.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate93\fe93\l2trans.exe")) { throw 'nofe93' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$name='no-candidate94-fe93-rt92-suite'
$out="$p\$name-01"
$cwd="$p\$name-run-01"
if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
$argv=@('suite', "$P2/pins/no-candidate94.tsv", $repo, "$P2/cold-candidate92", "$P2/cold-candidate48/full48/g2/frontend", "$P2/cold-candidate93/fe93/l2trans.exe", "$P2/cold-candidate92/rt92/driver.o", "$P2/$name-01", "$P2/cold-candidate92/rt92/driver-observe.o")
if ($argv.Count -ne 9) { throw "argv $($argv.Count)" }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name argv: 0 entry 0 -- " + ($argv -join ' ')) -Encoding utf8
& $tool 0 entry 0 -- @argv *> "$p\pins\$name-01.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
Write-Output 'RED94 done'
