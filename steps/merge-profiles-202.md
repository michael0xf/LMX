# FABLE-GROK-MERGE-PROFILES-20260925-202 к.1

STARTED FABLE-GROK-MERGE-PROFILES-20260925-202: grok/merge-profiles-202 база main ed2453a (гейт GATE DONE main cc024b1: build 276/276, harness 394/394, L3 11/11, check_docs OK).

Read-only. Код в этом коммите не меняется. Файлы к.2 только свои: `dev/l2src_sandbox/lmx_merge_owned.lm1` (вызов из `lmx_walk_merge_map`), селфтест рядом, строка harness — после «go» на переворот refusal пишет Opus (`l2trans.lm1` и `tools/l2_harness.ps1` не трогаю). Ядро Sonnet (`lmx_walk.lm1`, `lmx_pool.*`) не трогаю.

## Дыра

Нативная эмиссия квалифицированного операнда уже зовёт профили. Walked root — нет.

- `l2trans.lm1:20394-20399` — для qualified operand (`oi >= 0`) пишет `l2_mprofiles[ep] = lmx_range_profile(l2_program_arena, l2_mops[k])` и отказывается, если профиль 0.
- `l2trans.lm1:20424-20426` — при `ep > 0` вызывает `lmx_merge_profiles_owned(..., l2_mprofiles, ep, ...)`.
- `l2trans.lm1:17399-17402` — тот же операнд в walked root: комментарий «the walker's merge passes none yet», затем `l2_rw_refuse(..., "a merge of a qualified branch")`.
- `lmx_merge_owned.lm1:747` — `lmx_walk_merge_map` вызывает `lmx_merge_owned(...)` с `retain_profiles = 0`, `retain_count = 0`. Обёртка `lmx_merge_owned` (`:484`) — это `lmx_merge_profiles_owned` с нулевым списком профилей.

Профиль — не число транслятора. `lmx_range_profile` (`lmx_range.lm1:341-345`) возвращает `LmxPool.profile` ячейки, либо 0. Копир удерживает такой адрес как терминал: `lmx_graph_copy_owned.lm1:462-470` (`lmx_copy_retained_profiles`: тот же указатель, чужое владение не перенимается; если адрес не классифицируется в арене назначения — `LMX_GRAPH_COPY_INVALID`).

Строки, которые сейчас RED-класс «qualified branch» и должны стать eternal-runs после посадки (Opus снимает refusal и переворачивает harness):

| fixture | harness |
|---|---|
| `unit_merge_site.lm2` | `l2_harness.ps1:826` Needle `a merge of a qualified branch` |
| `unit_eternal_shape.lm2` | `:796` |
| `unit_array_empty.lm2` | `:812` |
| `unit_array_field.lm2` | `:819` |
| `unit_eternal_multi_profile_merge_refused.lm2` | `:2074` |

Минимальный пример тикета — `unit_merge_site.lm2`: `R: merge: A B C` при `independent: const: immutable` операндах.

## к.2 (после этого плана, без чужих файлов)

В `lmx_walk_merge_map`, после проверки что каждый `refs[i]` — Structure и до `lmx_merge_owned`:

1. Для каждого операнда `p = lmx_range_profile(arena, refs[i])`.
2. Если `p != 0`, дописать `p` в локальный список (дубликаты ядра идемпотентны — как в комментарии эмиссии `:20390-20393`; не выдумывать числовой id).
3. Если список не пуст — звать `lmx_merge_profiles_owned` с этим списком (и теми же pairs/body/container, что уже декодированы). Если пуст — оставить сегодняшний `lmx_merge_owned` (ноль профилей).
4. `lmx_walk_merge_into_map` в этот срез не входит: тикет назвал `lmx_walk_merge_map`.

Селфтест (новый файл под `dev/l2src_sandbox/tests/`, не Sonnet `lmx_walk.lm1`): два операнда с разными sealed-профилями, merge через `lmx_walk_merge_map`.

- Свидетель удержания: адрес члена результата совпадает с ячейкой immutable-ветви (`lmx_range_profile` члена = профиль операнда; запись в слот результата, который есть собственная ячейка ветви, — отказ копира, не новая копия). Ориентир уже есть в `tests/lmx_multi_profile_merge_selftest.lm1:132-137` и `tests/lmx_qualified_range_selftest.lm1:160`.
- Мутант: вызов `lmx_walk_merge_map` с тем же графом, но профили принудительно не переданы (ноль в списке) — квалифицированная ветвь копируется или классификация профиля на результате 0. Этот прогон RED. Боевой путь с профилями — GREEN.

Полный машинный гейт — перед merge к.2 в main. Этот к.1 кода не меняет; последний гейт машины — `steps/gate-results.md` на `cc024b1`.

Opus после RESULT снимает refusal «a merge of a qualified branch» и переворачивает 5 строк. Совместная посадка — одной веткой, договор в `steps/`.
