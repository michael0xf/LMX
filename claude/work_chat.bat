@echo off
rem work_chat: an agent on the Claude Agent SDK billed by API credits
rem (the key lives inside work_chat.py).
rem Interactive:        work_chat.bat
rem One-off request:    work_chat.bat -p "..."
rem For the lmx_uds relay (from the LMX root, dialogue kept between calls):
rem     python C:\claude\new\work_chat.py --session relay -p "From lmx_uds. Request X. ..."
rem All arguments are passed to work_chat.py unchanged.
rem NOTE: keep this file ASCII only; cmd.exe misparses UTF-8 batch text.
setlocal
cd /d C:\Nyasha_Planet\LMX
python C:\claude\new\work_chat.py --session work_chat %*
endlocal
