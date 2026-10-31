try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# One pipeline, chain 85 after generator85 (10:09:41Z exit0): stage85 prepare,
# FE85 (Useplan/Lower/Core/Emit of coherent85), RT85, suites85 (held78,
# no-candidate79, computed-absence79, owner73c). Each record runs in its own
# child pwsh; the chain stops at the first nonzero exit.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain85-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('candidate85-prepare', 'candidate85-frontend-parts', 'candidate85-runtime', 'suites85')
foreach ($r in $records) {
  $rec="$p\pins\$r.command"
  Add-Content -LiteralPath $term -Value ('start ' + $r + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ($r.ToUpper() + ' EXIT=' + $e + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
