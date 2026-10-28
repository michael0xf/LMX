$ErrorActionPreference='Continue'
$taskTerminal='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/tool32-05-methods-L2.terminal.txt'
('launcher ' + [DateTime]::UtcNow.ToString('o') + ' (detached pwsh runs tool32-05-methods-L2.command in a child pwsh after the reaper kill of 05:24Z; Codex: continue tool32-05 (CODEX-REPLY-BOOT43-BOUNDS-20261028T052500Z); stdout+stderr appended here)') | Out-File -Append -Encoding utf8 -LiteralPath $taskTerminal
& 'C:/Users/mtkra/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' '-NoProfile' '-NonInteractive' '-Command' "Set-Location -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/initial-tool32-43/src'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/tool32-05-methods-L2.command')))" *>> $taskTerminal
('EXIT=' + $LASTEXITCODE) | Out-File -Append -Encoding utf8 -LiteralPath $taskTerminal
('done ' + [DateTime]::UtcNow.ToString('o')) | Out-File -Append -Encoding utf8 -LiteralPath $taskTerminal
