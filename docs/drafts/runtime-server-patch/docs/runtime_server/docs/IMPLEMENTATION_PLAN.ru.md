# План реализации собственного LMX/MCP-сервера runtime

## 1. Основание и результат

План основан на текущих документах после тензорного патча, примерах таблиц/Message и исходниках `selfbuild.tar.gz`. [Матрица доказательств](SOURCE_EVIDENCE.ru.md) указывает конкретный код и отличает существующий механизм от нормативного требования. Приложенные LMX-тела реализуют прикладную композицию; их production type/admission/runtime исполнение пока NOT_RUN.

Цель: пользователь вызывает агентский метод на LMX; тот обращается к модели, получает законченный LMX-документ, исполняет его обычным runtime и передаёт модели фактический результат. Runtime одновременно обслуживает стандартный MCP и местные Message-вызовы, включая установку нового интерпретируемого поведения без перекомпиляции. Код и состояние сервера — обычный LMX.

## 2. Неизменные основания

- Один parser ядра с `[]`-подпарсером и один общий алгоритм группировки.
- `fromLmx` возвращает чистый граф, пригодный для компиляции; `toLmx` выдаёт код любой Structure и любого L3Thread.
- Namespace/preparation, typed call, owner, lifetime, copy и native/walker dispatch общие.
- Graph edit не очищает native, не запускает recompile и не изменяет уже выбранные вызовы.
- Каталог — поисковая проекция указанной компиляции. Текущий источник — живой граф и toLmx.
- SQL commit не равен общей транзакции памяти, native, mail и внешних эффектов.
- Объявление порта или наличие файла примера не считается реализованным provider.

## 3. Очерёдность

| Этап | Изменение | Наблюдаемый критерий готовности |
| --- | --- | --- |
| A | Общие parser/grouping и fromLmx/toLmx | Один путь для всех потребителей; полный roundtrip Structure/L3Thread |
| B | Runtime ports и местный Service | Реальные typed preparation/execution/diagnostics и owner writes |
| C | Message и hot replacement | Новый handler обслуживает следующий выбор без compile; старые calls завершаются нормально |
| D | Compiler facts и SQLite catalogue | Полная заявленная topology, доказательность, публикация через настоящий endturn hook |
| E | Native текстовый транспорт | Целые frames, actual receipt, отказ без исполнения префикса |
| F | Агент и API модели | Полный ask→model→runtime→observation цикл, остановка и поздние ответы |
| G | MCP current и отдельная legacy совместимость | Versioned wire, реальные capabilities, protocol fixtures на сервере |
| H | Интеграционная приёмка | Совпадение поведения local/native/MCP, codec/ownership/native границы |

Этапы D и E можно вести параллельно после A/B; F использует местный Message даже до HTTP. MCP не требует отдельного исполнительного ядра.

## A. Общее языковое основание

В целевой архитектуре **один основной parser с подпарсером `[]`, вызывающим основной, и один механизм группировки**. Квадратный компонент обслуживает INDEX, включая `var[arg:arg2:arg3]`, и компактное `[op` без пробела в разрешённом контексте. Определив начало выражения, он передаёт его основному parser. Содержимое `{...}` также делегирует, сам его не разбирает и не ищет закрывающую скобку. Основной parser возвращает точную позицию продолжения. TYPE/VALUE/обычные квадратные группы сохраняют свои контексты.

Старые независимые алгоритмы и таблицы связывания требуется удалить; новый сервер не должен согласовывать их адаптерами. Использовать действующий тензорный план, включая depth и правую ассоциативность высокой степени, не возвращая старые формы.

Подключить `sys\fromLmx` к общим P0/builder и `sys\toLmx` к полному kernel codec. Найденный dump с `...` при цикле не заменяет полный toLmx. Доработать общий ресивер, сохраняя source receivers, grouping, typed leaves, uninit/null/empty slots, повторные имена, sharing, cycles, actual parents и таблицы любого L3Thread. Не писать отдельный сериализатор сервера.

**Приёмка:** fromLmx выводимого текста восстанавливает заявленный граф и пригодность к обычному compile; интерпретация не требует обязательного compile/check/endturn. Реальные примеры с deferred initializers не исполняют их ради экспорта. Полнота codec проверяется отдельно от форматирования.

## B. Подключение RuntimePort

Использовать существующие `lm_p0_parse_bytes/string`, builder, typed invoke/eval и native/walker dispatch. Внешние receiver wrappers не должны выводить тип из pointer или обходить origin/private/requirements.

Реализовать prepareText/prepareGraph, execute, present, inspect, insert, copyTo, step и узкий admitHandler. Подготовка возвращает реальный Stage; execute возвращает фактический Receipt или поддержанный исход driver. Не превращать endturn в обычный return и не ловить неявную ошибку фиктивным PortFailure.

Для handler проверять не только named function signature, но и реальные consumer/finite-exit требования, owner и lifetime. Сохранять выбранный CODE и настоящий parent. Глобальные runtime object IDs и поиск callable по произвольной строке не нужны.

**Приёмка:** плохой source не меняет placement target; неправильный handler не записывается; typed results и отсутствие значения различаются; возврат ссылки не оставляет dangling arena/frame.

## C. Message и изменение сервиса

Развернуть Service как обычный owner-граф. `submitText/submitGraph` читают его handler при обслуживании. `replaceHandler` выполняет допущенную запись настоящего PLACE. Новый callable без native association исполняется существующим walker branch.

Письма направлять стабильному входу. Сформированное письмо старому CODE не переназначать; текущие frames не менять. Не вводить generation registry, tracking всех graph stores или fallback «native упал — повторить walker».

**Приёмка:** local call и local post дают одинаковые actual semantics; новый handler используется следующей selection без compile; old selected call и direct native A→B сохраняют своё назначение. Timeout и late answer проверяются существующим Message-механизмом.

## D. Компиляционный каталог

При явном compile фиксировать clean graph, owner, scope и compilation basis. Для topology использовать общий обход с operation-local map: существующий graph emitter уже выделяет label до обхода edges и сохраняет shared/cyclic links. Это образец общего механизма, не повод запускать C emission только ради индекса.

Передавать в каталог факты из настоящих решений preparation/type/binding/lowering. Сохранять written occurrences и unknown для динамических целей. Не выполнять defaults/внешние вызовы ради заполнения SQL. Native candidate list не заменяет полный обход DATA и некомпилируемых тел.

Реализовать typed compiler cursor, SQLite prepared writer и query binding из [catalogue.lmx](../src/catalogue.lmx). Одна active таблица на owner достаточна; история необязательна. Включить ordered fields, null slots, parents, calls/uses/reads/writes, types, source provenance, native artifacts, docs и tests. Полнота каждого вида анализа указывается отдельно.

Подготовить candidate до boundary. В существующем turn-коде пока нет завершённой проводки compile→catalogue→SQLite→endturn, поэтому добавить настоящий owner lifecycle hook. `endturn` не возвращается; код после него не является публикацией. Успешный SQL commit сообщает только успех SQL-проекции. При принятом runtime/native и отказавшем SQL — явный stale/recovery outcome, без заявленного rollback памяти.

Сохранять отдельно compilation input и optional post-tests-current: interpreted tests способны изменить граф. Любой запрос по catalogue-local key проверяет ожидаемый publication token в одной read transaction. Сменившийся snapshot возвращает stale; отсутствующий key — key-not-found. Для действия над живым объектом затем применяются обычные context/ref rules.

**Приёмка:** topology не теряет повторные имена, null slots, cycles/sharing; неопределённый вызов не становится ложным static edge; before/after SQL commit виден целый снимок; rollback SQL сохраняет предыдущий; interpreted edits видны в toLmx при честно старом каталоге.

## E. Native текст

Подключить реальный byte I/O и framing из [протокола](NATIVE_PROTOCOL.ru.md). Сначала локальный pipe либо обычный provider; затем HTTP application/lmx. Транспорт отдаёт только целый документ, не парсит вложенные скобки. Diagnostics идут вне protocol bytes.

**Приёмка:** UTF-8 byte length, partial I/O, invalid/truncated frame и EOF не приводят к выполнению префикса; реальный отказ подготовки/исполнения возвращается как таковой. Потерянный ответ не вызывает автоматического повтора эффекта.

## F. Агент и провайдер модели

Связать ModelPort с выбранным реальным API либо местной моделью. Полнота ответа устанавливается по фактическому завершению provider response; stream fragments остаются данными до конца.

Исполнить `agent.lmx` без нового scheduler. Job и nested callbacks живут в retained owner graph; callback получает состояние через настоящий parent, не через освобождённый local. Decision допускается до чтения полей. Список previous — история обмена, не очередь.

**Приёмка:** task→model→command→actual result→next round; finished, budget, incomplete, failure, undelivered, unanswered, stopped и late results различимы. Cancel политики агента прекращает новые отправки и не обещает отменить произвольную native работу.

## G. MCP

Подключить настоящий JSON codec и wire state machine поверх Service. Зафиксировать current 2026-07-28 и отдельный legacy 2025-11-25; [матрица](MCP_COMPATIBILITY.ru.md) перечисляет обязательные методы, directions и errors.

Начать с current base/discover/subscription handling и инструмента lmx. Затем реальные resources/templates, prompts, completion и MRTR. Объявлять только подключённые capabilities. Optional tasks — отдельный явно поддержанный профиль, без изобретения нового runtime scheduler. Outbound model API не смешивать с входной MCP-ролью.

Реализовать HTTP/stdio, cancellation, cache metadata, notifications, current headers и соответствующую deployment authorization. Legacy initialization/session и старые формы результатов не просачиваются в current wire.

**Приёмка:** приложенные positive/negative JSON/SSE fixtures превращены из reference vectors в запуски настоящего сервера; protocol validation отличается от LMX application failure. Параллельно подтверждается, что local/native/MCP вызывают один runtime path.

## H. Общая приёмка и пределы текущего пакета

Проверить библиотечные зависимости, actual type/admission, provider faults и owner lifetimes на текущей сборке ядра. Затем один сквозной сценарий: ask → inspect → каталог → новая Structure/fromLmx → owner Message → новый handler без compile → live toLmx → явный compile/endturn → новый каталог.

Отдельный сценарий должен удерживать старый frame/Message во время изменения handler. Ещё один — терять ответ после совершённого эффекта и подтверждать отсутствие автоматического повтора.

Пакет документации включает только новый/изменённый материал. Реальные выполненные проверки SQL, JSON, source shape и применимости патча перечисляет [VALIDATION](VALIDATION.ru.md). Они не заменяют production parser/runtime, сетевую интеграцию или MCP conformance.
