# for_codex — как писать fable_chat и получать его ответы

## Что такое fable_chat

`fable_chat` — агент на Claude Agent SDK (модель Fable 5.1), оплата из
API-кредитов. Это не живая сессия: его нет в ListAgents. Его запускает
почтальон `lmx_uds`: одно сообщение — один запуск — один ответ. fable_chat
помнит разговор между запусками и делает только то, о чём его попросили.
Сам он никому не пишет. Вопросы к тебе он задаёт внутри своих ответов.

Его правила: [for_fable_chat.md](for_fable_chat.md). Правила почтальона:
[for_lmx_uds_about_fable_chat.md](for_lmx_uds_about_fable_chat.md).

У fable_chat все инструменты разрешены без подтверждения. Если задача
затрагивает Git, сборки или чужие пути, явно напиши в запросе, что можно и
чего нельзя: например, коммитить ли и пушить ли.

## Маршрут

    Codex → lmx_uds → fable_chat → lmx_uds → Codex

## Как написать fable_chat

1. Возьми новый ID для каждого запроса: `FABLE-CHAT-<YYYYMMDD-HHMMSS>`.
2. Запиши сообщение в файл (UTF-8). Форма:

   ```text
   From Codex. REQUEST FABLE-CHAT-<ID>. Forward FULL text to fable_chat per for_lmx_uds_about_fable_chat.md and return its full reply to Codex with codex_inbound.py send --sender fable_chat --request-id FABLE-CHAT-<ID>.
   Task: <полный текст задачи: что сделать, что можно и чего нельзя, что вернуть>
   ```

3. Отправь файл почтальону из корня LMX. `uds.py` нужен node в PATH:

   ```powershell
   Set-Location C:\Nyasha_Planet\LMX
   $env:Path = "C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin;" + $env:Path
   cmd /c "python claude_chat\uds.py --name lmx_uds send < msg.txt"
   ```

   Передавай файл через `<` в cmd, а не конвейером PowerShell: конвейер
   добавляет в начало текста BOM.

   Успех этой команды означает только, что lmx_uds получил сообщение. Это
   ещё не значит, что fable_chat его выполнил.

## Как получить ответ

Ответ приходит в эту задачу Codex через привязанный `codex_inbound.py`: как
входящее сообщение от отправителя `fable_chat` с тем же ID. Текст
начинается со строки `From fable_chat. REPLY FABLE-CHAT-<ID>.` Если что-то
сломалось, почтальон пришлёт `From lmx_uds. FABLE_CHAT FAILED <ID>.` с
кодом выхода.

- Ответ fable_chat окончательный. Не подтверждай его ACK-ом.
- Чтобы ответить на его вопросы или дать следующую задачу, отправь новый
  запрос с новым ID. Он помнит предыдущий разговор.
- Нужно начать разговор с fable_chat с чистого листа? Попроси об этом
  lmx_uds в запросе явно: тогда почтальон запустит его с `--new`.
- Пока fable_chat работает над одним запросом, следующий ждёт в очереди у
  почтальона. Большая задача может идти десятки минут.

## Если ответа нет

1. Посмотри, что сделал почтальон, в его транскрипте:

   ```powershell
   python claude_chat/chat_status.py read --name lmx_uds --contains FABLE-CHAT-<ID>
   ```

   Ищи запуск `fable_chat.py` и последующий `codex_inbound.py send`.
2. Если пересылка упала из-за устаревшего канала, перепривяжи эту задачу
   командой `python claude_chat/codex_inbound.py bind`.
3. Не отправляй тот же ID повторно, пока не выяснишь, что с ним стало.
   Если нужен повтор, используй новый ID.
