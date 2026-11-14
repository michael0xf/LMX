# M11.5д: чтение написанных объявлений и копии значений, срез383

2026-11-14, Codex. База main/origin:
d0e384c156701f2367a78d782f4a3c78f78cff28 (принятый382).
Только main, C:/Nyasha_Planet/LMX; root — единственный writer/build.
Статус: private-проверки, native trace, whole G1/G2/fixedpoint, G2 repeat и штатные docs gates пройдены;
финальный index-check пройден; далее commit/push main.

## Общий механизм

[Различие копии raw объявления и удержанной F](../../handoff/copy-construction-reading-20261114.md)
сохраняется. Namespace исходного исполнения не переносится в копию графа.
Фактическое чтение отсутствующей F из raw fn/sub готовит достигнутый owner scope через
прежний space_declarations/evaluate0. Соседние written методы поэтому классифицируют
следующие computed actuals в том же порядке, что при обычном входе в область.
Копировщик, fn_data, физические slot/source/parent и правило обычного результата merge(F)
не изменены. Новых таблиц, error fields, кадров, opcode или парсера нет.

Один resolver получил query/read context. Query имён и binding_method остаются чистыми;
read возвращает локальный status и value. Это исключает повторный вход receiver-конструктора
из классификации его именованных actuals и сохраняет положительную ошибку конструктора,
вместо превращения её в missing3. Пути, числовые и обычные operand readers, capture,
чтение Model и @word используют тот же read. Slot requirement остаётся query.
Область enclosing fn для node определяется по точному raw source/parent, не только имени.
Существующая нормализация отказа поля на границе admission не менялась.

## Различающие значения

- [Baseline raw Scope](baseline-raw-methods03.log): source count1/2/3, затем copied main
  отказывает3. Новый читатель даёт copied main1/2, sub2, copied marks25 при source count3/marks3.
  Это новая F из copied initializer0; текущая namespace-F источника не импортируется.
- Scope, не запущенная предварительным call, даёт main1/2/count2; named parts с именем
  name дают source7/copied7 без рекурсивного повторного входа конструктора.
- Удержанная F копируется с текущей data. После прогрева3 три алиаса копии читают8,
  запись другим путём даёт9; source остаётся3, следующий source call даёт4.
- Явное создание clone из descriptor с count3 даёт4/5. После изменения descriptor data20
  clone сохраняет свою4, source остаётся3. Этот baseline уже проходил в382.
- Ordinary descriptor в числовом месте отказывает5 после before3, не превращается в FN.
- Непригодный written descriptor с extra отказывает5 при before1/after0; в382 чтение
  отсутствующей binding ошибочно давало3. Pending g с actual f() остаётся3/touches0;
  неизвестная до producer F не создаётся, сам f не вызывается. Неоднозначный путь даёт3.
- Два обхода одного графа: source_call/source_count1, held_call/held_count3. Новый обход
  создаёт свежие namespace bindings, а удержанная ссылкой F сохраняет собственную data.
  Этот контроль выполнен также native и forced с runs2.

Десять новых fixture pairs сохраняют полный AFTER. [Runtime01](runtime01.log) и [Graph01](graph01.log)
построены на Source01/761. Run53/Frame ABI сохранены; Build/GraphTool не менялись, bridge не нужен.
Source02 только добавил20 файлов; финальный Source03 исправил четыре старые строки expected.
[Source03](source03.sha256), [verify781](verify03.log), SHA-256:
4a7ed184d976b820d605f14c2e9a33970b16e0dae54c0ae95e83c35d9b5e5604.
Runtime driver.o: b1fe6b3f523aeb8c99870cb31291fed275fed49ea68e9a5058287be0616489ee.

## Private и старая форма expected

[Первый private34](private01.log) выполнил interp/native/forced.32 случая совпали полностью;
reference_alias и descriptor_merge имели только synthetic RHS wrapper, снятый ещё380/c5ba5ef9.
Он отличался уже в GRAPH-BEFORE, до исполнения383. [Seed382 reference_alias](baseline-reference_alias01.log)
и [descriptor_merge](baseline-descriptor_merge01.log) дают нынешнюю форму.
[Все6 сравнений с полным baseline AFTER](baseline-control01.log) прошли.
Исправлены ровно4 строки скобок: r1/r2 этих двух expected; числа21/33/3/3/7/7 и12/17 не менялись.
[Все102 полных AFTER](private-after01.log) готовых34 бинарников и [mutation24](mutation01.log) прошли.
Из-за expected бинарники повторно не собирались. Первый receipt с двумя FAIL сохранён.

[Native trace](native-copy-bindings01.log) показывает actual native root, consuming declaration
read и ordinary scope preparation, source7/copied7 и normal exit. Это не доказательство
полного native новых callable: M14 остаётся OPEN. Одноразовый GDB command file остаётся
в ignored build output, поддерживаемого debug runner нет.

## Настоящие поколения

[Whole bootstrap quick](bootstrap01.log) построил и проверил настоящие G1/G2,
по9 smoke; actual G1 строит G2. [Fixedpoint13](fixedpoint01.log) сравнил L1/C,
runtime bytes, нормализованные executable, frozen Source03 и verify781; все13 прошли.
[Штатный G2 graph-tool](g2-build01.log) построен заново, SHA-256:
10dbb1b4dab7e7dd3395ea441d8a481ec795e6992bf60f3afa0be91bc0e35b59.
[G2 repeat34](g2-01.log) прошёл в трёх режимах, включая runs2;
[33 полных negative AFTER](g2-after01.log) и [mutation24](g2-mutation01.log) прошли.
Рабочая кодовая связка383 — boot-m11-copy-bindings-01/g2 + graph-m11-copy-bindings-g2-01.
## Документация

[Штатный renderer](docs-render01.log) пересоздал35 пар семантики,14 implements cases
и оба source snapshot. [Docs-check01](docs-check01.log) прошёл35/14/27/44/615,
ссылки и LF27696 до staging. PRIVATE_OUT и CWD созданы свежими, грамматика не менялась.
Финальный [staged-index docs-check02](docs-check02.log) прошёл35/14/27/44/615,
ссылки и LF27737. Его собственный receipt добавлен после проверки с UTF-8/LF.
Оба diff --check чисты; два чужих untracked сохранили SHA-256.

## Оставшаяся приёмка

Штатные render/docs gates и финальный index-check пройдены.
Ограниченный proof двух классов копии не завершает внешний/вычисленный CodeBody,
used-interface/test M11.7, рабочий frontend M11.8, storage M13 или общий native/cache/flush M14.
Грамматика/P0 не менялись. Goal ACTIVE; после приёмки продолжить основной v3.
Два чужих untracked сохранить.
