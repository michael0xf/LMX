# Памятка этой сессии Grok CLI

Я — открытый терминальный чат Grok в LMX, не Grok Bot и не ACP-беседа `grok_direct`. Общая матрица каналов: [chat_config.md](chat_config.md), [work_chat/README.md](work_chat/README.md). Здесь только то, что легко перепутать в этой консоли.

## Кто я

- Лаунчер: `C:\grok\grok.bat` — всегда `cd /d C:\Nyasha_Planet\LMX`. Без аргументов: TUI `--cwd` LMX и `--resume grok`. Сообщение в уже открытую консоль: `C:\grok\grok.bat send "…"`. Send вызывает `grok_active.py --session grok` уже из LMX, как `--resume`. Не путать с Grok Bot. PID/UUID меняются.
- Рабочий каталог: `C:\Nyasha_Planet\LMX`.
- Входящие от Codex: консольный inject (`grok_active.py`). Inject ломается, пока этот ход печатает (`Concurrent user input`). Пятиминутный опрос `python claude_chat/grok_uds_pull.py` закрыт и заново не ставится.
- Не запускать `grok_active.py` против себя. Ответ Codex: `python claude_chat/uds.py --name lmx_uds send "From Grok. REPLY <ID>. …"`.
- `python claude_chat/grok.py ask` — **другая** беседа. Не подменять ею этот чат.

## Codex

- Исходящее к простаивающему или занятому Codex: `python claude_chat/codex_inbound.py send --sender Grok --request-id <UNIQUE> "…"`.
- **Не** вызывать `bind` снаружи. Bind только внутри той задачи Codex, которую надо слушать. После рестарта приложения Codex bind делает она сама.
- Приёмка инструмента ≠ ответ модели. `read` у этого MCP часто отдаёт пустые `items` даже когда Codex ответил в UI. Не слать повторно вслепую. Не крутить ACK-петли.
- Проверено из этой консоли: `CHAT-20260919-A742-GROK` ушёл одним `send`, thread был уже bound.

## Claude

- Реле: живая сессия `lmx_uds`. Не делать `uds.py start`, пока она уже есть. Не использовать устаревшие имена `l1-c9` / `l1-91` / `l1-98`.
- Постоянные имена: `lmx_uds`, `fable`, `deepseek`, `openrouter`. Лаунчеры вне репозитория. PID и session id после рестарта новые.
- Отправка: `python claude_chat/uds.py --name lmx_uds send "From Grok. Request <UNIQUE>. …"` с `ListAgents` + `SendMessage` у реле. Чтение: `python claude_chat/chat_status.py read --name lmx_uds --contains <UNIQUE>`. `uds.py logs` — шумный TUI, не нормальный разбор.
- Запись в named pipe ≠ конец хода. Ждать текст модели / `turn ended`.
- Транспорт pipe и логин провайдера — разные вещи. Always-approve в этом чате не логинит Claude.
- Не трогать процессы и pipe чужих Claude-агентов, не `--resume` их id, не читать их `.key`.

## Grok Bot

- GUI `Grok Bot.exe`, агент `2ff57700-9d3b-4933-a349-76bbe9f8aac7`. Это не эта консоль. `AttachConsole` к Bot не применять.
- Памятка Bot: [grok_bot.md](grok_bot.md). Webhook Bot ≠ inject в мой prompt.

## Поведение

- Без конкретного поручения ничего не слать в `lmx_uds`, Codex и чужие сессии. Не плодить контрольные коды.
- Тестовый ACK — ровно один раз, с тем кодом, который пришёл. Не rebind, не «улучшать» канал по дороге.
- Не печатать токены, pipe path секреты, содержимое `.key`. Не коммитить `claude_chat/profiles/`.
- Организационное — в `steps/` и этих памятках. В `LMX_blog/` только технические реплики автора о языке.
- Точка входа проекта: [READ.ME](READ.ME), затем [steps/current.md](steps/current.md).
