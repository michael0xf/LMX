# M11.5г/8: вычисляемые fn/sub и лексический CodeBody, срез381

2026-11-14, Codex. База main/origin:
c5ba5ef9c2693e2b817dbb9cdf90ce63cbf711f8 (принятый380).
Только C:/Nyasha_Planet/LMX, main; один writer/build.
Статус: кодовые проверки, whole bootstrap/fixedpoint, повтор G2 и штатные render/docs gates пройдены;
финальный index-check пройден; далее commit/push main.

## Поведение

Вычисляемые fn/sub в BODY применяют прежние receiver_bind/make/fn_apply там, где
исполнение дошло до producer. Written объявления по-прежнему готовятся при входе
в свой блок. Имя будущего локального метода откладывает только обращения в его
лексической области; unrelated missing сохраняет прежнюю раннюю фазу отказа.

Вложенные if/for/прочие CodeBody исполняются в прежнем кадре над той же DATA, но
отдельный контракт fn/sub сохраняет их имена в собственном лексическом блоке.
Из общей активации не следует экспорт fn-имени после if. Source holder, raw Frame
и F.parent сохраняются; Space использует существующие scope/name/value rows.

GraphFrame получил только lexical_scope — курсор выбранного физического CodeBody.
code/body/data остаются идентичностями запуска. Общий work_scope готовит written
объявления только при фактическом входе. Обходчик сохраняет/восстанавливает cursor
одной обёрткой block, включая flow/error; private block_body использует прежнюю логику.
Native выставляет cursor на входе и перед последующими statements, на if join и
loop test/end; redo/continue/cleanup входят через общие prefixes. Первый statement
уже покрыт entry-prefix: финальный emitter не повторяет тот же вызов.

Новая локальная F маскирует только FREE fallback своего scope, после данных и
формалов. Inline binding не подменяет общую строку снимка и не активирует её
для дочерних вызовов. Уже созданная inline F при reentry тоже не становится
free snapshot соседнего блока. named_int использует общий resolve_binding;
preflight/store не записывают поверх scoped F через старую free-ячейку.

В существующем Work.loaded различены loaded value1, динамическая видимость2,
all-required-pending4 и entry-required8. Бит4 — AND по обязательным употреблениям
строки, не OR; новое закрытое обращение его снимает. Pending local head сохраняет
снимок для возможного чтения до producer, но само по себе не делает его входом
для дочерних вызовов. Настоящее чтение/запись активирует2; mapped rows сохраняют
прежние load/dirty правила. Новых таблиц, активаций, opcode и журнала записей нет.

Initializer явного merge сканируется своим value reader в текущем lexical scope,
а не откладывается в общую очередь statements с чужим cursor. Сохранённая written
Structure сама не запускает поля; explicit merge-конструктор, как раньше,
вычисляет initializers. Это различие подтверждает прежняя received_structure_values.

## Проверки с независимыми результатами

- BODY с известным именем:9; whole descriptor с вычисляемым именем:12.
- Ordinary C(D): out28, default by-path14, cold initializer calls0.
- Fallback: перед producer внешняя local(5)=105, затем новая local(5)=50;
  результат10550, physical k8, входной snapshot остаётся5.
- Inline: quiet90/selected790 — внутри7, снаружи90. Повторный вход written
  local даёт790/790, sibling block не получает inline F.
- Dynamic parent helper даёт790: cursor вызывающей активации сохраняется
  при дочернем вызове и восстанавливается после inline.
- Grouped nested numeric actual:5 при physical8. While/continue:23,
  то есть2 iterations и3 вызова внешнего gate, вместо преждевременного stop
  через внутренний gate.
- Sub: direct2/nested2; explicit call по code\[0]direct даёт counter3.
  Голый code\direct отказывает3: при чтении CODE как DATA объявление и
  два call Frames являются тремя одноимёнными вхождениями.
- Privacy World:178, first8/consumed5/second5, physical8. Сохранённая группа
  не читает k; pending inline head не передаёт внешний snapshot5 в leaf.
  Позднее настоящее numeric consumption читает5 и делает его видимым leaf.
- Closed missing:3/touches0; mixed unknown DATA + inline pending:
  3/touches1/body_effect0. Обязательный внешний input проверен после ordered
  DATA, до BODY effects. Внешний merge initializer:3/touches0.
- Scoped Fn слева:4/before1/calls0/old x7 до RHS. Bare Fn в числовом
  return:1/before1/old x7 вместо чтения внешнего int.

Все17 pure прошли; [67 прежних полных AFTER](control-after01.log) совпали без
изменения expected. [Private31](private01.log) прошёл в interp/native/forced;
[93 полных AFTER](private-after01.log) и [mutation24](mutation01.log) прошли.

Bridge01 построен на принятом380 до полного stage sync: Frame layout/Run52
меняются согласованно. Первые runtime translation остановились на tail-cutter
оформлении и явных C-type casts; финальный [runtime06](runtime06.log) собран,
driver.o SHA-256:
3780bf765e038e525ba3560ae92e149ce6f11a9e2c6cf0cba18ba5d6418edcec.
Graph71/Run52/implements74; отдельная инфраструктура объявления не создана.

Source07/751 покрывает private31. Затем emitter снял один лишний scope call
первого statement, без смены runtime. [Graph03](graph03.log) и [новая inline
проверка](private02.log) в трёх режимах прошли на финальном [Source08](source08.sha256):
b84c11fec03b4eb7fa7a35db19ebf732be8ab13975191eb704207dab0961e906.
[Verify751](verify08.log) прошёл. Готовые31 бинарники не пересобирались из-за
receipt/golden или только другого ожидаемого значения.

[Native trace](native-lexical-scope01.log) показывает настоящий root и native outer
дважды, выбор physical CodeBody, fn_apply на его raw Frame, quiet90/selected790
и normal exit. Новая dynamic leaf идёт прежним walker fallback. Это не доказательство
полного native новых callable или обычных Structure M14.
[Генерируемый фрагмент](native-lexical-scope-generated.txt) сохранён как artifact;
одноразовый GDB command file остаётся в build output, поддерживаемого debug runner нет.

## Настоящая самопроверка поколений

[Whole bootstrap quick](bootstrap01.log) построил и проверил настоящие G1 и G2:
по9 smoke, actual G1 строит G2, оба поколения приняты штатным runner.
[Fixedpoint13](fixedpoint01.log) подтвердил одинаковые промежуточные L1/C,
runtime bytes, нормализованные executable и verify751 на frozen Source08.
[Штатный G2 graph-tool](g2-build01.log) построен заново, SHA-256:
b8abfe4c58cc5702009aa09f65ce0a9b040aec403602c1c31eec88989fbcce4f.
[G2 repeat86](g2-01.log) прошёл в interp/native/forced, включая second-walk reset2.
[102 полных negative AFTER](g2-after01.log) и [mutation24](g2-mutation01.log) прошли.
Рабочая кодовая связка boot-m11-computed-body-01/g2 + graph-m11-computed-body-g2-01.
## Документация

[Штатный renderer](docs-render01.log) пересоздал35 пар семантики,14 implements cases
и оба source snapshot. [Docs-check01](docs-check01.log) прошёл35/14/27/44/615,
ссылки и LF27605 до staging. PRIVATE_OUT заранее создан, receipt/CWD свежие.
Грамматика не менялась. Финальный [staged-index docs-check02](docs-check02.log)
прошёл35/14/27/44/615, ссылки и LF27660. Его собственный receipt добавлен после
проверки с UTF-8/LF. Оба diff --check чисты; два чужих untracked сохранили SHA-256.

## Оставшиеся работы

Полный M11 не закрыт: общий bounded CodeBody consumer для сохранённых групп
else/finally, рабочий frontend и полный implements/test M11.7/8 остаются OPEN.
Copied lexical construction bindings должны сохранять текущую live F/data через
ту же map, без повторного initializer; полный storage M13 и shared cache/flush/
ordinary native/continuation M14 — отдельные открытые зависимости основного v3.

Грамматика и P0 не менялись. Пробы короткого computed receiver отделяют следующий
return явным semicolon; общее построение Frame/receiver не заменено новым парсером.
Оба docs source и план согласованы штатным render/check после кодовых gates.
Чужие два untracked сохраняются. Весь goal ACTIVE; это очередной срез общего v3.
