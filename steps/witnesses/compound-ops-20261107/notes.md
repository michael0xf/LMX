# Составные присваивания и степень `**` — документы и план по поручению автора 2026-11-07

fable_pc, 2026-11-07. Поручение автора через Codex — добавить в документацию и план операторы `:=`, `+=`, `-=`, `*=`,
`/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=`, `**`
([CODEX-FABLE-AUTHOR-COMPOUND-POWER-DOCS-20261107T190048260Z-01](records/pins/CODEX-FABLE-AUTHOR-COMPOUND-POWER-DOCS-20261107T190048260Z-01.txt));
уточнение автора — ассоциативность и приоритет `**` как в Python
([CODEX-FABLE-AUTHOR-POWER-PYTHON-20261107T190238835Z-01](records/pins/CODEX-FABLE-AUTHOR-POWER-PYTHON-20261107T190238835Z-01.txt)).
Дословные реплики автора — в [журнале](../../../LMX_blog/2026-11-07.md), разделы «Составные присваивания и степень» и
«Ассоциативность и приоритет `**`»; пояснения Codex при передаче — там же, вне цитат. Это шаг документации и плана:
кода операторов нет ни у native, ни у обходчика, в собранный срез 302 ничего не внедрялось, pipeline сборок не запускался.
Поручение Codex о документе передачи
([CODEX-FABLE-HANDOFF-DOC-REPLY-20261107T190554887Z-01](records/pins/CODEX-FABLE-HANDOFF-DOC-REPLY-20261107T190554887Z-01.txt)):
`to_fable.md` (передача Opus от 17:45Z, состояние a07) сохраняется отдельным коммитом с точным списком из одного пути,
без переписывания итогом 302.

## Что записано

- [Книга](../../../provenance/semantics-book.md), RU и EN парно: новый подраздел `compound-assign` «Составные присваивания
  и степень» после `assign-known` — одиннадцать эквивалентностей через `:=` (`a += b` соответствует `a := (a + b)`, …,
  `a **= b` — `a := (a ** b)`), левая часть — уже известное место со всеми правилами `:=`; `=` остаётся сравнением, `^` —
  побитовым исключающим ИЛИ; группировка `**` как в Python: справа, сильнее `* / % + -`, слабее вызова, индекса и поля,
  слева сильнее унарных `+ - ~`, справа унарный операнд допустим (`-2 ** 2` есть `-(2 ** 2)`, `(-2) ** 2` сохраняет
  скобки, `2 ** -2` есть `2 ** (-2)`, `2 * 3 ** 2` есть `2 * (3 ** 2)`); не определены и уточняются до реализации:
  однократность вычисления места слева с эффектами (эквивалентность — не макроподстановка), типы и преобразования,
  отрицательная и дробная степень, `0 ** 0`, ошибки, атомарность, приоритет самих присваиваний. Generated
  [RU](../../../docs/LMX_semantics.ru.md) / [EN](../../../docs/LMX_semantics.en.md).
- [Грамматика](../../../provenance/grammar.json), раздел `operators` (§21) RU и EN: токены одиннадцати составных
  присваиваний и `**` — по одному токену без деления в P0; группировка `**`; `^` — XOR; реализации токенов нет.
  Generated [RU](../../../docs/LMX_grammar.ru.md) / [EN](../../../docs/LMX_grammar.en.md).
- [План](../../../next_core_tasks_v3.md): новый пункт M5 — уточнения до реализации, реализация одним общим механизмом
  (токены P0, понижение `a op= b` в общий путь `:=` с однократно вычисленным местом, `**` как общая числовая операция ядра
  для native и обходчика), проверка обоих исполнителей с конкретными значениями и мутантами (группировка слева направо,
  повторное вычисление места, `^` как степень). [Чек-лист](../../../next_core_tasks_v3_checklist.md): строка M3/N3
  (`|` внутри обратных кавычек экранирован по ревью Codex
  [CODEX-FABLE-OPS-DOCS-REVIEW-20261107T191018160Z-01](records/pins/CODEX-FABLE-OPS-DOCS-REVIEW-20261107T191018160Z-01.txt)).
  [steps/current.md](../../current.md): датированный абзац поручения. [Заметки о реализации](../../../docs/implementation-notes.ru.md)
  RU/[EN](../../../docs/implementation-notes.en.md): новый 4.3. [Реестр дефектов](../../defects.md): запись
  COMPOUND-ASSIGN-AND-POWER (OPEN) рядом с ASSIGN-KNOWN-OPERATOR.

## Проверка документов

P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`; рабочий tool — `cold-boot164a/quick164a/lmxtool.exe`
(`8b106da588fad35dc7b0139d963867f7087fae657b601e38920a0e8d1543f07e`, тот же, что в docs-шагах среза 302).
Список [docsops-render](records/pins/docsops-render.tsv) (`685ad296…`): `docs render semantics`, `docs verify semantics`,
`docs render grammar REPO docs`. Первый запуск 19:16:12Z ([терминал](records/pins/docsops-render.terminal.txt),
[лог](records/pins/docsops-render.log)) — отказ формы вызова: tool вызван без префикса драйвера (`checks LIST` вместо
`0 entry 0 -- checks LIST`), driver exit 2 и usage, ChecksExit 1; документы не тронуты. Повтор из нового каталога
`docsops-render-run-02` установленной формой READ.ME#docs-cycle
([консультация Codex](records/pins/CODEX-FABLE-DOCS-LAUNCH-FIX-20261107T191647208Z-01.txt), пришедшая параллельно с
исправлением) — 19:17:07→19:17:08Z ([терминал](records/pins/docsops-render-02.terminal.txt),
[лог](records/pins/docsops-render-02.log)): «Rendered 35 paired semantic chapters, 14 implements cases and both verbatim
source snapshots», verify — то же «Verified», grammar — «27 paired sections; 47 source excerpts», CHECKS 3 lines, 0 failed.
Разница generated: semantics RU/EN по +5 строк (якорь, заголовок, абзац), grammar RU/EN по +2 (абзац §21).

Архив — первый проход [docsops-archive-1](records/pins/docsops-archive-1.tsv) (`steps`): манифест путей P из
[records-ops-1](records/pins/records-ops-1.list) (16 путей), байтовые копии `stage-copy` в [records](records), манифест
проверен против копий. Индекс собран двумя точными списками — [allowfable](records/pins/allowfable.list) (`to_fable.md`) и
[allowops-1](records/pins/allowops-1.list) (14 документов и 16 копий); четыре копии логов tool с CRLF (`docsops-render.log`, `docsops-render-02.log` — [crlf-ops-1](records/pins/crlf-ops-1.list); `docsops-archive-1.log`, `docsops-check-a.log` — `pins/crlf-ops-2.list` в P) переписаны из индекса с LF, поэтому их хэши в [evidence.sha256](evidence.sha256) — хэши файлов P с CR, а не копий; `docs check` над индексом —
[docsops-check-a](records/pins/docsops-check-a.tsv) (PRIVATE_OUT `docsops-out-a` создан заранее). Второй проход
[docsops-archive-2](records/pins/docsops-archive-2.tsv): копии receipts первого прохода и docs check по
[records-ops-2](records/pins/records-ops-2.list), итоговый [evidence.sha256](evidence.sha256) по
[evidence.list](evidence.list) против P; затем копии второго прохода и evidence добавлены к индексу списком
[allowops-2](records/pins/allowops-2.list), docs check повторён над итоговым индексом
([docsops-check-b](records/pins/docsops-check-b.tsv)); receipts повтора остаются в P (`pins/docsops-check-b.*`), их итог
— в сообщении Codex по этому шагу. Коммиты: `to_fable.md` отдельно (список из одного пути), затем документы и эта запись.

## Отклонения

1. Первый запуск render без префикса драйвера — отказ формы вызова, сохранён как receipt, повтор с новым именем и каталогом.
2. Чек-лист: `|=` в ячейке таблицы записан как `` `\|=` `` (ревью Codex), иначе строка распадалась на 5 столбцов.

## Открыто

- Реализация M5 (ASSIGN-KNOWN-OPERATOR, COMPOUND-ASSIGN-AND-POWER): уточнения пункта M5.1 — у Codex перед кодом; срез
  `:=`/`merge` по to_fable.md — следующий.
