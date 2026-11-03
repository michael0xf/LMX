# Срез 272 — потребители свободного значения: C ABI, запись поля, length

Опубликован 2026-11-03, Opus, единственный writer/build по [передаче](../../../to_opus.md).
Срез закрывает пункты §5 передачи про raw-only consumer при известном C ABI и свидетели
адреса descriptor/DESC. Это зависимость N4-U, не завершение C, source-occurrence, общего
collector, трёх обходов, FULL или §§8/8a.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records)
приведены к UTF-8 LF без BOM и хвостовых пробелов, исходные receipts в P/pins не
менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Что изменилось

Свободное значение — запись `LmxWalkValue` без типизированной сырой проекции. Его получают
потребители, которым раньше нужен был статический тип. Новых норм нет, кроме применения
уже описанных к этому значению.

**Известный C ABI.** Объявление C-функции в predef-документе — единственный источник контракта.

- `lm_compiler_cproto_type_ft`, `lm_compiler_cproto_decl_read`: чтение L1-формы параметра и
  результата из корневых объявлений и `prototype`-кадров, затем из вложенных predef.
- Фактический аргумент: указательное место C-двери принимает ссылку с глубиной места, лист
  `LMX_TYPE_NONE`, потому что C-тип указуемого решает сам вызов. Число там же — `convert`.
- Объявленный результат читается только рядом с runtime-типизированным значением
  (`quote + c.lmx_type_base(2)`, `quote: c.strchr(…)`). `c.X` в обычной типизации остаётся
  опаковым.
- Ядро: `lmx_walk_value_cast_address`, `lmx_walk_value_cast_operand` для cast к указателю и
  числу; `lmx_walk_value_size` и общая таблица `lmx_walk_type_size` для `c.sizeof(quote)`.
- `lmx_walk_index` принимает индекс обычным приёмом `size_t`: другое число или ссылка дают
  implicit `convert`, как в native, а не INVALID.
- U-литерал рядом со свободным операндом в walked-теле несёт величину и суффикс
  (`lm_compiler_rw_dyn_side_ty`).

**Запись поля по имени.** Книга (L3, построение): путь с хвостом передаёт значение существующему
полю после обычного допуска. Раньше запись `quote\inner: v` допуска не проходила, поэтому
несовместимая Structure записывалась молча, а типизированное чтение падало с `UNSUPPORTED`.

- Транслятор записывает модель объявления и для ссылочного поля: `lm_compiler_emit_ns_names`
  печатает `lmx_source_place_model_set` для kind 10 по `lm_compiler_nsf_pointee`. Для kinds 2 и
  3 это было со среза 264.
- `lmx_walk_value_field_place` сохраняет координаты поля для записи, `lmx_walk_value_named_place`
  теперь её форма без них. `lmx_implements_receive_cell` — допуск по модели физического слота,
  `lmx_implements_receive_data_field` проверяет свою область и вызывает её.
- `lmx_walk_value_field_store`, общий для обоих исполнителей: ссылка проходит допуск к модели
  слота; ссылка не на Structure в слоте с моделью — `convert`; поле с Array принимает Array того
  же типа элемента, поле с Structure — Structure, иначе `convert`. Слот, держащий значение прямо,
  перепривязывается как в PUT_REF (`lmx_graph_ref_store_in`).
- `lmx_walk_value_store_with_writer`: в ссылочное место число — `convert`, контекстный литерал 0 —
  присутствующий null. Отказ для descriptor-места у общего PUT сохранён.
- Native: `lm_compiler_emit_actual_path_place_field`, `lm_compiler_emit_received_place_store_field`.
  Защита записи смотрит на `storage` места, потому что у прямого слота записывается слот, а не
  держимое значение. Walker: `lmx_walk_field_selector`, `lmx_walk_field_target` для `PUT` с
  дочерним именованным `OF` и `PUT_OF`.

**`length`.** `lmx_walk_value_length`: фактический Array записи, иное значение — `convert`,
присутствующий null — `interpreter`. Native печатает вызов в `lm_compiler_emit_free_length`,
walker `LMX_WALK_OP_LENGTH` идёт через запись и эту операцию. `lmx_walk_array_from` потерял всех
вызывающих и удалён вместе с экспортом.

**Свидетели** (`runs … 7 nf`, строки в `tests/full-suite.tsv`, 3 новых входа):

- `tests/dyn/free_c_abi.lm2` — все формы известного C ABI, 81..98.
- `tests/dyn/free_field_places.lm2` — ссылочное поле: запись и типизированное чтение, `implements`
  с сохранением значения, `convert` на число, null, адрес поля (`@ (quote\ref)`), адрес
  descriptor-слота Array и чтение через него, `length` Array, числа и Structure.
- `tests/dyn/free_slot_rebind.lm2` — прямые слоты: именованный ребёнок и Array, неподходящие
  значения, типизированные читатели.

`tools/build.lm2`: `walk_value_names` 161, `implements_names` 64, объявления новых операций. Новые
экспорты требуют нового tool и runtime, поэтому G0 — `tool134c`.

## Приёмка на замороженных байтах

Вход: 188 файлов, manifest `b9ccd9a50c72e4d0dcd14193ee70c797671a60ec720f1324f91149394a08722b`,
`P/cold-boot134b`. Первый запуск boot134a я сам остановил через 4 минуты, когда разделил
фикстуру и пакет изменился; [его терминал](records/pins/boot134a-detached.terminal.txt) содержит только
метку остановки, его результат нигде не использован.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Компонентный фокус | `tool134c`, `rt134d`, `fe134b`: 7 строк, 42 PASS, 0 отказов | [terminal](records/pins/tp134-probe-s08.terminal.txt), [список](records/pins/focus134-field.tsv) |
| Whole boot134b | 15:07:14.6776444Z→15:25:40.1074512Z, BootstrapExit 0, 1105.43 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot134b-quick.terminal.txt), [log](records/pins/boot134b-quick.log) |
| Сверка source | 188/0 против manifest | [сверка](records/pins/boot134b-compare.txt) |
| Producers | g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0 | там же |
| Цепочка | G1 frontend собран G2 frontend среза 271 `71f8b555…`; G1 runtime/tool и G2 frontend — G1 frontend `113a498e…`; G2 runtime/tool — G2 frontend `c2ea29ac…` | там же |
| Инвентари | 248/248, пересчитано 496 фактических хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только байтами 136, 137, 216, 217 | там же |
| Consumed | 306/306, файлы raw-equal | там же |
| Рабочие артефакты | рабочий tool и bundle равны G2; runtime равен изолированному `rt134d` | там же |
| G2 focus | 15:26:32.8514172Z→15:30:24.1524334Z, SuiteExit 0, `SUITE 36 rows, 0 failures`, в списке 3 новые строки | [terminal](records/pins/tp134b-suite-g2.terminal.txt), [log](records/pins/tp134b-suite-g2.log), [список](records/pins/focus134-final.tsv) |
| G2-наблюдение free_field_places | 15:30:35.9251104Z→15:30:51.0011868Z, WitnessExit 0, 106 PASS; результат 7 во всех запусках; forced в обоих roots: m 1, outer_address 1, slot_element 1, slot_size 1, outer_ref 1, put_ref 1, read_ref 3, ref_address 1, put_ref_wrong 1, put_ref_number 1, put_ref_null 1, size_items 1, outer_array 1, size_self 3, outer_number 1, outer_structure 1; native этих тел не обходит | [terminal](records/pins/tp134b-obs-fieldg2.terminal.txt), [log](records/pins/tp134b-obs-fieldg2.log) |
| G2-наблюдение free_c_abi | 15:31:05.9418718Z→15:31:22.7476597Z, WitnessExit 0, 46 PASS; forced в обоих roots: m 1, index_value 2, plus_u 1, outer_index 1, outer_index_int 1, outer_result 1 | [terminal](records/pins/tp134b-obs-abig2.terminal.txt), [log](records/pins/tp134b-obs-abig2.log) |

`through_slot` содержит машинный cast и остаётся native, поэтому его нет в наблюдении. Для
`free_slot_rebind` наблюдения нет: перепривязка прямого слота именованной Structure — запись кода
(`lmx_code_write`, дизайн §4.4), runtime сбрасывает слова выше, и следующие тела в native-сборке
идут обходчиком. Проверка «native этих тел не обходит» здесь по норме неверна. Строка `runs`
проверяет результат 7 в обоих режимах и обоих roots.

Tuple G2, `P/cold-boot134b/quick134b`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `f4b4ae5db4b47b05a306a4f6b0794a30f67d2de2db1f4c0e8bb4ec8c420e56e5` |
| `g2/frontend/l2trans.exe` | `c2ea29ac1de629a67dff67464f2cc9c77a32db95d3ad7f80d866087d3cd81fa2` |
| `g2/frontend/l1trans.exe` | `098eb511580fcdd0840154a0f84c0d9df3d3d4c88be28f44687c8c556c151652` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `4ec41ad7c5f9627d988dd0fdd0d92f5c5110197fb30c90a8e5bf38a335c299c7` |
| `g2/runtime/driver-observe.o` | `05f9d39593efd7e203f153426e59a50ae1a8cf856c22c06546d4f04f1f19e180` |

G0: `P/cold-tp134/tool134c/lmxtool-tool.exe` `861fb1efa0cb78b07f456dfdad33a09a37e3689b4985fb4da0d3294fe91696d2`.

## Посадка

[land272](records/pins/land272.command), новым рабочим tool, каждый шаг из своего CWD: verify,
stage-copy, manifest и stage-copy `inputs.list`, manifest, verify, verify обоих поднаборов consumed.
Все 8 шагов exit 0 ([terminal](records/pins/land272.terminal.txt)); 188 файлов, 0 сбоев, оба поднабора
по 65 исходников проверены против `selfbuild`.

`selfbuild/inputs.sha256` побайтно равен frozen-манифесту: `B9CCD9A5…`. Нормализация не потребовалась.
`inputs.list` — `69b70ac8b9ffbc4618fc5d0ddce43e74857c4f561baf5050447832913c700ee4`.

## Границы

Закрыто этим срезом только для свободного значения. Остаются размещёнными отказами транслятора,
потому что контракт неизвестен или форма не строится:

- C-функция без объявления в predef; variadic-позиция; опаковый C-операнд рядом со свободным
  значением (`quote + c.abs(2)`, `quote < c.INT_MAX`); `quote: c.abs(-7)`.
- `[]: xs quote`: привязке Array нужен статический контракт элемента. Свободное имя и так читается и
  индексируется как Array, отдельная привязка не требуется.
- `xs: quote` у собственного Array и типизированное `Box\items: Other\items`: прежние общие
  отказы, не связанные со свободным именем.
- Типизированное `Box\kid: Other` у именованного ребёнка остаётся
  [PATH-HEAD-WRITE-READ-AS-CALL](../../defects.md): транслятор читает его как вызов. Запись тем же
  путём через свободное имя теперь следует норме.

Не проверено: константы `define:` из predef рядом со свободным значением. Лист DESC в
`lmx_walk_value_receive_pointer` по-прежнему без свидетеля: типизированного места с этим листом в
сегодняшнем L2 нет, `LmxArray` без `c.` — неизвестный тип. Свидетели descriptor/DESC этого среза —
адрес слота и запись слота.

Найдено и не исправлено: тело с машинной операцией (например cast) не имеет обхода. Запись кода
сбрасывает `native` выше по кодовым связям, и такое тело после неё даёт `walk error: UNSUPPORTED` при
следующем вызове, хотя само не менялось. Это пункт U5 плана
([«если изменённое тело содержит L2…»](../../../next_core_tasks_v3.md#code-data-occurrences)).
Рядом: `lmx_implements_receive_cell` отвечает `UNSUPPORTED`, если строка модели есть, а самой модели в
арене нет; такого случая в свидетелях нет.

Дальше по §5: source-occurrence (U1–U3), снятие вывода throws, остатки proof-only/preflight, общий
collector/resolver, три прохода, FULL, §§8/8a. FULL на этих байтах не запускался.

## Документальная часть

`optimization_design_review_from_codex_20261101.md` включён в Git без изменения байтов
(`335E85B4…`, сверено с индексом): на него ссылается дизайн, это история ревью до среза 260.
`git diff --cached --check` отмечает в нём лишнюю пустую строку в конце; байты файла Codex сохранены,
других замечаний нет.

Книга и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на
проиндексированных путях среза, [docs272-check](records/pins/docs272-check.command),
15:34:36.0665307Z→15:35:04.8851310Z, exit 0: 35 парных глав, 14 случаев implements, 27 парных разделов
грамматики, 44 дословных фрагмента, 615 импортированных файлов, ссылки
([log](records/pins/docs272-check.log)). После неё менялись только эта запись, `evidence.*` и архивные
копии.
