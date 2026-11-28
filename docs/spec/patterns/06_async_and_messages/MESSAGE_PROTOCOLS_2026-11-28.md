# Message: новые прикладные шаблоны

Редакция 28 ноября 2026. **DRAFT; LMX parser/type/runtime NOT_RUN.** Это дополнение действующего каталога, с теми же полями `patterns.json`, тремя сравниваемыми языками LMX/Go/Erlang, отдельными исходниками, RU/EN объяснениями и подсчётом полного кода.

## Что уже было и что добавлено

| Потребность | Существующая основа | Дополнение |
| --- | --- | --- |
| Адресованный вызов и ответ | 061 Active Object, обычный post/answer | [109 Request-Response / Ask](109_request_response_ask_comparision.md): deadline, один terminal outcome, поздний reply |
| Сохранённое ожидание значения | 064 Future, 067 Guarded Suspension | [110 Become / Selective Stash](110_become_selective_stash_comparision.md): ограниченный FIFO только для work, control/query/reply продолжают обслуживаться |
| Иерархия детей и рестарт | 088 Structured Concurrency, 089 Supervision Tree | [111 Phased Message Lifecycle](111_phased_message_lifecycle_comparision.md): drain → фактическая остановка children → close parent |
| Внешнее I/O | 062 Reactor, 063 Proactor, 071 Half-Sync / Half-Async | [112 External Blocking Adapter](112_external_blocking_adapter_comparision.md): физическое блокирование в L2/native, completion обычным Message |

## Механизм Message и прикладной протокол

Message сам не создаёт deadlock. Здесь сохраняются штатные turns, addressed calls и post/answer; второй scheduler и LMX `synchronized` не вводятся. `synchronized`, native locks, GIL и OS waits могут быть деталями физического L2/host adapter.

В прикладном протоколе можно ошибиться: перепутать route, принять старый result за новое поколение, бесконечно откладывать control вместе с work, считать admission завершением операции либо спланировать шаг после закрытия его владельца. Это ошибки состояния и договора приложения. Новые примеры показывают явное состояние и переходы, позволяющие различить эти ошибки без изменения Message scheduling.

`post` уже обеспечивает корреляцию своих писем. Дополнительные token/epoch в новых примерах нужны для **другой наблюдаемой задачи**: deadline, stale completion и принадлежность текущему запуску native ресурса. Никакого отдельного Message mailbox из таблицы request IDs не строится.

## Конкретные границы providers

| Provider | Обязанность | Completion |
| --- | --- | --- |
| `timer.schedule(token,address)` в 109 | Зарегистрировать один поздний timer event и немедленно вернуть управление | `expire(token)` обычным Message |
| `events` во всех примерах | Сохранить локальное наблюдение без ожидания чужого owner | Не требуется; это owner-local trace sink |
| `native.beginFlush(epoch,address)` в 111 | Начать flush/cleanup внешнего ресурса и удержать его до completion | `flushed(epoch,ok)` после завершения native действия |
| `lifecycle.requestChildrenClose(epoch)` | Инициировать штатное закрытие двух прямых `Thread.children` | `stopped(id,epoch)` только после реальной остановки |
| `lifecycle.requestOwnerClose()` | Запросить собственное штатное закрытие из ещё живого handler | Протокол больше не требует сообщений этому owner |
| `native.submit(token,value,address)` в 112 | Скопировать вход, удержать resource, принять job в ограниченный native executor; return 1/0 — только admission | `completed(token,ok,value)` после возврата blocking call и освобождения его holds |
| `native.releaseIdle()` | Освободить ресурс, который уже не используется job | Не ожидает будущего Message |

У providers нет фиктивных успешных тел. Они имеют статус `REQUIRE_IMPLEMENTATION`, точно как физические I/O/lifecycle порты существующего каталога. Применение Python C API использует эту же границу: GIL/thread state удерживается в native части, а готовый результат приходит владельцу обычным Message.

Для 109 и 112 `selfAddress` идентифицирует конкретный экземпляр владельца. После restart host выдаёт новую identity; timer/native completion сохраняет identity исходного адресата и не перенаправляется по одному только повторно использованному имени. Один token без identity поколения не защищает от ответа старому экземпляру. Внутри экземпляра i64 counter никогда не переиспользуется: на максимуме следующий запрос отклоняется до сложения.

Для native hard crash результат может быть неизвестен. `beginClose`, timeout и потеря transport ответа не означают отмены уже выполненного эффекта. За пределами bounded fixture provider должен выдать реальный failure/unknown outcome и освободить или изолировать свои ресурсы; принудительное убийство произвольного C thread не является скрытой реализацией cancel.

## Почему selective stash сохраняет обслуживание

В 110 один и тот же owner имеет отдельные handlers `work`, `become`, `pump`, `reply`, `query`, `stop`. Только `work` пишет в FIFO. `become` меняет обычное поле phase; `pump` извлекает ровно один элемент и завершает turn, опубликовав следующий self Message. Лишний pump при пустом FIFO ничего не исполняет.

Входящие work при непустом FIFO добавляются в конец и не обходят ранее принятые work. `stop` не помещается в stash: он меняет phase, отклоняет оставшийся ограниченный набор и завершает приём work. Общая очередь Message не подменяется этой прикладной очередью.

## Lifecycle без poststop-зависимости

В 111 parent остаётся живым на протяжении drain и закрытия детей. Query, drained и stopped принимаются собственными handlers. Parent не вызывает свой poststop для координации. Только после обоих actual stopped он публикует итог и запрашивает close.

Рестарт — отдельная политика существующего 089. Новый экземпляр имеет новую identity/generation; старый drained/stopped не признаётся новым событием. Приведённый graceful сценарий явно предполагает, что оба ребёнка живы при начале drain и native flush завершается. Hard crash и watchdog не названы успешно выполненным drain.

## Проверка

[message_protocol_cases_20261128.json](../validation/message_protocol_cases_20261128.json) содержит входные последовательности и ожидаемые различающие наблюдения. [message_patterns_20261128.json](../validation/message_patterns_20261128.json) фиксирует статические проверки при выпуске поставки. Поля `workbook_publication`, `pdf_publication` и `visual_review` в этой расписке именуют архивные отчёты о той поставке. Состав рабочих изданий указан в [оглавлении группы](README.md). Для исполнения LMX, Go и Erlang в расписке стоит `NOT_RUN`.

Размеры считают все показанные объявления, helper bodies и комментарии. Реализация native ports, launcher, runtime и transport не считается бесплатной: она явно не включена в размер данного protocol/core листинга. Таблица не измеряет быстродействие и не выбирает победителя полного production приложения.
