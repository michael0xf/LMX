# Receiving coordinates: private87/88

Ненормативный checkpoint реализации, 2026-10-20. Codex — единственный
writer/build, Fable остановлен, goal ACTIVE. Public dev остаётся `0b8c6ded`;
private87/88 не перенесены. Этот результат не закрывает общий gate, все
маршруты путей или §§8/8a. Предыдущий [контрпример86](receiving-catalog-bridge-20261020.md)
сохранён, его положительные ожидания не заменены отказами.

## Общее изменение

87 копирует compiler86/current-contract84. Изменён только runtime
`build/codex_mixed_path_fold_87/src/l2src/lmx_implements.lm1`;
actual runtime — `build/codex_impl87_runtime_02`. Один валидатор проверяет
полную extent/width обеих половин карты. Совместимое неизвестное поле
уточняется, положительные принятые координаты сохраняются. Общие операции
rebase/join/keep/prepare/publish переносят counts, ordinal/LAST, lifetime и
ownership согласованно. Изменение ширины не читает LAST со старым неверным
stride; новая позиция не получает выдуманную identity. Permission и ключ
текущего требования не возникают из наличия адресной карты.

Owned-map refinement выявил проблему времени жизни: старое «запись уже
существует — освободить новый буфер» неверно при замене карты. Runtime02
проверяет фактически удержанный буфер; при равных координатах сохраняет
старое хранилище, при уточнении переносит новое целиком. До публикации
выполнены все выделения и проверки, частичного изменения на отказе нет.

87 закрывает различие «известный адрес против UNUSED», но ещё отказывает,
если две принятые модели дают разные положительные адреса неиспользуемого
поля. Это измерено положительным source-свидетелем. 88 копирует87 и меняет
тот же runtime unit; actual runtime — `build/codex_impl88_runtime_03`,
snapshot — `build/codex_impl88_source_snapshot_03/lmx_implements.lm1`.

В88 явные pending coordinate promises по-прежнему должны согласовываться.
Условные bound interpretations — альтернативы: одна общая операция сохраняет
непротиворечивые координаты, разные известные адреса оставляет unresolved.
Временная conflict-карта не позволяет третьей строке восстановить случайно
выбранный адрес. Она не входит в граф/permission/публикуемую карту.
Тот же механизм применяется при композиции source views и при выборе
target coordinates. Реальный DFS потребляет результат: нужный unresolved
edge отказывает, постороннее поле не блокирует доказанные используемые пути.
Прежняя принятая положительная карта ограничивает допустимые альтернативы;
физический source layout имеет прежний приоритет.

Новых graph opcode, backend-парсеров, native-only защит или специальных
веток Short/merge/capture нет. Все77 экспортированных заголовков86/88
побайтно совпали: это основание для повторной линковки прежних source objects,
а не предположение об их ABI.

## Измеренные проверки

- Original9 Consumer-equivalence, stable16, reference112 и dependencies39
  GREEN на87 и88; current-reference83 правильно отказывает после изменения
  **текущего** declared pointee requirement.
- [Refinement48](witnesses/used-scope-20261020/receiving-coordinate-refinement.c)
  GREEN: оба порядка incomplete/complete evidence, реальные read/address/write,
  новый Consumer с изменившимся типом, partial→informed→full, оба halves,
  owned replacement/equal storage, shrink/restore, malformed rows и отсутствие
  выдуманных координат после роста. Прежние predicates сохранены.
- [Alternatives38](witnesses/used-scope-20261020/receiving-conditional-alternatives.c)
  GREEN на88/03: оба порядка и halves, третья строка после конфликта,
  новый Consumer не получает ambiguous адрес, full permission не сочиняется,
  запись через адрес сохраняет другие поля; композиция source views идёт
  через ту же операцию. Exact87 control того же C —26 checks/9 FAIL;
  проверки после отсутствующей записи защищены, поэтому count меньше38.
  Original9 отдельно остаётся9/0.
- Прежние789+54 kernel predicates GREEN на88. Fault/baseline процессы:
  scoped78, full86, cached-refinement172; каждый достигнутый allocation failure
  отказал, старые записи/owned-map не изменились, итоговый live delta0.
  [Refinement fault input](witnesses/used-scope-20261020/receiving-coordinate-refinement-faults.c)
  сохраняет исходные проверки атомарности и проверяет старый owned child map.
  Бюджеты измерены заново, не заменены старыми62/70/140.
- Exact old-public sensitivity control сохраняет773+54 GREEN и шесть
  ожидаемых отказов новых bounds predicates. Это не шесть regressions88.
- Все142 прежних source/root value cells GREEN на88/03: переставленные
  layouts, references, indices, copy, hidden roots, synthetic, прежний
  used-views RED и отказ без evidence. Прежние oracle не ослаблены.
- [Missing used field](witnesses/used-scope-20261020/receiving-hidden-missing-used-field.lm2)
  ещё4/4 GREEN: raw foreign graph имеет допущенную Other(x,y), но не
  координату v; implements отказывает до входа use, `entered=0`.
- [Unused positive conflict](witnesses/used-scope-20261020/receiving-hidden-unused-conflict.lm2)
  ещё4/4 GREEN на88 и RED4/4 на87. Raw value допущено к A(v,w) и B(v,pad,w),
  без физической layout; Consumer использует только v. Проверены7→41→43,
  запись через адрес, сохранённые pad9/w29. В forced-walk остаются только
  foreign door и launcher machine bindings; use/check исполняются walker.
- Итого150 actual source/root cells на88/03. CALL-data81 direct record4 port
  отдельно сохраняет все79 прежних predicates и проходит79/0.

Тестовый [foreign ABI helper](witnesses/used-scope-20261020/include/l2src/tests/opaque_bound_views_test.h)
вызывает обычный admit_receiving с явной correspondence, проверяет успешный
допуск каждой модели и отсутствие физической layout у raw graph. Его
interleaved source slots относятся только к двум fixtures, не к runtime-эвристике.

## Ошибочные попытки сохранены

Первый helper предполагал физическую identity между компактным raw value и
source-графом с retained bodies. Все4 запуска abort3 в setup, не в Consumer.
Исправлены fixture coordinates; ожидания прежние. Повторные4/4 выше — на
явной карте. Extended87 test01 неверно кодировал used edge и разыменовал
отсутствующую запись;02 исправляет новый fixture и защищает продолжение после
failed assertion, прежний9-test не меняется.

Runtime88 attempt01 не создал C из-за L1 multi-dedent;02 добавляет tail cutter.
Первый fault-run02 нашёл второе allocation после первого отказа (seen7 при
fail6), хотя no-publication/live-delta уже проходили. Runtime03 прекращает
выделения сразу;78/86/172 fault runs относятся именно к03. Full87 recipe01
первоначально ссылался на отсутствующий C;02 на исходном70-test дал70/0.

В унаследованных сообщениях рецептов88 встречаются старые строки
`Runtime87`/`Kernel84`: фактические stage/runtime paths, object SHA и argv
в results.json относятся к88. Это не результаты предыдущего runtime;
не исправлять старые журналы задним числом ради метки.

## Воспроизводимость и незакрытые границы

Дополнение после окончания gate: kernel88 завершён325 OK/2 FAIL из327,
actual exit1. ADMIT остаётся58/25/broken0. Новый отказ table169/1:
«a copy with holes answered its type as the plain identity». Прежний85
table был169/0. Общий join/keep мог OR-ить `holes`, превращая новое
положительное обязательное обещание incoming identity в UNUSED, а затем
вернуть YES вместо отказа. Поэтому87/88 **не dependency-closed**, даже
после150 source cells и остальных локальных GREEN.

Private89 snapshot02 проверяет сохранение обязательного presence contract
до объединения, в обеих половинах. Пустое требующее поле не утверждает
присутствия — как в общем DFS. Первая89 попытка без последнего условия
отказала другой старой проверке partial self-body и сохранена как169/1.
С02 неизменённый полный table fixture проходит169/0
(`build/codex_table89_values_02.ps1`). Runtime89 и остальные регрессии ещё
проверяются; не переносить локальный169 GREEN на непроверенные контексты.
Ни один из169 predicates не менялся; native/walker код не менялся.

Actual runtime89/02 затем собран terminal0. Повторные stable16,
current-reference83, reference112, dependencies39, original9/refinement48/
alternatives38 и прежние789+54 predicates GREEN.78 measured scoped allocation
процессов тоже GREEN. Source142 ещё выполняются в session59372;
full/cached faults, дополнительные source8 и CALL-data79 ещё не повторены
на89. Полный kernel88 нельзя считать полным gate для89.

Recipes: `build/codex_impl87_runtime_02.ps1`, `codex_proof87_values_02`,
`codex_contract87_faults_02`, `codex_refinement87_faults_01`,
`codex_impl88_runtime_03`, `codex_proof88_values_02`,
`codex_alternatives88_values_01`, `codex_impl88_kernel_values_02`,
`codex_contract88_faults_01`, `codex_refinement88_faults_01`,
`codex_impl88_source_values_01`, `codex_catalog88_nested_variants_02`,
`codex_call_data88_values_01`; argv/actual exits сохранены в журналах и JSON.

2290 raw pins независимо повторно проверены:
`build/codex_impl87_88_completed_02.inputs.sha256`, manifest SHA256
`3884B3D22BF72EEF882EC030C387268962FE393A53FDC5BEDD90FC30103B6C48`.
Receipt01 попытался хешировать собственный открытый output log и отказал;
02 исключает receipt logs. `l2_driver_launch.err` исключён до любого чтения,
хеширования или копирования. Live kernel88 outputs в этот receipt не входят.

Frozen полный kernel88 запущен отдельно: session80095, worker PID15748,
startUTC2026-10-20T23:19:42.6216617Z,
`build/codex_impl88_kernel_01.ps1`; input3209 public tracked files плюс
14 private core overrides88 и неизменённый call_data81 port. На момент
этого checkpoint terminal result ещё не получен. Не запускать дубль,
не выдавать прежний327/1 kernel85 за результат88. Old manual ADMIT fixture
ещё не мигрировал; его прежние25 FAIL labels остаются открытым долгом.

Не доказаны все классы receiving evidence и приоритет declared giving place,
полный multiclass pure walker CALL и все переходы conditional evidence через
несколько композиций. Проверить, не теряется ли различие ambiguity/неполнота
при передаче между операциями; нынешние38 checks не универсальное доказательство.
Не вводить произвольный выбор первой модели, legacy decoder или отдельный обход.
Legacy primitive typed-take/empty Consumers, последний manual ADMIT port,
full L2 re-gate, public promotion и остальной v3/self-build/mail OPEN.
Goal активен; следующий обычный шаг не требует подтверждения автора.
