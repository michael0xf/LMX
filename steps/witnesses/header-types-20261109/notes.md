# Растущий список типов заголовка в бэкенде — 2026-11-09 (срез 341)

Исполнитель: opus. Повод — первая проба следующего шага маршрута 331 (срез 342, импорт C-двери в граф-пути): модуль
`l2_frontend_graph.lm2` с predef-заголовками фронтенда (`l2_frontend_types`, `l2_frontend_intern`, `l2_frontend_emit`)
hosted F переводит, а l1trans boot340 G2 отказывает:
`l1trans error: l2src/l2_application.h.lm1:829:1: too many header types`
([журнал](records/runs/opus341/fg341.log), 11:57Z-3). Правило: в трансляторе нет фиксированных потолков, размер берётся
из реального числа; известный предел — отказ трансляции, не авария.

## Причина

Список уже выписанных типов заголовочной единицы (`l1_hdr_emitted`) — фиксированный массив 2048 байт: имена через NUL,
около 130 имён. Единица, чьи predef доходят и до графа ядра, и до заголовков фронтенда, объявляет больше типов. Этот
порог ещё в аудите [искусственных пределов](../../artificial-limits-20260930.md) записан как `emitted/pending[2048]`.

## Изменение (src/l2src/l1_backend_text.lm2, l1_backend_emit.lm2, l1_backend_state_helpers.lm2, tools/build.lm2)

1. `l1_hdr_name_list_add(tab, cap, n, name)`: список передаётся ячейкой (`@@: tab`) с ёмкостью `cap`; если имени нет
   и места не хватает, список растёт через `realloc` (удвоение, не меньше нужного + 2048 байт). Отказ 1 — только без
   памяти; прежние сообщения «too many header types» / «too many structs» остаются на этом отказе.
2. `l1_emit_header_unit` и `l1_hdr_mark_unit_emitted`, `l1_hdr_field_node_deps_ready`, `l1_hdr_field_first_unready`,
   `l1_hdr_fnptr_deps_ready`, `l1_hdr_diagnose_cycle` читают список через ячейку `@@: hdr_emitted_cell`.
3. `decl_l1_backend_state` (tools/build.lm2): `@: char l1_hdr_emitted 0` и `size_t: l1_hdr_emittedcap 0U` вместо
   `[]: char l1_hdr_emitted 2048`.

Не изменено (ПОЗЖЕ): прочие фиксированные массивы бэкенда — `l1_th_names`, `l1_ca_names` (2048 байт), int-массивы на
32 и 8 элементов; `l1_hdr_pending` (2048) не используется.

## Проверки

1. **Стадия.** `stage` в cold-graph309-codex01 ([журнал](records/pins/opus341-stage41.log)): манифест
   `opus341-source41` — 403 входа, 0 отказов ([манифест](records/pins/opus341-source41.sha256)). tool41 —
   `build-self` переводом frontend boot340 G2 (c7c54a1a…) ([журнал](records/pins/opus341-build-self41.log),
   [запись](records/cold-graph309-codex01/tool41/record.txt)), lmxtool-tool.exe fbea34cb…. Промежуточная связка
   fehost08 — `build-frontend-host` тем же frontend на source41 ([журнал](records/pins/opus341-build-fehost08.log),
   [запись](records/cold-graph309-codex01/fehost08/record.txt),
   [связывание](records/cold-graph309-codex01/fehost08/link-record.txt),
   [запуск](records/cold-graph309-codex01/fehost08/launch.txt)): l2trans 883916f8…, l1trans 6b513abb….
2. **Отказ и исправление на одном входе** ([журнал](records/runs/opus341/fg341c.log)). Проба — WIP среза 342
   `l2_frontend_graph.lm2`, переведённый hosted F boot341 G2 в [L1](records/runs/opus341/fg341b.lm1) (274fdcc3…),
   внутри корня единицы (CWD = src): l1trans boot340 G2 — `too many header types` на `l2_application.h.lm1:829`;
   l1trans boot341 G2 — выход 0. Ошибки gcc `-fsyntax-only` в этой пробе (функции импорта C-двери фронтенда не
   объявлены единице) — незавершённая работа среза 342, к срезу 341 не относятся.
3. **`bootstrap quick` boot341** — `T41 bootstrap quick R S B S/boot340/g2/frontend/l2trans.exe boot341
   S/tests/smoke.tsv`, 0 отказов (15:20:14→15:52:01Z; [журнал](records/pins/opus341-bootstrap-quick.log), G2 —
   [журнал](records/cold-graph309-codex01/boot341/g2-build.log)). Smoke обоих поколений — 8 строк без отказов.
   Runtime G1 = runtime G2 = rt67 (`driver.c`, `driver.o`, `driver-observe.o` байт в байт): изменение бэкенда не
   меняет выпуск единиц, которые предел не задевал. Frontend, backend и tool G1 и G2 — одни образы кроме штампа
   (`exe-same` 1), их `l2trans.lm1/.c`, `lmxtool.lm1/.c`, `l2_libc.o`, `launch.txt` — одни байты; fehost08 = frontend и
   backend G1 кроме штампа ([сравнение](records/pins/opus341-compare-g1-g2.log)).

## Связки

- boot341: [g1](records/cold-graph309-codex01/boot341/g1/bundle.sha256),
  [g2](records/cold-graph309-codex01/boot341/g2/bundle.sha256),
  [рабочая](records/cold-graph309-codex01/boot341/working-bundle.sha256); frontend G2 l2trans.exe 0d8d872f…, l1trans.exe
  d9d1fedb…; рабочий инструмент boot341/lmxtool.exe 611a83f8fc5b7b2ed365784962cb05ff40c9db77e6a0e019372ebb30bac3ddb0 (tool G2).

## Команды (P = build2/codex_fix250generationchain01, S = P/cold-graph309-codex01, B = P/cold-candidate48/full48/g2/frontend)

```text
T41 0 entry 0 -- verify P/pins/opus341-source41.sha256 S
T41 0 entry 0 -- bootstrap quick R S B S/boot340/g2/frontend/l2trans.exe boot341 S/tests/smoke.tsv
(cd S/src) S/boot341/g2/frontend/l2trans.exe 0 entry 0 -- --library --machine lm_compiler_graph_main --header
    src/l2src/l2_frontend_graph.h.lm1 src/l2src/l2_frontend_graph.lm2 src/l2src/convert.lm2 src/l2src/primitive.lm2 OUT.lm1
S/boot340/g2/frontend/l1trans.exe src/l2src/opus341_probe.lm1 OUT-old.c     # too many header types
S/boot341/g2/frontend/l1trans.exe src/l2src/opus341_probe.lm1 OUT.c         # exit 0
```

Записи из build2 скопированы `stage-copy` по [списку](records.list), хеши — [records.sha256](records.sha256) и после
нормализации LF — [records-lf.sha256](records-lf.sha256).
