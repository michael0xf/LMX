# Объявление остаётся записанным, функцию создаёт обход — 2026-11-09

Исполнитель: opus. Основание — технические уточнения автора 2026-11-09, переданные Codex и записанные дословно в
[журнал](../../../LMX_blog/2026-11-09.md): объявление fn в дереве — именованная структура (fn её название) с аргументами
`name`, `args`, `return`, `var`, `body`; при обходе интерпретатором или транслятором в namespace этого обхода создаётся
структура функции «по тому же правилу по которому int: i 5 создаёт i»; namespace — изначально чистые таблицы обходчика,
не хранимые рядом с графом; var дополняется одинаково при любом происхождении структуры. Разбор Codex: копии
[records/pins/](records/pins/) (`codex-author-*.txt`, `codex-fn-*.txt`, `codex-332-*.txt`, `codex-real-fn-results.txt`);
мои письма — `opus332-letter-*.txt` там же. По письму OPUS-CODEX-FN-PLAN-20261109T0620Z-01 работа разбита на 332
(представление и namespace) и 333 (`fn: prepared`, `fn: new_name merge(f1, f2)` общим связывателем).

## Изменение

1. **Построитель** (`l2_graph_tool.lm2`). Всякий Frame `R: args` — Lmx, названная головой (строка адрес → name), поля —
   аргументы. Операция, записанная Frame (`-(2 + 3)`, `\(@x)`), — по-прежнему выражение без имени: слово оператора в
   поле 0 и операнды (разбор Codex, п. A: общий механизм receiver-форм «не переименовывает бинарное x+1 или безымянные
   данные»); `@: name T` — объявление. `int: name литерал` в любой Structure — сама именованная ячейка; объявления
   `fn`/`sub` — Lmx `fn`/`sub` с аргументами как написаны; автозаполнения var, нормализации частей и прежних
   `lm_graph_build_inline_names/body_var/method` нет. Пост-цикл `until:` блока данных удерживает снаружи только данные
   блока — места, `var`, именованные блоки (`lm_graph_own_field`), а не операторы, названные головой.
2. **Печать** (`lmx_graph.lm2`). Frame — `(голова аргументы)`; объявления — в записанной форме; блок `голова:` … `end:` —
   когда в нём место, оператор языка, два Frame или вложенный блок (`lmx_graph_dump_block`); операторы языка (`if`,
   `until`, `finally`, …) — одной строкой, как прежде.
3. **namespace обхода** (`LmxGraphSpace`/`LmxGraphSpaceRow` в `tools/build.lm2`, `lmx_graph_space_*`): строки «блок, имя,
   значение», пустые при входе в обход, освобождаются на выходе; вложенный обход (инициализаторы var, явный вызов)
   продолжает живой. Индекс таблицы имён по адресу (`names_index`) — состояние арены, не обхода.
4. **Конструктор F** (`lmx_graph_fn_make`, `lmx_graph_fn_var` в `lmx_graph_run.lm2`): при входе в блок ресивер
   `fn`/`sub` применяется к аргументам объявления; F — Lmx роли FN (`lmx:result`) с `parent` на объявление, названная
   значением `name`, поля — именованные ссылки `args`/`body`, своя ячейка слова `return`, новая `var`: общая копия
   записанной var одной картой и места без значения для собственных полей тела вне формалов и var; инициализаторы не
   исполняются; `native` объявления — вход F. Остальные формы ресивера (вся структура аргументов, имя + Structure частей)
   — 5, срез 333; `fm` — 5.
5. **Интерпретатор**: имена — по кадрам активаций, затем по namespace блоков цепочки `parent`, у F — по её var;
   операторы — по имени Frame; корень: места и fn/sub — с начала обхода, именованная Structure корня — по первому
   записанному полю своего имени (`lmx_graph_root_structure`: после определения `x: 4` `x(1; 2)` применяет x; одно поле
   — определение, если это значение: литерал, слово, ссылка, выражение, `merge`, вызов вызываемого), слово языка
   (`lmx_graph_language_receiver`, один список построителя и корня) — всегда оператор, неисполняемый отказывает явно
   (`table:` — 3). В теле: собственное место Structure стоит, объявление исполняется на своём месте; `var:` — данные;
   поле данных вызова — место этого имени, оператор с тем же именем вторым полем не считается (`lmx_graph_data_slot`).
6. **Транслятор**: своё пространство трансляции, `native` ставится на объявление, var-native нет; тела — через
   `lmx_graph_method_body`; корень — `lm_graph_root`, обёртка `lm_graph_body` открывает и закрывает namespace прогона.
7. **Фикстуры.** Новая `fresh_traversals` (два обхода). 13 ожиданий обновлены (ниже); 4 фикстуры merge вызываемых —
   отказ до 333 с поясняющим комментарием в источнике, их `.expected` удалены; `inputs.list` — 368 входов.

## Проверки

Все запуски tool/graph — из P/runs/opus332 (`cd … || exit 1`, строка CWD= в логах); логи `P/pins/opus332-*`.

1. Сборки и неудачные попытки (каждая — новая метка): tool30 (T29 на rt40) — exit 0. rt41 — разбор `lmx_graph.lm2`
   1180:5 (`else:` после вложенного `if` без `---`); rt42, rt43 — `assignment value has unknown type` (499/500:29): путь
   поля `row\address` в аргументе вызова функции своего модуля требует приведения, как везде в принятом коде; rt44 —
   exit 0, graph53 — exit 0.
2. `checks` graph53: 136 PASS, 62 FAIL. Найдено и исправлено: `-(2 + 3)` получал имя `-` (status 2); `var:` блок
   исполнялся как оператор; строки активации вычисляемого `int: seeded tick()` назывались `int`; поиск по имени видел
   оператор `x: x + 2` вторым полем `x`; `int: absent 8` под `if` не требовался от данных; `:=` в функцию — 3 вместо 4;
   пост-цикл удерживал операторы как данные. graph54 → 146 PASS, graph55 → 147 PASS; оставшиеся — печать/состояние
   объявлений и 4 фикстуры merge.
3. Ожидания (graph56, три режима совпадают байт в байт, корневые результаты `int:` — те же, что в прежних `.expected`):
   var объявлений печатается записанной (`int: calls 0` вместо состояния после вызовов), блоков автозаполнения нет, тело
   пост-цикла печатает общие места полностью. `fresh_traversals` после двух обходов: `last 1`, `pair 23` — второй обход
   снова считает от записанного `calls 0`; объявление после обходов — как написано.
4. merge вызываемых: `g: merge(f1)` — Structure, не функция (kernel §3.4, `lmx:result` — результат ресивера, не
   Structure с похожими частями; функцию делает `fn: g merge(f1)`, срез 333). Ответы: merge_callable 2, merge_recursion
   2, defined_call_body 4, defined_call_actuals 2; native и forced останавливаются (выход 1); всё до первого применения
   `g` совпадает с прежними ожиданиями.
5. Производственные модули (`G run S/<вход> 1`), graph52 (331) → graph56 → graph58:

| Вход | 331 | graph56 | graph58 |
|---|---|---|---|
| lmx_schedule, l2_libc, lmx_clock, os_native_path, text | exit 0 | exit 0 | exit 0 |
| primitive | `run answered 3` (`table:`) | exit 0 — `table:` стоял данными (дефект) | `run answered 3` |
| docs_check, winargs | `build answered 2` | exit 0 | exit 0 |
| lmxtool | `run answered 1` | `run answered 3` | `run answered 3` |

   Во всех — GRAPH-BEFORE = GRAPH-AFTER: объявления после обхода неизменны. docs_check и winargs строятся, потому что
   построитель больше не нормализует объявления (прежний отказ — разбор формалов в `lm_graph_build_method`); корень
   только создаёт F. lmxtool: `MainLetter: m` после блока `MainLetter` — оператор места, которого нет (3); прежде 1.
6. Слово языка: graph57 (общий список вместо списка интерпретатора) потерял символы `@`, `:=` — `@: p int @i` стал блоком,
   4 фикстуры — 3; graph58 проверяет оба списка.
7. Итог на graph58/tool31/rt49 (`opus332-source10`, 368 входов): `checks opus332-graph-check59.tsv` — `CHECKS 67 lines,
   0 failed`, 201 PASS (07:41:43→07:42:50Z); `mutation` 11/11, `method-mutation` 8/8; `sub_void_value` — `run answered 5`,
   `emit answered 5`, частичный L1 = graph56 (от graph52 отличается: нет var-native, тело через
   `lmx_graph_method_body`, имена операторов через `name_of`, корень `lm_graph_root`).

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus332.

- P/pins/opus332-source10.sha256, 368 входов: 27a550a6c35c96bd4caabb7e633929800687ed1c0714a844e2ac76ac3f9b37c2.
- T31 = S/tool31/lmxtool-tool.exe: 10328db72309b2ff8e1b925042d5bae2e41e7a2505235df0dd86d5461e593767 (собран T30 на
  rt47; T30 = 39b9705a…, собран T29 на rt40).
- S/rt49/driver.o: febba64124900c85cf4c78f5e72f753ce78d81fd388865eea7b539873bc28985.
- S/rt49/driver-observe.o: eb13309c62bda75dd31ab588dc1df7cd42d311379899bdf8c5b5bfed5d9cca6f.
- G58 = S/graph58/graph_trans-prod.exe: e46abc695960cb4890d100f5f92c75212965b77a9c5d14f0a9b75f2e5e684cad.

```text
T30 0 entry 0 -- build-self R S B F S/rt47/driver.o tool31
T31 0 entry 0 -- build-runtime R S B F rt49
T31 0 entry 0 -- build-graph R S B F S/rt49 graph58
T31 0 entry 0 -- checks P/pins/opus332-graph-check59.tsv
G58 0 entry 0 -- mutation
G58 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
G58 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G58 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph58/sub-void-refused.lm1 native 1
G58 0 entry 0 -- run S/<production input> 1
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check59-CASE`. Архив:
[список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); второй проход —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256); архивные команды — из P/runs/opus332.
217 копий первого прохода (89 с CR записаны из индекса в LF). Docs render semantics — S/docs49 (35 глав); docs check
S/docs50 над индексом среза (259 путей) — PASS. `git diff --cached --check` — две находки: пробел в конце строки
дословной реплики автора (LMX_blog/2026-11-09.md:158 и её копия в pins Codex) — сохранён по правилу дословности, как в
LMX_blog/2026-11-07.md. Повторный docs check над итоговым индексом (после второго прохода и этих notes) — S/docs51
(лог в P).

<a id="review-332"></a>
## Проход по ревью Codex 332

Ревью CODEX-OPUS-332-REVIEW-20261109T080211Z-01 ([копия](records/pins/codex-332-result-review.txt)) приняло факты
узкого среза и потребовало пять исправлений без нового ACK. Сделано на `opus332-source14` (373 входа):

1. **Слова языка — по адресу.** `lmx_graph_language_receiver` больше не сравнивает байты уже канонического слова: список
   ресиверов интернируется один раз в состояние графа (`LmxGraphState.receivers`/`receivers_count`,
   `lmx_graph_receivers_in` из `lmx_graph_state`), распознавание — сравнение адреса, как у остальных `w_*`.
2. **Поле корня классифицируется, когда обход до него дошёл.** `lmx_graph_space_places` удалена: `lmx_graph_space_open`
   создаёт только F объявлений `fn`/`sub`; новая экспортируемая `lmx_graph_space_reach(g, root, index)` вносит место
   (виды 1/3/5/6) или именованную Structure при достижении поля; `lmx_graph_root_structure` разрешает голову в namespace
   таким, каким он стоит у этого поля (`lmx_graph_resolve`, оба списка слов): одно поле-применение того, что сейчас
   отвечает вызываемым, — определение. Интерпретатор зовёт reach в начале каждого поля корня; транслятор — в своём
   namespace трансляции и выпускает тот же вызов в программу (`lmx_graph_space_reach(l2_g, lmx_call_code, i)`), для
   отложенного случая (одно поле применяет имя объявления) — выпущенная проверка с переходом. `fn_alias_call`
   (`h: f`, `r: h(3)`, `s: f(3)`): `@: h f`, `int: r 3`, `int: s 3` во всех трёх режимах; graph58 оставлял `r: (h 3)`
   неисполненным блоком.
3. **Обычное поле корня видно с объявления.** Запись по голому имени достигает только видимого места
   (`lmx_graph_visible_slot`: слот, если namespace уже связывает имя с ним) — в известных значениях, присваивании,
   записи блока, int-операторах и итоговой записи; `lmx_graph_named_int` отвечает 3 на имя, которое ничему не отвечает.
   `root_visibility` (`int: seen x` до `int: x 7`) — отрицательная: интерпретатор отвечает 3, native и forced —
   отрицательный R0 (exit 1; числового ответа интерпретатора им не приписывать — уточнение ревью Codex 332R); graph58 давал `seen 7`,
   graph59 — ответ 1 (поправлено в rt51/graph60).
4. **var функции — одной картой.** `lmx_graph_fn_var` сначала сопоставляет записанной var новую, копирует и затем ставит
   `parent` каждой копии через ту же карту (`child\parent = map_get(operand\parent)`), сохраняя вложенность; источники не
   меняются. `var_copy_nesting`: Code под копией Box читает `kk` Box — `seen 9` во всех режимах, записанная var после
   вызова прежняя (`int: r 0`); graph58 — `run answered 3` (Code уплощался под var и не находил `kk`). Объявление `@:`
   в var рабочими строками — отказ 5, как в HEAD; поэтому внутренней ссылки в var этот срез не пишет: перенаправление
   ссылки на записанную var через карту — по коду, без свидетеля запуском.
5. **Время жизни и §6.1.** Освобождаются служебные таблицы обхода и их корни, не F, удержанная программой обычной
   ссылкой (kernel RU/EN §3.4 и пример §10, комментарий у блока ресиверов в `lmx_graph_run.lm2`); §6.1 — голова
   именованного Frame — его имя, поля с 0 — аргументы, поле корня классифицируется при достижении; §5.2 — видимость полей
   корня по ходу обхода; §6.2 — список ресиверов по адресу.

Регресс по ходу: `method-mutation` на graph60 — 5/8 (`method-preserved-native-is-dispatched`,
`method-fresh-body-result61`, `method-next-body-result59`): проверка открывала namespace и вызывала `take`, не дойдя до
полей корня, и `Point`, видимая теперь с поля 0, не отвечала при приёме формала. На graph61 проверка доходит до полей
корня по порядку (`lmx_graph_space_reach`), как обход перед вызовом в `r`, — 8/8.

Итог на graph61/tool32/rt51: `checks opus332-graph-check61.tsv` — `CHECKS 70 lines, 0 failed`, 210 PASS
(08:34:16→08:35:29Z); `mutation` 11/11; `method-mutation` 8/8; `sub_void_value` — `run answered 5`, `emit answered 5`,
частичный L1 = graph58; производственные модули — как на graph58 (lmx_schedule, l2_libc, lmx_clock, docs_check,
os_native_path, text, winargs — exit 0; primitive и lmxtool — `run answered 3`), везде GRAPH-BEFORE = GRAPH-AFTER, журналы
graph60 и graph61 совпадают после строки CWD.

Кортеж прохода (обозначения — как выше):

- P/pins/opus332-source14.sha256, 373 входа: b50402c0063ab9c6972e03356aa96ef350ebf5e2c8a33ef743da03a4bf357cee.
- T32 = S/tool32/lmxtool-tool.exe: 6661de8cab0142e988f20c282d79e4c999c8e4a6903d29b013a9f3ba8ac96372 (собран T31 на rt49
  из source11; build.lm2 после source11 не менялся).
- S/rt51/driver.o: e29a4c5e023f4e2616838e8660262712b1d0a3c1218cabd441d9cd6d0e3ed977 (source12; исходники runtime после
  source12 не менялись).
- S/rt51/driver-observe.o: 22f7a3d15364f5a79301c9e5e0b90da322d734a1a99d2cc62ea1586561723b38.
- G61 = S/graph61/graph_trans-prod.exe: 695a71cec1eaa91b5bd1843d14dee04335acd66ae985cf60c60fa256fdbb6855 (source14).
- Промежуточные: rt50/graph59 (source11), G60 = 13eaf0df005f474e7ed70adc3f6e39689d81594ecb7a7f3de9c71c48dbad63d7
  (rt51, source12; checks60 — 70/0, 210 PASS; method-mutation 5/8).

```text
T31 0 entry 0 -- build-self R S B F S/rt49/driver.o tool32
T32 0 entry 0 -- build-runtime R S B F rt51
T32 0 entry 0 -- build-graph R S B F S/rt51 graph61
T32 0 entry 0 -- checks P/pins/opus332-graph-check61.tsv
G61 0 entry 0 -- mutation
G61 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
G61 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G61 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph61/sub-void-refused.lm1 native 1
G61 0 entry 0 -- run S/<production input> 1
```

OUT строк проверки — `S/check61-CASE`. Архив прохода: [список](records3.list), [SHA оригиналов](records3.sha256),
[SHA LF-копий](records3-lf.sha256) — копии в [records/](records/) рядом с копиями первого прохода; журналы docs check и
архивные — [список](records4.list), [SHA](records4.sha256), [SHA LF](records4-lf.sha256).

## Граница и следующее

1. 333: `fn: prepared` (подача всей Structure), `fn: new_name merge(f1, f2)` (имя + Structure частей — другая форма того
   же ресивера), коллизия имени, однократное вычисление фактических до эффектов; затем фикстуры merge вызываемых
   переписываются через `fn:`.
2. Поле корня классифицируется, когда обход до него дошёл: вид единственного поля и разрешение головы в namespace у
   этого поля (kernel §6.1); новой нормы о форме блока (`end:`) не нужно (ревью Codex 332, п. 2). Данные блока внутри
   исполняемого тела, кроме `var:`, не исполняются только как места.
3. Форма `var: (…)` как присваивание привязке var (книга, ordinary-var) в чистом графе по-прежнему не исполняется.
4. Открытые с 329–331: части `fn`/`return` композиции, адрес `@` ссылки на Structure, замена Structure/ссылочного слота,
   C-дверь интерпретатора, машинный экспорт из чистого графа (вход F вместо P0).
