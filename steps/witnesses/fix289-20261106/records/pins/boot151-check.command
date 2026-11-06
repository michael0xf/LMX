try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. Acceptance of a finished whole quick boot151<TP_TRY> by lmxtool commands only (Codex,
# CODEX-OPUS-288-REVIEW-NEXT-20261106-01: no PS comparison algorithm). Each line runs one command of the working boot150a tool
# and records its exit and output: the stage against its source manifest (verify); every producer record of both generations
# and the G1-built G2 record closed on its files (verify-record) and free of script hosts (deps); G1 against G2 (exe-same for
# the PE images, same for the rest, L1, C and the consumed inputs); the working tool and bundle against G2; the runtime against
# the boot150a G2 runtime (no kernel source changed); the candidate frontend TP_FE (a directory under P) against the G2
# frontend. Parameter TP_TRY, TP_FE. Output: pins/boot151<try>-check.terminal.txt; nothing is filtered.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY; $feDir=$env:TP_FE
if (-not $try -or -not $feDir) { throw 'parameters TP_TRY TP_FE' }
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
$S="$P2/cold-boot151$try"
$Q="$S/quick151$try"
$C="$P2/$feDir"
$O="$P2/cold-boot150a/quick150a/g2/runtime"
$term="$p\pins\boot151$try-check.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'EB11E493DE980D1339CB9CAA11236054ADAE37B63C78A07240D211B977BC3A2A') { throw 'tool hash' }
$cwd="$p\boot151$try-check-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
$script:fails=0
function Check([string[]]$words) {
  $o=& $tool 0 entry 0 -- @words
  $e=$LASTEXITCODE
  if ($e -ne 0) { $script:fails++ }
  Add-Content -LiteralPath $term -Value ('exit=' + $e + ' ' + ($words -join ' ')) -Encoding utf8
  Add-Content -LiteralPath $term -Value $o -Encoding utf8
}
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Check @('verify', "$P2/pins/source-boot151$try.sha256", $S)
Check @('verify-record', "$Q/g1/frontend/record.txt")
Check @('verify-record', "$Q/g1/runtime/record.txt")
Check @('verify-record', "$Q/g1/tool/record.txt")
Check @('verify-record', "$Q/g2-build-record.txt")
Check @('verify-record', "$Q/g2/frontend/record.txt")
Check @('verify-record', "$Q/g2/runtime/record.txt")
Check @('verify-record', "$Q/g2/tool/record.txt")
Check @('deps', "$Q/g1/frontend/record.txt")
Check @('deps', "$Q/g1/runtime/record.txt")
Check @('deps', "$Q/g1/tool/record.txt")
Check @('deps', "$Q/g2-build-record.txt")
Check @('deps', "$Q/g2/frontend/record.txt")
Check @('deps', "$Q/g2/runtime/record.txt")
Check @('deps', "$Q/g2/tool/record.txt")
Check @('exe-same', "$Q/g1/frontend/l2trans.exe", "$Q/g2/frontend/l2trans.exe")
Check @('exe-same', "$Q/g1/frontend/l1trans.exe", "$Q/g2/frontend/l1trans.exe")
Check @('same', "$Q/g1/frontend/l2_libc.o", "$Q/g2/frontend/l2_libc.o")
Check @('same', "$Q/g1/runtime/driver.o", "$Q/g2/runtime/driver.o")
Check @('same', "$Q/g1/runtime/driver-observe.o", "$Q/g2/runtime/driver-observe.o")
Check @('exe-same', "$Q/g1/tool/lmxtool-tool.exe", "$Q/g2/tool/lmxtool-tool.exe")
Check @('same', "$Q/g1/tool/lmxtool.lm1", "$Q/g2/tool/lmxtool.lm1")
Check @('same', "$Q/g1/tool/lmxtool.c", "$Q/g2/tool/lmxtool.c")
Check @('same', "$Q/g1/consumed-inputs.sha256", "$Q/g2/consumed-inputs.sha256")
Check @('same', "$Q/lmxtool.exe", "$Q/g2/tool/lmxtool-tool.exe")
Check @('same', "$Q/working-bundle.sha256", "$Q/g2/bundle.sha256")
Check @('same', "$O/driver.o", "$Q/g2/runtime/driver.o")
Check @('same', "$O/driver-observe.o", "$Q/g2/runtime/driver-observe.o")
Check @('exe-same', "$C/l2trans.exe", "$Q/g2/frontend/l2trans.exe")
Check @('exe-same', "$C/l1trans.exe", "$Q/g2/frontend/l1trans.exe")
Check @('same', "$C/l2_libc.o", "$Q/g2/frontend/l2_libc.o")
Check @('sha256', "$Q/lmxtool.exe")
Check @('sha256', "$Q/g2/frontend/l2trans.exe")
Check @('sha256', "$Q/g2/frontend/l1trans.exe")
Check @('sha256', "$Q/g2/frontend/l2_libc.o")
Check @('sha256', "$Q/g2/runtime/driver.o")
Check @('sha256', "$Q/g2/runtime/driver-observe.o")
Check @('sha256', "$Q/g2/tool/lmxtool-tool.exe")
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' failed commands ' + $script:fails) -Encoding utf8
Write-Output ('CHECK151' + $try + ' failed commands ' + $script:fails)
