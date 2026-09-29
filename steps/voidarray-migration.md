# Миграция `VoidArray`: `Lmx {VoidArray array; Lmx *parent; LmxEntry native}` (GATE A)

Слово автора — `LMX_blog/2026-09-23.md`, «Единый физический дескриптор Array и массива детей Lmx» и «Уточнение порядка членов и отказ от псевдонима» (`size_t` вместо `int`; `array` первым, `parent` вторым; «А зачем нужен `LmxArrayDesc`?»); ответ на Q18 там же («для void использовать тот же тип что в Lmx»; очерёдность — ведущий). `native` в конце записи — автор 2026-09-25 (`next_core_tasks.md` §0 п.5). Целевой текст — `docs/L2_spec_*.md` §2.

## Запись

```text
struct: VoidArray            # до Lmx: Lmx встраивает его по значению
    size_t: size
    @: void data
end: VoidArray

struct: Lmx
    VoidArray: array         # первым: &node->array — адрес самого узла
    @: Lmx parent
    LmxEntry: native
end: Lmx
```

- `Lmx.len` (int) → `node\array.size` (size_t, число слотов детей); `Lmx.data` → `node\array.data`.
- `LmxArrayDesc` → `VoidArray`, его `len` → `size`; `LmxArrayDynamicArray` → `VoidDynamicArray {VoidArray array; size_t capacity}`.
- Прочие дескрипторы `<T>Array` (`LmxCharArray`, `LmxRangeArray`, `LmxServiceEntryArray`, `LmxPostInboxSlotArray`) сохраняют `len`: их форма — слово автора 2026-09-24, эта миграция их не трогает.

## Инвентарь до правки (read-only, `7df5672`)

`LmxArrayDesc`: 211 строк / 232 вхождения в 51 файле `dev/l2src_sandbox` (близнец `l2src` тот же), 2 в `tools/l2_harness.ps1`, 0 в `lm1/build`, `dev/l3_interp`, `l1src`. Чтения/записи `len`/`data`: у `Lmx` — 68 строк ядра, 51 строка тестов, 29 строк `dev/l3_interp`, 5 строк эмиттеров `l2trans.lm1`; у `LmxArrayDesc` — 96 строк ядра, 53 строки тестов, 9 строк эмиттеров. Зависимостей от «`parent` первым» нет: ни `offsetof`, ни адреса поля узла, ни `@@`-взгляда на узел, ни позиционных инициализаторов. Знаковые остатки `int len`: `lmx_arena_refs` (INT_MAX, `len < 0`), `lmx_merge_owned` (INT_MAX ×2, `len <= 0`), `lmx_graph_copy_owned` (`len < 0` → INVALID), `lmx_walk` (`len <= 0` ×2), `l3_thread`, `l3_recv`.

## Что сделано

- Переименование типов — механически (267 вхождений, 52 файла; резервные `*.bak_*` и `build/` не трогались).
- Поля — по объявленному типу основания (параметры и локалы каждой функции L1): `Lmx` → `\array.size`/`\array.data`, `VoidArray` → `\size`; выражения-основания (`(cast: (@: Lmx) x)\len`, `message\graph\len`, `f\roles\data`) — вручную; остаток нашёл компилятор.
- `l1trans` режет путь `x\f.g` по точке в списке аргументов вызова (`f(a, x\array.size)` → `f(a, x->array, ., size)`); такие места взяты в скобки: `f(a, (x\array.size))`. В условиях, присваиваниях и приведениях форма работает без скобок. Дверь `c.sizeof(...)` режет её даже в скобках.
- Защиты `INT_MAX` по счётчику детей и проверки `len < 0` сняты: счётчик — `size_t`; переполнение `size_t` защищено как было (`lmx_merge_add_width`, `unmatched > SIZE_MAX - total`). `<limits.h>` снят там, где стал не нужен.
- Эмиттеры `l2trans.lm1`: `l2_pl%d\\array.size < %dU`, `l2_mresult\\array.size != %dU`, `l2_entry_unit\\array.size != %uU`, `l2_nsp[%d]\\array.size`/`\\array.data`; дескрипторы (`l2_ao`, `l2_ai`, `l2_a%d_desc`, `l2_profile_array`, `(cast: (@: VoidArray) …)`) — `\\size`. Пины harness `l2_mresult\len != N` → `l2_mresult\array.size != NU`.
- Сравнения `size_t` с литералами получили `U`; счётчики `int` в трёх циклах сравниваются через приведение. Предупреждений сборки ядра меньше базы: 2459 против 2508 (`q33`); новых нет.

## Свидетели и мутанты

- `tests/lmx_dynarray_layout_selftest.lm1`: `@ pn\array` — адрес узла; `parent` сразу за `VoidArray`; `native` после `parent`; `sizeof(Lmx) = VoidArray + указатель + LmxEntry`; `array.size` держит `4294967296U`. Мутанты по копии (заголовок перегенерирован из мутированного `lmx.h.lm1`): лишнее поле `int: extra` → «Lmx is array, parent, native and nothing else»; `parent` первым → «Lmx offsetof(array) = 0» и «Lmx parent follows array»; `int: size` → «Lmx.array.size is a size_t»; контроль — 0 отказов. Чтение `len` мимо вложенности — ошибка компиляции (`Lmx` больше не имеет `len`).
- `tests/lmx_merge_selftest.lm1` 3c: `@ a\array` равен адресу узла и классифицируется `LMX_KIND_STRUCT`, не `LMX_KIND_ARRAY`; `a\array.data` — адрес слотов, который 3b классифицирует `LMX_KIND_CHILDREN`. Отдельный дескриптор — `LMX_KIND_ARRAY` (`lmx_ref_selftest`).
- `tools/gate_dynarray_capacity.ps1`: имена `LmxArrayDesc`/`LmxArrayDynamicArray` запрещены в `dev/l2src_sandbox` (исходники и тесты) и `dev/l3_interp`; на старом дереве гейт RED с местами, на миграции OK.

## Не этот срез

Спеки L1/L2, `CORE.md`, книга — fable (CHECK?). `docs/`, `steps/`, `LMX_blog/`, `provenance/` сохраняют старое имя как историю. `dev/mixa_sandbox` поля `Lmx` и `LmxArrayDesc` не читает. Самосборка `lm1/build` — 0 ссылок на `Lmx`.
