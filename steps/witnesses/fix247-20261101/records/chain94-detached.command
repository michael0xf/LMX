try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Detached launcher of chain94, the raw-route holder check of the ordinary
# managed DEREF (coherent94; Codex CODEX-OPUS-THROWDEREF93-20261101-ANSWER01):
# red94 (the witness on FE93, before the guard), candidate94-prepare,
# candidate94-frontend-parts (FE94), suites94 -- each only when the previous
# record exited 0. Each record runs in its own child pwsh; one pipeline --
# nothing else runs while it is live. Runs after chain93 is done.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain94-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('red94', 'candidate94-prepare', 'candidate94-frontend-parts', 'suites94')
foreach ($name in $records) {
  $rec="$p\pins\$name.command"
  Add-Content -LiteralPath $term -Value ("start $name " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ("$name EXIT=$e " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
