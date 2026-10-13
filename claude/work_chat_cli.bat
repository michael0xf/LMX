@echo off
rem work_chat_cli: an ORDINARY Claude Code session (not work_chat.py) billed by
rem Console API credits; the key is set in this process's environment only.
rem This tests the plain "claude with ANTHROPIC_API_KEY" path: if it works, the
rem session is a full peer named work_chat (ListAgents / SendMessage from
rem lmx_uds, fable_pc, etc.) and the work_chat.py client is not needed.
rem No --remote-control: Remote Control needs a claude.ai login and does not
rem work with an API key; local peers and the named pipe do not depend on it.
rem What to check after start:
rem   /status  - the auth line must say API key (Console), not subscription;
rem   if the CLI asks whether to use the key from the environment, answer yes;
rem   in another session ListAgents must show work_chat.
rem NOTE: keep this file ASCII only. cmd.exe reads batch files in the OEM code
rem page, and "chcp" mid-file plus multi-byte text desyncs its line parser.
rem Usage: work_chat_cli.bat [additional claude arguments...]
cd /d C:\Nyasha_Planet\LMX
setlocal
chcp 65001 >nul
set CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1
rem ===== PUT THE KEY of the linked Console organization here (same as in work_chat.py) =====
set "ANTHROPIC_API_KEY=sk-ant-PUT_KEY_HERE"
rem =====================================================================================
if "%ANTHROPIC_API_KEY:PUT_KEY_HERE=%" neq "%ANTHROPIC_API_KEY%" echo Set ANTHROPIC_API_KEY in work_chat_cli.bat 1>&2 & exit /b 1
rem Real executable, not the wrapper in C:\claude (same as fable.bat).
set "WC_EXE=%USERPROFILE%\.local\bin\claude.exe"
if defined LMX_CLAUDE_EXE set "WC_EXE=%LMX_CLAUDE_EXE%"
if not exist "%WC_EXE%" echo Claude executable not found at "%WC_EXE%". Set LMX_CLAUDE_EXE. 1>&2
if not exist "%WC_EXE%" exit /b 1
set "WC_NAME=work_chat"
if defined LMX_WORK_CHAT_NAME set "WC_NAME=%LMX_WORK_CHAT_NAME%"
set "WC_MODEL=claude-fable-5-1"
if defined LMX_WORK_CHAT_MODEL set "WC_MODEL=%LMX_WORK_CHAT_MODEL%"
"%WC_EXE%" --model "%WC_MODEL%" --name "%WC_NAME%" %*
endlocal
