#!/bin/sh
# work_chat: an agent on the Claude Agent SDK billed by API credits
# (the key lives inside work_chat.py).
# Interactive:        work_chat.sh
# One-off request:    work_chat.sh -p "..."
# Working script: C:\claude\new\work_chat.py; override with WORK_CHAT_PY.
# All arguments are passed to work_chat.py unchanged.
cd /c/Nyasha_Planet/LMX || exit 1
exec python "${WORK_CHAT_PY:-/c/claude/new/work_chat.py}" --session work_chat "$@"
