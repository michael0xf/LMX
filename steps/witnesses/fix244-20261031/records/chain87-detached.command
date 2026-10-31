try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# One pipeline, chain 87: stage87 prepare, FE87 (ONLY Lower87), RT87,
# suites87. Each record runs in its own child pwsh; the chain stops at the
# first nonzero exit.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain87-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('candidate87-prepare', 'candidate87-frontend-parts', 'candidate87-runtime', 'suites87')
foreach ($r in $records) {
  $rec="$p\pins\$r.command"
  Add-Content -LiteralPath $term -Value ('start ' + $r + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ($r.ToUpper() + ' EXIT=' + $e + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
