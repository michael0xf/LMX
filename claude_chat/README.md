# LMX: транспорт

Действующая матрица и статус проверки — [work_chat/README.md](../work_chat/README.md). Почтальон обязан читать [to_lmx_uds.md](../to_lmx_uds.md) и, если адресат `fable_chat`, [его отдельный маршрут](../for_lmx_uds_about_fable_chat.md). Для обратной доставки в Codex — [CODEX_INBOUND.md](CODEX_INBOUND.md). `chat_config.md` оставлен лишь кратким указателем; старый подробный текст в Git-истории.

Из корня `C:\Nyasha_Planet\LMX` read-only проверить локальный реестр и привязку:

```powershell
python claude_chat/chat_status.py peers
python claude_chat/codex_inbound.py status
```

На 2026-10-14 Grok CLI выведен автором из текущей работы и локально не обнаружен; старый консольный адаптер не возобновлять без нового указания автора. Старая привязка inbound Codex сначала дала `connect ENOENT`, затем адресная Codex-задача выполнила `bind`, и повторный `status` прошёл. Это ещё не доказательство доставки конкретного сообщения. `opus` и `fable_pc` разрешаются в Claude `ListAgents`, не в этом локальном реестре; Codex и `fable_chat` там отсутствуют. Не запускать новую сессию для обхода отсутствующего адресата.
