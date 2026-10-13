@echo off
rem fable_chat_cli: an ORDINARY interactive Claude Code session (not
rem fable_chat.py) billed by Console API credits; the key is set in this
rem process's environment only.
rem If it works, the session is a full peer named fable_chat_cli
rem (ListAgents / SendMessage from lmx_uds, fable_pc, etc.).
rem No --remote-control: Remote Control needs a claude.ai login and does not
rem work with an API key; local peers and the named pipe do not depend on it.
rem What to check after start:
rem   /status  - the auth line must say API key (Console), not subscription;
rem   if the CLI asks whether to use the key from the environment, answer yes;
rem   in another session ListAgents must show fable_chat_cli.
rem NOTE: keep this file ASCII only. cmd.exe reads batch files in the OEM code
rem page, and "chcp" mid-file plus multi-byte text desyncs its line parser.
rem Usage: fable_chat_cli.bat [additional claude arguments...]
cd /d C:\Nyasha_Planet\LMX
setlocal
chcp 65001 >nul
set CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1
rem ===== PUT THE KEY of the linked Console organization here =====
set "ANTHROPIC_API_KEY=sk-ant-PUT_KEY_HERE"
rem ================================================================
if "%ANTHROPIC_API_KEY:PUT_KEY_HERE=%" neq "%ANTHROPIC_API_KEY%" echo Set ANTHROPIC_API_KEY in fable_chat_cli.bat 1>&2 & exit /b 1
rem Real executable, not the wrapper in C:\claude (same as fable.bat).
set "WC_EXE=%USERPROFILE%\.local\bin\claude.exe"
if defined LMX_CLAUDE_EXE set "WC_EXE=%LMX_CLAUDE_EXE%"
if not exist "%WC_EXE%" echo Claude executable not found at "%WC_EXE%". Set LMX_CLAUDE_EXE. 1>&2
if not exist "%WC_EXE%" exit /b 1
set "WC_NAME=fable_chat_cli"
if defined LMX_FABLE_CHAT_CLI_NAME set "WC_NAME=%LMX_FABLE_CHAT_CLI_NAME%"
set "WC_MODEL=claude-fable-5-1"
if defined LMX_FABLE_CHAT_CLI_MODEL set "WC_MODEL=%LMX_FABLE_CHAT_CLI_MODEL%"
"%WC_EXE%" --model "%WC_MODEL%" --name "%WC_NAME%" %*
endlocal
