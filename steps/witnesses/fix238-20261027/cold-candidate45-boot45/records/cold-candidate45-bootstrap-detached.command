$ErrorActionPreference='Continue'
$taskTerminal='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-bootstrap.terminal.txt'
('launcher ' + [DateTime]::UtcNow.ToString('o') + ' (detached pwsh runs the bootstrap record in a child pwsh; stdout+stderr appended here)') | Out-File -Append -Encoding utf8 -LiteralPath $taskTerminal
& 'C:/Users/mtkra/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' '-NoProfile' '-NonInteractive' '-Command' "Set-Location -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate45-bootstrap.command')))" *>> $taskTerminal
('EXIT=' + $LASTEXITCODE) | Out-File -Append -Encoding utf8 -LiteralPath $taskTerminal
('done ' + [DateTime]::UtcNow.ToString('o')) | Out-File -Append -Encoding utf8 -LiteralPath $taskTerminal
