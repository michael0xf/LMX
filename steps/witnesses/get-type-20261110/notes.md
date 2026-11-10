# Ресивер `getType` в чистом графе (план M6, шаг 5) — 2026-11-10

Исполнитель: fable. Норма — решение автора 2026-11-10 ([журнал](../../../LMX_blog/2026-11-10.md),
[книга](../../../docs/LMX_semantics.ru.md#get-type)): `getType(arg)` возвращает код типа участка арены, в котором лежит
адрес `arg`; аргумент — адрес или ссылка, значение без адреса — ошибка; ноль и адрес вне арены дают «нет типа»;
ресивер одинаков в интерпретаторе и в `native`. Шаг — пятый в [разделе M6 плана](../../../next_core_tasks_v3.md#m6).
Почему шаг сделан в чистом графе и как прочитаны ноль и `@u` —
[ответы исполнителя А2–А4](../../../LMX_blog/q/fable-self-answers-20261110.md).

## Изменение

1. **Ядро графа** (`src/l2src/lmx_graph.lm2`). Слово `getType` — слово состояния `w_get_type` и член списка слов
   языка (`lmx_graph_receivers_in`). Новая операция `lmx_graph_address_type(g, value, out)` говорит, какой адрес
   обозначает значение: Structure — адрес собственного заголовка; ссылка на ячейку `int` и ссылка на Lmx — адрес,
   который она хранит; `int` и слово адресом не являются — ответ 5. Тип отвечает `lmx_range_type_of` арены графа;
   для адреса, которого нет ни в одном участке, это `LMX_TYPE_NONE`.
2. **Интерпретатор** (`src/l2src/lmx_graph_run.lm2`). `lmx_graph_eval_number` читает Frame `getType` с одним
   аргументом: написанный литерал `0` — нулевой адрес, результат `LMX_TYPE_NONE`; иначе аргумент вычисляется как
   значение и спрашивается ядро. `lmx_graph_language_word` знает слово, поэтому голова `getType` в теле метода — не
   свободное имя.
3. **Эмиттер** (`src/l2src/l2_graph_tool.lm2`). `lm_graph_emit_number` выпускает вызов той же операции ядра с выходом
   по отказу; литерал `0` — константа.
4. **Рецепт** (`tools/build.lm2`). Поле `w_get_type` в шаблоне `LmxGraphState` и 59-е имя экспорта модуля
   `lmx_graph` — `lmx_graph_address_type`; из-за шаблона инструмент пересобран (`build-self`).
5. **Фикстуры** `tests/graph/get_type.lm2` с ожиданием и `tests/graph/get_type_value.lm2`; `inputs.list` — 407 входов.

## Значения

`get_type`, дамп после исполнения — одинаков в interp, native и forced:

| Строка | Значение | Что проверяет |
| --- | --- | --- |
| `int: t_cell getType(@i)` | 2 | адрес ячейки `int` |
| `int: t_ref getType(p)` при `@: p int @i` | 2 | ссылка обозначает ячейку, которую хранит |
| `int: t_uninit getType(@u)` при `int: u` | 2 | `@u` — ячейка места, а не указатель «без инициализации» |
| `int: t_box getType(Box)` | 13 | заголовок Structure |
| `int: t_held getType(h)` при `h: Box` | 13 | ссылка на Structure обозначает её |
| `int: t_null getType(0)` | 0 | нулевой адрес — «нет типа» |
| `same`, `differs` | 1, 1 | сравнение кодов между собой |
| `int: t_formal inside(7)` при `return: getType(@a)` | 2 | формал в теле `fn` |

2, 13 и 0 — нынешние значения констант ядра `LMX_TYPE_INT`, `LMX_TYPE_STRUCT`, `LMX_TYPE_NONE`; нормой они не
закреплены. `get_type_value` (`int: t getType(i)`): интерпретатор отвечает 5, native и forced останавливают R0.

Две первые пробы отказали и показали границы подмножества: форма `@: h Box` в чистом графе не исполняется (ответ 5) —
в фикстуре стоит `h: Box`; в теле `fn` ресивер отвечал 3, пока слово не вошло в `lmx_graph_language_word`.

## Кортеж и проверки

Каталог `P` — `build2/codex_fix250generationchain01`; все команды инструмента — из `P/runs/fable-m6-01`.

- **Стадия** `P/fable-main01`, наполнена из `main`: прежняя стадия `P/cold-graph309-codex01` содержит исходники ветки
  `v2`. Manifest `fable-source04` — 407 файлов.
- **Исходная точка до изменения:** `rt-f01` — `driver.o` `0ee3203b…`, побайтно `rt68` среза 342; 82 строки
  graph-check, 246 PASS.
- **Инструмент** `tool-f02` `81d3cb4b…` (собран рабочим инструментом среза 342 `22d4f0ea…`).
- **Runtime** `rt-f03` — `driver.o` `66839a96…`; **транслятор графа** `graph-f03` `f174b6f0…`.
- **graph-check:** список `fable-graph-check-f03.tsv`, 84 строки — 82 прежние и две новые; `CHECKS 84 lines,
  0 failed`, 252 PASS в режимах interp, native, forced.
- **Мутант:** в `lmx_graph_address_type` ссылка обозначает саму себя, а не хранимый адрес (`rt-f03m` `4c3e0e80…`,
  `graph-f03m` `0c5f5c36…`). `get_type` падает во всех трёх режимах (`CHECKS 1 lines, 1 failed`); в дампе
  `t_cell`, `t_ref`, `t_uninit`, `t_formal` = 1001025, `t_held` = 1001026. Стадия восстановлена `stage-copy` из
  того же manifest и сверена с репозиторием.
- **bootstrap quick** `boot-f03` (инструмент `tool-f02`, hosted frontend среза 342): `BOOTSTRAP quick 0 failures`,
  17:10:40Z–17:29:26Z. Runtime G1 и G2 — `66839a96…`, побайтно `rt-f03`; frontend (`l2trans`, `l1trans`) и
  инструмент G1 и G2 — один образ, кроме штампа линковки (`exe-same` 1 для трёх пар). Рабочий инструмент дальше —
  `P/fable-main01/boot-f03/lmxtool.exe` `2813b499…`, hosted frontend — `boot-f03/g2/frontend/l2trans.exe`
  `9f3003fb…`.
- **Документы:** перегенерация книги и `docs check` на индексе — метки `docs97-fable01` и `docs98-fable01`, выход 0.

## Не сделано

- Прежний путь понижения — рабочий frontend с его `native` и обходчиком — ресивера не знает.
- Константы `c.LMX_TYPE_*` в чистом графе недоступны: у его интерпретатора и эмиттера нет C-двери. Фикстура сверяет
  числа дампа и отношения `same`, `differs`.
- `getType(S[i])` проверяется с шагом 4.
- Адрес вне арены Message: у графа одна арена, проверен только нулевой адрес.
- `getType(x)` отдельным оператором, без потребителя результата, отвечает 3.

## Записи

[records.sha256](records.sha256): sha256 исходного файла, sha256 копии и путь копии. Копии в `records/` приведены к LF
(журналы инструмента пишут CRLF); имена файлов журналов режимов — `native-run.log`, `forced-run.log`.

- `records/pins/` — manifest исходников и оба списка graph-check;
- `records/runs/` — терминалы и выводы сборок, проверок, мутанта, bootstrap и сравнения поколений;
- `records/check-f03-get_type/`, `records/check-f03-get_type_value/`, `records/check-f03m-get_type/` — записи
  запусков и журналы двух новых строк и мутанта.
