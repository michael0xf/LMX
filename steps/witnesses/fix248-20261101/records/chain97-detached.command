try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Detached launcher of chain97, V63's used-closure witness (Codex
# CODEX-OPUS-V63EDGE-20261031-ANSWER01 (b)) on the unchanged FE94 + RT92:
# suites97 (owner73e). The record runs in its own child pwsh; one pipeline --
# nothing else runs while it is live. No translation: FE94 and RT92 are reused.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain97-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('suites97')
foreach ($name in $records) {
  $rec="$p\pins\$name.command"
  Add-Content -LiteralPath $term -Value ("start $name " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ("$name EXIT=$e " + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
