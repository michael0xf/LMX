@echo off
rem work_chat — агент на Claude Agent SDK за API-кредиты (ключ внутри work_chat.py).
rem Интерактив:            work_chat.bat
rem Разовый запрос:        work_chat.bat -p "..."
rem Для почтальона lmx_uds (из корня LMX, с памятью диалога между вызовами):
rem     python work_chat\work_chat.py --session relay -p "From lmx_uds. Request X. ..."
rem Все аргументы передаются в work_chat.py как есть.
setlocal
cd /d C:\Nyasha_Planet\LMX
python work_chat\work_chat.py --session work_chat %*
endlocal
