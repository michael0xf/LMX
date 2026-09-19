@echo off
rem Attach this terminal to the stored background session id; nothing hardcoded.
rem Usage: attach.bat [session-name]   (default: lmx_uds)
setlocal
set "LMX_NAME=%~1"
if "%LMX_NAME%"=="" set "LMX_NAME=lmx_uds"
python "%~dp0uds.py" --name "%LMX_NAME%" attach
