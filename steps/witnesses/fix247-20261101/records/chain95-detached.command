try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Detached launcher of chain95, the raw store's holder check (coherent94's
# write route, built in chain94's FE94): red95 (the witness on FE93, before the
# guard), suites95 (the same witness on FE94) -- each only when the previous
# record exited 0. Each record runs in its own child pwsh; one pipeline --
# nothing else runs while it is live. No translation: FE93 and FE94 are reused.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain95-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('red95', 'suites95')
foreach ($name in $records) {
  $rec="$p\pins\$name.command"
  Add-Content -LiteralPath $term -Value ("start $name " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ("$name EXIT=$e " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
