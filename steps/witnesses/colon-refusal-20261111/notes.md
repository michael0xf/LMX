# Отказ записи двоеточием в рабочем frontend — срез 350, 2026-11-11

Исполнитель: fable. Норма — решение автора 2026-11-10:
[структурные формы объявляют или вызывают](../../../LMX_blog/2026-11-10.md#forms-declare-or-call),
[объявление, а не присваивание](../../../LMX_blog/2026-11-10.md#colon-declares-not-assigns); книга —
[структурные формы](../../../docs/LMX_semantics.ru.md#forms-declare-or-call),
[объявление Structure](../../../docs/LMX_semantics.ru.md#colon-declares). План — раздел
[M7](../../../next_core_tasks_v3.md#m7), шаг 4 для рабочего frontend: понижение L3, обходчик, машинный путь L2 и
машинный путь из чистого графа. В чистом графе шаг сделан срезом 346.

## Что изменено

1. **Отказ в точке записи** (`src/l2src/l2_frontend_types.lm2`, `lm_compiler_colon_write`). Функция переписи
   срезов 347–349 вызывается в каждой ветви, которая выпускает для структурного Frame запись в место: нативное
   понижение L3 (`lm_compiler_emit_stmts_with_position`), машинные места (`lm_compiler_emit_loc_stmt`), обходчик
   (`lm_compiler_rw_stmt_content`). Теперь она же отказывает. Frame оператора `:=`, Frame формы ресивера и Frame,
   голова которого — слово языка или `@`, по-прежнему проходят без вопроса. Вид 1–6 (голова — известное место:
   имя, путь по полям, элемент, разыменованная ячейка, поле памяти C; вид 6 — зарезервированное `var`) — отказ:
   - машинный метод, элемент, разыменование, поле памяти C: «a form with a colon declares and writes no known
     place: assign with :=»;
   - имя и путь L3: то же с продолжением «(a Structure is declared again by its written body)».
   Вид 7 и 8 (форма определяла место значением: `h: Box`, привязка к методу `b: tick`, результат вызываемого
   `r: h(3)`) — отказ: «a form with a colon whose head names nothing declares a Structure with its tail inside, not
   a place: a reference is declared `@: name value`, a value by its receiver; a Structure declared with this tail
   inside is not lowered yet». Вид 9 (место под Structure в голове, вопрос П1) и вид 10 (письменная Structure на
   своём месте) проходят. Строка переписи, если переменная `L2_COLON_WRITES` задана, пишется до отказа.
2. **Машинный путь из чистого графа** (`l2_frontend_graph.lm2`, `lm_compiler_graph_block`). Две ветви,
   выпускавшие запись по формам `владелец\поле: значение` и `имя: значение` (имя — формал или место функции),
   отказывают: «…the field through this path is assigned with :=», «…this formal or place of the function is
   assigned with :=». Запись выпускает только ветвь оператора `:=`.

## Пределы

- Понижение L3 строит повторное объявление Structure только по письменному телу (вид 10). Structure с другой
  сущностью внутри — `Struct1: Struct2` при известной `Struct1`, `h: Box` при неизвестной `h` — оно не строит.
  Прежде такая запись присваивала ссылку, то есть исполняла отозванное чтение; теперь она отказывает. Пример автора
  исполняет чистый граф (срез 346).
- Отказ не различает место-Structure и место значения: форма на голове-Structure с хвостом-значением по норме —
  повторное объявление, а не ошибка, и сообщение сформулировано так, чтобы быть верным для обоих случаев.
- Строка переписи после отказа одна за запуск: полный список мест даёт только транслятор до этого среза.
- Прежний отказ «assignment target must be a declared typed mutable value» (голое имя, которого нет ни среди мест,
  ни среди определений отсутствующей головы) не менялся.

## Фикстуры

Новые строки `refuses` полного набора, режимы `nf`:

| Фикстура | Форма | Игла |
|---|---|---|
| `dyn/colon_known_literal_refused.lm2` | `i: 6` при `int: i` | `5:5` |
| `dyn/colon_known_name_refused.lm2` | `i: j` | `6:5` |
| `dyn/colon_known_call_refused.lm2` | `i: g()` | `9:5` |
| `dyn/colon_known_path_refused.lm2` | `P\f: 2` | `7:5` |
| `dyn/colon_known_root_refused.lm2` | `code: 8` в корне | `4:1` |
| `dyn/colon_known_index_refused.lm2` | `cells[1U]: 5` | `4:1` |
| `dyn/colon_known_deref_refused.lm2` | `\p: 3` | `7:5` |
| `dyn/colon_known_body_refused.lm2` | `y: 7` в теле именованной Structure | `7:5` |
| `dyn/colon_absent_reference_refused.lm2` | `h: Box` при неизвестной `h` | `8:1` |

Игла первых восьми — «a form with a colon declares and writes no known place: assign with :=», девятой — «a form
with a colon whose head names nothing declares a Structure with its tail inside, not a place».

Пересмотрены две фикстуры прежнего правила. `occurrence_bare_refused` и `occurrence_node_refused` проверяют чтение
имени с двумя корневыми головами; вторая голова была записана `y: 7` и `hits: 2` — присваиванием, которое
считалось головой. Теперь вторая голова — повтор объявления (`int: y 7`, `int: hits 2`); сообщение прежнее, номера
строк в иглах сдвинулись вместе с новыми строками комментария (`8:13`, `6:18`). `quoted_colon_head_limit` не
тронута: она закрепляет предел точного идентификатора в голове, а не правило.

## Проверки

- **Пробная трансляция** изменённых частей прежним frontend (`m8o`), холодный frontend `fe-f06` (manifest 33).
- **Отрицательные фикстуры холодным frontend** (`m8p`, сводка — `records/probes/m8-summary.txt`): семь из девяти
  отказывают названным сообщением на названном месте; две (`i: j`, `i: g()`) без частей `convert` и `primitive`
  останавливаются раньше — «the program has no source table primitive.description», с частями (как их подаёт набор)
  — тем же отказом. L1 не остаётся.
- **Мутант «отказ снят»** (`fe-f07m`, manifest `34m1`: функция возвращает 0 сразу после строки переписи; проба
  `m8t`): все девять отрицательных фикстур транслируются нативно и с `--walk-methods`, L1 записан; тем же вызовом
  `fe-f06` отказывает всем девяти. После сборки мутанта исходник и стадия возвращены и сверены с manifest 34 по
  sha256 (`stage34b.out`).
- **Машинный путь** (`m8r`): модуль ядра `lmx_ids` с одной записью, возвращённой к двоеточию (`n: bn`, строка 50),
  командой сборки — отказ `50:9`; тот же модуль без правки — L1 побайтно равен L1 сборки.
- **Машинный путь из графа** (`m8s`, frontend `boot-f18/g2`, со словом `--graph`): `lmx_schedule` с
  `slot\owner: owner` — отказ в `lmx_schedule_init`, оператор 3; `lmx_process_deadline` с `wait: max_wait` — отказ в
  `lmx_process_deadline_arm`, оператор 12. L1 не остаётся.
- **`bootstrap quick` `boot-f18`** (manifest 34) — 0 отказов, 06:54:11Z–07:07:16Z; frontend, `l1trans` и инструмент
  G1 и G2 — `EXE-SAME 1`; `l1trans` и инструмент — `EXE-SAME 1` с `boot-f17/g2`; `driver.o` `0fec21ad…`,
  `driver-observe.o` `f7f580ec…` прежние (`boot-f18-same.out`). Сборка проходит с отказом: в исходных текстах
  транслятора, ядра и инструмента записей двоеточием нет. Перепись сборки — 20 строк, две формы `MainLetter: m`.
- **Полный набор `suite-f13`** — `SUITE 149 rows, 0 failures`, 1162 PASS, 07:07:29Z–07:23:40Z.
- **L1 программ набора** (`rowl1-f12-f13.out`): у всех 220 программ, собранных в `suite-f12` и `suite-f13`, L1
  побайтно один: отказ не изменил ни одного выпускаемого файла.
- **Список `smoke-kernel225`** (`suite-f13k`) — 9 строк, 0 отказов. Транслятор графа `graph-f16` — `EXE-SAME 1` с
  `graph-f15`.
- **Отчёт последнего прогона** (`census-tests-f03.tsv`, `colon-report-f11.out`): 542 строки, 69 мест — 60
  объявлений (письменная Structure 54, место под Structure в голове 6) и девять форм новых фикстур, названных перед
  отказом.
- **Graph-check не повторялся:** фикстуры `tests/graph`, транслятор графа и runtime те же, что в прогоне
  `check-f17`.
- Индекс коммита сверен с manifest 34 по sha256; `docs check` на индексе — метка `docs117-fable01`.

## Оплошности исполнителя

- Первая проба машинного пути — три строки своего текста с `--library --machine` — отказала обеим записям
  сообщением о таблице `primitive.description`: проба не повторяла условий сборки. Заменена настоящим модулем ядра
  по записанной команде сборки.
- Строки набора добавлены после manifest 33; сборка и набор идут на manifest 34.

## Записи

`records/pins` — manifest 33 (отказ, новые фикстуры), 34 (тексты коммита) и `34m1` (мутант); `records/runs` —
терминалы и вывод сборок и прогонов, сравнения L1 и образов, отчёт; `records/probes` — пробы `m8o`–`m8t`: тексты
модулей с возвращённой записью, вывод, журналы отрицательных фикстур (`m8p`, `m8t`) и их сводка. Контрольные суммы
записей — `records.sha256`.
