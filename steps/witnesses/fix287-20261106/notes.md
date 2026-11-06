# Срез 287 — индекс указателя на обходимом корне (ROOT-POINTER-INDEX-WALKED)

Опубликован 2026-11-06, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Норма: ответ Codex на вопросы нормы 285, п. 5 ([дословно](../fix285-20261106/records/pins/codex-285-norm-answers.txt), CODEX-OPUS-285-NORM-ANSWERS-20261106T002216Z-01): «пробел реализации, не выбор новой нормы»; отделить допустимый L3 INDEX над реальным place (общий маршрут 271) от подлинной L2-операции, которую интерпретировать нельзя (книга :797), без вечного отказа и без интерпретатора L2. Книга: проверки доступа принадлежат L3, нативному и интерпретируемому (:655); в L2 индекс не получает автоматической проверки границ, проверяемый доступ — L3 (L2 §18). Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) — байты оригиналов из P, строки приведены git к LF (`* text=auto eol=lf`); оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 286

Каждый ряд `runs` строится native и forced и запускается с корнем native (root0) и обходимым (root1, `walkroot 1`). На кортеже boot148b ([a03](records/pins/tp149-probe-a03.terminal.txt), список [probe287-a](records/pins/probe287-a.tsv)) свидетель и обе пробы 284 проходят root0 и падают в root1 в обоих режимах: `lmx: walk error: UNSUPPORTED` (driver exit 3). На первом кандидате ([d01](records/pins/tp149-probe-d01.terminal.txt), список [probe287-d](records/pins/probe287-d.tsv)) все десять рядов проходят; на G2 boot149b — они же и `sha256_vectors` ([sepg2b](records/pins/tp149-probe-sepg2b.terminal.txt), список [probe287-e](records/pins/probe287-e.tsv), 11 рядов, 0 отказов):

| Запись | 286, root1 | 287 |
| --- | --- | --- |
| свидетель `root_pointer_index` | UNSUPPORTED | 7 во всех четырёх запусках |
| [p284k](records/cold-tp140/tests/dyn/p284k_root_pointer_index.lm2): `int: a px[0U]` в корне | UNSUPPORTED | 7 |
| [p284j](records/cold-tp140/tests/dyn/p284j_slash_index_comma.lm2): `two(px\[0U], \py)` в корне | UNSUPPORTED | 7 |
| `immutable_reached_write` | 7; `write_index` с `p[0U]: 9` в forced остаётся native | 7; `write_index` обходится |
| [p287a](records/cold-tp140/tests/dyn/p287a_formal_index.lm2)–[p287c](records/cold-tp140/tests/dyn/p287c_own_index_write.lm2): формал, чтение и запись собственного указателя метода | 6, 11, 12; тела в forced native ([b01](records/pins/tp149-probe-b01.terminal.txt)) | 6, 11, 12; тела обходятся |
| [p287d](records/cold-tp140/tests/dyn/p287d_formal_after_writes.lm2)–[p287f](records/cold-tp140/tests/dyn/p287f_formal_after_deref_write.lm2): запись через `px` в корне, затем `get(px, 0U)` | root0 3 ([c01](records/pins/tp149-probe-c01.terminal.txt)) | 3 во всех запусках, см. «Публикация» |

## Где был дефект

Обходимый код отправлял всякий индекс машинного указателя в SOURCE_MACHINE: чтение и `@` через `lm_compiler_rw_raw_index_value`, запись в голове `p[i]: v` через `lm_compiler_rw_machine_path`. Это ставит `rw_machine`: метод остаётся native, а корень при `walkroot 1` обходчику не отдать, и кадр SOURCE_MACHINE отвечает `UNSUPPORTED` при исполнении. Решение принималось по форме generated кода (raw index), не по категории исходной операции: `px[0U]` над собственным полем корня — L3 INDEX над настоящим местом, тот же, что в методе уже шёл маршрутом 271 через свободное имя.

## Механизм

- **Маршрут.** `lm_compiler_rw_index_place` (конец `l2_frontend_emit.lm2`): raw index, у которого корень — собственное поле или формал (`oi`/`fi`, `root_kind` 0), шаги — только индексы машинного указателя (`names` 0), а у каждого индексируемого указателя ядро знает указуемое (базовый указательный тип транслятора, не `@ void` и не внешний тип), строится цепочкой ELEM, у записи последний шаг — ELEMPUT. Держатель первого шага — значение места (`lm_compiler_rw_binding_value`: собственное поле — AT со свидетелем указательного типа, формал — ARG), следующего — элемент, выбранный предыдущим. Индекс принимается в `size_t` (`lm_compiler_rw_numeric_receive_span`, как у ELEM массива), значение записи — по типу элемента (`lm_compiler_rw_reference_receive`, как у записи в Array). `@ px[0U]` — ADDRESS над тем же ELEM.
- **Ядро не менялось.** ELEM/ELEMPUT обходчика вызывают `lmx_walk_value_index_place` среза 271: указатель в пулы арены классифицируется по фактической ячейке, иначе по указательному коду; ненулевой индекс идёт шагом интервала или размером указуемого; выход из интервала и переполнение — неявный `interpreter`; запись через неизменяемую ссылку отказывает. tools/build.lm2, runtime и G0 те же, что у 286.
- **Индекс без преобразования.** Маршрут берёт шаг, только если его индекс `size_t` принимает без преобразования (`lm_compiler_rw_index_receivable`): значение типа `size_t`, значение с типом при исполнении (его принимает `lmx_walk_index`) или один числовой литерал. Индекс другого числового типа доходит до `size_t` только через приёмник преобразования программы (`primitive.convert`, `lm_compiler_numeric_receive_prepare`); записанный как индекс C, это машинный индекс, который исполняет native, и он остаётся на прежнем пути. Без этого условия первая сборка boot149a отказала при трансляции `tests/sha/sha256_vectors.lm2:31:13` (`all[i]` с `int: i` в методе `run`, который native и так): `the program has no method lm_stg_convert_int_size_t, the receiver of this conversion` — на 286 этот ряд проходил.
- **SOURCE_MACHINE остаётся** подлинной L2-операции: шаг-член (C ABI), корень — машинная локальная, слот или C-константа, указатель на `void` или внешний тип, индекс, которому нужно преобразование. Там метод по-прежнему native.
- **Следствие.** Под `--walk-methods` методы с индексом собственного или формального указателя теперь обходятся, а не остаются native: `write_index` в `immutable_reached_write` (283 писал, что его нельзя называть в спеке наблюдения), тела свидетеля.

Runner, cache, второй resolver, скрытые корни и интерпретатор L2 не вводились.

## Свидетель

[tests/dyn/root_pointer_index.lm2](../../../selfbuild/tests/dyn/root_pointer_index.lm2), native и forced, оба корня. Первая ошибка не затирается (`if: code = 7 && …`). Запись через указатель наблюдается через указатель; `touch()` до первой записи через `px` публикует начальные рабочие значения корня (см. «Публикация»).

| Код | Что проверяет |
| --- | --- |
| 11 | `int: a px[0U]` в корне (форма p284k) |
| 12 | `px[0U]: 4`, затем чтение `px[0U]` |
| 13 | `@: py int @ px[0U]` и `\py: 6`, затем `px[0U]` |
| 14, 15 | `pc[1U]`, `pc[2U]` через `@: pc int @ cells[0U]` в Array корня: шаг интервала |
| 16 | `pc[1U]: 19`, затем `cells[1U]` |
| 17 | форма `px\[0U]` |
| 18, 19 | формал: `get(px, 0U)`, `get(pc, 2U)` |
| 20 | запись через формал: `put(pc, 1U, 23)`, затем `cells[1U]` |
| 21, 22 | собственный указатель метода: `q[0U]` и `q[0U]: 12` с чтением через `\q` |

## Мутанты

Ручные правки стейдж-файла `cold-tp140/src/l2src/l2_frontend_emit.lm2` первого кандидата ([mut287](records/pins/mut287.tsv)), каждая — целый фронтенд ([tp149-fe](records/pins/tp149-fe.command)) и список [probe287-m](records/pins/probe287-m.tsv) на runtime boot148b. После каждой файл восстановлен копией из варианта, весь стейдж проверен `lmxtool verify` по source-tp149 ([рецепт](records/pins/tp149-restore.command): [m1](records/pins/tp149-restore-m1.terminal.txt), [m2](records/pins/tp149-restore-m2.terminal.txt), оба exit 0). Строки обоих мутантов во втором кандидате те же.

| Мутант | Фронтенд | Итог |
| --- | --- | --- |
| m1: чтение и адрес не идут маршрутом (`int: status 2` в `lm_compiler_rw_raw_index_value`) | [fe149m1](records/pins/tp149-fe-m1.terminal.txt), 10:29:11→10:35:17Z | убит: [m1](records/pins/tp149-probe-m1.terminal.txt), root1 свидетеля и p284k — `walk error: UNSUPPORTED` в native и forced ([лог](records/tp149-probe/m1/root_pointer_index-native/run-root1.log)) |
| m2: запись не идёт маршрутом (`k: 2` в `lm_compiler_rw_stmt_content`) | [fe149m2](records/pins/tp149-fe-m2.terminal.txt), 10:36:09→10:42:31Z | убит: [m2](records/pins/tp149-probe-m2.terminal.txt), root1 свидетеля — UNSUPPORTED, p284k без записи проходит ([лог](records/tp149-probe/m2/p284k_root_pointer_index-native/run-root1.log)) |

Условие приёма индекса различает только `sha256_vectors`: без него (boot149a) полный список на G2 — 84 из 85, с ним (boot149b) — 85 из 85.

## Наблюдение обходчика

Существующий os-walk-witness ([рецепт](records/pins/tp149-obs.command)), спека `touch=1,get=2,put=1,own_read=1,own_write=1` над свидетелем и `write_index=2` над `immutable_reached_write`. На первом кандидате ([rpi01](records/pins/tp149-obs-rpi01.terminal.txt), [irw01](records/pins/tp149-obs-irw01.terminal.txt)), на втором ([rpi02](records/pins/tp149-obs-rpi02.terminal.txt), [irw02](records/pins/tp149-obs-irw02.terminal.txt)) и на G2 boot149b ([rpig2](records/pins/tp149-obs-rpig2.terminal.txt), 12:50:30→12:50:37Z, 40 PASS; [irwg2](records/pins/tp149-obs-irwg2.terminal.txt), 12:50:38→12:51:46Z, 16 PASS) одно и то же: forced в обоих roots обходит каждое тело точное число раз, L1 не даёт этим телам native-слова; native не обходит ни одно; результат 7 во всех запусках. На 286 у тех же тел в forced L1 стояли native-слова и кадр SOURCE_MACHINE: в P `tp149-probe/a03/root_pointer_index-forced/p.lm1` — 5 native-слов (get, put, own_read, own_write и код юнита) и 13 SOURCE_MACHINE, в `d01/…` того же ряда — одно native-слово (код юнита), 0 SOURCE_MACHINE, 19 ELEM/ELEMPUT; у p287a–c в `b01/…-forced/p.lm1` по два native-слова и одному SOURCE_MACHINE, в `d01/…` — одно и ни одного; у `write_index` (`a03/immutable_reached_write-forced/p.lm1`) — `l2_m10_tr`, в `d01/…` его нет. Копии L1 в запись не взяты (их размер), подсчёт — `grep -c` по этим путям.

## Приёмка

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Первый кандидат | fe149a 10:01:01→10:07:04Z, FrontendExit 0, l2trans `a33f05dc…`; пробы 10/0 (d01), фокус 68/0 (10:11:40→10:28:42Z) | [fe](records/pins/tp149-fe-a01.terminal.txt), [d01](records/pins/tp149-probe-d01.terminal.txt), [f01](records/pins/tp149-probe-f01.terminal.txt), [список](records/pins/focus149.tsv) |
| Whole boot149a (история) | 10:43:18.7534207Z→11:03:15.8224590Z, BootstrapExit 0, 1197.07 с; сверка 218/0, 248/248, 245 + 3 PE; G2 focus 68/0; полный список на G2 85 рядов, 1 отказ: `sha256_vectors native: built`, отказ трансляции ([лог](records/tp149-probe/fullg2/sha256_vectors-native/p.L2.log)) | [terminal](records/pins/boot149a-quick.terminal.txt), [сверка](records/pins/boot149a-compare.txt), [g2focus](records/pins/tp149-probe-g2focus.terminal.txt), [fullg2](records/pins/tp149-probe-fullg2.terminal.txt), [sepg2](records/pins/tp149-probe-sepg2.terminal.txt) |
| Второй кандидат | условие приёма индекса; fe149b 11:43:12→11:49:36Z, l2trans `bdd630a1…`; пробы с `sha256_vectors` 11/0 (e01) | [fe](records/pins/tp149-fe-b01.terminal.txt), [e01](records/pins/tp149-probe-e01.terminal.txt) |
| Whole boot149b | 11:53:38.0142864Z→12:12:53.0093853Z, BootstrapExit 0, 1155.00 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot149b-quick.terminal.txt), [log](records/pins/boot149b-quick.log), [detached](records/pins/boot149b-detached.terminal.txt) |
| Сверка source | 218/0 против manifest `43142543…` | [сверка](records/pins/boot149b-compare.txt) |
| Producers | g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0 | там же |
| Инвентари | 248/248, пересчитано 496 фактических хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только байтами 136, 137, 216, 217 | там же |
| Consumed | 306/306, файлы raw-equal | там же |
| Рабочие артефакты | рабочий tool `3ffac1a4…` = G2 tool, bundle = G2; runtime driver `2cab6a27…` и observe `47f74b3b…` равны G2 runtime boot148b байт в байт | там же |
| G2 focus | 12:14:17.1378063Z→12:31:05.9479113Z, SuiteExit 0, `SUITE 68 rows, 0 failures` | [g2focusb](records/pins/tp149-probe-g2focusb.terminal.txt) |
| Полный список на G2 | 12:31:10.7526502Z→12:46:39.9651083Z, SuiteExit 0, `SUITE 85 rows, 0 failures` | [fullg2b](records/pins/tp149-probe-fullg2b.terminal.txt), [список](records/pins/fullsuite149.tsv) |
| Пробы на G2 | 12:46:47.5775718Z→12:48:27.4535327Z, `SUITE 11 rows, 0 failures` | [sepg2b](records/pins/tp149-probe-sepg2b.terminal.txt) |
| Посадка | land287 12:49:03→12:49:05Z, 8 шагов exit 0; `selfbuild/inputs.sha256` = source-tp149 `43142543…`; consumed sources G1 = G2, 65 строк | [terminal](records/pins/land287.terminal.txt), [рецепт](records/pins/land287.command) |

Кортеж: рабочий tool `3ffac1a49ddc1337…`, G2 frontend `8e415dadbf1e2e6b…`, l1 `2386e4409f3cfdd5…`, l2_libc `af9fdae33655f8e6…`, driver `2cab6a2717653d4e…`, observe `47f74b3b39de2cd9…`. G0 — рабочий tool 286 `17afcadc…` (tools/build.lm2 не менялся), previous frontend — G2 286 `3480b4de…`.

## Публикация

p287d–p287f показывают модель публикации, а не дефект: `int: x 3` в корне — выполненная запись рабочего значения, `dirty`; запись через `px` идёт в ячейку; на границе вызова `get(px, 0U)` публикуется грязное рабочее 3 и затирает её (книга :493, :510, :512: перед передачей управления публикуются только рабочие поля с отметкой `dirty`, явная запись через ссылку наблюдаема через другие ссылки, перечитывания нет). Native и обходчик отвечают одинаково: 3 в root0 и root1, native и forced. Первый вариант свидетеля читал голое `cell` после `q[0U]: 12` и ждал 6 от `get(px, 0U)` — ошибки свидетеля, не транслятора; сгенерированный L1 пробы p287f это показал (`l2_m1_publish1` перед вызовом).

## Что не сделано

- **Native индекс собственного или формального указателя** остаётся индексом C (`lm_compiler_emit_raw_index_value`): без проверки интервала, которую книга (:655) отдаёт L3 и в нативном коде, тогда как обходимый ELEM её делает. Для корректной программы ответы равны; различаются выход за объект (в native — неопределённое поведение C) и отрицательный индекс. Записано как OWN-POINTER-INDEX-NATIVE-CHECK.
- Формы, оставшиеся на SOURCE_MACHINE (шаг-член C ABI, машинная локальная, C-константа, `@ void`, внешний тип) в обходимом корне по-прежнему падают при исполнении `UNSUPPORTED`, а не отказывают при трансляции; срезом не менялись.
- Индекс другого числового типа (`int`, `unsigned`) остаётся на SOURCE_MACHINE даже там, где у программы есть приёмник преобразования в `size_t`: проверка его наличия в трансляторе пишет общее состояние преобразований и диагностику таблицы, пробой из обходчика её не позвать. Для обходимого корня такой индекс по-прежнему `UNSUPPORTED` при исполнении.
- Не свидетельствованы рядом: двухуровневый индекс `pp[0U][1U]`, скрытый вход с конкретным указательным типом, предикат типа указуемого (`@ void`, внешний тип) — ни один ряд их не различает. Условие приёма индекса различает только `sha256_vectors` полного списка (boot149a против boot149b).

## Происхождение

Рецепты, списки и тексты Codex ([ревью 286](records/pins/codex-286-review.txt), [ревью дополнения](records/pins/codex-286-addendum-review.txt)) записаны вручную инструментом Write; мутанты — ручные правки с восстановлением и verify; пробы — фикстуры L3 в стейдже; архив, docs check и evidence — языковые рецепты docs287*. Вспомогательных скриптов, клонов рецептов заменой текста и проверок циклами нет. Отступления, сообщённые Codex:

1. Два поиска Grep по каталогу `selfbuild/src/l2src` (рекурсивно, не по точному файлу) при разборе транслятора и один по несуществующему пути; вывод — только строки исходников `.lm2`.
2. Однократное чтение собственного транскрипта сессии через `python -I -c` (разбор строк JSONL), чтобы найти дословный текст двух ревью Codex 286; к проверке среза не относится.
3. Циклы `for` в Bash печатали первые строки названных логов запусков (только показ); ожидания — `until grep …; do sleep …`.

Порядок docs check: точный allowlist (152 пути: документы, пакет selfbuild, записка, evidence.list и 139 копий первого прохода архива) проиндексирован `git add --pathspec-from-file` в 12:57:56Z, `git diff --cached --check` = 0, затем языковой `docs check` ([рецепт](records/pins/docs287-check.command)): [docs287-check-a](records/pins/docs287-check-a.terminal.txt) 12:58:04.9181820Z→13:01:12.7737403Z, exit 0, «line endings LF in the index for all 19005 tracked files», ссылки ([log](records/pins/docs287-check-a.log)) (CODEX-OPUS-286-DOCS-ADDENDUM-20261106T0930Z-02). После него — копии его receipts, evidence-манифест ([docs287](records/pins/docs287.terminal.txt): manifest и verify, exit 0, 151 строка) и копии его receipts; они добавлены к индексу вторым точным списком.
