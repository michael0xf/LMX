# LMX: продолжение работы Opus — инструкция Fable

Написал Opus 2026-11-07 ~17:45Z по указанию автора: «остановись и напиши инструкцию to_fable.md по продолжению
работы». Эта версия заменяет прежний текст файла целиком; поручение 2026-11-01 о редизайне — история Git.

## Владение

- Opus остановлен 2026-11-07 17:43Z: фоновых задач нет, процессов pipeline (`l2trans`, `l1trans`, `cc1`, `gcc`,
  `lmxtool`, `lmxtool-tool`) нет (проверка 17:43Z), свободно ~7.7 ГиБ физической памяти. Opus больше не пишет и не строит.
- Fable — единственный writer/build/docs LMX с момента принятия этой инструкции; сообщи Codex о принятии (ID
  `FABLE-ACCEPT-<UTC>`). Codex — консультант через lmx_uds: сам не кодит и сборок не запускает; все технические,
  нормативные и организационные вопросы — ему, не автору. В каждый момент один writer/build и один pipeline
  compiler/test/docs.
- Законченный проверенный срез — commit/push в main без ACK, только по точному allowlist. Периодических отчётов не
  нужно; статус автору — короткие строки по-русски.

## Читать сначала (по порядку)

1. `AGENTS.md`, `READ.ME`.
2. `steps/current.md`: датированные абзацы 2026-11-07 (строки 13–58) — действующие поручения; ниже — записи срезов
   286–301 (образец объёма записи среза).
3. `LMX_blog/2026-11-07.md` — дословные слова автора.
4. `steps/witnesses/fix302-20261107/notes.md` — проект среза 302, карта строковых путей до среза, устройство, сборки
   кандидата, отклонения, открытое.
5. `steps/witnesses/named-assign-20261107/notes.md` — проба `:=`/`merge` на кортеже 301, места в коде, документация.
6. `steps/witnesses/fix301-20261107/notes.md` — полный образец среза: рецепты, мутанты, приёмка, посадка, docs, архив.
7. `steps/defects.md` — NAMED-BINDING-BY-HEAD, ASSIGN-KNOWN-OPERATOR, MERGE-OPERAND-FORMS,
   CALL-WHOLE-ARGUMENTS-STRUCTURE, CALL-ARGUMENT-ORDER-AXBY, REPEATED-DECL-*.

## Действующие поручения (кратко; норма — current.md и журнал)

1. **IDENTIFIER-CODES** (автор, CODEX-OPUS-AUTHOR-COMPLETE-ALL-ID-PATHS-20261107-01): каждый идентификатор — код своего
   написания, новое написание — следующий номер (без хеша), таблиц «код → имя» и «имя → код» ровно две, обе
   информационные; ни native, ни обходчик, ни семантические проходы frontend не сравнивают имена строками; загрузка
   единицы — явная граница нормализации; один сервис процесса `lmx_ids`; copy/merge/attach переносят коды. Довести до
   конца во всех путях; подтверждения автора не ждать; промежуточный срез задачу не закрывает. Итог — один RESULT Codex:
   граница изменения, кортеж и manifest, receipts, карта потребителей и удалённых строковых путей; доказательство, что
   одно написание из разных единиц — один код при любом порядке ввода; тесты: одно написание в разных областях,
   единицах и аренах, разные написания, затенение тем же кодом, копия в другую арену без текста, узнавание
   скопированной головы. В том же переходе — AXBY и ранняя проверка имён и формы (CALL-ARGUMENT-ORDER-AXBY).
2. **`:=` и пример с `merge`** (автор, CODEX-OPUS-AUTHOR-FINISH-ASSIGN-MERGE-NATIVE-WALKER-20261107-01 и уточнения того
   же дня): приёмка — `steps/current.md` строки 29–58 (дословно перечислено: запись известного места, отказ неизвестной
   левой части, ссылка на метод, `mytest(a := 5)`, `mytest(a := a(5))`, `mytest(merge(mytest\args; (a: int: 5)))` = 35,
   та же Structure через переменную, регрессия NAMED-BINDING-BY-HEAD: `mytest(a(5))` и `mytest(a: 5)` вызывают `a` ровно
   один раз и подают результат позиционно; `:=` — общий оператор с узкой функцией, его проверки и вне вызовов;
   прежние формы остаются; перенос одной формы `:=` в контекст без известного места — отказ без нового поля).
3. **Узкая пауза**: только исправление поведения повторного объявления (REPEATED-DECL-*) ждёт упрощения автора; новых
   правил смены или сохранения типа не вводить; многократные типизированные записи известного места допустимы.

Порядок: закончить срез 302 (промежуточный срез IDENTIFIER-CODES), затем срез `:=`/`merge`, затем остаток
IDENTIFIER-CODES и итоговый RESULT.

## Состояние на 2026-11-07 17:43Z

- `HEAD` = `origin/main` = `e85a3861`. P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01` (не в git).
- WIP среза 302 — только рабочая копия и стейдж, не закоммичен. 14 изменённых путей `selfbuild/` (кандидат a07,
  список `P/pins/tp164-changed-a07.list`, хэши `P/pins/tp164-changed-a07.sha256`): `inputs.list` (238 входов, +
  `src/l2src/lmx_ids.lm2`), ядро `lmx_ids.lm2` (новый, untracked), `lmx_source_names`, `lmx_call`, `lmx_walk_values`,
  `lmx_implements`, `lmx_graph_copy_owned`, драйвер `l2_driver`, frontend `l2_frontend_values`, `_emit`, `_core`,
  `_lower`, `tools/build.lm2`, фикстура `tests/dyn/free_c_pointer.lm2`. Запись — `steps/witnesses/fix302-20261107/notes.md`
  (untracked).
- В коммиты не включать: `to_codex.md` (чужой dirty); `steps/witnesses/fix249-20261101/notes.md` и
  `steps/witnesses/fix250-20261101/` (прежний WIP Opus, держать отдельно); прочие untracked witnesses из `git status`
  на старте сессии. Этот файл — по решению автора/Codex.
- Стейдж `P/cold-tp140` = кандидат a07, **кроме мутанта m1**: в `cold-tp140/src/l2src/lmx_ids.lm2`, строка 124,
  `if: r = 0 && nb = 0U` (в a07 — `if: r = 0`). Вариант `P/variants/tp164` — байты a07 всех 14 путей; manifest стейджа
  `P/pins/source-tp164-a07.sha256` (238 входов). Сборка rt164m1 перегенерировала заголовки стейджа
  (`src/l2src/lmx_ids.h.lm1` `44f17b95…`, `lmx_source_names.h.lm1` `623625c6…`, `lmx_walk_values.h.lm1` `e755f33b…`) —
  те же байты, что у rt164b.
- Кортеж кандидата: tool `cold-tp140/tool164a/lmxtool-tool.exe` `059c4603626ffe9c37ce66f7d068206e282463a1857aeb49494b6cde0ec14796`
  (из a01; `tools/build.lm2` не менялся до a07); runtime `cold-tp140/rt164b` — driver.o
  `f5eaed6ff0c8ccfdd27a3198f3e9c7ff70a7743751a311f0809a26b674eba8d8`, driver-observe.o
  `4e3fc11a68706feab90af250a594212451abaff260a76921ce7c81c13560ada6` (ядро a03 = a07); frontend
  `cold-tp140/fe164d/l2trans.exe` `b5d87c158a643f4496c064ea2e3079b36a661b981b4e5d08a26b3dcd175842e3` (a06 = a07 по
  frontend). История сборок и отказов — таблица «Сборки кандидата» в записи.
- Результаты (receipts в `P/pins`):
  - фокус f302a (`f302a.tsv`, 21 ряд реестра по путям имён): 21/0 — `tp151-probe-f302a.log`;
  - весь реестр r302a (`registry302-a.tsv` = байты `selfbuild/tests/full-suite.tsv`): 113 рядов, 2 отказа — только
    `free_c_pointer`, оба режима, ошибка gcc: фикстура звала C-дверью `lmx_walk_value_field_place` прежней сигнатуры
    (6 аргументов, `char *` селектора; теперь код имени и ещё два аргумента) — `tp151-probe-r302a.log`. В a07 `door_text`
    переведён на `const char *` у `lmx_ids_code` (длина 0 → 0 без чтения указателя); ряд на a07 — f302b 1/0
    (`f302b.tsv`, `tp151-probe-f302b.log`). Это миграция теста из-за сигнатуры ядра, не ошибка именованного связывания —
    так и записать;
  - мутант m1 (rt164m1: `lmx_ids_put` не находит прежнее написание) по `mut302.tsv` (9 рядов реестра: строки 12 56 100
    103 115 119 120 138 165): 36 отказов из 36 запусков — убит (`tp151-probe-m302a.log`). Отказ ли это только самопроверки
    драйвера `ids_check` или и программ — не разделено: посмотреть `P/tp151-probe/m302a/<ряд>-native/run-root0.log`
    одного ряда.
- Пункт «Открыто» записи о голове ссылки любой глубины устарел: в a07 `receiving_reference_head` читает метку кода
  `lmx_ids_reference` (её ставит `lmx_ids_put` на границе ввода написания) — поправить запись.

## Срез 302: что осталось (по порядку)

0. **Вернуть стейдж из m1.** Записать инструментом Write `P/pins/mut302-restore.tsv` (две строки через табуляцию, по
   образцу `steps/witnesses/fix301-20261107/records/pins/mut301-restore.tsv`):
   `stage-copy	P/pins/tp164-changed-a07.sha256	P/variants/tp164	P/cold-tp140` и
   `verify	P/pins/source-tp164-a07.sha256	P/cold-tp140` (P — полный путь); запуск `lmxtool steps` рабочего tool boot163a
   (`P/cold-boot163a/quick163a/lmxtool.exe 0 entry 0 -- steps <список> > <лог> 2>&1`) из нового каталога запуска;
   ждать `VERIFIED 238 files, 0 failed`.
1. **Мутанты m2–m4** (каждый: Edit файла стейджа; сборка отдельным сообщением — runtime `P/pins/tp164-rt.command` с
   `TP_LABEL=rt164mN TP_TRY=mN` или frontend `P/pins/tp164-fe.command` с `TP_LABEL=fe164mN TP_TRY=mN`; ряды `mut302.tsv`
   рецептом `P/pins/tp151-probe.command` с `TP_TOOL=cold-tp140/tool164a/lmxtool-tool.exe`, `TP_FE`, `TP_RT` на
   мутантную сборку; затем возврат шагом 0):
   - m2 — `lmx_graph_copy_owned.lm2`, `lmx_copy_name_prepare`: имя вхождения (порт 0) копируется кодом `0U` вместо
     `c.lmx_source_name_get(src_arena, source)` — копия теряет имя;
   - m3 — `lmx_walk_values.lm2`, `lmx_walk_table_cells`: прежнее условие 301 `if: \tokens = 0` вместо
     `if: \tokens = 0 && place_map[0][1] != (cast: (size_t) -1)` — таблица именованного режима снова требует токенов;
   - m4 — `l2_frontend_values.lm2`, `lm_compiler_path_selector_parts`: `selected[0]: v` → `selected[0]: (cast: (size_t) -1)`
     — записанное `[N]` теряется в обоих исполнителях.
   Выживший мутант — пробел реестра: добавить фикстуру, которая его убивает (RESULT всё равно требует тестов «копия в
   другую арену без текста» и «узнавание скопированной головы»).
2. **Whole bootstrap boot164a quick.** Рецепты `P/pins/boot164-quick.command` и `boot164-detached.command` написать
   вручную по `boot163-quick.command`/`boot163-detached.command`: **G0 — tool164a** (`059c4603…`: `tools/build.lm2`
   изменён срезом, рабочий tool boot163a не годится), предыдущий frontend — G2 boot163a
   (`cold-boot163a/quick163a/g2/frontend`: l2trans `57ad3f2e8a05b4262c6a690c5e7dc4751611d5a486c77801d6c4d8390da69ffb`,
   l1trans `85b0c8c4cc29f2d802f99ec6f6dbc52c78afa6668dc642dcf2abaddf3105ac6d`, l2_libc `af9fdae3…`), база
   `cold-candidate48/full48/g2/frontend` (хэши — как в boot163-quick), smoke `tests/smoke-kernel225.tsv`. Стейдж
   `cold-boot164a` — список `boot164a-prepare.tsv` по `boot163a-prepare.tsv` с `source-tp164-a07.sha256`. Детачированный
   запуск — через pwsh 7 (у 301 запуск из Windows PowerShell 5.1 дал BOM в терминале — отклонение 1 записи 301).
3. **Приёмка**: `boot164a-check.tsv` по `boot163a-check.tsv` (38 команд `lmxtool checks`): стейдж против manifest,
   записи producers G1/G2 замкнуты, G1 против G2 (`exe-same`/`same`), рабочий tool и bundle = G2, rt164b = G2 runtime
   байт в байт, fe164d = G2 frontend по `exe-same`. Самотест G2 tool — `P/pins/tp152-selftest.command`.
4. **Посадка**: `land302.tsv` по `land301.tsv` (вариант `tp164`, 238 входов, `selfbuild/inputs.sha256`).
5. **Docs** (часть IDENTIFIER-CODES): по находке Codex книга `provenance/semantics-book.md` (RU ~:100, :683, :685; EN
   ~:518) всё ещё говорит, что обходчик узнаёт голову по таблице имён, — исправить на коды; описать границу загрузки
   единицы и сервис `lmx_ids` там, где документы описывают имена; затем `docs render/verify semantics` и `docs check`
   (PRIVATE_OUT создать заранее; staged allowlist; копии с CR — удалить по точному списку и `git checkout-index --stdin`).
6. **Записи и коммит**: дописать `fix302-20261107/notes.md` (результаты, мутанты, приёмка, посадка, кортеж); `records/` —
   копии рецептов, списков, логов, терминалов и цитируемых сообщений Codex (`P/pins/codex-302-*.txt`, в том числе ещё
   нигде не архивированные: `codex-302-named-assign-docs-review-complete.txt`, `opus-codex-302-named-assign-published.txt`,
   `codex-302-author-finish-assign-merge.txt`, `codex-302-author-assign-general-known.txt`,
   `codex-302-author-assign-preserve.txt`, `codex-302-author-repeated-typed-intent.txt`, `codex-302-author-assign-narrow.txt`;
   `codex-302-ids-home-scope-answer.txt`), `evidence.sha256`; абзац среза 302 в `steps/current.md` (промежуточный срез:
   IDENTIFIER-CODES не закончен); `steps/defects.md`; commit/push по allowlist; сообщение Codex — промежуточный результат,
   не RESULT.

## После 302: срез `:=` и `merge`

Места, найденные пробой (номера строк — рабочей копии a07, могли сдвинуться):
- P0 `selfbuild/src/l2src/p0_parser.lm2`: скан головы останавливается на `:` (около :2144 и :2501) и делает COLON Frame
  (около :2522–2531), поэтому `a:=5` сейчас — голова `a:` с телом `=5`. По грамматике §21 (`provenance/grammar.json`)
  `:=` — один операторный токен: левая часть, `:=`, правая часть; `a := 5` и `a:=5` — одна запись.
- Связыватель трансляции `lm_compiler_bind_value_actuals_into` (`l2_frontend_lower.lm2` :880–960): именование по
  совпадению головы Frame с формалом (:901–923) — это NAMED-BINDING-BY-HEAD; убрать механизм, не обходить условием;
  именованная подача — только `a := value`.
- Обходчик — `lmx_callable_bind_prefix` (`lmx_implements.lm2`), native — `lmx_call_bind_actuals` (`lmx_call.lm2`); оба
  должны дать одно соответствие.
- Операнды `merge`: `lm_compiler_merge_value_refusal` и `lm_compiler_merge_decl_operand` (lower),
  `lm_compiler_merge_operand_node` (emit): формы `f\args`, `a: int: 5`, `(a: int: 5)` сейчас «not lowered yet».
- Вся структура аргументов одной Structure (результат `merge` и переменная) — CALL-WHOLE-ARGUMENTS-STRUCTURE.
- Фикстуры пробы `p302n_*` — в `P/cold-tp140/tests/dyn` (копии в
  `steps/witnesses/named-assign-20261107/records/cold-tp140/tests/dyn`): d1/d2 сейчас 35 и ни одного вызова `a` (должно
  стать 62 и один вызов), b/b2/c/c2 — отказ «tst has no argument a» (норма 35), m*/e* — «not lowered yet».
- Имя `test` — слово языка (ресивер `test:`): программы автора с `test` пишутся как `mytest`/`tst`.
- Неразрешённый общий случай — производитель всей структуры аргументов с эффектами и ранняя проверка имён/формы — вопрос
  Codex с первоисточником; остальное продолжать.

## Затем остаток IDENTIFIER-CODES

- Внутренние сравнения frontend по кодам: P0, области видимости, resolve, intern сигнатур, ключи бросков.
- Транслятор L1 (backend) — тот же переход.
- AXBY и ранняя проверка имён и формы до эффектов аргументов (в том числе через изменяемое место callable).
- Итоговый RESULT по списку раздела «Действующие поручения», п. 1.

## Правила и ловушки практики

- Корневой `C:/Nyasha_Planet/LMX/build` не читать, не перечислять, не трогать. Basename `l2_driver_launch.err` нигде не
  читать, не перечислять, не хешировать, не копировать, не стейджить (и в выводе команд не печатать).
  `steps/witnesses/used-scope-20261020/reference-producer117.patch` — непрочитанным и неизменённым.
- Только точные пути, manifests и явные git pathspec: без `git status` без путей, без листингов каталогов и
  рекурсивного поиска по стейджу и каталогам запусков (логи ряда — по известным именам: `p.L2.log`, `p.L1.log`,
  `p.CC.log`, `run-root{0,1}.log`). После коммита — только `git status --porcelain -uno -- <точные файлы>`.
- Без reset/clean/массового add, новых веток/worktree/PR. Frozen inputs и исторические receipts не переписывать.
- Правки исходников — вручную (Edit/Write); рецепты и списки — руками (Write или `printf`/одна команда `sed -n` по
  точным строкам), без циклов и скриптов-генераторов, без новых проб и тестовых систем; только существующий pipeline
  языка (`lmxtool steps/checks/suite/rebuild/build-runtime/build-frontend/bootstrap/docs`), каждый запуск — из своего
  нового каталога.
- Запуск рецептов `.command`: pwsh 7 по полному пути
  `/c/Users/mtkra/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe` (в PATH bash его
  нет) формой `"$PW" -NoProfile -Command "& ([ScriptBlock]::Create([IO.File]::ReadAllText('<рецепт>')))"`; `-File`
  принимает только `.ps1`. Параметры — переменные окружения (`TP_LABEL`, `TP_TRY`, `TP_LIST`, `TP_TOOL`, `TP_FE`,
  `TP_RT`). Один рецепт на фоновую команду; правку и сборку, которая её читает, не класть в одно параллельное сообщение;
  сборка runtime перегенерирует заголовки стейджа — не запускать suite одновременно с ней. Рецепты сами проверяют
  свободную память и живой pipeline.
- После мутанта — всегда возврат стейджа из варианта и verify.
- Ловушки L2 этого среза: слова языка (`length`, `test`, `table` и др.) нельзя связывать; спуск уровня P0 больше чем на
  шаг — только через `---`; поле локальной структуры по значению (`t\length`) в аргументе C-вызова распадается в C на
  `t, ., length` — передавать отдельной переменной; новые функции машинного модуля — в конец модуля (нумерация
  параметров заголовка), экспорт — в список имён `tools/build.lm2`; изменение прототипа ядра требует пересборки
  заголовков (build-runtime).
- `LMX_blog/` — только дословные технические ответы автора (дата и источник вне цитаты, выдержки помечены,
  организационное исключено); правила цитат — `READ.ME`.
- Коммиты — с атрибуцией своей модели; identity репозитория общая.

## Связь с Codex

- Через существующий мост lmx_uds (свежий ListAgents перед отправкой). Сообщение — файлом:
  `python claude_chat/codex_inbound.py send --sender <своё имя> --request-id <ID> < "<файл>"` из
  `C:/Nyasha_Planet/LMX`; JSON доставки — не ответ Codex. Ответ Codex сверять с транскриптом relay
  (`~/.claude/projects/C--Nyasha-Planet-LMX/ff11f4c5-75c5-499f-a9c2-7d5b4fc7efea.jsonl`, первое вхождение
  `REQUEST_ID: <ID>`) и архивировать дословно в `P/pins` (инструмент Write срезает хвостовые пробелы — проверить).
- Большие ревью — через Codex, не своими агентами. Вывод Codex не выдавать за дословное решение автора (пример —
  поправка атрибуции CODEX-OPUS-REDECL-TYPE-PROVENANCE-CORRECTION-20261107-01 в записи 302). OPEN-статусы дефектов
  менять только по реальным результатам.
