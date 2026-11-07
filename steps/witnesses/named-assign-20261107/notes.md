# Именованная подача, `merge` аргументов и оператор `:=` — проба на кортеже 301 и документация

Opus, 2026-11-07. Поручения автора через Codex: проверить, что `test(merge(test\args; a: int: 5))` уже работает (п. 2
сообщения CODEX-OPUS-AUTHOR-NAMED-MERGE-ASSIGN-DISCUSS-20261107-01), проверить сам `merge` того примера
(CODEX-OPUS-MERGE-ARGS-ISOLATE-PROBE-20261107-01), проверить форму автора со скобками и внести оператор `:=` и пример с
`merge` в документацию (CODEX-OPUS-AUTHOR-DOCUMENT-ASSIGN-MERGE-PARENS-20261107-01). Различители по находке Codex
(CODEX-OPUS-NAMED-COLLISION-SOURCE-20261107-01), уточнение автора об именованном связывании
(CODEX-OPUS-AUTHOR-NO-COLON-NAMED-BINDING-20261107-01), контроль второго операнда над обычной Structure
(CODEX-OPUS-MERGE-PARENS-BASELINE-REVIEW-20261107-01), ревью Codex итога пробы
(CODEX-OPUS-302-BASELINE-REVIEW-DOCS-20261107-01) и формулировок книги (CODEX-OPUS-302-DOCS-WORDING-REVIEW-20261107-01).
Дословные копии сообщений — [records/pins](records/pins); реплики автора — [журнал](../../../LMX_blog/2026-11-07.md),
раздел «Именованная подача аргументов, `merge` и оператор `:=`». Ничего из результатов пробы не объявлено нормой;
новой семантики в пробе нет; незавершённый WIP среза 302 (IDENTIFIER-CODES) не собирался и не участвовал.

## Кортеж и стейдж

P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`. Опубликованный кортеж 301: tool
`cold-boot163a/quick163a/lmxtool.exe` `3ac5c8ba04bec58fa1d8a1cae9c3caf877b94266cdf93ed48f5a962487aaae05`, G2 l2trans
`cold-boot163a/quick163a/g2/frontend/l2trans.exe` `57ad3f2e8a05b4262c6a690c5e7dc4751611d5a486c77801d6c4d8390da69ffb`,
runtime `cold-boot163a/quick163a/g2/runtime`: driver.o `a9365005ae61bf456d251217be4314d9d49612a0ea826642d5153698bd5cf03a`,
driver-observe.o `ed5378825f4ea1f1e09ea8e4ea681c49759e69fec25511b911d3ee83cf4f4a8a` (байты rt163a). Рабочий стейдж
`cold-tp140`: `verify` tool boot163a против `source-tp163-a01.sha256` (manifest 301, 237 входов) — `VERIFIED 237 files, 0
failed` ([лог](records/pins/p302n-verify.log)); сгенерированный `lmx_walk_values.h.lm1` — `43583c82…`, как у rt163a.

Рецепт — прежний [tp151-probe](../fix291-20261106/records/pins/tp151-probe.command) (`9c8ae90a…`, не менялся): `lmxtool
suite` по списку рядов, режимы n и f, корни 0 и 1, с TP_TOOL/TP_FE/TP_RT на этот кортеж; запуск pwsh 7.6.5.

## Программы

Написаны инструментом Write в `cold-tp140/tests/dyn` ([копии](records/cold-tp140/tests/dyn)). Вызываемое — `tst (int:
c 3; int: a) int`, тело `c * 10 + a`: у `c` записанное умолчание, чтобы незаполненный `c` не скрывал вопрос. Имя автора
`test` — слово языка (ресивер `test:`), программа его не связывает; текст автора с `test` сохранён рядом `refuses`
p302n_t_word. В d1/d2 — `tst (int: c 3; int: a 2) int` и видимый callable `a (int: n) int` = n + 1 со счётчиком вызовов
(выход — значение + 100 × вызовы); e/f — обычная Structure `Args (int: c 3; int: a 0)`.

| Программа | Что проверяет | SHA-256 |
| --- | --- | --- |
| p302n_t_word | текст автора: `fn: test`, `test(merge(test\args; a: int: 5))` | `232a69a7…` |
| p302n_a_positional | контроль: `tst(4, 5)` = 45, `tst(a: 5)` = 35 без callable `a` | `29055ac2…` |
| p302n_m_merge | `merge(tst\args; a: int: 5)` отдельно: `a` = 5, `c` = 3 | `c902e179…` |
| p302n_m2_merge_source | то же и исходный `tst\args` не записан | `a7ba5ed5…` |
| p302n_m3_merge_parens | `merge(tst\args; (a: int: 5))` отдельно | `50db0533…` |
| p302n_m4_parens_source | то же и исходный `tst\args` не записан | `49be1335…` |
| p302n_b_inline | `tst(merge(tst\args; a: int: 5))` = 35 | `0d949a04…` |
| p302n_b2_inline_parens | `tst(merge(tst\args; (a: int: 5)))` = 35 | `df01c5a8…` |
| p302n_c_variable | `pack: merge(tst\args; a: int: 5)`, затем `tst(pack)` | `f14587e7…` |
| p302n_c2_variable_parens | то же с `(a: int: 5)` | `2f4607ff…` |
| p302n_d1_colon_callable | `tst(a: 5)` при видимом callable `a` | `9c048e11…` |
| p302n_d2_call_callable | `tst(a(5))` при видимом callable `a` | `121b99f3…` |
| p302n_e_merge_struct | `merge(Args; a: int: 5)` | `8cd7827a…` |
| p302n_e2_merge_struct_parens | `merge(Args; (a: int: 5))` | `031910b6…` |
| p302n_f_merge_decl_parens | контроль `merge(Args; (int: a 5))` | `44ffe0d8…` |
| p302n_f2_merge_decl | контроль `merge(Args; int: a 5)` | `bb20e557…` |

## Запуски и результаты

Списки: [p302n](records/pins/p302n.tsv) `89b7aa08…`, [p302n-2](records/pins/p302n-2.tsv) `2dd69433…`,
[p302n-3](records/pins/p302n-3.tsv) `1f547889…`, [p302n-4](records/pins/p302n-4.tsv) `9b56632e…`. Логи `suite` и
терминалы — [records/pins](records/pins) (`tp151-probe-p302n-0N.log`, `.terminal.txt`); логи рядов —
[records/tp151-probe](records/tp151-probe) (`p.L2.log` транслятора, `run-root{0,1}.log` запусков). Native и обходчик
одинаковы во всех рядах, корни 0 и 1 одинаковы.

| Запуск | Ряды | Итог |
| --- | --- | --- |
| p302n-01, 15:31:06.94Z | 11 рядов первой версии с именем `test` | все 22 трансляции: «test is a word of the language: a program cannot bind it» на строке `fn: test` |
| p302n-02, 15:33:58.78Z | t_word | refuses: отказ, needle, нет L1 — PASS в обоих режимах |
| | a_positional | 7 во всех 4 запусках: `tst(4, 5)` = 45, `tst(a: 5)` = 35 |
| | m, m2, m3, m4 | трансляция: «this merge operand form is not lowered yet», detail `atom=tst`, столбец 17 — первый операнд `tst\args`; до второго операнда и до исполнения не доходит |
| | b, b2 | трансляция: «tst has no argument a» (12:18, `frame=tst`) — binder кладёт весь Frame `merge` в позицию `c`; раньше опускания операндов |
| | c, c2 | тот же отказ на строке `tst(pack)` (12:18 и 13:18), раньше отказа операнда строкой выше: `pack` — один позиционный аргумент |
| | d1, d2 | выход 35 во всех 8 запусках: формал `a` = 5, `c` = 3, callable `a` не вызван (счётчик 0); прямой контроль `a(5)` после — 6 и +1 вызов |
| p302n-03, 15:35:08.93Z | e, e2 | трансляция: «this merge operand form is not lowered yet», столбец 23 — сам второй операнд (`frame=a` у `a: int: 5`, без detail у `(a: int: 5)`) |
| p302n-04, 15:36:06.59Z | f, f2 | 7 во всех 4 запусках каждого: `pack\a` = 5, `pack\c` = 3, `Args\a` = 0, `Args\c` = 3 |

Выводы, не нормы: `merge` сам исправен для формы объявления поля над обычной Structure; авторские вторые операнды
`a: int: 5` и `(a: int: 5)` и первый `tst\args` трансляция не опускает, поэтому исполнением на 301 нельзя сказать, нужны
ли скобки; приёма единственной Structure как всей структуры аргументов нет; совпадение головы с именем формала поглощает
и `a: 5`, и явный `a(5)` как именование. Места: операнды — общий `lm_compiler_merge_value_refusal`
(l2_frontend_lower.lm2:16981–16985) из классификации операнда (`lm_compiler_merge_operand_node`,
l2_frontend_emit.lm2:15040–15058, или `lm_compiler_merge_decl_operand`, l2_frontend_lower.lm2:16987–17025; позиция —
операнд, не объявление); binder — `lm_compiler_bind_value_actuals_into`, l2_frontend_lower.lm2:925–954; именование —
там же, :901–923. Дефекты: NAMED-BINDING-BY-HEAD, ASSIGN-KNOWN-OPERATOR, MERGE-OPERAND-FORMS,
CALL-WHOLE-ARGUMENTS-STRUCTURE ([реестр](../../defects.md)).

## Документация

- [Журнал](../../../LMX_blog/2026-11-07.md): четыре сообщения автора дословно, с пометками цитат Codex; пояснения Codex
  отдельно. Просьба автора «и надо проверить что merge в том примере работает» — поручение проверки, не уточнение языка;
  она выполнена этой пробой и в журнал не внесена.
- Книга `provenance/semantics-book.md` (RU и EN) и сгенерированные `docs/LMX_semantics.ru.md`, `.en.md`: в главе
  построения — подраздел `assign-known` «Запись в известное место: `:=`»; в главе вызываемых — абзац `named-actuals`
  (именованная подача `a := value`; `a: 5` и `a(5)` ею не являются), абзац `whole-arguments` (результат `merge` как вся
  структура аргументов, пример автора с `mytest`, норма 35 отдельно от нынешнего отказа 301 со ссылкой на границы
  реализации и эту запись); примеры `f(x := touch())` и `y := 25` вместо прежних `x:` и `y:`.
- Грамматика `provenance/grammar.json` и сгенерированные `docs/LMX_grammar.ru.md`, `.en.md`: в разделе операторов —
  токен `:=` (P0 не делит его на `:` и `=` и не делает `a:` головой Frame; приоритет и ассоциативность не определены); в
  разделе 18 — снятие оболочки касается записанной анонимной Structure, приём вычисленной — семантика.
- `docs/implementation-notes.ru.md`, `.en.md`: подраздел 4.2 — принятое правило и открытая реализация, исполненный
  контроль `merge` отдельно.
- `steps/defects.md` — четыре записи OPEN; `steps/current.md` — абзац о решении.

Не определено решением и в книге названо так: приоритет и ассоциативность `:=`, значение записи как выражения, снятие
уровней `@`, ранняя проверка имён и формы для вычисленной структуры аргументов.

## Вопросы к Codex и ответы

Ответы — CODEX-OPUS-NAMED-ASSIGN-NOTE-ANSWERS-20261107-01 ([копия](records/pins/codex-302-named-assign-note-answers.txt);
в доставленной копии сообщения цитата автора получила лишнюю букву, поправка — CODEX-OPUS-NOTE-ANSWERS-QUOTE-FIX-20261107-01,
[копия](records/pins/codex-302-note-answers-quote-fix.txt); архивный текст взят из транскрипта relay, где цитата верна).

1. Глава композиции книги уже содержит `merge(y: int: 5; add\body)`, где `y: int: 5` без скобок «становится полем
   результата композиции этого тела» (пример из руководства). Ответ: автор пишет «кажется надо», общего запрета формы без
   скобок нет; документируется его явная форма `(a: int: 5)` с границей реализации; прежний пример не удаляется, предел
   опускания нормой не становится; приём операндов самим ресивером `merge` отличается от поглощения `a(5)` связывателем
   формалов.
2. Структура в переменной (`tst(pack)`). Ответ: правило общее — вызов с одной Structure не отличается от вызова с
   цепочкой аргументов, в том числе для той же Structure в переменной; это открытая реализация общей нормы, а не новый
   выбор автора; скрытых операций и вызова голого атома из этого не следует. Первая фраза абзаца `whole-arguments`
   книги уже это говорит; запись дефекта обобщена.
3. Ранняя проверка имён и формы при производителе всей структуры аргументов с эффектами. Ответ: не установлена; явная
   неопределённость в книге остаётся; зависимое решение — только после разбора Codex или автора.

## Рендер, архив и docs check

Всё — `checks`/`steps` рабочего tool boot163a из отдельных каталогов запуска. Рендер
([docs302n-render](records/pins/docs302n-render.tsv), [лог](records/pins/docs302n-render.log)): `docs render grammar` —
27 парных разделов, 47 выдержек источника; `docs render semantics` и `docs verify semantics` — 35 парных глав, 14 случаев
implements, оба снимка источников; изменились ровно четыре сгенерированных документа. Первый проход архива
([docs302n-archive-1](records/pins/docs302n-archive-1.tsv), [лог](records/pins/docs302n-archive-1.log)): манифест 104
путей P из [records302n.list](records/pins/records302n.list), байтовые копии `stage-copy` в [records](records),
[evidence.sha256](evidence.sha256) проверен против P и против копий (104/0). Точный allowlist
([allow302n-1](records/pins/allow302n-1.list), 118 путей: 14 записаны `printf`, 104 пути копий — `sed` из списка
records) проиндексирован `git add --pathspec-from-file` при пустом индексе; индекс сверен со списком `diff`
([листинг](records/pins/index302n-1.txt)); 72 копии с CR ([список](records/pins/crlf302n-1.list), один `grep -l -U` по
списку) удалены по точному списку и записаны git из индекса с LF (`git checkout-index --stdin`); повторный подсчёт — 0.
PRIVATE_OUT создан до запуска; docs check ([список](records/pins/docs302n-check-a.tsv), [лог](records/pins/docs302n-check-a.log)):
`CHECKS 1 lines, 0 failed`, LF в индексе для всех 20756 отслеживаемых файлов. Второй проход
([docs302n-archive-2](records/pins/docs302n-archive-2.tsv)) копирует receipts первого прохода и docs check, два ответа
Codex этого шага и дополняет evidence; затем этот файл, копии второго прохода и правки после ответов Codex добавлены к
индексу вторым точным списком, docs check повторён над итоговым индексом (receipts второго прохода и повторного docs
check остаются в P: `pins/docs302n-archive-2.log`, `pins/allow302n-2.list`, `pins/crlf302n-2.list`,
`pins/docs302n-check-b.*`).

## Отклонения

1. Первый запуск рецепта не стартовал: в bash нет `pwsh` (exit 127), ничего не создано; дальше pwsh по полному пути.
2. Одиннадцать программ первой версии (имя `test`, запуск p302n-01) переписаны на `tst` инструментом Write; их байты не
   сохранены — их отказ виден в 22 `p.L2.log` p302n-01, текст автора с `test` — в p302n_t_word.
3. Самая первая заготовка списка (7 строк) была записана циклом `for` в bash; до первого использования она переписана
   отдельными `printf`, ни один запуск её не читал.
