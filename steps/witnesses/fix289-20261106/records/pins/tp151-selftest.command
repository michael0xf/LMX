try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. The tool's existing self-test (lmxtool selftest DIR CHILD) with the child built by a candidate frontend
# (TP_CHILD, a path under P: an L3 program whose part tools/text.lm2 now indexes by size_t), run by the working boot150a tool;
# its log is the receipt. Parameters TP_CHILD, TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY; $childRel=$env:TP_CHILD
if (-not $try -or -not $childRel) { throw 'parameters TP_CHILD TP_TRY' }
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
$term="$p\pins\tp151-selftest-$try.terminal.txt"
$run="$p\tp151-selftest-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $run) -or (Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\tp151-selftest-$try")) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'eb11e493de980d1339cb9caa11236054adae37b63c78a07240d211b977bc3a2a') { throw 'working tool hash' }
$child=$p + '\' + ($childRel -replace '/','\')
if (-not (Test-Path -LiteralPath $child)) { throw ('missing child: ' + $child) }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' child ' + (ShaTp $child)) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- selftest "$P2/tp151-selftest-$try" ($P2 + '/' + $childRel) *> "$p\pins\tp151-selftest-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SelftestExit ' + $e) -Encoding utf8
Write-Output ('SELFTEST151 ' + $try + ' exit=' + $e)
exit $e
