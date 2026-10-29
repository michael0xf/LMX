$ErrorActionPreference='Continue'
$taskT='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate46-tool-rebuild-frontend.terminal.txt'
Add-Content -LiteralPath $taskT -Value ('launcher '+[DateTime]::UtcNow.ToString('o')+' (detached pwsh runs the rebuild-frontend record in a child pwsh; stdout+stderr appended here)')
& 'C:/Users/mtkra/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -NonInteractive -Command "Set-Location -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/cold-candidate46-tool-rebuild-frontend.command')))" *>> $taskT
Add-Content -LiteralPath $taskT -Value ('EXIT='+$LASTEXITCODE)
Add-Content -LiteralPath $taskT -Value ('done '+[DateTime]::UtcNow.ToString('o'))
