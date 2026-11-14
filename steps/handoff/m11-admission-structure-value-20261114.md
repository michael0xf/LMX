# M11.7: Structure-value в допуске и первый source-known preflight

2026-11-14. Read-only исследование после принятого384/62072bca, во время замороженной короткой bootstrap-сборки385.
Измеренный root baseline ниже передан основным writer; помощник сборок и запусков не делал.
Этот handoff не закрывает M11.7/M13/M14.

## Узкая граница текущего допуска

Baseline `@: Model (int: v 0); fn: f (@: value Model) int (return: value\v); int: r f((int: v 7))`
отказывает4. Обычная Structure Point в own data метода проходит. Причина общая, не корневая:

- `selfbuild/src/l2src/lmx_graph_run.lm2`, `lmx_graph_admit`: требование берётся через
  `lmx_graph_formal_model`, затем `lmx_graph_resolve_value(code.parent, requirement, prepare=1)`.
  Значением Model может быть reference-place kind6, включая рабочую snapshot-cell текущей активации.
- `lmx_graph_admit_paths` проверяет `kind(model)==4 && kind(candidate)==4` до обхода путей.
  Поэтому reference-value отвергается до того, как `lmx_graph_step` сможет применить обычную проекцию ссылки.
- `lmx_graph_read_actual`/`lmx_graph_read_received_value` также вправе дать candidate как reference-value,
  а не только непосредственно записанную Structure.

Следующий узкий срез: в `lmx_graph_admit_paths` один раз спроецировать **локальные** model/candidate
через существующий `lmx_graph_target`, затем сохранить прежние kind4 gate и used-path/type checks.
Не менять общий resolver и `lmx_graph_admit` → `out[0] := actual`: место, значение ссылки и её referent
нужны разным потребителям. Не добавлять поиск физического Model-слота или root-ветку.

## Source resolve, снимки и M14

`lmx_graph_resolve_binding_context`/`lmx_graph_resolve_value` уже выбирают binding по текущей цепочке
activation/formal/data/lexical. Для mapped reference возвращается рабочая clone-cell, сохраняющая выбор
ссылки данной активации. Consumer target читает именно это выбранное значение, а не заново физический
`data\Model`. Поздняя перепривязка физического места не должна молча обновлять snapshot ссылки.

Проекция не публикует dirty, не вызывает flush, не копирует Structure и не меняет передаваемое actual.
Referent остаётся тем же общим S; его поля читает прежний `step`. Общий direct cache и публикация M14
этой коррекцией не реализуются. Это предварительное объяснение source resolve для M14, не новый контракт.

`selfbuild/src/l2src/lmx_graph.lm2`, `lmx_graph_target`, имеет ограниченное поведение:

- kind8/9 сначала даёт underlying reference-cell; kind6 читает один payload;
- kind7 читает held slot, учитывает wrapper8/9 и reference-cell6 и возвращает referent только если он kind4;
  если Structure не получена, возвращает исходный kind7, который admission kind4 gate обязан отвергнуть;
- прочие значения возвращаются как есть; NONE/0 не становится Structure.

Не вводить `while target(...)` или рекурсивное раскрытие: граф допускает циклы, а существующая проекция
ограничена и не зацикливается даже при self-reference. Произвольная глубина указателей/void остаётся M13.
Одного успешного `target` недостаточно для утверждения совместимости — сохраняется весь прежний допуск путей.

## Маленькая приёмочная проба для коррекции

```lmx
@: Model (int: v 0)
@: Candidate (int: extra 99; int: v 7)
@: Alias Candidate
fn: f (@: value Model) int
    return: value\v
int: literal f((int: v 7))
int: by_place f(Candidate)
int: by_alias f(Alias)
```

Независимые ожидания:7/7/7; extra не используется, порядок полей не совпадает с моделью, значения
Model/Candidate не меняются. Отдельный negative с candidate без v сохраняет refusal4 до тела f.
Повторить обычный Point и существующие reference/alias cases; не выдавать эту пробу за full implements/map.

## Отдельный первый шаг construction-admission

Основной v3 M11.7 требует проход после построения, включая заведомо несовместимый вызов в недостижимой ветви.
Общая точка — `selfbuild/src/l2src/l2_graph_build.lm2`, конец `lm_graph_build_root` после всех полей;
`lm_graph_build_file` затем уничтожает P0. Оба `lm_graph_run_file` и `lm_graph_emit_file` используют этот путь.

Первый отдельный срез можно ограничить **source-known call shape/default preflight**:

- прежний временный `lmx_graph_space_open` готовит written F через `receiver_bind(evaluate=0)`/`receiver_make`;
- `lmx_graph_bind_call` уже проверяет labels, порядок/повторы, число actuals и наличие обязательных defaults;
- сначала отделить чистую проверку формы от исполнительского ограничения `lmx_graph_call_shape`
  «результат только int», чтобы не отклонить допустимые machine-source result descriptions;
- обходить existing CodeBody views, включая недостижимые ветви; не вычислять actuals, initializers, code или test;
  computed/head-expression/dynamic formal не объявлять source-known посредством runtime readers.

Пример: `fn: take (int: value) int (return: value); if: 0 (take(unknown := 1))` должен отказать при построении.
Существующая `selfbuild/tests/graph/named_unknown.lm2` закрепляет binder refusal до touch().

Это не блокирует Structure-value коррекцию выше. `lmx_graph_admit_paths` пока обходит все nested Lmx без
CodeBody-role фильтра; его нельзя объявить универсальным construction pass для inert groups/nested methods.
Общие `lmx_implements_*` интерфейсные workers и slot-map APIs уже существуют, но требуют корректной связи
descriptor/Consumer/мест. Их чистая адаптация, полный used-interface admission и test остаются следующим слоем,
без второго runtime, постоянной SourceName-таблицы или нового каталога моделей.
