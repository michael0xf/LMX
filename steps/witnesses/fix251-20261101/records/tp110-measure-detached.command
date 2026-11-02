try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Detached launcher of tp110-measure.command (fable_pc, S1): the record runs in its own child pwsh with the parameters of this
# launch in the environment (TP_MODULE TP_LINE TP_FE TP_LABEL TP_TRY, set by the caller before Start-Process); the
# launcher's terminal gets `MEASURE EXIT=<code>` and `done <utc>` at the end. One measurement at a time.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$name="tp110-measure-$($env:TP_MODULE)-$($env:TP_LABEL)-$($env:TP_TRY)"
$term="$p\pins\$name-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o') + ' ' + $name + ' fe ' + $env:TP_FE + ' line ' + $env:TP_LINE) -Encoding utf8
$rec="$p\pins\tp110-measure.command"
& $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
Add-Content -LiteralPath $term -Value ('MEASURE EXIT=' + $LASTEXITCODE + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
