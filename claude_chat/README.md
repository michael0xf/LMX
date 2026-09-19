# Отдельные собеседники LMX

**Уже открытый чат Grok:** [GROK_ACTIVE.md](GROK_ACTIVE.md), `grok_active.py` — обмен с исходной активной сессией подтверждён. Не путать с отдельной ACP-беседой ниже.

**Прямой Codex ↔ Grok проверен отдельно:** [GROK_DIRECT.md](GROK_DIRECT.md), клиент `python claude_chat/grok.py ask "сообщение"`. Это Grok через ACP, а не описанный ниже Claude-собеседник.

Два независимых входа. Оба без файловых inbox/outbox и вотчеров. Секреты не печатать и не коммитить. Два агента L1 (`l1-98`, `l1-c9`) не трогать: не `--resume` их ID, не их pipe, не их `.key`.

## Подтверждённый полный цикл после входа, 2026-09-19

Пользователь завершил OAuth-вход, CLI показал `Login successful`. Codex проверил два последовательных сообщения через `uds.py send` в сессию `lmx_uds` (bg id `b9488e33`, pid 22092 на момент проверки):

1. Запрос запомнить `LMX-ORBIT-7392` → ответ модели `SAVED LMX-ORBIT-7392`.
2. Запрос повторить ранее заданный код, без кода в самом запросе → ответ `LMX-ORBIT-7392`.

Второе сообщение отправлено при статусе `idle` и запустило новый ход. Оба ответа прочитаны внешним процессом через `claude logs b9488e33`. Ответ не приходит на соединение отправки; logs содержит терминальные управляющие последовательности и повторные перерисовки, а не чистый JSON ответа. Проверка относится к этой работающей сессии и версии CLI, не подтверждает поведение после перезапуска.

Сессия использует общий профиль CLI `~/.claude`, а не изолированные config-каталоги прежнего моста `-p`. Успешный вход не означает авторизацию тех отдельных профилей. Настройки провайдеров и процессы L1 не изменялись.

Сессия уже запущена: для обращения использовать `send` и `logs`, не повторять `start` для того же имени.

## 1. Интерактивная сессия и named pipe (проверяемый прямой обмен)

Клиент: `python claude_chat/uds.py`. Это **не** `claude -p`. Запускается фоновая интерактивная сессия Claude Code 2.1.278 с собственным `--messaging-socket-path`.

### Команды из корня LMX

```powershell
python claude_chat/uds.py --name lmx_uds start
python claude_chat/uds.py --name lmx_uds status
python claude_chat/uds.py --name lmx_uds send "Запомни слово маяк и ответь коротко."
python claude_chat/uds.py --name lmx_uds logs
python claude_chat/uds.py --name lmx_uds send "Какое слово я попросил запомнить?"
python claude_chat/uds.py --name lmx_uds stop
```

Второй участник: другое `--name` (например `lmx_uds_b`). У каждого свой адрес pipe, pid, `sessionId` и inbox-ключ.

### Два разных входа

| Что | Где | Зачем |
| --- | --- | --- |
| Авторизация **локального транспорта** | Файл `~\.claude\sessions\<pid>.<hash>.key` своей сессии, поле `peerToken`. Публикуется CLI при старте inbox. | Первая JSON-строка `{"type":"auth","token":"..."}` |
| Авторизация **провайдера модели** | OAuth / API-ключ / `ANTHROPIC_AUTH_TOKEN` + при необходимости `ANTHROPIC_BASE_URL` в окружении процесса сессии | Ход модели. Наличие профиля или `oauthAccount` в `~\.claude.json` **не** подтверждает вход |

Транспорт проверен без провайдера. Ход модели без провайдера обрывается: `Not logged in · Please run /login`.

### Протокол (сверка с CLI 2.1.278 при старте)

CLI печатает:

```text
[uds-messaging] Listening: \\.\pipe\LOCAL\cc-msg-<32 hex>
[uds-messaging] Inject messages (auth line REQUIRED here; a pipe is not reachable via socat/AF_UNIX):
  node -e "const c=require('net').connect(process.argv[1],()=>{c.write(
      JSON.stringify({type:'auth',token:process.env.CLAUDE_CODE_MESSAGING_TOKEN})+'\n'+
      JSON.stringify({type:'user',message:{role:'user',content:'hello'}})+'\n');c.end()})" "<path>"
```

Внешний процесс, который **не** наследует env сессии, берёт `peerToken` из **своего** `.key` (оба токена принимает `J9r`: peer или child). Формат — две JSON-строки с `\n`, одним `write`:

```text
{"type":"auth","token":"<peerToken своей сессии>"}
{"type":"user","message":{"role":"user","content":"…"}}
```

Первая полная строка обязательна за 30000 ms. Рецепт Node — штатный. На этой машине у Python нет `AF_UNIX`; клиент вызывает `claude_chat/inject.js`.

### Как получается ответ

Проверено: **ответ модели по тому же pipe не возвращается** (`inbound_bytes 0`, `NO_REPLY_ON_SOCKET`). Подтверждение `write` — не ответ модели.

Внешний процесс читает вывод сессии штатной командой `claude logs <bg-id>` (обёртка: `uds.py logs`). Это терминальный вывод фоновой сессии, не почтовый файл.

Квитанция `hold-receipt` на адрес отправителя не уходит, если у отправителя нет своего inbox в пространстве `\\.\pipe\LOCAL\cc-msg-*` (`reply address unshaped or outside our socket namespace`).

### Что проверено 2026-09-19 (эта сессия Grok)

- Флаг `--messaging-socket-path` в 2.1.278 есть (в `--help` не показан; ошибка пустого пути и Windows-формат `\\.\pipe\<name>` — в бинарнике).
- Новая сессия `lmx_uds` в `C:\Nyasha_Planet\LMX\claude_chat`, kind `bg`, собственный pipe. L1 не останавливались и не резюмировались.
- Штатная публикация inbox-ключа своей сессии. Токены L1 не читались.
- После `crossSessionInbound: accept` в **локальном** `claude_chat/.claude/settings.json` (не глобальные настройки пользователя) входящее сообщение: `Routed user message to queue (priority=next)`.
- Простаивающая сессия **начала ход**. Ход сразу: `turn ended in error: Not logged in · Please run /login`.
- Без этой политики, если сессия в bypass, внешний inject держится: `held inbound peer message (cause=no-mode-asserted)`.
- Контрольное слово во втором ходе **не проверено**: провайдер не вошёл.

Первая сессия-эксперимент `lmx-uds` / `08300e6d` остановлена. Рабочая: `lmx_uds` / `b9488e33` (пока не сделан `stop`).

### Что нужно от пользователя для полного цикла

В терминале, где должен работать ход модели, задать окружение провайдера **этой** новой сессии или выполнить вход внутри неё:

```powershell
claude attach b9488e33
```

затем `/login` **или** остановить сессию и снова `uds.py start` из оболочки, где уже заданы `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_API_KEY` и при необходимости `ANTHROPIC_BASE_URL`. Не копировать env из процессов L1 и не запускать их `.bat`. Секреты в чат и в git не класть.

После входа: два `send` с «маяк» и вопрос про слово; в `logs` должен быть текст модели, не только ошибка login. Одинаковый `session_id` в `uds-state.json`.

## 2. Headless `claude -p` (прежний мост, другой канал)

Вход: `python claude_chat/chat.py`. Профили `grok`, `grok_bot`, `claude_code` в `claude_chat/profiles/`. Ответ — JSON stdout команды `ask`. Это не интерактивный pipe.

```powershell
python claude_chat/chat.py --profile claude_code status
python claude_chat/chat.py --profile claude_code login
```

`loggedIn: false` во всех трёх профилях на момент проверки. Не заменяет задачу §1.

## Сообщение для другого агента

«В LMX есть клиент `python claude_chat/uds.py` к отдельной фоновой сессии Claude Code. Читай `claude_chat/README.md`. Не используй `claude -p` вместо pipe. Не трогай L1. Транспорт: auth + user JSON в named pipe; ответ модели — через `uds.py logs`, не через то же соединение. Для lmx_uds вход выполнен и полный цикл проверен; использовать send и logs без повторного start.»
