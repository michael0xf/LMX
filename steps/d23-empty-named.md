# D-23 — empty Structure as one named argument

## План

`take(x: ())` — один именованный аргумент, значение пустая Structure, не вызов `x`. P0 даёт кадр `x` с одним пустым Structure-полем. Голова совпадает с формалом типа Structure (`E: x`), тело пустое.

- Тип без полей: `E: ()` / `end: E`. `lmx_arena_refs_open_owned` отказывает на нуле, поэтому форма — узел длины 0. Допуск пустого значения к такой форме — YES (у Consumer нет детей).
- Проверка: `l2_named_empty_actual` не зовёт `l2_check_fields` на этот кадр. Сканер не делает `x` динамическим входом.
- Корень (walker): `l2_rw_empty_arg` — FRESH пустого узла, `lmx_walk_admit` к `E`, аргумент вызова. Нативный вызов внутри метода — `lmx_node_new_owned` и `l2_emit_admit`.
- Свидетель `unit_matrix_empty_named_value`: Entry 7. Пины `lmx_walk_admit`, `LMX_WALK_OP_FRESH`. Мутант «голова снова вызов» — «unknown method», frame=x.
- Не этот срез: непустой именованный аргумент (`n: 1`), D-24, Q7, D-81, полный `implements`.

## RESULT

Ветка `grok/d23-empty-named`. База main `587e05e`.

Свидетель Entry 7. Мутант измерен: `l2_named_empty_actual` сразу `return: 0` — `unknown method`, frame=x; откат переводит.

Гейт: build 282/282 (`build/l2src/20260926_023817`), harness 412/412 (`build/l2_harness/20260926_023552`), L3 11/11, имена 69/128, check_docs OK. Ядро не менялось.
