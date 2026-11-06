try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 290. The tool's self-test (lmxtool selftest DIR CHILD) run by a CANDIDATE tool (TP_TOOL, a path under P: its
# self-test has the list runner's checks, test_check_lists), with a child built by the candidate frontend (TP_CHILD, a path
# under P); its log is the receipt. Parameters TP_TOOL, TP_CHILD, TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY; $toolRel=$env:TP_TOOL; $childRel=$env:TP_CHILD
if (-not $try -or -not $toolRel -or -not $childRel) { throw 'parameters TP_TOOL TP_CHILD TP_TRY' }
$tool=$p + '\' + ($toolRel -replace '/','\')
$term="$p\pins\tp152-selftest-$try.terminal.txt"
$run="$p\tp152-selftest-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $run) -or (Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\tp152-selftest-$try")) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
$child=$p + '\' + ($childRel -replace '/','\')
if (-not (Test-Path -LiteralPath $tool) -or -not (Test-Path -LiteralPath $child)) { throw 'missing tool or child' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' child ' + (ShaTp $child)) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- selftest "$P2/tp152-selftest-$try" ($P2 + '/' + $childRel) *> "$p\pins\tp152-selftest-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SelftestExit ' + $e) -Encoding utf8
Write-Output ('SELFTEST152 ' + $try + ' exit=' + $e)
exit $e
