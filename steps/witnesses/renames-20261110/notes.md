# Переименования `getType` → `typeof`, `sendMessage` → `send`, `receiveMessage` → `receive` — 2026-11-10

Исполнитель: fable. Поручение автора 2026-11-10 ([журнал](../../../LMX_blog/2026-11-10.md#renames)): переименовать в
документах и в коде. Меняются написанные слова ресиверов; их смысл, аргументы и коды типов прежние.

## Что переименовано

1. **`typeof`** — слово ресивера чистого графа (`src/l2src/lmx_graph.lm2`: слово состояния `w_typeof`, список слов
   языка; шаблон `LmxGraphState` в `tools/build.lm2`; интерпретатор и эмиттер читают то же слово). Фикстуры
   `tests/graph/typeof.lm2`, `typeof.expected`, `typeof_value.lm2` (прежде `get_type*`) и фикстуры `struct_index*`.
   Прежний путь понижения ресивера не знал и не знает.
2. **`send` и `receive`** — слова почты рабочего frontend (`l2_frontend_helpers.lm2`: `lm_compiler_receiver_word`,
   `lm_compiler_receive_msg_shape`; `l2_frontend_emit.lm2` — семь мест; `l2_frontend_lower.lm2` — два), сообщения
   транслятора и выпускаемого кода (`receive binds one or two names`, `lmx: invariant: send failed`), список слов
   чистого графа, комментарии шаблонов ядра в `tools/build.lm2`, все исходные тексты `selfbuild` — инструменты
   (`receive: m` … `send: exit(...)`) и тесты: 170 файлов `.lm2`, 218 строк (13 файлов и 53 строки в `src` и
   `tools`, 157 файлов и 165 строк в `tests`). Индекс коммита сверен с manifest `fable-source11`: все 412 входов
   совпали по sha256.
3. **Документы:** книга (ресивер `typeof`, слова почты), спецификация реализации, `CORE.md`, инструкция разработчика,
   `docs/new_parts/threadMessageAPI*.md` и `mutating_debug_API*.md`, план (разделы M6 и 8a), чек-лист. Якоря
   документов (`#get-type`) и имена записей прежних срезов не менялись; прежние имена названы там, где документ
   говорит о «старых» операциях.

Не переименованы и не читаются сборкой: унаследованные деревья `dev/`, `l2src/`, корневой `tools/`, исторические
записи `steps/`.

## Два хода самосборки

Транслятор читает собственные исходники, а инструменты начинаются с `receiveMessage: m` и кончаются
`sendMessage: exit(...)`. Frontend, который знает только прежние слова, не переведёт исходники с новыми; frontend,
который знает только новые, нечем собрать из исходников с прежними.

- **Ход A** (коммит `eba21575`): frontend принимает оба написания, исходники пишут прежние слова; `typeof` — сразу.
- **Ход B** (этот коммит): исходники и документы пишут `send` и `receive`, frontend знает только их. Первое
  поколение собирает frontend хода A.

## Кортеж и проверки

Каталог `P` — `build2/codex_fix250generationchain01`; все команды инструмента — из `P/runs/fable-m6-01`; стадия —
`P/fable-main01`.

- **Ход A.** Manifest `fable-source09`; `tool-f06` `434740cd…` (шаблон `w_typeof`), `rt-f05` — `driver.o`
  `d325eb0b…`, `graph-f05`. graph-check, список `fable-graph-check-f06.tsv`: `CHECKS 88 lines, 0 failed`, 264 PASS в
  режимах interp, native и forced. `bootstrap quick` `boot-f05` (frontend `boot-f04`): `BOOTSTRAP quick 0 failures`,
  19:29:08Z–19:41:33Z; runtime G1 = G2 = `rt-f05`; frontend и инструмент G1 и G2 — один образ, кроме штампа линковки.
- **Ход B.** Manifest `fable-source10` — от `fable-source09` отличаются 170 файлов; для набора тестов —
  `fable-source11`: он отличается одной строкой списка `tests/full-suite.tsv`, где сообщение для
  `os_implements_refused` называет столбец 23 вместо 30, потому что слово в той же строке стало короче.
  `bootstrap quick` `boot-f06` (инструмент `boot-f05/lmxtool.exe` `724d9596…`, frontend `boot-f05/g2` `5d0569a5…`):
  `BOOTSTRAP quick 0 failures`, 19:45:10Z–19:57:25Z; runtime G1 = G2 = `rt-f06` (`56b73642…`); `l1trans` и инструмент
  G1 и G2 — один образ, кроме штампа линковки. Frontend `l2trans.exe` G1 и G2 различаются (`exe-same` 0): G1 выпущен
  frontend хода A, а тот вписывает в выпускаемый код прежнее сообщение. Выпущенный L1 hosted frontend двух поколений
  отличается тремя строками — комментарием шаблона и двумя сообщениями `lmx: invariant: sendMessage failed` /
  `lmx: invariant: send failed`. Третье поколение этот срез не собирал: совпадение G2 = G3 покажет следующий
  bootstrap, который пойдёт от `boot-f06/g2`.
- **graph-check после хода B** (инструмент `boot-f06/lmxtool.exe` `19990ab9…`, `rt-f06`, `graph-f06`, список
  `fable-graph-check-f07.tsv`): `CHECKS 88 lines, 0 failed`, 264 PASS.
- **Полный набор** `tests/full-suite.tsv` (frontend `boot-f06/g2` `df27fecf…`, runtime `rt-f06`):
  `SUITE 139 rows, 0 failures`, 1102 PASS, 20:00:36Z–20:17:17Z.
- **Документы:** перегенерация книги и `docs check` на индексе — метка `docs110-fable01`, выход 0.

## Не сделано

- Прежние слова `sendMessage`, `receiveMessage` и `getType` транслятор не отвергает особым сообщением: теперь это
  обычные неизвестные имена.
- Объявление `typeof` в прежнем пути понижения — вместе с остальными дополнениями раздела M6 плана.

## Записи

[records.sha256](records.sha256): sha256 исходного файла, sha256 копии и путь копии. Копии в `records/` приведены к LF.

- `records/pins/` — manifest исходников обоих ходов и списки graph-check;
- `records/runs/` — терминалы и выводы сборок, проверок, bootstrap, сравнения поколений и полного набора тестов.
