try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# One pipeline: generator85-prepare, then (only on exit 0) generator85-self,
# each record in its own child pwsh so a record's final exit cannot end this
# launcher.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\generator85-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$prep="$p\pins\generator85-prepare.command"
& $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$prep')))" *>> $term
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('GENERATOR85-PREPARE EXIT=' + $e + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
if ($e -eq 0) {
  $self="$p\pins\generator85-self.command"
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$self')))" *>> $term
  Add-Content -LiteralPath $term -Value ('GENERATOR85-SELF EXIT=' + $LASTEXITCODE + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
