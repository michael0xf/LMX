try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp120t (fable_pc, slice 258 fix07): the same record with the candidate's rebuilt tool tool120 (443C27BB, tp120-tool: tools/build.lm2 with the two kernel exports) as the tool; the frontend and runtime it builds from are boot119a's G2.  G0 = tool120.
# boot120: the detached launcher of boot120-quick (the whole short bootstrap of the optimization line after tp120): the record
# runs in its own child pwsh so its final exit cannot end this launcher; one pipeline -- nothing else runs while it is live.
# Parameter: TP_TRY (a, b, ...), passed on to the quick record.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$term="$p\pins\boot120$try-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o') + ' try ' + $try) -Encoding utf8
$rec="$p\pins\boot120t-quick.command"
& $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
Add-Content -LiteralPath $term -Value ('BOOT120-QUICK EXIT=' + $LASTEXITCODE + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
