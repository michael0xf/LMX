try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# One pipeline: RT86w, then (only on exit 0) suites86w, each record in its own
# child pwsh so a record's final exit cannot end this launcher.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\check86w-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$rt="$p\pins\candidate86w-runtime.command"
& $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rt')))" *>> $term
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('RT86W EXIT=' + $e + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
if ($e -eq 0) {
  $su="$p\pins\suites86w.command"
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$su')))" *>> $term
  Add-Content -LiteralPath $term -Value ('SUITES86W EXIT=' + $LASTEXITCODE + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
