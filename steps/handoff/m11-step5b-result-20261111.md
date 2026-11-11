# M11, шаг 5б (часть opus2): части вызываемого, Structure данных запуска, один связыватель форм, запуск Structure по имени — итог opus2

Исполнитель: opus2 (Opus 5.5). Вход: задание fable2 на мою часть 5б — шаги 1–4 подготовки (Г; Б+В+А; Д; запись пути
снаружи) и шаг 5 (один связыватель форм `call`, `fncall` и записи запуска Structure; запуск по имени в коде метода и
над поданными данными; место-ссылка в голове; `declare_place_reference` в трёх частях; коды ответов), три проверки
слов автора. Нормы — журнал [2026-11-11](../../LMX_blog/2026-11-11.md) (`#structure-call-by-name`,
`#callable-parts-visibility`, `#parser-tree-not-expanded`), ответы Р20–Р22
([ответы исполнителя](../../LMX_blog/q/fable-self-answers-20261110.md)). Коммитов нет: рабочее дерево ждёт fable2.
Документы не трогал (их ведёт sonnet2).

## 1. Что сделано, по файлам и процедурам

### `selfbuild/src/l2src/lmx_graph_run.lm2` (интерпретатор)

Шаг 1 (Г, имена частей вызываемого из его кода):
- `lmx_graph_resolve`: пропуск собственных записей кода запуска (`launched`, 5а) — только для обычной Structure,
  запущенной над поданными данными. У вызываемого собственные поля — его части (`args`, `data`, `code`, `return`), и
  они отвечают в его коде.

Шаг 2 (Б+В+А, Structure данных запуска без строк, динамическое связывание по цепочке):
- `lmx_graph_work_open_parts` (Б): строка кадра заводится только для места; именованная Lmx модели данных (не `int:` и
  не `@:`) строки не получает — её находит реестр.
- `lmx_graph_work_capture` (В): имя Structure данных — не место, захвата нет (ответ 0), запись в голое имя не создаёт
  место.
- `lmx_graph_work_load`: 5 только для числовой ячейки (`int:`).
- `lmx_graph_resolve` (А): после строк и формалов каждой активации цепочки — реестр данных этого запуска
  (`lmx_graph_data_find`); именованная Structure (не место) отвечает ссылкой, две записи и больше — ничем. Порядок:
  строки → формалы → реестр данных запуска → лексика (Р20).

Шаги 3–4 (Д, `call: Point` из кода метода; запись пути снаружи) — общими механизмами, своего кода нет.

Шаг 5 (один связыватель форм; запуск по имени; место-ссылка в голове; коды ответов):
- `lmx_graph_receivers_open`: контракты `call` — `[code]`, `[data code]`, `[args data code]`; `fncall` — `[return code]`,
  `[data return code]`, `[args data return code]` (`return` берётся как написан); записи запуска Structure — `[]`,
  `[data]`. Контракт записи запуска зарегистрирован под словом `()` — у записи нет имени ресивера, а `()` не пишется
  именем.
- Новые: `lmx_graph_forms_width`, `lmx_graph_receiver_form_of` — выбор формы по написанным фактическим (позиция,
  `:=`, для частей `fn`/`sub` ещё голова), один для всех контрактов; `lmx_graph_receiver_bind` переведён на него (и
  его рабочие массивы на 8 слотов теперь по ширине форм).
- Новые: `lmx_graph_launch_formals` (экспорт) — имена формалов фактических записи запуска; транслятор связывает той
  же функцией. `lmx_graph_launch_actual` — значение фактического (операнд `:=` или сам фактический).
  `lmx_graph_launch_operand` — операнд запуска: написанная в скобках безымянная Structure — она сама, как написана
  (`lmx_graph_merge_literal`), иначе вычисление.
- `lmx_graph_eval_explicit_call`, `lmx_graph_eval_fncall` — через связыватель; операнды в порядке записи.
- Новые: `lmx_graph_code_apart` (код отделён от данных: кадр запуска, данные ≠ код), `lmx_graph_launch_head` (экспорт:
  Structure, которую запускает запись с этой головой — через место-ссылку везде, по собственному имени — в коде,
  отделённом от данных), `lmx_graph_eval_launch_record` (формы `[]`, `[data]`; запуск — `lmx_graph_call_data`).
- `lmx_graph_block` (режим 0): после вызова вызываемого — запуск записи; иначе как прежде (8 / 5).
- `lmx_graph_exec_statement`, `lmx_graph_root_declares`: голова — место-ссылка на обычную Structure — запуск (корень
  исполняет его уже сейчас).
- `lmx_graph_eval_number`: запись запуска Structure на месте операнда — 5.
- Новая `lmx_graph_scan_launch` и правка `lmx_graph_work_scan` (обход кода при открытии кадра): в записи запуска
  (`call`, `fncall`, голова — обычная Structure) именованный фактический выбирает формал запуска, а не свободный вход
  кода; написанная безымянная Structure — данные как написаны, обход из неё ничего не читает (у `merge` такой операнд
  читается значениями, как прежде).

### `selfbuild/src/l2src/l2_graph_tool.lm2` (эмиттер)
- Новые `lm_graph_launch_actual`, `lm_graph_emit_launch_operand`.
- `lm_graph_emit_explicit_call`, `lm_graph_emit_fncall` — связывание при трансляции (`lmx_graph_launch_formals`), операнды
  в порядке записи; нет формы — отказ там, где код до записи доходит.
- `lm_graph_emit_apply_or` — ветка запуска: голова решается при исполнении (`lmx_graph_launch_head`), форма — при
  трансляции; нет формы — отказ (5) там, где запускается.
- `lm_graph_emit_block` (код метода): `apply_or` и тогда, когда трансляция видит обычную Structure.
- `lm_graph_emit_number`: голова — обычная Structure на месте операнда — отказ при исполнении, а не ошибка трансляции.

### `selfbuild/tools/build.lm2`
- Экспорт `lmx_graph_run`: +`lmx_graph_launch_formals`, +`lmx_graph_launch_head` (43 → 45).

## 2. Фикстуры (`selfbuild/tests/graph`, все в `inputs.list`)

Шаги 1–4 и проверки автора (11, положительные; `.expected` — секция AFTER интерпретатора):

| Фикстура | Что показывает | Итог |
|---|---|---|
| `callable_part_names` | имя части `args` из кода вызываемого (Г) | `seen 2` |
| `callable_data_structure` | Structure данных вызываемого видна коду ссылкой, без строки (Р20) | `seen 4` |
| `callable_data_write` | запись пути в коде пишет сам экземпляр; второй вызов и чтение снаружи видят её | `first 2`, `second 3`, `outside 3` |
| `callable_data_path_write` | запись пути снаружи (`f\data\Point\x := 8`) видна вызываемому | `seen 8` |
| `callable_data_call` | `call: Point` в коде вызываемого — Point над собой, один экземпляр | `seen 2` |
| `given_data_structure` | код над поданными данными читает их Structure ссылкой (В) | `seen 4` |
| `callable_data_shadow` | Structure данных запуска раньше лексики | `seen 3` |
| `caller_data_dynamic` | Structure данных вызывающего — динамически, раньше лексики | `seen 3` |
| `callable_if_write` | проверка автора: запись в теле `if` меняет переменную метода | `seen 5` |
| `inner_write_local` | проверка автора: голая запись внутреннего метода не меняет объемлющий | `seen 19` |
| `inner_reads_outer` | проверка автора: внутренний метод читает объемлющий | `seen 7` |

Шаг 5, положительные (5):

| Фикстура | Что показывает | Итог |
|---|---|---|
| `struct_launch_method` | в коде вызываемого `Own()` — над собой; `Bump(Counter)`, `Bump(data := Counter)` — над данными | `seen 72` |
| `struct_launch_given` | то же в коде над поданными данными (`Step(Inner)`, `Step(data := Inner)`, `Twice()`) | `seen 21`, `twice 2` |
| `place_reference_launch` | голова — место-ссылка на обычную Structure: `p()`, `q(D)` в корне, `p()`, `q(data := D)` в коде | `seen 320` |
| `struct_launch_literal` | данные — безымянная Structure в скобках: `Add(data := (int: v 5))`, `call((int: v 3); Add)` в коде и в корне | `seen 8`, `after 12` |
| `call_named` | именованная и смешанная подача `call`, `fncall` в корне и в коде вызываемого | `named 12`, `mixed 12`, `with_args 17`, `in_method 13` |

Шаг 5, отрицательные (5 новых и одна переписанная):

| Фикстура | Запись | Ответ |
|---|---|---|
| `struct_launch_two` | `Bump(A B)` в коде — два позиционных, формы нет | 5 |
| `struct_launch_args` | `Bump(args := A)` — аргумент другого имени, формы нет | 5 |
| `struct_root_declares` | `S()` в корне рядом с объявлением `S` — объявление до 5г; голое имя `S` | 3 |
| `struct_launch_operand` | `int: r S()` — запись запуска на месте операнда | 5 |
| `place_reference_unknown` | прежний текст `declare_place_reference`: `p` → Model, `p: other`, `other` неизвестно | 3 |
| `declare_place_reference` (переписана, имя то же) | `@: p int @i`, `p: other` — ссылка указывает не на вызываемое и не на Structure | 8 |

## 3. Проверки (P = `build2/codex_fix250generationchain01`, сцена NS = `P/fable-main01`, квитанции в `P/runs/opus-m11-5b`)

Кортеж: frontend `NS/boot-f24/g2/frontend/l2trans.exe`, база `P/cold-candidate48/full48/g2/frontend`, инструмент сборки
`NS/boot-f24/lmxtool.exe` до шага 5, с шага 5 — `NS/tool-o03/lmxtool-tool.exe` (build-self: экспорт `lmx_graph_run` изменён;
квитанция `build-self-tool-o03.out`; sha256 501077fb…). Каждая метка — новая, ни одна не переиспользована.

| Шаг | Манифест (файлов) | Runtime / граф | Список (строк) | Квитанция | Итог |
|---|---|---|---|---|---|
| 1 (Г) | `opus-source11` (501) | `rt-o11` / `graph-o11` | `opus-graph-check-o11.tsv` (131) | `checks-o11.out` | 131, 0 failed |
| 2–4 (Б+В+А; Д; путь снаружи) | `opus-source12` (511) | `rt-o12` / `graph-o12` | `opus-graph-check-o12.tsv` (131) | `checks-o12.out` | 131, 0 failed |
| фикстуры шагов 1–4 и проверок автора | `opus-source13` (521) | `rt-o12` / `graph-o12` | `opus-graph-check-o13.tsv` (141) | `checks-o13.out` | 141, 0 failed |
| 5, первая сборка | `opus-source14` (521) | `rt-o14` — отказ трансляции | `opus-graph-check-o14.tsv` — не запускался | `build-runtime-rt-o14.out` | см. ниже |
| 5 | `opus-source15` (521) | `rt-o15` / `graph-o15` | `opus-graph-check-o15.tsv` (141) | `checks-o15.out` | 141, 1 failed |
| 5, правка обхода кадра | `opus-source16` (521) | `rt-o16` / `graph-o16` | `opus-graph-check-o16.tsv` (141) | `checks-o16.out` | 141, 1 failed |
| 5, фикстуры | **`opus-source17` (536)** | **`rt-o16` / `graph-o16`** | **`opus-graph-check-o17.tsv` (151)** | **`checks-o17.out`** | **151, 0 failed** |

- `rt-o14`: frontend не типизирует путь поля (`state\w_call`) как аргумент функции модуля — «assignment value has
  unknown type, atom=state» (`NS/rt-o14/lmx_graph_run.L2.log`). Существующий код всегда кладёт такое слово в локальную
  переменную (`w_fn := state\w_fn`); сделал так же. Метка `rt-o14` сожжена, `graph-o14` не строился.
- `checks-o15`, `checks-o16`: единственный упавший — `declare_place_reference` в режиме interp (прежний текст фикстуры:
  ссылка на обычную Structure теперь запускает её, ответ 3 вместо 8). Это задуманный переворот: фикстура переписана в
  `opus-source17` (часть 1 из трёх), прежний текст ушёл в `place_reference_unknown` (часть 3).
- Между `o15` и `o16` — правка обхода кадра (`lmx_graph_work_scan`, `lmx_graph_scan_launch`): без неё код вызываемого
  с `call((int: v 3); Add)` или `Add(data := (int: v 5))` отказывал при входе (3) — обход читал написанную безымянную
  Structure как объявление места `v` самого вызываемого.
- Итог: рабочее дерево `selfbuild` = манифест `opus-source17` (536 файлов, `sha256sum -c` без расхождений), сцена
  заполнена им (то же). Последняя сборка: `rt-o16` (driver.o d5e73aef…), `graph-o16` (graph_trans-prod.exe 289bcd56…).
  `pins/opus-graph-check-o17.tsv` — 130 строк `fable-graph-check-f26.tsv` на `rt-o16`/`graph-o16` и 21 новая строка 5б;
  три режима (interp, native, forced) у каждой строки.
- Пробы шага 5 (`runs/opus-m11-5b/q22…q46.lm2`, выводы `r15-*.out`, `r16-*.out`) — до фикстур; ответы совпали с
  фикстурами.

## 4. Мутанты

Каждый мутант: правка `sed` в файле сцены (манифест `opus-source17`), сборка `rt-omK`/`graph-omK` инструментом
`tool-o03`, свой список `pins/opus-graph-check-omK.tsv` (строки списка `o17`), затем сцена восстановлена из манифеста
(`stage-copy`, квитанции `ostage17rK.out`) и сравнена с репозиторием (`cmp`: «restored»). Скрипт и вывод:
квитанции `build-runtime-rt-omK.out`, `build-graph-graph-omK.out`, `checks-omK.out` в `runs/opus-m11-5b`.

| Мутант | Шаг | Правка | Строки | Итог |
|---|---|---|---|---|
| m1 | 1 (Г) | `lmx_graph_resolve`: пропуск собственных записей и для вызываемого (`… method(…) = 0` → `!= 7`) | `callable_part_names` | 1 из 1 убит (все три режима) |
| m2 | 2 (Б) | `lmx_graph_work_open_parts`: строка и для Structure модели (`head != 0` → `head = 0`) | `callable_data_structure`, `callable_data_write`, `callable_data_call` | 3 из 3 (все режимы) |
| m3 | 2 (А) | `lmx_graph_resolve`: реестр данных запуска в цепочке снят (`found := 0U`) | `caller_data_dynamic`, `given_data_structure`, `struct_launch_given`, `callable_data_shadow` | 4 из 4 (все режимы) |
| m4 | 2 (В) | `lmx_graph_work_capture`: Structure поданных данных требуется как место (`head != 0` → `head = 0`) | `given_data_structure` | 1 из 1 (все режимы) |
| m5 | 5 | «запись с головой-Structure отказывает, как прежде»: `lmx_graph_launch_head` всегда 0 | `struct_launch_method`, `struct_launch_given`, `place_reference_launch`, `struct_launch_literal`, `place_reference_unknown` | 5 из 5; у `place_reference_unknown` — interp (ответ 8 вместо 3), native и forced проходят: отрицательной строке там нужен лишь выход 1 |
| m6 | 5 | «именованный аргумент читается операндом, как прежде» (интерпретатор): `lmx_graph_launch_actual` отдаёт сам фактический | `call_named`, `struct_launch_method`, `struct_launch_literal` | 3 из 3: interp и forced; native проходит — эмиттер разворачивает `:=` сам (m7) |
| m7 | 5 | то же в эмиттере: `lm_graph_launch_actual` не разворачивает `:=` | `call_named`, `struct_launch_method`, `struct_launch_literal` | 3 из 3: native; interp и forced проходят — интерпретатор разворачивает `:=` сам (m6) |

Шаги 3 и 4 своего кода не имеют, своих мутантов у них нет: `callable_data_call` убит мутантом m2 шага 2,
`callable_data_path_write` ни в один список мутантов не входил.

## 5. Пределы и замеченное (не сделано в 5б или не норма)

1. **Корень и Structure над собой до 5г.** Роль кода у записи с головой — обычной Structure они не исполняют: в корне
   `S()` остаётся объявлением (ещё одно вхождение `S`; фикстура `struct_root_declares`, ответ 3 на голое имя), в
   Structure над собой такая запись, как и прежде, — 5 (пробы q22, q23 рабочего каталога). Через место-ссылку запуск
   действует везде, корень включая (Р22, п. 2).
2. **`data()` в коде метода** по-прежнему пропускается: запись с головой `data` в теле проходит (`lmx_graph_block`,
   ветка `w_data`). Р21, п. 7 («запуск данных текущего запуска над ними же») в этом шаге не исполнен.
3. **Безымянная Structure как единственный позиционный аргумент записи.** P0 читает `Add((int: v 7))` как
   `Add: int: v 7` — хвост записи, одно поле которого — место, а не Structure; ответ 5, как у `call` с такими данными
   (Р22, п. 3). Безымянная Structure подаётся по имени (`Add(data := (int: v 5))`) или вторым операндом `call` через `;`
   (`call((int: v 3); Add)`) — фикстура `struct_launch_literal`.
4. **Чтение «целиком» (whole-arguments) и подача головой** (`name: value`) остаются у частей `fn` и `sub`; у `call`,
   `fncall` и записи запуска — только позиция и `:=` (Р22, п. 4). `fncall(Body)` — 5, как прежде (`fncall_arity`).
5. **`return` на месте операнда** в коде вызываемого отвечает частью (проба q16: `length(return)` — 4, у `length` слово
   не Structure). Общим механизмом, своего кода нет; фикстуры нет (по слову fable2).
6. **Пустая ссылка.** `@: p 0` — 4, `@: p` — 5 на своей строке: пределы среза (книга их описывает, не 5б). Поэтому
   голову «пустая ссылка» (ответ 8 по Р22, п. 2) показать фикстурой нельзя.
7. **Блок `end:` в скобках части `data`** оставляет лишнюю запись `end: Point` (P0): фикстуры 5б пишут Structure данных
   вызываемого одной строкой; это более поздняя часть 5б (опись sonnet2).
8. **Строки контрактов в пространстве корня.** Контракты `call` и `fncall` записаны строками пространства под своими
   словами, как `fn` и `sub`; голое слово `call` на месте операнда теперь находит контракт (как прежде `fn`). Слова языка
   на месте головы и операнда отвечают, как прежде (2).

## 6. Для проверки

- Манифест `P/pins/opus-source17.sha256` (536 файлов): `sha256sum -c` из `selfbuild` и из `P/fable-main01` — без
  расхождений (проверено после всех мутантов).
- Список `P/pins/opus-graph-check-o17.tsv` (151 строка) → `P/runs/opus-m11-5b/checks-o17.out`:
  `CHECKS 151 lines, 0 failed`. Повтор: `NS/tool-o03/lmxtool-tool.exe 0 entry 0 -- checks P/pins/opus-graph-check-o17.tsv`
  из своего каталога `P/runs/<метка>`.
- Сборка: `build-self-tool-o03.out`, `build-runtime-rt-o16.out`, `build-graph-graph-o16.out`.
- Мутанты: `P/pins/opus-graph-check-om1.tsv` … `om7.tsv` → `checks-om1.out` … `checks-om7.out`; восстановление сцены —
  `ostage17r1.out` … `ostage17r7.out`.
- Файлы правки: `selfbuild/src/l2src/lmx_graph_run.lm2`, `selfbuild/src/l2src/l2_graph_tool.lm2`,
  `selfbuild/tools/build.lm2` (только список экспорта), `selfbuild/inputs.list` (+37 строк), `selfbuild/tests/graph`
  (21 новая фикстура, 16 файлов `.expected`; переписана `declare_place_reference.lm2`).
