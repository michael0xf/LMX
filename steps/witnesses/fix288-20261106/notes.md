# Срез 288 — проверяемый L3 INDEX собственного или формального указателя в native (OWN-POINTER-INDEX-NATIVE-CHECK)

Опубликован 2026-11-06, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Норма: ответ Codex на результат 287 ([дословно](records/pins/codex-287-norm-review.txt), CODEX-OPUS-287-NORM-REVIEW-20261106T1318Z-01): для операции, установленной как L3 INDEX над настоящим place, native обязан иметь те же проверки доступа, что обходчик, — через общий выбор места среза 271 (`lmx_walk_value_index_place`), с тем же приёмом индекса, проверками интервала и переполнения, адресом, чтением и записью и порядком отказа; отдельный checker и исключение backend не нужны; настоящий L2 остаётся без проверок и не интерпретируется (книга :797). Там же п. 2: «индекс другого числового типа ⇒ подлинная L2-операция» из нормы не следует, условие приёма — ограничение реализации. Ответ на вопрос о категории ([дословно](records/pins/codex-288-category-answer.txt), CODEX-OPUS-288-CATEGORY-ANSWER-20261106-01): тело `run` фикстуры `sha256_vectors` — L3 с машинными вставками (книга, provenance :7, :9–15; READ.ME:33), п. 3 ревью 287 отозван; фикстуру исправить (`int: i` → `size_t: i`, все digest, проверки и коды выхода прежние); индекс другого числового типа — OPEN, без unchecked C fallback. [Вопрос](records/pins/question288.txt). Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) — байты оригиналов из P, строки приведены git к LF (`* text=auto eol=lf`); оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 287

Тот же расширенный свидетель на кортеже boot149b ([sep01](records/pins/tp150-probe-sep01.terminal.txt), список [probe288-s](records/pins/probe288-s.tsv)): native root0 и root1 и forced root0 (код корня native) — `driver exit -1073741819` (0xC0000005: индекс C на адресе вне всякого объекта), forced root1 — 7: обходчик ловит `interpreter`. `sha256_vectors` с `size_t: i` даёт 7 и там.

## Где был дефект

На 287 L3 INDEX собственного поля или формала в native оставался индексом C (`lm_compiler_emit_raw_index_value`, `lm_compiler_emit_raw_index_location`): адрес считал C, интервала и переполнения никто не проверял, хотя обходимый код тот же доступ делал через `lmx_walk_value_index_place`. Для корректной программы ответы совпадали; выход за объект в native был неопределённым поведением C.

## Механизм

- **Один предикат.** `lm_compiler_index_l3_path` (конец `l2_frontend_resolve.lm2`, экспорт в tools/build.lm2): корень — собственное поле или формал (`root_kind` 0), метод — не функция машинного модуля (`lm_compiler_m_machine`), каждый шаг — индекс указателя, указуемое которого типизирует ядро (базовый указательный тип транслятора, не `@ void`), индекс без преобразования принимается в `size_t` (`lm_compiler_index_receivable`: `size_t`, значение с типом при исполнении, один числовой или символьный литерал). Его спрашивают native-снижение (чтение, запись, `@`) и обходимое (`lm_compiler_rw_index_place`, вместо условия 287 `lm_compiler_rw_index_receivable`, которое удалено).
- **Native чтение** (`lm_compiler_path_record_read_context_full`): место выбирает `lm_compiler_emit_actual_path_place` — тот же эмиттер, что у свободного корня среза 271: индекс принимается в `size_t`, `lmx_walk_value_index_place` над держателем, неявные `implements`, `convert`, `interpreter` и статус; чтение — `lmx_walk_place_load` по фактическому типу места с проекцией в тип элемента, как ELEM обходчика.
- **Native запись** (`lm_compiler_emit_raw_index_store` → `lm_compiler_emit_index_l3_store`, конец `l2_frontend_lower.lm2`) в порядке ELEMPUT обходчика: сначала место, затем барьер записи на его хранилище, затем значение, принятое по типу элемента, затем `lmx_walk_value_store` в выбранное место; до готового значения ничего не пишется.
- **Native `@`** (`lm_compiler_emit_address_context_raw`, `_full`): адрес выбранного места `lmx_walk_place_address`, как ADDRESS над ELEM.
- **Держатель — текущее значение.** У типизированного корня держатель места собирается из рабочего C-значения с контекстом записи (`lmx_walk_value_ref_context`), как raw-индекс брал базу; у свободного корня держатель — сама запись. Запись рабочего значения собственного поля в native обновляет C-копию, а ссылку записи не трогает (`lmx_value_cell_fill` копирует в чужого owner только контекст): второй кандидат держал `@: s char "abcdef"` устаревшей записью, и `free_value_consumers` упал в фокусе и полном списке (см. «Мутанты», h).
- **Прогноз эффекта в сканере не нужен.** Неявный выброс выходит из любого native-тела своим кодом возврата, и трамплин передаёт этот статус дальше; `l2_out_throw` — канал полезной нагрузки (`lm_compiler_emit_implicit_throw`). Первый кандидат помечал такие пути в сканерах эффектов; мутант m2 показал, что эта пометка ненаблюдаема, и обе ветки удалены. (Поправка формулировки в срезе 289 по ответу Codex CODEX-OPUS-288-REVIEW-NEXT-20261106-01: возвратный статус и его передача остаются.)
- **Ядро не менялось.** Runtime boot149b используется как есть.
- **Что предикат не берёт** — шаг-член C ABI, корень машинная локальная, слот или C-константа, указатель на `void` или внешний тип, индекс другого числового типа — остаётся на прежнем маршруте (native — индекс C, обходчик — SOURCE_MACHINE). Это предел реализации, а не категория нормы (п. 2 ревью 287): записано как OPEN INDEX-NUMERIC-RECEPTION и L3-INDEX-ROUTE-LIMITS.
- **Машинная память.** Над указателем в память вне арены (`c.malloc`, C-литерал) ядро не знает интервала: проверки длины нет, дескриптор такому объекту не выдумывается (ответ о категории); указатель в ячейки арены проверяется по интервалу.

Runner, cache, второй resolver, отдельный checker и интерпретатор L2 не вводились.

## Фикстура `sha256_vectors`

[tests/sha/sha256_vectors.lm2](../../../selfbuild/tests/sha/sha256_vectors.lm2): `size_t: i 0U`, `while: i < 256U`, `i: i + 1U`. Выбранный `all[i]` — L3 INDEX собственного указателя; машинные вставки L2 — `c.malloc`, `c.free` и `cast:`, как были. Все digest, проверки и коды выхода прежние. 7 на всех кандидатах и на G2. (Поправка формулировки в срезе 289 по ответу Codex CODEX-OPUS-288-REVIEW-NEXT-20261106-01: прежний текст относил `all[i]` к машинным вставкам.)

## Свидетель

[tests/dyn/root_pointer_index.lm2](../../../selfbuild/tests/dyn/root_pointer_index.lm2), native и forced, оба корня, первая ошибка не затирается. Коды 11–22 — среза 287. Индекс `2305843009213693951` (`× sizeof(int)` = 2^63 − 4) уводит адрес из любого интервала и ничего не переполняет.

| Код | Что проверяет |
| --- | --- |
| 23 | чтение через формал за интервалом: `get(pc, far)`; выброс выходит из `get` и пойман вызывающим |
| 24 | запись через формал за интервалом: `put(pc, far, 1)` |
| 25 | адрес через формал за интервалом: `far_address(pc)` с `@: pz int @ p[far]` |
| 26 | собственный указатель метода за интервалом: `own_far()` (`@: q int @ slots[0U]`, `q[far]`) |
| 27, 28 | собственный указатель корня за интервалом: `pc[far]` и `pc[far]: 1` под `catch: interpreter` |
| 29 | `cells[1U]` после неудачных записей — прежние 23 |
| 30 | `literal_char()`: `@: s char "abcdef"`, `s[2U]` — держатель native — текущее значение |

## Мутанты

Ручные правки стейдж-файлов ([mut288](records/pins/mut288.tsv)), каждая — целый фронтенд ([tp150-fe](records/pins/tp150-fe.command)) и список [probe288-m](records/pins/probe288-m.tsv) на runtime boot149b; после каждой файл восстановлен копией из варианта и весь стейдж проверен `lmxtool verify` ([tp150-restore](records/pins/tp150-restore.command): [m1](records/pins/tp150-restore-m1.terminal.txt), [m3](records/pins/tp150-restore-m3.terminal.txt), [m4](records/pins/tp150-restore-m4.terminal.txt), exit 0; после m2 — новый prepare [a02](records/pins/tp150-prepare-a02.terminal.txt)).

| Мутант | Фронтенд | Итог |
| --- | --- | --- |
| m1: native чтение идёт индексом C (`raw_view\descriptor != 0`) | [fe150m1](records/pins/tp150-fe-m1.terminal.txt), 14:02:22→14:07:49Z | убит: [m1](records/pins/tp150-probe-m1.terminal.txt), native root0/root1 и forced root0 — 0xC0000005, forced root1 7 |
| m2: сканер эффектов не помечает L3 INDEX (`return: (cast: (int) (0))`) | [fe150m2](records/pins/tp150-fe-m2.terminal.txt), 14:08:28→14:14:28Z | не убит: [m2](records/pins/tp150-probe-m2.terminal.txt), 7 во всех запусках; ветки удалены |
| m3: native запись — запись C (`place\descriptor != 0`) | [fe150m3](records/pins/tp150-fe-m3.terminal.txt), 14:24:47→14:28:52Z | убит: [m3](records/pins/tp150-probe-m3.terminal.txt), native root0/root1 и forced root0 — 0xC0000005, forced root1 7 |
| m4: native `@` — адрес C (`address\descriptor != 0`) | [fe150m4](records/pins/tp150-fe-m4.terminal.txt), 14:29:26→14:33:33Z | убит: [m4](records/pins/tp150-probe-m4.terminal.txt), native root0/root1 — `exit 25, expected 7` ([лог](records/tp150-probe/m4/root_pointer_index-native/run-root0.log)), forced 7 |
| h: держатель типизированного корня — запись (второй кандидат fe150b) | [fe150b](records/pins/tp150-fe-b01.terminal.txt) | убит: `free_value_consumers` — 4 отказа в [фокусе](records/pins/tp150-probe-f01.terminal.txt) и [полном списке](records/pins/tp150-probe-u01.terminal.txt) (R0 остановлен непойманным выбросом, [лог](records/tp150-probe/f01/free_value_consumers-native/run-root0.log)); код 30 — R0 остановлен во всех четырёх запусках ([sepb](records/pins/tp150-probe-sepb.terminal.txt)) |

m1 и m2 — мутанты первого кандидата, m3 и m4 — второго; третий меняет только держатель внутри маршрута, по которому идут все три места.

## Наблюдение обходчика

Существующий os-walk-witness ([рецепт](records/pins/tp150-obs.command)), спека `touch=1,get=3,put=2,own_read=1,own_write=1,own_far=1,far_address=1` над свидетелем, на G2 boot150a ([rpig2](records/pins/tp150-obs-rpig2.terminal.txt), 16:06:43→16:06:56Z, 52 PASS): forced в обоих roots обходит каждое тело точное число раз (выброс за интервалом в `get`, `put`, `own_far`, `far_address` тоже входит в счёт), L1 не даёт этим телам native-слова; native не обходит ни одно, его L1 связывает native-слово каждого; результат 7 во всех запусках. `literal_char` в спеку не входит: его `cast:` — машинная вставка, тело и в forced остаётся native. В native L1 свидетеля на третьем кандидате (P `tp150-probe/c01/root_pointer_index-native/p.lm1`) 20 вызовов `lmx_walk_value_index_place` и `lmx_walk_place_address` и 18 держателей `lmx_walk_value_ref_context(@ l2_hv…)`, в native L1 287 (`tp149-probe/d01/…`) — ни одного вызова; в forced L1 (`c01/…-forced/p.lm1`) 26 ELEM/ELEMPUT и один SOURCE_MACHINE — `cast:` в `literal_char`. Копии L1 в запись не взяты (их размер), подсчёт — Grep по этим путям.

## Приёмка

| Проверка | Результат | Receipt |
| --- | --- | --- |
| G0 tool | `rebuild tool` стейджа кортежем boot149b (tools/build.lm2 экспортирует одно имя resolve больше): 13:50:31→13:52:31Z, RebuildExit 0, `tool150a/lmxtool-tool.exe 86b6da32…` | [tool](records/pins/tp150-tool-a01.terminal.txt), [рецепт](records/pins/tp150-tool.command) |
| Первый кандидат | prepare a01 (source-tp150 `39ee23d0…`); fe150a 13:53:14→13:58:41Z, l2trans `fddee206…`; пробы 9/0 (a01); разделение на кортеже 287 (sep01) | [prepare](records/pins/tp150-prepare-a01.terminal.txt), [fe](records/pins/tp150-fe-a01.terminal.txt), [a01](records/pins/tp150-probe-a01.terminal.txt), [sep01](records/pins/tp150-probe-sep01.terminal.txt), [список](records/pins/probe288-a.tsv) |
| Второй кандидат | без веток сканера (m2): prepare a02 (`12a1e57a…`); fe150b 14:16:49→14:22:33Z, l2trans `ce5d2458…`; пробы 9/0 (b01); tool транслятором кандидата 1:47, smoke; фокус 68 рядов, 4 отказа, полный список 85 рядов, 4 отказа: `free_value_consumers` во всех запусках | [prepare](records/pins/tp150-prepare-a02.terminal.txt), [fe](records/pins/tp150-fe-b01.terminal.txt), [b01](records/pins/tp150-probe-b01.terminal.txt), [toolfe](records/pins/tp150-toolfe-b01.terminal.txt), [f01](records/pins/tp150-probe-f01.terminal.txt), [u01](records/pins/tp150-probe-u01.terminal.txt) |
| Третий кандидат | держатель — текущее значение, код 30: prepare a03 (`61cbda82…`); fe150c 15:11:16→15:15:06Z, l2trans `6e7ca356…`; пробы 10/0 (c01); tool транслятором кандидата 15:17:17→15:18:47Z, smoke; фокус 68/0 (15:18:48→15:33:44Z), полный список 85/0 (15:33:48→15:47:57Z) | [prepare](records/pins/tp150-prepare-a03.terminal.txt), [fe](records/pins/tp150-fe-c01.terminal.txt), [c01](records/pins/tp150-probe-c01.terminal.txt), [toolfe](records/pins/tp150-toolfe-c01.terminal.txt), [f02](records/pins/tp150-probe-f02.terminal.txt), [u02](records/pins/tp150-probe-u02.terminal.txt), [фокус](records/pins/focus149.tsv), [полный](records/pins/fullsuite149.tsv), [список](records/pins/probe288-c.tsv) |
| Whole boot150a | 15:48:40.1789044Z→16:04:04.0403247Z, BootstrapExit 0, 923.86 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 tool150a, предыдущий frontend — G2 boot149b | [terminal](records/pins/boot150a-quick.terminal.txt), [log](records/pins/boot150a-quick.log), [detached](records/pins/boot150a-detached.terminal.txt), [рецепт](records/pins/boot150-quick.command) |
| Сверка source | 218/0 против manifest `61cbda82…` | [сверка](records/pins/boot150a-compare.txt), [рецепт](records/pins/boot150-compare.command) |
| Producers | g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0 | там же |
| Инвентари | 248/248, пересчитано 496 фактических хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только байтами 136, 137, 216, 217 (у tool ещё 218, тот же CheckSum) | там же |
| Consumed | 306/306, файлы raw-equal | там же |
| Рабочие артефакты | рабочий tool `eb11e493…` = G2 tool, bundle = G2; runtime driver `2cab6a27…` и observe `47f74b3b…` равны G2 runtime boot149b байт в байт (ядро не менялось) | там же |
| Кандидат и G2 | fe150c и G2 frontend: l2trans и l1trans равны по размеру и отличаются только байтами PE 136, 137, 216, 217, l2_libc.o raw-equal — фокус и полный список прошли на коде G2, на G2 они не повторялись | там же |
| Пробы на G2 | рабочим tool, G2 frontend и runtime: 16:05:01.9197624Z→16:06:42.6060601Z, `SUITE 10 rows, 0 failures` | [sepg2](records/pins/tp150-probe-sepg2.terminal.txt) |
| Посадка | land288 16:07:13→16:07:15Z, 6 шагов exit 0; `selfbuild/inputs.sha256` = source-tp150 `61cbda82…`; consumed sources G1 = G2, 65 строк | [terminal](records/pins/land288.terminal.txt), [рецепт](records/pins/land288.command) |

Кортеж: рабочий tool `eb11e493de980d13…`, G2 frontend `c284f0a173602d96…`, l1 `5e5955cb4867baeb…`, l2_libc `af9fdae33655f8e6…`, driver `2cab6a2717653d4e…`, observe `47f74b3b39de2cd9…`. G0 — tool150a `86b6da32…`, previous frontend — G2 287 `8e415dad…`.

## Стоимость

L3 INDEX собственного или формального указателя в native теперь вызов ядра на каждый доступ (`lmx_walk_value_index_place`: классификация адреса бинарным поиском по индексу арены, до двух поисков интервала, загрузка или store места) вместо индекса C; отдельно не замерено. Код: G2 l2trans 1591922 байт (287 — 1589208), G2 tool 1922225 (287 — 1921713); `lmxtool.lm1`, переведённый кандидатом fe150c, — 207523 байт против 205523 у транслятора 287 (+1%): это L1 корня tools/lmxtool.lm2, чьи индексы `size_t` маршрут берут; методы tools собираются машинной библиотекой (`--library --machine tool_main`, `lm_compiler_m_machine`), их индексы — подлинный L2 при любом типе. (Поправка в срезе 289: прежний текст объяснял малый рост тем, что индексы tools почти все `int`.) Whole quick 923.86 с против 1155.00 с у boot149b — измерение всего конвейера, не контролируемое сравнение.

## Что не сделано

- **Индекс другого числового типа** (`int`, `unsigned`) у собственного или формального указателя остаётся индексом C в native и SOURCE_MACHINE в обходчике, даже где у программы есть приёмник преобразования в `size_t`: общий приём индекса этими эмиттерами не сделан (INDEX-NUMERIC-RECEPTION, OPEN; ответ о категории — без unchecked C fallback, форма отказа — по общему контракту приёма). Методы tools этим не затронуты: они собираются машинной библиотекой, их индексы — подлинный L2 (поправка в срезе 289; прежний текст говорил, что почти все индексы tools — `int`).
- **Остальные пределы маршрута** — шаг-член C ABI, машинная локальная, слот, C-константа, указатель на `void` или внешний тип — на прежнем пути (L3-INDEX-ROUTE-LIMITS, OPEN); в обходимом корне они по-прежнему падают при исполнении `UNSUPPORTED`.
- **Не свидетельствованы рядом:** двухуровневый индекс `pp[0U][1U]`, отрицательный индекс-литерал, указатель в ячейки арены другого типа (тип места — фактический, а приём значения — по типу элемента).

## Происхождение

Рецепты, списки, таблица мутантов и тексты Codex записаны вручную инструментом Write; мутанты — ручные правки стейдж-файлов с восстановлением и verify; пробы — фикстуры L3 в стейдже. Клонов рецептов заменой текста нет; проверки циклами на PowerShell были — см. п. 3. Отступления, сообщённые Codex:

1. Один поиск Grep по несуществующему точному пути (`selfbuild/src/l2src/l2_frontend_state.lm2`) и один хэш несуществующего точного пути (`selfbuild/src/l2src/lmx_source_names.h.lm1`); каталоги не перечислялись.
2. Две фоновые цепочки запускали подряд несколько рецептов одной командой (prepare, frontend, проба); каждый рецепт со своими проверками.
3. (Добавлено в срезе 289 по ответу Codex CODEX-OPUS-288-REVIEW-NEXT-20261106-01.) Рецепт сверки [boot150-compare](records/pins/boot150-compare.command) — алгоритм на PowerShell, а не вызов инструмента: циклы foreach и for по манифесту, записям producers и инвентарям, побайтовое сравнение через ReadAllBytes; раздел 7 (fe150c и G2) добавлен в этом срезе. По READ.ME:35 и §8 S8.5 поддерживаемые сверка, проверка и сбор результатов выполняются L2/L3; запись рецепта инструментом Write языка алгоритма не меняет. Того же класса PS-фильтры в [land288](records/pins/land288.command) (подмножество consumed через Where-Object и foreach, Compare-Object), [tp150-prepare](records/pins/tp150-prepare.command) (Compare-Object с проверкой допустимых путей), [tp150-probe](records/pins/tp150-probe.command) и [tp150-toolfe](records/pins/tp150-toolfe.command) (Select-String с ForEach-Object по строкам PASS/FAIL, foreach по входам), [tp150-restore](records/pins/tp150-restore.command) (Where-Object по списку), [tp150-obs](records/pins/tp150-obs.command) (foreach по входам, ForEach-Object по failures.tsv, Select-String по строкам PASS/FAIL) и [docs288-archive](records/pins/docs288-archive.command) (цикл нормализации текста копий); циклы foreach по фиксированным шагам, пинам и входам есть и в остальных рецептах 288 (tp150-tool, tp150-fe, boot150-prepare, boot150-quick с Select-String, docs288). Доказанные результаты 288 этим не отменяются; receipts сохранены как есть. С 289 рецепты не содержат таких алгоритмов: сверки — командами lmxtool (`manifest`, `verify`, `stage-copy`, `same`, `exe-same`, `verify-record`, `deps`).

Порядок docs check: точный allowlist (120 путей: документы, пакет selfbuild, записки 287 и 288, evidence.list и 103 копии первого прохода архива) проиндексирован `git add --pathspec-from-file` в 16:11:22Z, `git diff --cached --check` = 0, в индексе ровно эти 120 путей; затем языковой `docs check` рабочим tool boot150a ([рецепт](records/pins/docs288-check.command)): [docs288-check-a](records/pins/docs288-check-a.terminal.txt) 16:11:32.0767613Z→16:11:53.9955050Z, exit 0, «line endings LF in the index for all 19117 tracked files», ссылки ([log](records/pins/docs288-check-a.log)). После него — копии его receipts ([второй список](records/pins/docs288-text2.list)) и evidence-манифест ([docs288](records/pins/docs288.command): manifest и verify); они и эта записка добавлены к индексу вторым точным списком.
