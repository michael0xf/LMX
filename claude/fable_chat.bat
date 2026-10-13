@echo off
rem fable_chat: an agent on the Claude Agent SDK (Fable 5.1) billed by API
rem credits; the key lives inside C:\claude\new\fable_chat.py.
rem Interactive:        fable_chat.bat
rem One-off request:    fable_chat.bat -p "..."
rem The lmx_uds relay calls fable_chat.py directly, see
rem for_lmx_uds_about_fable_chat.md in the LMX root.
rem All arguments are passed to fable_chat.py unchanged.
rem NOTE: keep this file ASCII only; cmd.exe misparses UTF-8 batch text.
setlocal
cd /d C:\Nyasha_Planet\LMX
python C:\claude\new\fable_chat.py --session fable_chat %*
endlocal
