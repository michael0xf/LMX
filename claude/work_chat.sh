#!/bin/sh
# work_chat — агент на Claude Agent SDK за API-кредиты (ключ внутри work_chat.py).
# Интерактив:            ./work_chat.sh
# Разовый запрос:        ./work_chat.sh -p "..."
# Для почтальона lmx_uds (из корня LMX, с памятью диалога между вызовами):
#     python3 work_chat/work_chat.py --session relay -p "From lmx_uds. Request X. ..."
# Все аргументы передаются в work_chat.py как есть.
cd "$(dirname "$0")/../git/LMX" || exit 1
exec python3 work_chat/work_chat.py --session work_chat "$@"
