# M11.5д/7: требования физического места, срез380

2026-11-14, Codex. База main/origin:
d670a0e9eb9ef4450907f88f0f058b20314f20b0 (принятый379).
Работа только C:/Nyasha_Planet/LMX, main, один writer/build.
Статус: кодовая приёмка, штатные render/docs gates и финальный index check пройдены; далее commit/push main.

## Изменение

Baseline379 [первая проба](baseline01.log) отказывала4 на atom-slot.
Требование относится к принимающему физическому месту на время всего исполнения:
известная Structure, написанная атомом, даёт NONE; последующие Structure/int/Structure
не меняют его на тип нового payload. Лексический atom_target выбирает сущность
без чтения неинициализированного payload и без подмены формалом текущего вызова.

Повторно использованы ImplContractFact/ImplContract и LmxCopyMap: GraphSpace хранит
один факт на физический slot и индекс slot→ordinal+1. Рост массива не оставляет
указателей на старые rows. Это не журнал записей, не копия графа, не SourceName metadata
и не история в Work. Space освобождает обе временные структуры на выходе; следующий
независимый обход выводит описание заново из текущего графа. Serializer переносит только
текущий граф. Merge/Fn-data устанавливают факты новых мест по действующему соответствию
источник→копия; таблицы контракта в граф не переносятся.

Обходчик и native вычисляют base/index, вызывают Run slot_prepare до RHS, затем Graph
допускает полученный адрес по сохранённым kind/type либо NONE и выполняет прежнюю
запись с инвалидизацией. Неверный индекс сохраняет старую границу отказа после RHS.
Низкоуровневые facts/type/admit живут в Graph, лексическая подготовка в Run.

Общий assignment builder снимает только синтетическую обёртку одного formed Frame.
Прямой RHS merge(...) теперь выполняется как application; написанная группа остаётся
literal, исключение assignment AST сохранено. Девять прежних expected изменены лишь
в скобках синтетического RHS; ответы и значения58 pure-проб сохранены.

## Сборочная closure

Bridge04 построен на принятом379 до полной смены Space ABI. Неудачный runtime01
выявил цикл Graph↔Run header: низкоуровневые helpers перемещены в Graph.
Перед bridge04 проверены и восстановлены333 consumed inputs379; restore затронул
только частный stage. Сначала producer, затем полный source sync; чужой WIP не тронут.
Graph71/Run51/implements74 согласованы, append имеет также статический прототип
в существующем L3-генераторе. Runtime02 и graph02 собраны штатными командами.
[Source04](source04.sha256) verified717, SHA-256:
f255aebc815b78d24e40bf636a7d4421154fd76b45040dbc0afc66e24c0eb62e.

## Независимые ожидания и результаты

- slot_atom_replace: три последовательные записи дают7/41/9.
- slot_atom_lexical: формал A=9 не подменяет лексическую Structure A; seen7.
- slot_fact_growth:12 разных receiving facts, повторная запись каждого; sum492,
  last2/count12 после новой Structure в последнем слоте.
- slot_atom_rhs: настоящий вызов rhs() в индексе операнда merge удаляет исходное A
  из Holder до внешней записи; calls1/seen7 доказывают подготовку требования до RHS.
  Поля написанной literal Structure сами не вычисляются: ранняя исследовательская
  форма (int:trigger rhs()) не доказывала RHS effects и в принятую проверку не вошла.
- slot_atom_copy: merge копирует ранее заменённый atom-slot; последовательные записи
  дают copied_number41/copied_length2/source_length2. Вычисляемый sub копирует Src
  как свою data, добавляет обычный own number41 и записывает его адрес в слот0;
  made_stage2 и индексная ссылка дают made_number41.
- slot_context_reset: первый отдельный проход даёт stage1; следующий выводит уже
  Structure requirement из текущего графа и отказывает4 на int address, stage1 сохранён.
- slot_typed_refused: физическая Structure принимает другую Structure, затем
  отказывает4 на int address; stage1 и прежняя B сохранены.
- slot_typed_rhs_refused: int-место отказывает4 адресу Structure-ref cell (тот же
  primitive kind, другой type); before1/after0/calls1/старое value7.
- slot_bounds_rhs_refused: RHS вызывает функцию один раз, затем отказ7;
  after0 и прежний Slots(A) сохранены.

[Private67](private01.log) прошёл в interp/native/forced; все201
[полных AFTER](private-after01.log) совпали. Отдельный [reset с двумя проходами](private02.log)
прошёл во всех трёх режимах; ещё3 полных AFTER проверены тем же штатным comparator.
[Mutation24](mutation01.log) прошёл.

[Native trace](native-slot-rhs01.log) показывает actual lm_graph_root →
slot_prepare → native rhs → index_write, затем внешнюю запись и normal exit.
Это не утверждение native всех nested/copy callee. Исходный GDB command file остаётся
только в build output; [генерируемый фрагмент](native-slot-rhs-generated.txt) сохранён
как свидетельство общего порядка. Поддерживаемый дополнительный runner не создавался.

## Настоящие поколения

[Whole bootstrap quick](bootstrap01.log) прошёл: настоящие G1/G2, по9 smoke;
[fixedpoint13/verify717](fixedpoint01.log) пройдены. Runtime02 driver.o побайтно равен G2:
91a50561127b10338f0933ae59f464d143cfd7115e46b06b97779784d6079062.
Штатный G2 [заново собрал graph-tool](g2-build01.log), SHA-256:
84076e93b57dce186764cf23e94d394873f8eae2138638d24ed15d3a206f44c1.
[68 случаев](g2-01.log) прошли в трёх режимах, включая reset2;
[84 полных negative AFTER](g2-after01.log) и [mutation24](g2-mutation01.log) совпали.
Дополнительные3 private AFTER reset2 [проверены](private-after02.log).
Рабочая кодовая связка boot-m11-slot-contract-01/g2 + graph-m11-slot-contract-g2-01.

## Документация

Штатный [renderer](docs-render01.log) пересоздал35 пар семантики,14 implements cases
и оба snapshot. [Первый docs-check](docs-check01.log) дошёл до line endings, но не получил
обязательный существующий PRIVATE_OUT. Исправлена только команда: [повтор02](docs-check02.log)
прошёл35/14/27/44/615, ссылки и LF27563 до staging. Прежний receipt не перезаписан.
Это ошибка подготовки выходного каталога, а не дефект семантики или проверки окончаний строк.
Грамматика не менялась. Финальный [docs-check03](docs-check03.log) проверил полный staged index:
35/14/27/44/615, ссылки и LF27604. Его собственный receipt добавлен после проверки с UTF-8/LF;
оба diff --check чисты. Чужие два untracked сохранили исходные SHA-256.

## Открытые зависимости

Допуск380 ограничен существующими физическими kind/type/NONE. Глубокий Structure
implements и статический admission M11.7, полный M11, storage M13 и shared cache/
flush/обычный native M14 остаются OPEN. Не проверять deep models текущим payload kind.

Копирование лексического предка с raw fn/sub требует переноса construction binding
через общее соответствие копии. Наблюдаемый отказ3 при пути к скопированному main
является также границей обходчика M11.5г/5д, не только native M14.
Computed declaration с известным static name в nested BODY ещё может отказать3
на capture; достигнутый fn_apply ограничен ROOT/own DATA и отказывает5 для nested BODY.
Оба пункта включены в основной v3, без обхода искусственными методами.

Для будущей правки copied binding нельзя просто повторить constructor от raw initializer:
у уже созданной F должны копироваться текущие own data через ту же карту, без сброса
накопленного состояния. Контроль должен сначала прогреть source count до3, затем
получить copied call4 при неизменном source3; исходный контроль count0 этого не доказывает.

Весь goal ACTIVE; после приёмки продолжить основной v3. Полный suite не запускался:
штатная whole bootstrap quick сохраняет настоящие поколения и минимальные smoke.
