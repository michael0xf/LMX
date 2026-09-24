# Почта L2: `sendMessage` / `receiveMessage` (первая обёртка над ядром)

Автор (2026-09-24, дословно в `LMX_blog/2026-09-24.md`): «сделайте нормальную почту, nextMessage поменяйте на receiveMessage и сделайте возможность не только по порядку но и выборку по имени Message, отправителю и тп.; sendMessage — отправка … sendMessage это уже первая обёртка — проявляйте фантазию и ищите аналоги (к примеру тут близко к Erlang) … постфикс "Message" лучше оставить».

Ядро сегодня (измерено на `7fd36d6`): `LmxMsg` = {running, success, handoff_ready, graph}; конверт — сам Message, письмо — его граф; почтовый ящик `LmxPost` — FIFO-кольцо `inbox` + `staged` → `outbox` на границе хода (`lmx_post_publish`), взятие только по порядку (`lmx_post_take`); отправителя ядро не записывает; у родителя-заглушки R0 ящика нет. В L2 есть только приём `nextMessage: m` (автор, Q10).

## Аналог — Erlang (узнаваемо)

| Erlang | LMX | Что делает |
| --- | --- | --- |
| `Pid ! Msg` | `sendMessage: Msg` / `sendMessage: Ref Msg` | ставит письмо в staged; уходит адресату на границе хода (модель 28) |
| `receive Msg -> … end` | `receiveMessage: m` | первое письмо по порядку (прежний `nextMessage`) |
| `receive {tag, X} -> … end` (выборочный приём) | `receiveMessage: m Model` | первое письмо, чей граф проходит `implements(Model)` (позиционно); остальные остаются в ящике в прежнем порядке |
| `receive {From, X} …` | `receiveMessage: m from: Ref` | письмо от отправителя `Ref` — требует ссылки на отправителя (K3 ниже) |
| `exit(Reason)` к связанному родителю | `sendMessage: exit(exit_code: 7; stdout: ""; stderr: "")` | без адресата — родителю (для R0 — host-корню) |

Правила обёртки (транслятор; ядро не трогается, кроме шагов K):

1. `sendMessage: X` — одно поле-Structure `X`: адресат — родитель текущего Message (`lmx_thread_parent`; для R0 — host-корень). `sendMessage: Ref X` — первое поле — ссылка на Message (ребёнок из порождения, `m` из приёма, значение поля), второе — письмо. Различение по типу поля (ссылка / Structure), не по имени. Письмо — обычная Structure, её граф и есть письмо (конверт = Message). Уходит на границе хода, как сегодня staged → outbox.
2. `receiveMessage: m` — как `nextMessage: m` (переименование; фикстуры и транслятор — механически). `receiveMessage: m Model` — выборочный приём: первое письмо, проходящее допуск по модели `Model` (позиционный `implements`, как приём `exit` у host), остальные не трогаются (K1). Нет подходящего — как нет письма (сегодняшняя семантика пустого ящика).
3. Постфикс `Message` сохраняется; других имён нет (`send:`/`post:` не вводятся).

## Шаги ядра — только с одобрения автора (`q23.md`)

- **K1** выборочное взятие: `lmx_post_take_if(box, lane, admit, ctx)` — первое письмо inbox, для которого `admit(ctx, letter) = 1`, изымается, порядок остальных не меняется (одна функция рядом с `lmx_post_take`, тот же владелец-lane).
- **K2** host-корень (родитель R0) — полноценный Thread с ящиком: принимает `exit` от R0 (Opus -159 к.2h строит host; ящик — шаг ядра).
- **K3** отправитель: ядро не хранит отправителя; для выборки «по отправителю» и ответов нужна ссылка на отправителя — либо поле-ссылка в письме по соглашению обёртки (как Erlang `{self(), Msg}` — но меняет форму модели письма), либо поле записи `LmxMsg` (автор: «поле, которое не из четырёх, должно иметь LMX-владельца в графе»). Решение — автору.

## Порядок работ

1. Сейчас (без K): `sendMessage: X` → родитель, через существующий staged/outbox; `receiveMessage: m` — переименование; фикстуры `nextMessage` → `receiveMessage`; `exit(...)` из R0 к host (Opus -159 к.2b — хвосты фикстур, драйвер).
2. После K1: `receiveMessage: m Model`.
3. После K3: `from:`.

## Ответы автора (2026-09-25) и уточнения

- K1 = да, как **итератор** (старая спека §yield: `fn: words () iterator(Text)`, `yield:`, `each: word in words`): ядро — курсор по inbox в порядке допуска (`lmx_post_cursor_open/next/take/close`: `take` изымает письмо под курсором, остальные не трогаются) — Grok после -161; обёртка — `receiveMessage` без аргументов = взять первое (как сегодня); `receiveMessage: Model` = обойти курсором, первое письмо, чей payload проходит `implements(Model)`, изъять; `each: m in receiveMessage` — обход без изъятия (порт `iterator`/`yield` — отдельный пункт плана).
- K3 = а: письмо = анонимная Structure `(sender-ref; payload)` — обёртка `sendMessage` кладёт ссылку на отправляющий Message первым полем; приёмник допускает `m\[1]` по модели, `m\[0]` — отправитель (для ответа: `sendMessage: m\[0] reply(...)`).
- Транспорт (K4 = а, автор 2026-09-25): элемент outbox несёт ссылку на ящик адресата; на границе хода после `publish` lane владельца переносит письма в inbox адресатов (`lmx_post_accept`) — тикет Grok после -161; до него `sendMessage`/`exit` = `lmx_service_post`.
- Платформенные настройки host (Q1, автор): пока одна — рабочая директория процесса (`LmxCharArray` в вечном профиле host, R0 читает общей ссылкой).
- Host (Opus -159 к.2h, форма H1): host = сегодняшний корневой Thread (арена, ящик, schedule, manager, service), R0 — его ребёнок через `lmx_child_reserve_profiled` с result-ячейкой (корень неуспеха сохраняется), вечный профиль host’а — R0 общей ссылкой, программа R0 — builder (arena, graph) после резервации (в 2b — `l2_program_build`).

## Форма письма — решение координатора (2026-09-25, Opus -173)

Каждое письмо — фиксированная двухполевая анонимная Structure `(sender: @: LmxMsg; payload)`: payload — ОДНО поле-Structure (вложенное, не расплющенное), модель пользователя (`MainLetter`, `exit`, …) описывает payload и допускается по полю 1; поле `sender` пользователь в модели не объявляет; `m\[0]` — отправитель, `m\[1]\x` — поле payload. Письмо `mainArgs` host’а — `(sender = Message host; (mainArgs))` (Opus -173); письмо `exit` — `(sender = R0; exit(exit_code; stdout; stderr))` (2b). Обёртка `receiveMessage: m` привязывает `m` к письму; `receiveMessage: m Model` допускает поле 1 по `Model` (Sonnet -172). Тип ссылки на отправителя — `@: LmxMsg` (адрес Message = адрес Thread через префикс); `sendMessage: Ref X` — service post в `(LmxThread*) Ref`; поле-ссылка `@: T name` в теле именованной Structure — общая ветка (правило автора «@ любой глубины — receiver объявления»), не Message-специальный вид.
