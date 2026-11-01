try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Detached launcher of chain93, the throw channel of the native typed
# dereference (coherent93): generator93-prepare, generator93-self,
# candidate93-prepare, candidate93-frontend-parts (FE93), suites93 -- each only
# when the previous record exited 0. Each record runs in its own child pwsh so
# its final exit cannot end this launcher; one pipeline -- nothing else runs
# while it is live.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain93-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('generator93-prepare', 'generator93-self', 'candidate93-prepare', 'candidate93-frontend-parts', 'suites93')
foreach ($name in $records) {
  $rec="$p\pins\$name.command"
  Add-Content -LiteralPath $term -Value ("start $name " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ("$name EXIT=$e " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
