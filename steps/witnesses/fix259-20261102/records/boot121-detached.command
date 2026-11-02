try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot121: the detached launcher of boot121-quick (the whole short bootstrap of the optimization line after tp121): the record
# runs in its own child pwsh so its final exit cannot end this launcher; one pipeline -- nothing else runs while it is live.
# Run this launcher bare (never piped): a pipe holds the calling shell until the bootstrap ends.  Parameter: TP_TRY (a, b, ...),
# passed on to the quick record.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$term="$p\pins\boot121$try-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o') + ' try ' + $try) -Encoding utf8
$rec="$p\pins\boot121-quick.command"
& $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
Add-Content -LiteralPath $term -Value ('BOOT121-QUICK EXIT=' + $LASTEXITCODE + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
