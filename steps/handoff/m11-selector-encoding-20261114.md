# M11.7: кодирование селектора — следующий код после 387

Дата: 2026-11-14. Это передача следующего ограниченного среза, не новая норма и не отчёт о реализации.
Правок кода и запусков проверок в рамках этой передачи нет.

**Обновление writer388:** оба описанных ниже graph/P0 шага реализованы ограниченно и прошли13 новых
interp/native/forced случаев. Итоговая occurrence unit содержит два WORD (decimal digits, canonical name),
без bracket markers: роль RHS path3 достаточна и не требует нового state field. Общий reader — Graph74,
Run54 принимает raw step; compact producer использует прежний P0/expression builder, manual split удалён.
Shared lexical head scanner и compact-piece wrapper используют прежний scan_quoted; локальный colon
delimiter разрешён без изменения global quoted_token_boundary. Whole bootstrap388/fixedpoint15 и G2 repeat20/21
пройдены в ограниченной приёмке с прежним root-case OPEN; docs-check01/final index-check02 также PASS.
Это не весь M11.7/8/M13/M14. Исходное предложение четырёх WORD ниже сохранено
как исследовательский контекст, не описание фактической unit. Новый статус — в steps/current.md.

## Доказанный дефект

Точное имя после снятия границ и свёртки удвоенных backticks является обычным каноническим именем.
Токен внутри backticks атомарен: его `\`, `[` и `]` не становятся синтаксисом
([грамматика, §5](../../docs/spec/LMX_grammar.ru.md),
[семантика имён и путей](../../docs/spec/LMX_semantics.ru.md#fields)).

В [построителе](../../selfbuild/src/l2src/l2_graph_build.lm2) `lm_graph_build_occurrence` соединяет
уже разобранные `[`, N, `]`, name в один WORD с payload `[N]name`. `lm_graph_build_selector` создаёт такой же WORD
для compact path head. В [Run](../../selfbuild/src/l2src/lmx_graph_run.lm2) `lmx_graph_occurrence_word`,
вызванный из `lmx_graph_step_index`, заново распознаёт occurrence по этому payload.
Поэтому обычный WORD точного имени `[0]x` неотличим от occurrence 0 имени x.
Проверка «сначала найти буквальное имя» дефект не решает: в одной Structure могут одновременно быть
буквальное поле `[0]x` и повторные поля x; оба написанных селектора должны сохранять свой выбор.

Отдельная потеря лексических границ: `lm_graph_build_selector` делит compact head по каждому byte 92,
а `lm_graph_path_text` и `lm_graph_index_text` проверяют bytes без границ exact component.
До этого этапа P0 также ограничивает compact quoted chains: его сканер головы отвергает backtick внутри
некавыченной головы, compact-piece reader не выделяет exact token в середине цепочки,
а quoted-token boundary не принимает соседний path/index suffix.
Spaced path expression уже проходит через обычные P0-токены и `lm_graph_build_expression`;
этот путь позволяет сначала проверить collision независимо от compact lexical patch.

Конкретная проба Graph02 среза387 (SHAaa29a2b3), 2026-11-14:

```lm2
@: S (int: x 7; int: x 9; int: `[0]x` 11)
int: literal S \ `[0]x`
int: first S\[0]x
int: second S\[1]x
```

Измерено literal7/first7/second9 вместо11/7/9. В BEFORE оба первых selector напечатаны
одинаково `[0]x`, хотя исходные токены различаются. Это воспроизведённый дефект, не готовая реализация.

## Срез 1: различить имя и occurrence в построенном графе

**Предлагаемое решение реализации, не норма:** оставить внешний path из трёх полей
`[owner, WORD("\\"), step]`. Обычный step — WORD канонического имени, всегда буквальный.
Occurrence step — обычный anonymous Lmx, сохраняющий уже разобранный unit:
`[WORD("["), WORD(decimal digits), WORD("]"), WORD(canonical name)]`.
Не добавлять opcode, тип пула, исходный флаг, таблицу quoting или запись в реестре.
Десятичные цифры сохраняются словом, чтобы не вводить ограничение ordinal машинным Graph int.

1. Изменить `lm_graph_build_occurrence`: вместо конкатенации bytes построить этот обычный Lmx;
   сохранить прежние проверки смежности P0-полей, cursor и boundary. Имя получить существующим
   `lm_graph_p0_name_word`; цифры не вычислять как выражение.
2. Перевести существующий `lmx_graph_step_index` на raw step. WORD выбирать буквально через прежний
   `lmx_graph_data_find`; структурный occurrence читать общим запросом и выбирать через тот же
   `lmx_graph_data_find(name, ordinal)`. Существующий `lmx_graph_occurrence_word` заменить чтением
   структурного unit, не оставлять параллельный строковый распознаватель.
   Проверять переполнение `size_t` при `ordinal * 10 + digit`: оно не должно выбирать другое вхождение.
   Не вычислять name/ordinal, не обходить произвольные дочерние структуры.
3. Передавать raw step через всех потребителей ниже. Сохранить родителя, адреса полей, разрешение атома,
   admission, working snapshots и ошибки прежнего механизма. Не нормализовать resolver или stored actual.

### Точные producers и consumers

| Файл | Функции и изменение |
| --- | --- |
| [l2_graph_build.lm2](../../selfbuild/src/l2src/l2_graph_build.lm2) | `lm_graph_build_expression` → `lm_graph_build_occurrence`: producer правого step; внешний path3 прежний. `lm_graph_build_selector`: compact producer, согласовать во втором срезе. |
| [lmx_graph_run.lm2](../../selfbuild/src/l2src/lmx_graph_run.lm2) | `lmx_graph_step_index`, `lmx_graph_step`, `lmx_graph_step_place`: общий raw-step consumer вместо параметра canonical-name char pointer. |
| [lmx_graph_run.lm2](../../selfbuild/src/l2src/lmx_graph_run.lm2) | `lmx_graph_path_field`, `lmx_graph_admit_path`, `lmx_graph_eval_value`: передавать `graph_get(path, 2)`, не `word_text` этого поля. `lmx_graph_admit_path` использует один и тот же step для модели и кандидата. |
| [l2_graph_tool.lm2](../../selfbuild/src/l2src/l2_graph_tool.lm2) | `lm_graph_emit_operand` (ветка path) и `lm_graph_emit_field_place`: выпускать raw `graph_get` правого поля вместо `lm_graph_emit_word`; вызывать тот же Run consumer. Существующий `lm_graph_emit_address` даёт адрес держателя. |
| [lmx_graph.lm2](../../selfbuild/src/l2src/lmx_graph.lm2) | `lmx_graph_dump_head`: печатать структурный occurrence и буквальный exact-name step различимо; не восстанавливать роль по payload WORD. |
| [lmx_graph_run.lm2](../../selfbuild/src/l2src/lmx_graph_run.lm2) | `lmx_graph_work_scan_context`, `lmx_graph_preflight_scope`: сохранить существующий пропуск правого поля path3 целиком, чтобы имя/цифры occurrence не стали свободными inputs. |

`lmx_graph_group_expression` и `lmx_graph_single_candidate` узнают внешний path3; его форму не менять.
Структурный step не подавать общему вычислителю actuals или CodeBody.

### Минимальная приёмка первого среза

- В одной S объявить два x и буквальное поле `[0]x` с разными числами. Spaced path с exact-name WORD
  выбирает буквальное поле; написанное occurrence `S\[0]x` выбирает первое x, `[1]x` — второе.
- Записать через оба селектора и прочитать через алиасы: меняется только выбранное физическое поле.
- Повторить выбор через модельный formal, чтобы `lmx_graph_admit_path` не расходился с исполнением.
- Проверить native/forced walker и прежнюю неоднозначность голого x. Слишком большой ordinal не должен
  переполняться до существующего вхождения.

## Срез 2: общий lexical compact patch

1. В существующем P0 использовать `lm_p0_scan_quoted` для exact component, включая doubled backticks:
   точки изменения — `lm_p0_parse_fields_until_with_layout` (скан головы),
   `lm_p0_append_compact_atom_pieces`, `lm_p0_scan_compact_atom_piece` и
   `lm_p0_require_quoted_token_boundary` / `lm_p0_is_quoted_token_boundary`.
   Сохранить остальные quoted-token boundaries и диагностики; не разрешать склеивание произвольных атомов.
2. Обобщить существующий `lm_graph_build_indexed` в чтение selector через тот же
   `lm_p0_parse_bytes` → `lm_graph_build_expression`. Перевести на него compact path/index selectors,
   убрав ручной split в `lm_graph_build_selector`. `lm_graph_path_text` / `lm_graph_index_text`
   при выборе маршрута должны учитывать protected exact token, а не считать его payload синтаксисом.
   Producers головы приложения (`lm_graph_build_node`) и левой части (`lm_graph_build_assignment`)
   должны получить тот же graph path, что tail expression; отдельного parser/precedence reader не создавать.
3. Проверить compact quoted root с suffix, компонент с `\`, компонент с doubled backtick,
   буквальное `[0]x`, occurrence с exact label, attached index и цепочку после него.
   Сверить чтение, запись и голову применения с соответствующими spaced expressions.

Первый срез не объявляет compact quoted chains реализованными. Оба среза не закрывают весь M11.7,
глубокий implements, test или M14.
