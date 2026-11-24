# Свидетельство: общее числовое значение (Value и типизированное хранилище) — принят как компонент

Составил sonnet, 2026-11-23, по CODEX-SONNET-NUMERIC-WITNESS-DRAFT-20261123-114 и
CODEX-SONNET-NUMERIC-FINAL-DOCS-20261123-132. Опирается на частное каноническое дерево `common-numeric-codex/selfbuild`
и расписки root `common-numeric-accept-20261123/root01/` (оба в
`build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable/tz-20261121/`, не отслеживаются git),
на стадию `sol-m14-field-values-01` и на исходники R. Я сборок, запусков и генераторов не выполнял; здесь только то, что
записано в расписках и видно в тексте дерева. Компонент принят ведущим по адресным распискам (раздел 0); публикацию и
хеш коммита укажет ведущий, здесь их нет. Норма, журнал автора и goal не затронуты: это исправление реализации общего
числового механизма, не семантическая поправка. Полные хеши взяты из расписок; где расписки нет, хеша нет.


## 0. Честная граница (читать первой)

- Общий числовой механизм ПРИНЯТ КАК КОМПОНЕНТ по адресным распискам (решение ведущего), но не весь 27.17. Потеря знака
  большого `NONE` и сужение `ULONG` исправлены в общих `Value`, типизированном хранилище, операторах и производителях
  литералов; ширина `ullong` локальна модулю литерала и ограниченным числовым потребителям (общую величину читает,
  например, счёт сдвига), а общий транспорт и хранилище — типизированный `Value`. Обхода в индексаторе нет.
- Получены расписки на ядро и рецепт (Tool01, Tool02, Runtime03, Kernel01, Kernel02; раздел 3) и на frontend FEH03 с
  точечными прогонами `first03` и `rest16-03` (17 строк, 0 отказов; раздел 4). Строки PASS у каждой строки с исполнением
  по 6: это 2 PASS сборки плюс 4 реальных исполнения (native и forced, каждое при root 0 и root 1), а не шесть
  маршрутов; у строк отказа трансляции PASS означает проверку отказа, а не исполнение. Все 102 строки PASS нельзя
  называть 102 маршрутами исполнения.
- История frontend: FEH01 собран (exit 0), точечный прогон 15 строк дал 24 ошибки компиляции C (голый `ullong` в LM1).
  Пакет 109 исправил его, FEH02 (exit 0) повторным прогоном `targeted15-02` снова дал 24 ошибки: настоящую
  синтаксическую ошибку L1 в моём тексте (присваивание `:=` вместо `:` в ветке NONE). Её исправил root (указание 122):
  lower `4b59810a5a3fae50b8c0fdc6469fcaf208a85b96b2bc8e5be4d1d0f6dc74f9ec`, в нём отличается ровно одна строка. На FEH03
  оба набора (`first03`, `rest16-03`) прошли без отказов (раздел 4).
- Исходный пин машинного Array (ожидается 7) остаётся ОТКРЫТЫМ (M13 и M14, ограничение сборщика): сборщик отказывает до
  эмиссии на объявлении локального Array. Обычный Array-тест `common_numeric_array.lm2` исполнен (6 PASS: 2 сборки и 4
  исполнения при native и forced, root 0 и 1; раздел 4). Покрытия raw-Array этот документ не заявляет; поддерживаемого
  машинного исходника Array пока нет (сборщик и ABI).
- Не приняты: части I и II среза индекса L2, весь 27.17, M13, M14, шаг 21.25. Не пройдены полный bootstrap, неподвижная
  точка, полный список suite и 32-битный ABI: это явная граница проверки, а не обязательные ворота каждого компонента, и
  они автоматически не обещаются; широкая самосборка стоит на границе связанного изменения после стабилизации I и II по
  быстрому руководству. Условная ветка ULONG шире SIZE_T в тексте есть, ABI 32 не заявляется.
- Открыто (раздел 5): части I и II среза индекса, весь 27.17, общий accessor индекса по FOREIGN-целым (исследуется),
  новые отказы для `u8`, `u16`, `u32`, `u64` и `uchar` недопустимы. Не приняты: все foreign-операторы, шаг 21.25, M13,
  M14, W1–W5, 32-битный ABI и полная самосборка.

## 1. Что вошло в каноническое дерево

Пятнадцать путей кода (`integration15-files.tsv`: 13 изменённых и 2 новых; `integration15-copy.log`:
`STAGED 15 files, 0 failed`): двенадцать основных (десять изменённых: девять исходников, из них шесть frontend и три
ядра, и рецепт `tools/build.lm2`; два новых теста) и три контрольных (`selfbuild/inputs.list`, `selfbuild/inputs.sha256`
и `selfbuild/tests/full-suite.tsv` с двумя новыми строками регистрации тестов). В манифест 1678 файлов входят 13 из них
(двенадцать основных и `full-suite.tsv`): два служебных файла списка входов в него сами не входят. Базовый манифест 1676
файлов (`stage-baseline-verify.log`: `VERIFIED 1676 files, 0 failed`) относится к принятому срезу пути (коммит
`753c62c82885ee2049377693d50a1f70aaf3f114`); итоговый манифест 1678 файлов снят (раздел 4). Три контрольных файла лежат
в стадии `sol-m14-field-values-01`, а не в частном каноническом дереве; их хеши взяты из `integration15-files.tsv`.

```
src/l2src/lmx_walk_values.lm2    60285881194374f64e32f673f2c87a57e59a17e1ded9084868595ca3852a205c
src/l2src/lmx_graph.lm2          68fa082158763d528a325e015b23852a16b82a52a1e14a10ef65319f2b193ec8
src/l2src/lmx_graph_run.lm2      32329ff4bc26669c7606fa496468b622162d575e1fe39539990a047ed1cd7acb
src/l2src/l2_frontend_core.lm2   8036a2265c8d3a028724140ec0fe023b539573bab5e49ff30db25c06ed04943b
src/l2src/l2_frontend_helpers.lm2 71002d6accc94971d7d826b13645caf46310e7455a03d0dc19ef01414c01b1ff
src/l2src/l2_frontend_lower.lm2  4b59810a5a3fae50b8c0fdc6469fcaf208a85b96b2bc8e5be4d1d0f6dc74f9ec
src/l2src/l2_frontend_resolve.lm2 0d47ee4e26c506e572c4fea178af2a3764047ac86f57583772e7ba8aa4c2708c
src/l2src/l2_frontend_values.lm2 c80cbe93d14b7aadeed64da3366f24f7211002d092a614a722db51c57e2f73f8
src/l2src/l2_frontend_emit.lm2   281d17f351ac88187eb8b5f93b0d6850cc06c49420082e236f40d5c0433b8d02
tests/dyn/common_numeric_value.lm2 29b093ec604993d53a0954349b41421912ad8a9b7ca9dec7a34b533636db65fe
tests/dyn/common_numeric_array.lm2 d20b64720769db2f3d3d72c0e357e47951f8c2d689dc298f0588609e8943e5d3
tools/build.lm2                  ee6213621ad998764362c05dd9addcc6beadc6cddc58e733dad4c092c931a6ca
tests/full-suite.tsv (контр.)    3dcb35e0309e91447703bf0a3218cf8355cf8a36493fed99ba338ceb970bb804
inputs.list (контрольный)        8b71fd7670c0a2e68e781be98f5b23b29984957ec37ef615c3b2a7f9afef0615
inputs.sha256 (контрольный)      d85695337cae16f29049c7fc471dcd8982dc5f9d9fee5834503ceb7786bf3254
```


### 1.1 Общий Value и типизированное хранилище

- Готовое число идёт дальше как сам `Value` (или как его типизированное хранилище), а не как слово `size_t`.
  `lmx_walk_value_load` читает фактическое поле типа (`number`, `wide`, `natural`, `longnum`, `byte`) ДО очистки выхода
  (хранилище может быть членом самого выхода) и копирует только размер этого поля, не весь временный `Value`.
- Раскладка публичного `Value` не менялась (проверка root). `tools/build.lm2` описывает запись `LmxWalkValue` (строка
  1176) и входит в изменение: в нём объявление и раскладка `Value` не менялись (по моему сравнению с HEAD), изменены
  только списки экспортов и их счётчики (раздел 1.6); подпись `lmx_walk_value_lit` изменена в `lmx_walk_values.lm2`
  (`size_t` величина стала `ullong`, добавлен знак). Общий ABI неизменным не объявляется, только раскладка `Value`;
  новые функции ядра читают поля `Value`.

### 1.2 NONE: знак и преобладающая нагрузка

- Контекстный литерал без своего типа (`LMX_TYPE_NONE`) хранит знак в `number` (0 или 1), величину в БОЛЕЕ ШИРОКОЙ из
  двух существующих нагрузок (`longnum`, если `ULONG_MAX > SIZE_MAX`, иначе `wide`) и написание `U` в `natural`. Нулевая
  величина нормализует знак в 0. Новых полей и типов нет.
- Конструктор `lmx_walk_value_lit(out, ullong величина, int U, int знак)`: величина шире обеих нагрузок отвечает
  `LMX_WALK_UNSUPPORTED` ДО очистки выхода; ни один существующий `ULONG` или `SIZE_T` отказа не получает. `ullong` здесь
  локальный тип разбора и прототипа, не транспорт числа.
- `lmx_walk_value_magnitude(Value, ullong@ величина, int@ знак)` отдаёт знак и полную величину: NONE как записано, `INT`
  и `CHAR` знаковые по фактическому знаку C (минимум без знакового отрицания), беззнаковые типы без знака.
  `lmx_walk_value_lit_fits` сравнивает знак и величину с границами типа (`INT`, `CHAR`, `UCHAR`, `UNSIGNED`, `ULONG`,
  `SIZE_T`).

### 1.3 Типизированные bin, unary и truth

- `lmx_walk_value_numeric(Value)` проверяет только то, что значение есть, это число и тип родной; слова не берёт.
  `lmx_walk_value_truth(Value, int@)` проверяет полный ноль фактического типа (в том числе `ULONG` с нулевым младшим
  словом).
- `lmx_walk_value_bin`: готовые типизированные операнды остаются в своём хранилище без копий всего `Value`, принимается
  (`lmx_walk_value_adopt`) только контекстный литерал, и тип выбирается из собственного объекта C. Счёт сдвига берётся
  из величины и знака (`count_negative` и `count >= ширина` дают `interpreter`). `lmx_walk_value_unary` работает в
  повышенном типе (`NEG`, `POS`, `BNOT`), `INT_MIN` знаково не отрицается, исходный знак литерала сохраняется до приёма.
- `lmx_walk_value_receive` отдаёт вместимость контекстного литерала `lmx_walk_value_adopt` (знак и величина против
  границ типа, иначе неявный `convert`); `lmx_walk_value_store_with_writer` пишет байты `Value` своего типа без
  промежуточного слова (тип `Value` равен типу места ПОСЛЕ обычного приёма; входной `NONE` ещё принимается до записи);
  `lmx_walk_value_materialize` переносит фактическую нагрузку по её размеру (контекстный литерал сперва принимается; без
  физического хранилища ответ `UNSUPPORTED`) и сохраняет источник до очистки выхода-алиаса.

### 1.4 Старый word API

- `lmx_walk_value_number` (слово `size_t`) оставлен только для настоящих потребителей слова и ничего не сужает молча:
  NONE шире `SIZE_MAX` и `ULONG` шире `SIZE_MAX` отвечают `INVALID`. `lmx_walk_value_num` для NONE идёт через
  `lmx_walk_value_lit`. Во frontend остаются читателями слова: ограниченный `lm_compiler_num_value` (счётчики, ширины,
  удерживаемые слова поля), проба нуля в `lm_compiler_emit_single_repeat_check` и отказный путь
  `lm_compiler_emit_selected_value_full` для места без примитивного типа C (21.25, ОТКРЫТО).

### 1.5 TLIT4 и разбор величины во frontend

- Разбор величины: `lm_compiler_num_value_span` и `lm_compiler_rw_num_lit` дают `ullong`; знак и `U` отдельно; граница
  `ULLONG_MAX` и шаг цикла как у разбора числа Graph. `lm_compiler_num_value` сохранил подпись `size_t@` и отказывает
  выше `SIZE_MAX`. Общий беззнаковый литерал и умолчание формала проверяются границами своего типа (`SIZE_MAX`,
  `UINT_MAX`, `ULONG_MAX`).
- Свободный LIT несёт четыре поля (`TLIT4`: операция, величина, `U`, знак) вместо трёх; `lm_compiler_rw_tlit` принимает
  `ullong`, отказывает выше нагрузки и при `ULONG_MAX > SIZE_MAX` пишет `lmx_walk_store_ulong` (иначе
  `lmx_walk_store_size`).
- Динамические производители литерала печатают `lmx_walk_value_lit(..., МАГНИТУДАU, U, знак)` без дополнения до
  конструктора; статус конструктора сохраняется, при не OK отмечается как сбой обхода и метод выходит.
- `lm_compiler_emit_numeric_view` читает число через фактический типизированный член (для NONE знак и величину через
  `lmx_walk_value_magnitude`, отрицание модуля в беззнаковой области) для явных C-видов (`work_decl`,
  `selected_value_full`, явное приведение); `lm_compiler_emit_full_truth_operand` даёт истинность для связок и условий;
  результат трамплина и числовой аргумент вызова пакуются типизированным временным объектом и `lmx_walk_value_load`.
- Запасные числовые пути записи элемента Array берут тип готового C-значения из статического типа места, а не из
  рантаймового `.type`; тип вне списка 0, 1, 2, 34, 36 отвечает прежним 2. Для машинного метода в каноническом
  `lm_compiler_emit_array_place` стоит ранняя ветка root (типы 0, 1, 2, 34, 36): типизированный lvalue по выбранному
  адресу, без `Value` и без приёма, затем `lmx_value_context_copy(контекст, 0)`; в тексте она есть, исполнением не
  покрыта (раздел 4).
- Пакет 109: `lm_compiler_emit_scalar_aliases` регистрирует внешний скаляр `ullong` до цикла псевдонимов, псевдоним
  профиля единицы применён в виде числа (`lm_compiler_emit_numeric_view`), а обе точки литерала по фактическому 109
  приведение сняли совсем и печатают положительную величину как `%lluU` (прототип вызываемого принимает `ullong`); без
  строки `ullong` в профиле вид числа отвечает 2. Побочный эффект: каждая единица с таблицей получает ещё одну строку
  `type:` (меняются хеши единиц).

### 1.6 Рецепт и экспорты

- `tools/build.lm2`: список `lmx_walk_values` вырос с 193 до 196 имён (`lmx_walk_value_numeric`, `lmx_walk_value_truth`,
  `lmx_walk_value_magnitude`); список `l2_frontend_lower` вырос с 427 до 428 (`lm_compiler_emit_numeric_view`, его
  вызывает core). Рецепт R: `c050cbd9a1f501534a3a95b35c843a067060b273b1ceb015031d4cc1f63d40a2`; рецепт канонического
  дерева: `ee6213621ad998764362c05dd9addcc6beadc6cddc58e733dad4c092c931a6ca`.

## 2. Правки поверх принятого среза пути (откуда что)

- Исходники frontend ведёт root после сигнала 106: `l2_frontend_core.lm2` и `l2_frontend_helpers.lm2` это пакет 97 моего
  частного набора, `l2_frontend_resolve.lm2` пакет 95, `l2_frontend_lower.lm2` и `l2_frontend_values.lm2` пакет 109
  поверх канонического lower (97, 104 и 104-array плюс ранняя ветка root), `l2_frontend_emit.lm2` пишет root.
- Мои private пакеты неизменяемы: `native-numeric-pack-sonnet/out-95`, `out-97`, `out-97-build`, `out-104`,
  `out-104-array`, `out-109`; `out-97b` заменён и не применялся.

## 3. Расписки root (kernel и recipe)

Все файлы расписок лежат в `common-numeric-accept-20261123/root01/` (корень tz-20261121 назван во вводной части).

- Tool01, `codex-numeric-s2126d-tool01`: exit 0, 0.8 мин. `lmxtool-tool.exe`
  `23c15f6a93181cb31d08617c1a56bfda010fe4f89428e779f696e18c5d94a4bf`; `lmxtool.lm1`
  `83103f6ac679315841fc9f5ccd4a570cc1e8aef940e7b3811598e485a3208a97`; рецепт
  `b7b10f78ac7bdf390756977a12eac8b553898f35e80ad981fafd5b7f9c070156`. Только рецепт, экспорты `lmx_walk_values` 193 →
  196.
- Tool02, `codex-numeric-s2126d-tool02`: exit 0, 0.8 мин. `lmxtool-tool.exe`
  `727d6bd4f12d827cb4d66f137d210d32dcefedeb7477c6e6eea1c1bd3e290b14`; рецепт
  `ee6213621ad998764362c05dd9addcc6beadc6cddc58e733dad4c092c931a6ca` (walk 196, lower 428).
- Runtime01 и Runtime02: exit 1 (ошибки компиляции ядра), root исправил две: локальный указатель `LIT4` объявлен с явным
  `void`, значение сохраняется по значению; `saved.type` внутри `c.lmx_type_base` ломал старый FE, взят готовый локал
  `ty`.
- Runtime03, `codex-numeric-s2126d-rt03`: exit 0, 1.8 мин; старый FEH01, frontend остался базовым. Входы (4 пути):
  `lmx_walk_values.lm2` `60285881194374f64e32f673f2c87a57e59a17e1ded9084868595ca3852a205c`, `lmx_graph.lm2`
  `68fa082158763d528a325e015b23852a16b82a52a1e14a10ef65319f2b193ec8`, `lmx_graph_run.lm2`
  `32329ff4bc26669c7606fa496468b622162d575e1fe39539990a047ed1cd7acb`, `tools/build.lm2`
  `b7b10f78ac7bdf390756977a12eac8b553898f35e80ad981fafd5b7f9c070156` (как у Tool01); `MANIFEST 4 files, 0 failed`.
  `driver.c` `3dbd9da37beb4245d87c6bab7f638a7df40dcf07122d2a688b1ab0a42cb1915a`; `driver.o`
  `e58946012166f755c473b6263b0ca52d3203ef49be1cc54a23ecfad7fce06531`; `driver-observe.o`
  `9dd41456005ecb2e6f373ce49d206c13631b8b8565a01fcaa8f13d5484a4f60d`; `HEADERS 124 regenerated`.
- Kernel01: тест `common_numeric_value.lm2` `f8cfcca6881bd0db8a56361ffe408087b2158450252e6faa8f69a4e38628bef4`,
  `SUITE 1 rows, 0 failures`, 6 строк PASS (2 сборки и 4 исполнения `gives 7`); проверены общие API `Value`, а не
  генерация LIT4 из исходника.
- Kernel02: тот же тест с добавленными пинами фактического знака `CHAR` и `UCHAR` 255 (коды 32 и 33),
  `29b093ec604993d53a0954349b41421912ad8a9b7ca9dec7a34b533636db65fe`, `SUITE 1 rows, 0 failures`, 6 строк PASS, из них 4
  исполнения `gives 7`; `lmx_unit_cn_values_common_numeric_value.lm1`
  `caef0b32b2bbbbd114c4f27aa78180b009a01125b5f347e425a36520a903441e`.
- Тест `common_numeric_value.lm2` содержит условный пин `ULONG` с нулевым младшим словом при `ULONG_MAX > SIZE_MAX`; его
  исполнение и 32-битный ABI этим хостовым прогоном не заявлены. Тест покрывает также: истинность, `EQ`, `SUB`, `BNOT`,
  `NEG`, запись в типизированное место, материализацию и копию ячейки, литерал `SIZE_MAX` против `-1` до выбора
  принимающего типа, `INT_MIN`, `~0U` как `UINT_MAX`, знаковый `CHAR`, `UCHAR` 255.

## 4. Frontend и Array: что получено и чего нет

- FEH01: exit 0, 6.2 мин, `l2trans.exe` `39706a0e340b712be8b4a87f8dc3c07a2a902c9adfa246361a4cbae0757d2bf6`;
  `MANIFEST 5 files, 0 failed`; входы: `l2_frontend_core.lm2`
  `8036a2265c8d3a028724140ec0fe023b539573bab5e49ff30db25c06ed04943b`, `l2_frontend_helpers.lm2`
  `71002d6accc94971d7d826b13645caf46310e7455a03d0dc19ef01414c01b1ff`, `l2_frontend_lower.lm2`
  `da0d00278743148a8e2f22fc69231cd7febebbaaf67e91f37c607c305723e0a6` (до пакета 109), `l2_frontend_resolve.lm2`
  `0d47ee4e26c506e572c4fea178af2a3764047ac86f57583772e7ba8aa4c2708c`, `l2_frontend_emit.lm2`
  `281d17f351ac88187eb8b5f93b0d6850cc06c49420082e236f40d5c0433b8d02`.
- Точечный прогон `targeted15-01` на FEH01: 15 строк, 24 отказа. Двенадцать строк компиляции в двух режимах (native и
  forced) дали `step 3 kind 0 exit 1 [CC]`: в сгенерированном C `'ullong' undeclared (first use in this function)`
  (`bit_values`, `free_result_convert`, `free_held_receive`, `free_number_places`, `typed_shift_guards`,
  `unary_complement`, `formal_defaults`, `formal_default_none_refused`, `bound_typed_reception`,
  `receiver_literal_range`, `exact_scalar_storage`, `graph_copy_names`); три строки с отказом трансляции
  (`bit_mixed_refused`, `formal_default_type_refused`, `receiver_literal_unrepresentable_refused`) дали 18 строк PASS.
  Причина (голый `ullong` в LM1) адресована пакетом 109; результат FEH02 см. ниже.
- Пакет 109 применён в каноническом дереве (lower `05c9feccdfcd473d4106787edea8b83048675b03552e853c3426be86cf2fcc2e`,
  values `c80cbe93d14b7aadeed64da3366f24f7211002d092a614a722db51c57e2f73f8`); разбор P0 обоих файлов без ошибок
  (`l2_frontend_lower-p0-109.log`, `l2_frontend_values-p0-109.log`; это синтаксис, не семантика и не компиляция C).
  Относительно FEH01 для FEH02 заменены только lower и values (`frontend-source02.list`).
- FEH02: exit 0, 7.1 мин (21:47:36 до 21:54:44, 428 с), минимум свободной памяти 2436 МБ, пик сборки около 552 МБ
  (`guard-feh02.txt`); `l2trans.exe` `fa8eca3c73a124e12053cf564f49bc0f79f183cbbec10998a90991cf64978080`; `l1trans.exe`
  `9d67ab8619fe1c0d562be55bc5cd99a12b2f77bfed918c0aee0f50b76c0370c6`; `l2_libc.o`
  `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` (так в `feh02.log`); `HEADERS 125 regenerated`. Это
  сборка frontend, не приёмка.
- Точечный прогон `targeted15-02` на FEH02 (exit 1, 0.5 мин): снова 15 строк и 24 отказа (те же двенадцать строк в двух
  режимах, `step 3 kind 0 exit 1 [CC]`), три строки отказа трансляции PASS (18 строк). Диагностика сменилась:
  `called object 'l2_castm31' is not a function or function pointer` (например `bit_values-native/p.c:529`). По тексту
  `p.lm1` и `p.c` в ветке NONE вида числа (`lm_compiler_emit_numeric_view`) отрицание величины записано в LM1 как
  `l2_castm31 := ...`, и в C оно стало вызовом `l2_castm31(...)` (`p.c:529`); остальные присваивания сгенерированного
  LM1 пишутся `имя: значение`. В первом прогоне (`targeted15-01/bit_values-native/p.CC.log`) этой строки отдельной
  диагностики нет: там `implicit declaration of function 'l2_castm31'` стоял в строке ОБЪЯВЛЕНИЯ (`p.c:519`,
  `ullong = l2_castm31 (((ullong)0));`) и вытекал из голого `ullong`, а вызов в строке 524 им закрывался. Это моё чтение
  текста; причина подтверждена исправлением root и прогоном на FEH03 (ниже).
- Исправление root (указание 122): в сгенерированном LM1 присваивание `:=` заменено на `:`; lower
  `4b59810a5a3fae50b8c0fdc6469fcaf208a85b96b2bc8e5be4d1d0f6dc74f9ec`. Моё сравнение с пакетом 109 (lower
  `05c9feccdfcd473d4106787edea8b83048675b03552e853c3426be86cf2fcc2e`): файлы одной длины (21887 строк) и различаются
  ровно строкой 12747. Разбор P0: `lower-p0-assignment122.log` (код возврата root сообщил exit 0).
- FEP03 (частичная сборка только lower; `frontend-source03.list` содержит один путь): exit 0, 3.4 мин (22:00:28 до
  22:03:52), минимум свободной памяти 2631 МБ, пик 449 МБ; в `fep03.log` четыре строки `VERIFIED 449 files, 0 failed`
  (строгое повторное использование и ABI); промежуточный `l2trans.exe`
  `1c10f74fe8dd7c7b444de149dd47fb59daff90533e66865ece1fd963d5463824` в расписках не является хостовым (ниже).
- FEH03 (связывание с хостом): exit 0, 1.2 мин (22:04:22 до 22:05:36, 74 с), минимум свободной памяти 2650 МБ, пик 573
  МБ; `l2_frontend_host.lm1` `a87c3f1598afe96428f038c4336c1053f24c510d9961494d9fd3876d00ec74b0`; `l2trans.exe`
  `9c025c31fec82f9c3ec87b9e02c207baf498c3a830dcbc7b72a9f96dd6baae30`; `launch.txt`
  `52ce29dadaeed2b1f2fcc601ad149b89f3e6fb5547dc32738e0e05b331807767`; `HEADERS 125 regenerated`; после связывания
  `lower-only-verify-after-link03.log`: `VERIFIED 449 files, 0 failed`.
- Точечные прогоны на FEH03. `first03` (`bit_values`): `SUITE 1 rows, 0 failures`, 6 PASS, 22:06:07 до 22:06:10.
  `rest16-03` (14 существующих строк и два новых теста): `SUITE 16 rows, 0 failures`, 96 PASS, 1.3 мин (22:06:28 до
  22:07:43), минимум свободной памяти 3179 МБ, пик 81 МБ. Вместе 17 строк (15 существующих и 2 новых) и 102 строки PASS
  (по тексту журналов): 28 сборок (`built`), 56 исполнений (`gives 7`: 14 строк с исполнением по 4, native и forced при
  root 0 и 1) и 18 проверок отказа у трёх строк отказа (`bit_mixed_refused`, `formal_default_type_refused`,
  `receiver_literal_unrepresentable_refused`: трансляция отказывает, отказ называет нужное слово, L1 не остаётся); это
  не 102 маршрута исполнения.
- Array, исходный пин (`pins/open-machine-local-array.lm2`, `array01`): тест `common_numeric_array.lm2` старой редакции
  `cffc7510eddda65d77ca441fca8c15bf36870514b823999f19937d5ba3a4cf61` (ULONG в локальном Array машинного модуля,
  ожидается 7): трансляция машинного модуля отказала (`L2 translation failed`, exit 1) до эмиссии на объявлении
  локального Array. Пин сохранён как ОТКРЫТЫЙ, не как проходящий тест отказа; снимается вместе с M13 и M14.
- Array, обычный тест: `common_numeric_array.lm2` текущей редакции
  `d20b64720769db2f3d3d72c0e357e47951f8c2d689dc298f0588609e8943e5d3` (готовый ULONG при записи в Array и чтении обратно,
  правая часть один раз, проверяемый транспорт, native и walker) исполнен в `rest16-03`: 6 PASS (2 сборки и 4 исполнения
  `gives 7`). Это не покрытие raw-Array: сырой машинный Array проверен только чтением и компиляцией, штатное исполнение
  от исходника до результата ОТКРЫТО (указание 108).
- Новое тестовое покрытие: `common_numeric_value.lm2` в `rest16-03` (6 PASS, из них 4 исполнения) и регистрация обоих
  тестов в `tests/full-suite.tsv`: 349 строк против 347 в HEAD, добавлены
  `machine dyn/common_numeric_value.lm2 7 nf cn_values` и `runs dyn/common_numeric_array.lm2 7 nf` (моё сравнение со
  стадией).
- Graph01 (потребитель графа на FEH03 и RT03): exit 0, 21 с (22:08:34 до 22:08:55), минимум свободной памяти 3204 МБ,
  пик 130 МБ; `graph_trans-prod.exe` `40b94fe8da37bcb82c2c6af08aebe72e3c9939e0082a9021558c93a0e4b36e55`;
  `HEADERS 125 regenerated`.
- Проверки потребителя графа (`gc2-*.log`, 22:09:32 до 22:09:34): три файла `tests/graph/init_arith.lm3`, `expr_u01.lm3`
  и `literal_typed_spellings.lm3`, по три режима (interp, native, forced), 9 строк `GRAPH-CHECK ... PASS`, исполняемый
  файл из Graph01 во всех девяти. Первая попытка `gc-init_arith.log` (22:09:14) вернула FAIL с `cannot read or parse`
  для `tests/graph/init_arith.lm3`: путь был относительным при неверном рабочем каталоге (ошибка запуска ведущего, не
  кода); с абсолютным путём той же строки PASS. Это три выбранные строки, не весь список графа.
- Итоговый манифест: `manifest-final1678.log` `MANIFEST 1678 files, 0 failed`; `verify-final1678.log`
  `VERIFIED 1678 files, 0 failed`; `unchanged1665-final.log` `VERIFIED 1665 files, 0 failed`; `inputs-final1678.sha256`
  содержит 1678 строк, sha256 этого списка `d85695337cae16f29049c7fc471dcd8982dc5f9d9fee5834503ceb7786bf3254` (хеш
  файла, мой пересчёт совпал с сообщением ведущего). Моё сравнение со списком принятого среза пути
  (`path-accept-20261123/root01/final-source.sha256`, 1676 строк): изменены 11 путей (шесть frontend, три ядра,
  `tests/full-suite.tsv`, `tools/build.lm2`), добавлены 2; 1676 минус 11 даёт 1665. Эти 13 строк манифеста равны
  двенадцати основным путям кода и `full-suite.tsv`; два служебных файла списка входов в него сами не входят (расписка
  `integration15-files.tsv`). `git diff --check` в R, по сообщению ведущего, без замечаний.

## 5. Открыто и не принято

- Открыты: части I и II среза индекса L2 (вместе), весь 27.17, общий accessor индекса по FOREIGN-целым (исследуется).
  Новые отказы для `u8`, `u16`, `u32`, `u64` и `uchar` недопустимы там, где раньше был путь через конвертер; проверка
  индекса целым видом (частный черновик CHECK, `out-117`) НЕ применена и остаётся черновиком.
- Не приняты: все foreign-операторы, шаг 21.25, M13, M14, W1–W5, 32-битный ABI, части I и II индекса, весь 27.17.
- Не пройдены и автоматически не обещаются (граница проверки, не обязательные ворота каждого компонента): полный
  bootstrap, неподвижная точка, полный список suite, 32-битный ABI; широкая самосборка стоит на границе связанного
  изменения после стабилизации I и II по быстрому руководству.
