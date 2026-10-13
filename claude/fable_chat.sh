#!/bin/sh
# fable_chat: an agent on the Claude Agent SDK (Fable 5.1) billed by API
# credits; the key lives inside C:\claude\new\fable_chat.py.
# Interactive:        fable_chat.sh
# One-off request:    fable_chat.sh -p "..."
# Working script: C:\claude\new\fable_chat.py; override with FABLE_CHAT_PY.
# All arguments are passed to fable_chat.py unchanged.
cd /c/Nyasha_Planet/LMX || exit 1
exec python "${FABLE_CHAT_PY:-/c/claude/new/fable_chat.py}" --session fable_chat "$@"
