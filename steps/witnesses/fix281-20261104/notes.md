# Срез 281 — запись в объявленное ссылочное поле по чтениям места (REFERENCE-FIELD-STATIC-WRITE, пятая часть U2/U3)

Опубликован 2026-11-04, Opus. Часть U2/U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences). Нормы те же, что в [записи 280](../fix280-20261104/notes.md): неиспользуемые поля не сравниваются, неизвестность не основание для запрета, отказ оставляет старое значение. Норма не менялась.

Приёмка прошлого среза: Codex независимо проверил 280 и подтвердил поставленный объём, compiler и тесты при этом не запускал; это не полное закрытие всех принимающих мест, строки реестра открыты, [дословно](records/pins/codex-280-verified.txt).

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 280

- `Holder\p: OnlyQ`, где `@: p RefBox RefBox`, у `OnlyQ` нет поля `a`, отказывал, хотя `a` никто не читает: и через корень, и через типизированную локальную, в native и forced. Такая запись шла через `lmx_walk_value_admit` с моделью поля, поэтому целиком; свободный путь уже шёл по чтениям места.
- Типизированная локальная, у которой путь останавливается на ссылочном поле, требовала от значения всю его Structure. [p281f_ref_local](records/cold-tp140/tests/dyn/p281f_ref_local.lm2): `@: l RefHolder RefHolder` с `l\p: Other` или `@: held RefBox l\p` отказывает, если поле уже держит значение уже модели, а `l\p\q` проходит. Код [92](records/tp143-probe/ctl280g/p281f_ref_local-native/run-root0.log) на G2 280: случаи 3, 4 и 5. Причина: у последнего шага пути нет `pointee`, поэтому план ставил «всё поле». Это я нашёл пробой этого среза, на кортеже 280 дефект тот же.

Разделение [sep281](records/pins/tp143-probe-sep281.terminal.txt): 8 строк, 16 отказов. `structure_slot_write` и `p281b_forms` останавливают R0 на первой записи уже модели; `p281d_stages` даёт код 201, `p281f_ref_local` код 92 вместо 71, во всех четырёх конфигурациях. Контроли `map_chain`, `place_map`, а также `p281e_local` и `p280j_reffree` проходят: эти случаи кортеж 280 уже умел.

## Механизм

- **Нативная запись.** [lm_compiler_path_write_by_slot](../../../selfbuild/src/l2src/l2_frontend_lower.lm2): лист вида 10 с моделью, не машинный метод, не письмо. Такая запись идёт `lm_compiler_emit_structure_path_store`, как у поля, держащего Structure: `lmx_walk_value_field_store` с допуском по чтениям места и единственной перепривязкой слота, ячейка поля сохраняется (`lmx_walk_slot_bind`). Курсор теперь называет слот листа и для ячейки.
- **Обходчик.** `lm_compiler_rw_path_write_rec` не проводит допуск по модели для такой записи; `PUT` над `OF` в ядре идёт в store слота, если слот объявляет модель (`lmx_walk_slot_declared`). Типизированный null остаётся обычной записью в ячейку.
- **План.** `lm_compiler_use_plan_path`: у пути, остановившегося на ссылке, модель берётся из листа. Запись через такой путь и принятое значение больше не считаются чтением всего поля.
- **Письмо не менялось.** Полезная нагрузка письма выбирается моделью, поэтому письмо остаётся на прежнем маршруте. В пакете нет теста, доставляющего письмо; свидетель здесь только один: L1 программы [p281a_letter](records/cold-tp140/tests/dyn/p281a_letter.lm2) с пустым ящиком байт в байт совпадает на кортежах 280 и 281. Значения письма при исполнении этот срез не проверяет.

Нового прохода, runner, cache и второго resolver нет.

## Свидетели

[tests/dyn/structure_slot_write.lm2](../../../selfbuild/tests/dyn/structure_slot_write.lm2), новые коды, старые остались:

| Код | Что проверяет |
| --- | --- |
| 113 | `RefHolder\p: RefOnlyQ` принят, чтение видит значение |
| 114 | `RefHolder\p: RefNoQ` отказ, старое значение стоит |
| 115, 116 | типизированная локальная: запись и отказ |
| 117 | формал: отказ |
| 119 | `@: ref_held RefBox ref_holder\p`: значение уже модели принимается локальной, которая читает только `q` |
| 118 | типизированный null: чтение через него `interpreter`, запись поверх него проходит |

Отдельные пробы вне списка, на [кандидате](records/pins/tp143-probe-d01.terminal.txt): `p281b_forms` (результат вызова, типизированная локальная, свободное значение, число как неявный `convert`, вложенный держатель), `p281d_stages`, `p281e_local`, `p281f_ref_local`, `p280j_reffree` проходят. Письмо `p281a_letter` при пустом ящике останавливает R0 на обоих кортежах, в этом списке оно только ради сравнения L1. [p281g_refstatic](records/cold-tp140/tests/dyn/p281g_refstatic.lm2) даёт [70](records/pins/tp143-probe-e01.terminal.txt): `OnlyQ` принят, `NoQ` отказан на обоих маршрутах. Та же проба на кортеже 280 давала 80, все четыре записи отказаны.

Мутанты ([правки](records/pins/mut281.py.txt), [прогон](records/pins/runmut281.sh.txt), [результаты](records/pins/mut281.txt)):

| Мутант | Результат |
| --- | --- |
| Запись снова идёт по модели (`byslot`) | все четыре конфигурации: R0 остановлен |
| Только обходчик оставляет допуск по модели (`rwmodel`) | forced на обоих roots и native root1: R0 остановлен |
| Путь, остановившийся на ссылке, снова требует всё поле (`leafmodel`) | все четыре конфигурации: R0 остановлен |
| Письмо идёт через store слота (`letter`) | **программой не пойман**: фикстура проходит, доставленного письма в пакете нет. Виден только в L1 `p281a_letter`: `lmx_walk_value_field_store` 1 вместо 0 |
| Ядро не ведёт `PUT` над ссылочным полем в store слота (`kerneldeclared`) | коды 114 и 116: запись принимается без допуска |

## Приёмка на замороженных байтах

Вход: 203 файла (65 source, 34 tools, 104 tests), manifest `9fa1f933d723fd3e8ee212fc31a6ba82ed7f6e263b9cfebad3c81c7b190d040c`, `P/cold-boot143a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot143a | 23:08:27.8454090Z→23:28:29.3404490Z, BootstrapExit 0, 1201.50 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot143a-quick.terminal.txt), [log](records/pins/boot143a-quick.log) |
| Сверка | source 203/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217 и у одного ещё 218; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe равны изолированному rt143a | [сверка](records/pins/boot143a-compare.txt) |
| G2 focus | 23:29:04.3064430Z→23:42:10.9247609Z, SuiteExit 0, `SUITE 53 rows, 0 failures` | [terminal](records/pins/tp143a-suite-g2.terminal.txt), [log](records/pins/tp143a-suite-g2.log) |
| Полный список на G2 | 23:44:47.1089295Z→23:59:12.4566807Z, SuiteExit 0, `SUITE 81 rows, 0 failures` | [terminal](records/pins/tp143-probe-fullg2.terminal.txt) |
| G2-наблюдение | `formg2` 23:42:15.0454102Z→23:44:45.9676201Z, 46 PASS: `read_ref_q` 6, `ref_local_put`, `ref_local_refused`, `ref_formal_refused`, `ref_local_held`, `ref_null_read` по 1. WitnessExit 0, forced в обоих roots с точными счётчиками, native не обходит ни одно: 6 тел | [formg2](records/pins/tp143a-obs-formg2.terminal.txt) |

Tuple G2, `P/cold-boot143a/quick143a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `48293eea210e01fd1b6e570a14ff5fb9a907ee5ac9b4c6a6e990505d1f29ed94` |
| `g2/frontend/l2trans.exe` | `d01296f2bd5d45f924093dc35ba836d032932b9ceb28996624f5d059505eb776` |
| `g2/frontend/l1trans.exe` | `fd4d6d504e6e54f2897cc2e2d1648265df115efb14e8d042b5043fd0f67c5c00` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `2909cd9f66bf682110f68b051d7f18c06d8019e7c1ad542e96ab03e3d8cf0bc4` |
| `g2/runtime/driver-observe.o` | `c2cdff5bcc352495c56565401fa0fcbd7baa4956e15374f2377e1e075479a673` |

G0: `P/cold-tp140/tool143a/lmxtool-tool.exe` `ec107e00abfd0767614e30839de876505d471340a96a7717e56a04dd24b4549e`. Предыдущий frontend — G2 среза 280, boot142a. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp143` и `pins/source-tp143.sha256`.

Посадка [land281](records/pins/land281.command): 8 шагов exit 0 ([terminal](records/pins/land281.terminal.txt)), 203 файлов, оба подмножества consumed равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Границы и находки

- **Не закрыто.** U2 и U3 остаются открытыми: `@: Box\f two`, `@: x a\b`, `x: var\i`, позиционные hidden input и callable. FULL на этих байтах не запускался.
- **RECEIVING-UNKNOWN-COVERAGE-WHOLE** остаётся: типизированная локальная без известного плана и результат спрашивают весь интерфейс, коды 103, 104, 110 закрепляют именованность отказа, а не его необходимость. Этот срез снял только случай пути, остановившегося на ссылке.
- **Письмо:** см. механизм, положительного свидетеля доставленного письма нет.
- **Написанная форма через голову-путь.** `Box\k: (int: a 8)` не транслируется: `int has no value`, и у поля-Structure, и у ссылочного поля, на кортежах 280 и 281. [p281c_written](records/cold-tp140/tests/dyn/p281c_written.lm2). Строка реестра WRITTEN-FORM-THROUGH-PATH-HEAD.
- **Поправка к записи 280 по времени.** Там стояло «Это среда, а не код». Codex, `CODEX-OPUS-280-VERIFIED-SCOPED`: чередование трёх пар не показывает заметного замедления на четырёх строках и поддерживает объяснение средой, но одно не доказывает, что средовая каждая часть роста whole. Формулировки в записи 280 и в профиле исправлены; в сообщении коммита 280 осталась прежняя, история не переписывается.
- **Ошибки в моих пробах.** `p280i_refstatic` не вызывал читателя, поэтому `NoQ` был законно принят и дальше типизированная локальная останавливала R0, красный прогон оставлен ([a01](records/pins/tp143-probe-a01.terminal.txt)). Исправляя пробу, я изменил файл, связанный доказательствами среза 280. Заметил после прогона [d01](records/pins/tp143-probe-d01.terminal.txt) и до посадки: байты восстановлены из записи 280 и совпали с хэшем, `evidence.sha256` срезов 279 и 280 перепроверены построчно, 0 расхождений; исправленная проба живёт под именем `p281g_refstatic`. В `d01` строка `p280i_refstatic` — это её содержимое.
- **Сборка.** `fe143a` собрана до исправления плана, `fe143b` с ним; это последовательные правки, не сбои.

## Документальная часть

Книга, L2 и грамматика норму уже содержат и не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs281-check2](records/pins/docs281-check2.command): exit 0, [terminal](records/pins/docs281-check2.terminal.txt), [log](records/pins/docs281-check2.log). Первая проверка [упала](records/pins/docs281-check.log): `DOCS-CTRL` нашёл управляющий символ в моей пробе `p281c_written`, строка 9, heredoc превратил обратную косую с `a` в BEL. Отказ трансляции стоит строкой раньше, поэтому результат пробы тот же; файл исправлен, проба снята заново на обоих кортежах ([281](records/pins/tp143-probe-e02.terminal.txt), [280](records/pins/tp143-probe-ctl280h.terminal.txt)).
