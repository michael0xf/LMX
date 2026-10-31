try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# One pipeline, chain 85b after RT85 attempt 01 stopped at the walker: the
# walker swap (candidate85b-walker), RT85b (candidate85-runtime-02), then
# suites85-02. Each record runs in its own child pwsh; the chain stops at the
# first nonzero exit.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$pw='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$term="$p\pins\chain85b-detached.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$records = @('candidate85b-walker', 'candidate85-runtime-02', 'suites85-02')
foreach ($r in $records) {
  $rec="$p\pins\$r.command"
  Add-Content -LiteralPath $term -Value ('start ' + $r + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  & $pw -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '$p'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath '$rec')))" *>> $term
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ($r.ToUpper() + ' EXIT=' + $e + ' ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
  if ($e -ne 0) { break }
}
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
