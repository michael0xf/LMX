try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Detached launcher of chain92, the coherent Lower/export/writer/runtime slice
# (Codex CODEX-OPUS-V63A-20261031-ANSWER01): generator92-prepare,
# generator92-self, candidate92-prepare, candidate92-frontend-parts (FE92),
# candidate92-runtime (RT92), suites92 -- each only when the previous record
# exited 0. Each record runs in its own child pwsh so its final exit cannot end
# this launcher; one pipeline -- nothing else runs while it is live. Runs after
# FE90 (candidate90-detached) is done.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain92-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('generator92-prepare', 'generator92-self', 'candidate92-prepare', 'candidate92-frontend-parts', 'candidate92-runtime', 'suites92')
foreach ($name in $records) {
  $rec="$p\pins\$name.command"
  Add-Content -LiteralPath $term -Value ("start $name " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ("$name EXIT=$e " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
