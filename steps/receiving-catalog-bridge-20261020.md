# Receiving catalog86 и незакрытая эквивалентность доказательств

Ненормативный checkpoint, 2026-10-20. Следует за
[current-contract84/85](receiving-contract-proof-20261020.md).
Public dev не изменён; proposed compiler86 не принят как dependency-closed
исправление. Продолжать общий механизм; не вводить ветку для merge.

## Возможные мосты — не разрешение значения

На compiler79 + runtime84/05 программа
[synthetic address](witnesses/used-scope-20261020/receiving-hidden-synthetic-address.lm2)
отказывала во всех четырёх translation/root cells. Good уже допущена к Model,
но box хранит новую модель от merge(Model). В каталоге не было возможного
моста между прежней требуемой схемой и текущей синтетической.

Compiler86 дополняет единый каталог динамического источника мостами от
receiving schemas, уже содержащихся в конечном program pair inventory.
Типы и адреса каждого моста подготавливает тот же L2D105Plan, COUNT/FILL
читают его закрытый результат. Runtime не получает разрешения из наличия
строки: сначала требуется настоящая физическая layout либо завершённое
соответствие именно этого значения, затем общий аналитический допуск.
Нет вывода раскладки по конструктору, нового разбора пути, имени в native
или отдельного алгоритма ссылок/индексов. Source diff86 —17 строк одной
функции l2_d105_catalog; runtime не менялся относительно84/05.

Первая версия без условия динамического источника изменила три прежних
65 metadata expectations, в том числе sealed consumption. Версия02
сохраняет известный физический источник и дополняет только динамический.
Прежние65 predicates сохранены, source-linked194 distinct assertions GREEN.

## Измеренные результаты

- Прежние37 source fixtures ×2 roots и14 mixed fixtures ×4 cells:130 GREEN.
  Весь L2/L1/C сгенерирован заново на compiler86 и собран с ABI84;
  это не повторная линковка прежних79 program.o.
- Synthetic address:4/4 GREEN. Проверены actual7, write41, address write43,
  readback и сохранённый pad29. В forced-walk артефакте остаются только
  foreign C door и launcher machine bindings; use/check исполняются walker.
- [No-evidence refusal](witnesses/used-scope-20261020/receiving-hidden-synthetic-no-evidence.lm2):4/4 GREEN.
  [Test-only door](witnesses/used-scope-20261020/include/l2src/tests/opaque_graph_unclassified_test.h)
  создаёт обычный one-int граф того же вида, но без layout и receiving
  correspondences. Он отказал через implements до входа use, counter=0,
  чужие Good fields не изменились. Строки catalog не заменили доказательства.
- Всего138 фактически выполненных source/root cells GREEN этих границ.
- [Bridge metadata](witnesses/used-scope-20261020/receiving-catalog-bridge-test.c):72/0.
  Все65 старых predicates плюс7 новых: текущий мост, counts/types, отсутствие
  дублирования, sealed emission при отключённой namespace field metadata,
  обе половины map и полный release. Exact79 frontend control:72/4, отказывают
  только четыре из новых7 assertions. Рецепт01 не передал исходному FILL
  тесту имя output-файла и получил два старых отказа; рецепт02 исправляет
  argv, не predicates.
- Exact79 compiler + тот же runtime84 и новые ABI headers: первоначальный
  synthetic address по-прежнему RED4/4, actual exit1 вместо oracle7.
  Следовательно новый GREEN не вызван одной сменой runtime/headers.

Рецепты: build/codex_catalog86_build_02.ps1, catalog86_values_01,
catalog86_consumers_01, catalog86_mixed_01, catalog86_nested_variants_02,
catalog86_bridge_unit_02, catalog86_control79_01. Подробные argv, SHA,
bindings и exit codes сохранены в их output/results.json и журналах.

## Обязательный положительный контрпример — ещё RED

[Used views](witnesses/used-scope-20261020/receiving-hidden-synthetic-used-views.lm2)
добавляет вторую настоящую принятую модель Short, содержащую только v.
Полная Model содержит v,w; use читает/пишет только v. Обе прежние принятые
модели сопоставляют v одной и той же ячейке Good. w не используется этим
Consumer; Good.w=9 и pad=29 должны оставаться прежними.

Proposed86 отказывает4/4 до ожидаемого результата7, native и forced walker.
Предыдущие138 GREEN **не** закрывают общий алгоритм. Нельзя убрать Short,
поменять положительное ожидание на удобный отказ либо считать иной порядок
строк исправлением.

[Kernel counterexample](witnesses/used-scope-20261020/receiving-used-proof-equivalence.c)
на настоящем runtime84/05 даёт9 checks /3 failures, actual exit1:
оба исходных допуска успешны; новый допуск возвращает UNKNOWN2 во всех
трёх вариантах — явная used coverage, sparse ordinary Consumer, full
requirement при наличии достаточного complete proof и совместимого
неполного evidence. Старые записи не меняются на отказе.

Кодовая причина видна в общем lmx_implements_resolved_view: после композиций
он требует lmx_implements_same_map по ВСЕЙ width и обеим половинам. Вторая
модель даёт UNUSED для w, первая — настоящий адрес; UNKNOWN/неполнота
отождествляется с противоречием. Такой же strict equality используется
при выборе нескольких source views и перед публикацией. Это не native
защита и не недостаток только merge-emitter.

Следующий срез должен согласовать общее объединение/сравнение адресных
свидетельств с реально требуемым Consumer, неизменяемыми уже доказанными
адресами и допускаемым уточнением неизвестных координат. Отдельно проверить
новый Consumer после частичного допуска, порядок complete/partial evidence,
действительный конфликт двух известных адресов, обе halves, вложенные
ссылки/индексы, map counts/types, атомарность, ownership и allocation faults.
Все Consumers/движки должны пользоваться общим результатом; не добавлять
fallback, новый parser или частный фильтр Short/merge.

Рецепт kernel counterexample: build/codex_used_evidence87_control_01.ps1.
Private86 оставлен для продолжения вместе с safe current-contract84;
публичного переноса и full L2 re-gate86 не было. Последний frozen kernel85
остаётся327/1 на исходниках84, его нельзя переименовать в результат86.

1195 файлов независимо повторно хешированы в
`build/codex_catalog86_completed_02.inputs.sha256`, включая исходные
LM2 input argv и обычные convert/primitive inputs; SHA256 manifest:
`98972B8D23E408935E78BF5C955A742D942BC623DC4E5010C095C5A30505B7FC`.
Current compiler LM1:
`FF868673B06EBA6B49A475663057D7A50D0CD22A3E9E08E1FF6E33767BA00C56`.
Tracked72-test в точности равен измеренному C:
`4BD5DFDAE3C4E4BECE99379201BB0B9BC20BA23C5E27AB4461DE4D241C5A9CDC`.
Kernel9-test:
`4F62A9887E82C78FFB549F93DD747DEDA812572947EAC4D5C73F6FF2829E2B53`.
Запрет на l2_driver_launch.err соблюдён до чтения/хеширования/копирования.
