# M8: перепись и подготовка потребителей, срез 360

2026-11-13, codex. База — 63ee1054, принятый пакет P0. Это первый подшаг
M8, а не приёмка сохранения групп. Нормализация и отказ голого head:
в принятом парсере пока остаются.

Рабочее дерево — P/wt/sol-m8-20261113-01, квитанции —
P/runs/sol-m8-20261113-01 (далее R), стадия — P/sol-p0-stage01 (S), где
P = C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01.
Сохранённые WIP других сессий не менялись. Старые boot01 и graph02 не
перезаписывались; новые образы имеют собственные имена.

## Что изменено

P0 отмечает только фактически выполненное раскрытие: FRAME_SOLE_GROUP
и TRAILER_SOLE_GROUP — биты диагностических флагов, без новых полей ABI.
Дамп, статус и диагностика разбора сохраняются. Команда графа
`groups ROOT LIST NEW_OUT` обходит уже разобранное дерево, включая вложенные
документы, трейлеры и Mix; не угадывает роль головы и не сканирует build2.
Список входов задаётся явно. Колонки TSV: file, kind, metadata, offset,
line, column, flags, head. metadata=1 отделяет Mix. Для трейлера позиция
относится к его владельцу; flags — флаги Frame либо трейлера, не Node.

Перепись финального исходного пакета: 487 поддерживаемых .lm2 в selfbuild из Git,
24 723 раскрытия; из них 24 525 в 108 исходниках ядра/инструментов и
198 в 379 тестовых входах. В этом пакете все строки — Frame вне Mix.
return — 14 472, const — 3 706. Это события нормализатора в дереве,
не число строк исходного текста и не число исполняемых записей.
Полные списки и отчёт: R/all-maintained.list, R/sources.list,
R/groups-final02.tsv; [точный список входов](inputs.list). Замеры groups02, groups-all01 и groups-final01
относятся к более раннему исходному пакету этого же рабочего дерева.

`lm_compiler_description_body` даёт заимствованный вид группы там, где
ресивер читает описание. Он не меняет P0 и владение узлами, не раскрывает
обычные объявления Structure. Проверка единственного активного поля
обходится без повторного подсчёта всего тела. Экспорт добавлен в штатный
рецепт машинного модуля.

Команда L2 `group-migrate ROOT SITES` применяет просмотренные места отчёта.
Строка SITES — relative-file TAB offset TAB exact-head, в порядке файла и
смещения. Инструмент сверяет голову, двоеточие и открытие группы, затем
удаляет только двоеточие и промежуточные пробелы/переводы строк:
`A: (fields)` становится `A(fields)`. Выбор объявлений остаётся смысловым
шагом по отчёту, имя в алгоритм не зашито. Исходники проекта этим срезом
ещё не мигрированы: сначала нужен общий приём аргументов вызова.

## Граница и следующий шаг

Группировка выражения уже читается рабочим frontend, но аргумент-Structure
нужно принимать общим связывателем вызова по контракту формалов. Пример
[grouped-call.lm2](grouped-call.lm2) фиксирует эту зависимость до переключения
парсера. Кандидат с отключённой нормализацией сохранён отдельно:
S/frontend-m8-02 и R/m8-preserve-groups-candidate.patch. Он не продвигался
и не служил seed принятого bootstrap.
Принятый G2 компилирует grouped-call.lm2 с кодом 0; кандидат без раскрытия
отказывает с кодом 1: `add_fields has no argument b`, строка 4, колонка 13.
Отказ относится к связыванию двух полей написанной группы, не к разбору P0.

По просмотру кода следующая правка проходит через
lm_compiler_bind_value_actuals_into и lm_compiler_whole_candidate/shape
рабочего frontend; в чистом графе — через lmx_graph_single_candidate,
lmx_graph_bind_call/call_single и получение значения по принимаемому
контракту. Сейчас single_candidate распознаёт имя, merge и путь, но не
написанную анонимную Structure. Части ресивера fn также должны читать
группу как описание без раскрытия обычного объявления. После снятия
нормализатора отчёт groups нужно перевести на наблюдение сохранённого
тела; диагностические биты выполненного раскрытия тогда больше не нужны.
Сохранённый кандидат перед переносом сверить с финальной редакцией среза.

Дальше M8.2: общий приём написанной/вычисленной Structure в вызове для
чистого графа и рабочего frontend, затем миграция просмотренных обычных
объявлений, снятие нормализации и пустой head:. Отдельно остаётся уже
зафиксированный пропуск return-трейлера построителем чистого графа.
M11 и настоящая самосборка L3/L2 этим подготовительным срезом не закрыты.

## Проверки

- Финальный образ graph-m8-05 и настоящий G2 tool: 139 случаев parser-suite,
  0 отказов. Ожидания P0 не менялись.
- Отчёт для Frame, return-трейлера и Mix совпал с независимо записанными
  тремя строками TSV, включая смещения 0/25/37 и metadata 0/0/1.
  [Вход](records/roles.lmx), [результат](records/roles.tsv).
- G2 group-migrate изменил только два выбранных объявления (однострочное и
  вертикальное); L2 same подтвердил точный текст. Неверное смещение отвергнуто,
  исходный текст второго файла сохранён и проверен same. Проверки — штатными
  командами L2; нового внешнего test runner нет.
- whole_arguments прошёл interp/native/forced на graph-m8-05 с G2 frontend,
  backend и runtime; 3 PASS. Полный режим не запускался.
- Bootstrap quick boot-m8-01: G0 собрал и проверил G1, настоящий G1 собрал
  и проверил G2. В каждом 9 smoke-строк, 0 отказов; оба пакета продвинуты.
- Восемь сравнений G2 tool: L1/C frontend и tool равны побайтно, runtime
  driver.o равен побайтно, образы frontend/backend/tool равны кроме PE-времени
  линковки. Runtime также совпадает с принятым P0 по SHA.
- Canonical selfbuild/inputs.sha256 — 597 входов, равен source08.sha256.
  Bootstrap использовал source07. Различается только l2_graph_tool.lm2:
  финальная диагностическая команда допускает любые явно выбранные файлы,
  сохраняет прежнее экранирование эмиттера и выводит голову в одной строке TSV.
  Она не входит в consumed-inputs bootstrap и отдельно собрана настоящим G2.
- Docs check docs03: 35 пар семантики, 14 implements-случаев, оба снимка
  источников, 27 пар грамматики, 44 буквальных excerpt, 615 импортов,
  ссылки и точное вступление; LF индекса для 27 008 файлов. Первые docs01/02
  остановились на запуске Git без созданного PRIVATE_OUT; финальный запуск
  использовал заранее созданный R/docs03. Текстовые квитанции приведены к LF.

Основные квитанции: [bootstrap](records/bootstrap.txt), [сравнения](records/fixedpoint.txt),
[P0](records/parser.out), [документы](records/docs-check.txt); полные журналы,
сравнения fixedpoint03 и результаты parser-final02 — в R. Команды:

```text
TOOL = S/boot-m8-01/g2/tool/lmxtool-tool.exe
GRAPH = S/graph-m8-05/graph_trans-prod.exe
REPO = P/wt/sol-m8-20261113-01

S/tool-m8-03/lmxtool-tool.exe 0 entry 0 -- bootstrap quick REPO S P/cold-candidate48/full48/g2/frontend S/boot01/g2/frontend/l2trans.exe boot-m8-01 S/tests/smoke-kernel225.tsv
GRAPH 0 entry 0 -- groups REPO R/all-maintained.list R/groups-final02.tsv
TOOL 0 entry 0 -- parser-suite REPO GRAPH REPO/tests/parser/current/expectations.json R/parser-final02
TOOL 0 entry 0 -- group-migrate R/migration02 R/migration01/selected.tsv
TOOL 0 entry 1 -- group-migrate R/migration02 R/migration01/stale.tsv
```

SHA-256 принятых образов, кандидата и полных данных отчёта:

    ff89762c37d55c6f1532d9f0163013e9f3c23c19b2391111148e7d7858f0c4f9  S/boot-m8-01/g2/tool/lmxtool-tool.exe
    c91b59ec19e4b8d382890346ac5b7f57c00f29e2430f22785df36583fd2d78d6  S/boot-m8-01/g2/frontend/l2trans.exe
    13885fe824f723dda816b09ec5517d6e88a9436c853fe8d9b94e833b96185ae4  S/boot-m8-01/g2/frontend/l1trans.exe
    f383c5274bfb135effa194d06ab895a4fc6caae3a49e16f4748e269eb2befefc  S/boot-m8-01/g2/runtime/driver.o
    d8db4eb5e521b83cbdfe92aa6c0973e27f07b4334c614985f90283dc6f52ecb4  S/graph-m8-05/graph_trans-prod.exe
    ad534ca021e922de627bc303e3420217bb4227ade358e09647da890e514303a1  S/frontend-m8-02/l2trans.exe
    5743ad157b63e7ee747977dd7de481f5827df7f8c577e4f37fb58083744fd2f7  R/groups-final02.tsv
    d006846d2c7085460f0f0655fb6183fbb6466e4ad43edce15142d3c5eb880c8b  R/source07.sha256
    5944865e6a664d85b24eaf21e10fefdd193e882d2bec147ac5c7d747cce56939  R/source08.sha256
