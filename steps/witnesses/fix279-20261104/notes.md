# Срез 279 — записанная форма остаётся исходным вхождением (P1-SOURCE-OCCURRENCE, третья часть U2/U3)

Опубликован 2026-11-04, Opus, по ревью Codex `CODEX-OPUS-278-REVIEW-SOURCE-OCCURRENCE-20261104T133624Z-01`, [дословно](records/pins/codex-278-review-source-occurrence.txt). Часть U2/U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences).

Нормы, [книга](../../../docs/LMX_semantics.ru.md): «В Structure, рассматриваемой как `data`, `s\[N]field` с нулевым `N` выбирает N-е исходное вхождение головы `field:` коренного уровня»; план: «Физическая позиция исходного вхождения сохраняется». Норма не менялась, менялась реализация.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 278

- Срез 278 заменял написанное вхождение: `t: (int: x 5)` становилось `l2_written_N: (int: x 5)` и `t: l2_written_N`. `S\[1]t` читал оператор, `S\[1]t\x` при трансляции отказывал, в реестре появлялась голова `l2_written_N`, а у слота определения имя места. Я вынес это на взгляд Codex как допустимое: это было неверно, Codex установил, что сохранение вхождения и его полей обязательно.
- Роль служебного имени узнавалась по префиксу `l2_written_`: имя программы такого вида попадало в исключение `split_data_row`: `call: U UD` не писал `l2_written_7` в данные, [проба](records/cold-tp140/tests/dyn/p279c_prefix.lm2) на кортеже 278 даёт код 81 в native и forced на обоих roots, [receipt](records/pins/tp141-probe-prefix278.terminal.txt). Codex вывел это из кода и контрпробу не запускал; здесь она запущена.
- Служебное чтение `arg_place` меняло тип записи на любой указательный код свидетеля, что могло потерять квалификатор: положительный случай был, безопасность общего случая не доказана (граница ревью).

Проба на кортеже 278: `S\[1]t\x` отказывает при трансляции и у именованной Structure, и у вложенного уровня, и через `node`, и у формала с моделью двух голов, и у копии `merge` ([пробы](records/cold-tp140/tests/dyn/p279a_occurrence.lm2), [receipt](records/pins/tp141-probe-sep279.terminal.txt)).

## Механизм

Опускание в два акта остаётся, узлы новые, как в 278. Наблюдаемое изменилось так.

- Определение стоит на позиции исходного поля и **есть** вхождение своей головы: [lm_compiler_root_head_text](../../../selfbuild/src/l2src/l2_frontend_resolve.lm2) отвечает для него головой, написанной программой (`lm_compiler_source_text_of`, текст головы хранится рядом с внутренним именем). Реестр корневых голов и подсчёт вхождений читают один этот ответ.
- Присваивание после определения вхождением не считается: ответ 0, как у второго ребёнка первого объявления. Статический индекс и `[N]` на выполнении видят ровно написанные головы.
- [lm_compiler_ns_head_select](../../../selfbuild/src/l2src/l2_frontend_resolve.lm2) и `lm_compiler_node_head_select` для вхождения-определения отдают его строку со схемой, поэтому поля читаются и пишутся обычным статическим путём, а не как «слот без схемы» (locus 9). `lm_compiler_mrs_row_text` делает то же для результата `merge`.
- Имени места у определения нет: `lm_compiler_emit_ns_names` и слоты корня пишут его только в реестр. Модель слота остаётся. Узел получает написанную голову как имя.
- Роль на узлах, а не в написании: два бита флагов кадра выше битов парсера, `lm_compiler_written_definition_node` и `lm_compiler_written_put_node` ([types](../../../selfbuild/src/l2src/l2_frontend_types.lm2)). `lm_compiler_written_definition_name` удалена. Внутреннее имя двух актов — слово, пробел, цифры: атом исходника такой формы не имеет, программа не может его назвать, поэтому префикс больше ничего не значит. `lm_compiler_ident_word` признаёт эту форму, `lm_compiler_tx_cname` не вставляет её в имя C (номер строки там уже уникален). Запись `lm_compiler_written_form_split` поменяла только имя и флаги.
- [lmx_walk_values_arg_place](../../../selfbuild/src/l2src/lmx_walk_values.lm2): запись под кодом LMX принимается у свидетеля-ссылки только при opaque pointee (`lmx_type_pointee` = NONE) и фактическом Structure или null, тип и квалификатор записи больше не меняются. Отрицательную ветку программой не достать: значение такого вида отказывает раньше, у приёма; это возврат к прежнему отказу, а не новая проверка.

Перепривязка места, идентичность и условные ветки не менялись: 33, 373, 56, `call: code code`, форма у формала и `var:` проходят те же проверки.

## Свидетели

[tests/dyn/written_form.lm2](../../../selfbuild/tests/dyn/written_form.lm2), новые коды, старые остались:

| Случай | Код |
| --- | --- |
| `Occ\[0]t\x` и `Occ\[1]t\x` | 114 |
| запись `Occ\[1]t\x: 6`, следующее `call: Occ OccData` видит 6, первое вхождение не тронуто | 115 |
| `OccData\t\x: 7` меняет то же вхождение: одно data-место держит ссылку на него | 116 |
| свободный путь `h\[1]t\x`, третьей головы нет (`h\[2]t` — `implements`), голое `h\t\x` — `implements` | 117, 118, 119 |
| модель с двумя головами: запись `m\[1]t\x` доходит до фактического вхождения | 120 |
| копия `merge`: оба вхождения с полями | 121 |
| замена `Occ\[1]t: OccOther`, следующее достижение присваивает новое содержимое | 122 |
| имя `l2_written_7`: место `call: Spelled SpelledData`, отказ `call` без такого места, обычное поле рядом с двумя `t`, локальное имя с двумя формами | 123–126 |
| `node\[1]rooted\x` | 127 |

Отдельные пробы вне списка, [все проходят на кандидате](records/pins/tp141-probe-d01.terminal.txt): `p279i_nested` (две формы на вложенном уровне, статически и свободно), `p279j_three` (три формы), `p279d_root` (корень: место держит достигнутое значение, оба индекса `node`), `p279b_free2`, `p279e_copy3`, `p279k_model2`.

| Кортеж | Результат | Receipt |
| --- | --- | --- |
| Срез 278, G2 boot140c | 10 строк, 16 отказов: `written_form` и 7 проб вхождений не транслируются (`unknown field path segment`, `field path goes through a slot with no Structure`) в native и forced; контроли `p279k_model2` и `p278k_s_index2` проходят | [terminal](records/pins/tp141-probe-sep279.terminal.txt) |
| Кандидат 279, полный список | `SUITE 81 rows, 0 failures`, native и forced, оба roots | [terminal](records/pins/tp141-probe-full01.terminal.txt) |
| G2 boot141a | `focus141-final` 53/0 | [focus](records/pins/tp141a-suite-g2.terminal.txt) |

Мутанты ([правки](records/pins/mut279.py.txt), [прогон](records/pins/runmut279.sh.txt), [результаты](records/pins/mut279.txt)), все на `written_form`, native и forced на обоих roots:

| Мутант | Результат |
| --- | --- |
| Определение не отвечает головой (`headtext`) | отказ трансляции `unknown field path segment` |
| Присваивание считается вхождением (`puthead`) | сначала выжил: третье «вхождение» тоже не имело `x`. Проверка 118 усилена и читает само вхождение, повтор тем же бинарником даёт 118 |
| Имя места у определения (`placename`) | `invariant`: именная карта не находит голову |
| Статический индекс без строки определения (`headselect`) | отказ трансляции |
| То же через `node` (`nodeselect`) | отказ трансляции |
| Определение просит место у данных (`dataask`) | отказ `call`, R0 закрыт |
| Результат `merge` считает только строки с именем головы (`mrstext`) | отказ трансляции |
| Префикс снова определяет роль (`prefix`) | код 123: `call` не пишет `l2_written_7` в данные |

## Приёмка на замороженных байтах

Вход: 203 файла (65 source, 34 tools, 104 tests), manifest `f1cdb8230f094af59dc0153ca03117e7a5cc2307fb346f9afd03ab92cfaf404f`, `P/cold-boot141a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot141a | 15:59:23.9478940Z→16:13:30.8965757Z, BootstrapExit 0, 846.95 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot141a-quick.terminal.txt), [log](records/pins/boot141a-quick.log) |
| Сверка | source 203/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe равны изолированному rt141a | [сверка](records/pins/boot141a-compare.txt) |
| G2 focus | 16:14:30.0635449Z→16:23:52.4408663Z, SuiteExit 0, `SUITE 53 rows, 0 failures` | [terminal](records/pins/tp141a-suite-g2.terminal.txt), [log](records/pins/tp141a-suite-g2.log) |
| Полный список на G2 | 16:31:43.2943388Z→16:42:24.6359445Z, SuiteExit 0, `SUITE 81 rows, 0 failures` | [terminal](records/pins/tp141-probe-fullg2.terminal.txt) |
| G2-наблюдение | три прогона `written_form`, спек режется на 16 имён: [formg2](records/pins/tp141a-obs-formg2.terminal.txt) 16:23:56.6121264Z→16:26:30.3402479Z, 106 PASS; [form3g2](records/pins/tp141a-obs-form3g2.terminal.txt) 16:26:31.8177077Z→16:29:04.7757597Z, 52 PASS; [form4g2](records/pins/tp141a-obs-form4g2.terminal.txt), новые тела `occ_free`, `occ_free_second`, `occ_free_third`, `occ_free_bare`, `occ_model_write`, `spelled_local`, `rooted_index`, 16:29:05.8110492Z→16:31:41.8454853Z, 52 PASS. Все WitnessExit 0, forced в обоих roots с точными счётчиками, native не обходит ни одно: 30 тел | [form](records/pins/tp141a-obs-formg2.terminal.txt) |

Tuple G2, `P/cold-boot141a/quick141a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `f67e809b29ce15997e4cff532688530bbfc85bc84a7ba7118f8eb30eaf2d4324` |
| `g2/frontend/l2trans.exe` | `0b97a5e2a1690626b4d5a9b138ebdae5ee4a637f1d64cac6b7e4eb392ca8b078` |
| `g2/frontend/l1trans.exe` | `0c31837eb0c0a6cd0999b1b0649ba9849e1eb7c16347d525683f74aba6027abb` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `9b314600b2e3a8c9c27f8f16629ff113399f2916e5d8e2b615e205834862bab0` |
| `g2/runtime/driver-observe.o` | `a9cde4bfce12718bd03a675ece547110c0359bddcb6d89602297d78a2e4150c4` |

G0: `P/cold-tp140/tool141a/lmxtool-tool.exe` `ad653a65c04be2d6b4ab152394d1d996468aea8cbfd2ba40e765a15ddd512315`. Предыдущий frontend — G2 среза 278, boot140c. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp141` и `pins/source-tp141.sha256`.

Посадка [land279](records/pins/land279.command): 8 шагов exit 0 ([terminal](records/pins/land279.terminal.txt)), 203 файлов, оба подмножества consumed равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Границы и находки

- **Не закрыто.** U2 и U3 остаются открытыми: `@: Box\f two`, `@: x a\b`, `x: var\i`, позиционные hidden input и callable, приём слота по используемым полям (следующий). FULL на этих байтах не запускался.
- **Отказ достигнутой записи в immutable.** Остаётся `walk error: INVALID`; Codex: это не окончательный ответ, нужен обычный неявный `interpreter`. Строка реестра IMMUTABLE-REACHED-WRITE-NAMED.
- **Новые строки реестра.** WRITTEN-FORM-OVER-NUMBER и KNOWN-CALL-OCCURRENCE-STATIC-REFUSAL: оба статические отказы, разбирать при снятии proof-only/preflight.
- **Чтение пути в вызываемом коде с данными.** В `call: Code Data` строка `n: t\x` после `t: (int: x 5)` читает физический слот данных, то есть прежнее значение: `p279g_b` и `p279g_c` дают 0 на кортежах 278 и 279, одинаково в native и forced. Это следует из книги: «Непосредственно построенная Structure (`A: (...)`) в `A\value` выбирается из её физического графового поля. Путь не … публикует `dirty`-значение». Не дефект, но поведение стоит знать: читателю пути рабочее значение не видно до контрольной точки. [Пробы](records/cold-tp140/tests/dyn/p279g_b.lm2), [receipt](records/pins/tp141-probe-b02.terminal.txt).
- **Статическая таблица D105.** Поле определения в требовании идёт под внутренним именем, у кандидата такого нет: ребро остаётся дырой и заполняется именной картой при исполнении. `p279b_free2` и код 120 это проходят, наблюдаемой разницы нет.
- **Ошибка в моём черновике проб.** `p279k_model_full` ожидал отказ при исполнении и упёрся в статический отказ известного вызова, это строка реестра выше; `p279g_written_call` ждал 5, книга даёт 0. Оба файла и receipts оставлены.
- **Сбои сборок, все под своими метками.** [fe141a](records/pins/tp141-fe-a1.terminal.txt): `node` — слово языка. [fe141b](records/pins/tp141-fe-b1.terminal.txt): предикаты в `helpers`, а `types` идёт раньше в `frontend.c`, неявное объявление в C, перенесены в `types`.
- **Перезапуск сессии.** Работа среза шла через API Error 403 и перезапуск автором; после него сверены HEAD, живые процессы и WIP, повторов не запускалось.
- **Нарушение границ.** Один раз `ls tp140-probe/ae01 | head -n 5`, собственный каталог проб, уже после повторного правила Codex. Сообщено Codex. Дальше только точные пути.

## Документальная часть

Книга, L2 и грамматика норму уже содержат и не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs279-check](records/pins/docs279-check.command): 16:43:51.8234254Z→16:44:13.7810915Z, exit 0: 35 парных глав, 14 случаев implements, оба снимка источников, 27 парных разделов грамматики, 44 дословные выдержки, 615 импортированных файлов, ссылки, окончания LF. Манифест [evidence.sha256](evidence.sha256): `MANIFEST 155 files, 0 failed`, `VERIFIED 155 files, 0 failed`, [docs279](records/pins/docs279.terminal.txt).
