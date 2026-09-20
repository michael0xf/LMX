@echo off
rem Attach this terminal to the stored background session id; nothing hardcoded.
rem Usage: attach.bat [session-name]   (default: lmx_uds)
setlocal
rem Draw in the terminal's normal buffer so the window keeps its scrollback.
rem The attach client renders the screen, so the variable belongs here, not
rem on the background session, which draws nothing.
set "CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1"
set "LMX_NAME=%~1"
if "%LMX_NAME%"=="" set "LMX_NAME=lmx_uds"
python "%~dp0uds.py" --name "%LMX_NAME%" attach
