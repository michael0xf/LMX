# M11.5г: общий вызов через выражение головы, срез379

2026-11-14, Codex. База main/origin:
369ded971a5ad42a8f014844886f62336afbfc7d (принятый378).
Работа только C:/Nyasha_Planet/LMX, main; один writer/build.
Статус: кодовая приёмка и штатные render/docs-check пройдены; далее commit/push main.

## Изменение

Baseline378 head-methods probe отвечал3 до исполнения: прежний anonymous
[path, actuals...] терял отличие nullary Frame от написанной группы и сканировал
именованный actual как вход caller. Общий carrier теперь [headExpr, WORD("()"),
actualsLmx]. Это обычный operator AST с канонической строкой, без отдельного opcode.
Named Frames сохраняют представление; query application_parts возвращает borrowed
head/actuals. Одна application_head выбирает живую цель до actual effects, затем
прежний binder/admission/invoke либо ordinary launch потребляет actuals.
Выбор между fn/sub и обычной Structure выполняет fn_result; descriptor без code
отказывает в прежнем binder до actuals, а не запускается как обычная Structure.

Entry scanner сначала обрабатывает head expression, затем existing call view actuals:
именованные labels не становятся free inputs; неизвестный target сохраняет optional
receiving contracts. Written outer groups остаются BODY values. Native emitter
использует ту же выбранную цель и source coordinates actuals; старые path-specific
runtime/emitter routes удалены. Own-data receiver helper отделён от общего root block.
Dump/serializer сохраняют пустые actuals и outer written group. Exact identifier
со скобкой не становится index-head application: общий index-text guard согласован
с прежним selector builder. Парсер заново не переписывался.

Graph machine frontend распознаёт carrier до binary/colon dispatch и явно сообщает:
expression-head application is not supported by the graph machine frontend.
Typed indirect lowering остаётся OPEN M11.8; named module/C-door calls сохраняются.

Частная опись M11.6 относительно378: восемь прежних helper функций (path_head,
dump_path, eval_path_statement, exec_statement, launch_head, emit_call,
emit_path_statement, emit_apply_or) заменены восемью общими helper функциями;
builder_application — одна новая функция построения общего AST. По git diff --numstat
пять затронутых core-файлов дают260 добавленных/230 удалённых строк:
graph87/42, run87/110, native tool50/60, builder26/5, machine frontend10/13.
Это частный перенос consumers, а не полное завершение M11.6/7/8.

## Независимые ожидания

- head_methods: quiet0, first5, empty2, named10, calls3. Группы (Holder\calc)
  и (Holder\calc()) не выполняют функцию.
- head_selected: first107, second203, head_count1/effect_count1. Chooser выбирает
  first до change(), который меняет тот же source reference на second.
- head_structures: Self5 после двух запусков, given data11; точное имя со скобкой
  сохраняет Structure и значение3.
- primitive head8, wrong arity5, no result5, signature without code5:
  effects0 и after0, actual touch() не выполнен.

Runtime01/graph02 построены. Семь pure и58 случаев в interp/native/forced прошли;
174 полных AFTER и24 mutation checks прошли. Первый AFTER manifest ошибочно
указывал native/forced.log; исправлен только receipt path на forced/run.log.
Все готовые58 бинарников сохранены, C повторно ради этого не собирался.
Source03 verify699 заморожен перед whole bootstrap.

[Whole bootstrap01 quick](bootstrap01.log) построил настоящие G1/G2, по9 smoke;
[fixedpoint13](fixedpoint01.log) и verify699 прошли. Source03 SHA-256:
5900418fc66ec872de828fa271bdcbacff547a9b9ca09606f67dcb69d30bf729.
Runtime01 driver d37f08e0e1a3ca6b049a917479d47b03ce3ff461127aa3c9aff7611500eae918
совпадает с G2. Штатный G2 [заново построил graph-tool](g2-build01.log), SHA-256:
241327771a0dd3d1249e347b8c5ee1fd79187d7d2e68f2fad25be6234ba3c542.
[58 случаев](g2-01.log) прошли в трёх режимах; все72 [полных AFTER](g2-after01.log)
24 отрицательных случаев и24 [mutation checks](g2-mutation01.log) прошли.
Рабочая кодовая связка S/boot-m11-head-application-01/g2 + graph-m11-head-application-g2-01.

Одноразовый внешний GDB [trace01](native-head-selected01.log) подтвердил actual native root,
application_head, native choose перед native change и normal exit. Числа107/203 и head_count1
сохраняются. [Генерируемый фрагмент](native-head-selected-generated.txt) показывает единственный
выбор головы перед actuals. Командный GDB файл остаётся только в build output; отдельного runner нет.
Две G2 frontend-пробы — [value](machine-head-value01.log) и [statement](machine-head-statement01.log) —
подтвердили ожидаемый capability diagnostic до binary/colon dispatch.

## Граница native и следующие работы

У private head_selected root, choose/change имеют native entry. Вложенные
Holder.first/second пока не получают native и используют прежний walker fallback.
Равенство чисел и AFTER во всех режимах не доказывает native этих двух callee.
Общий native обычных Structure, nested native registration, shared direct cache,
flush и продолжение после публикации остаются M14. Legacy computed-int physical
storage до публикации остаётся M13; полный M11.5г/5д/5е/7/8 не завершён.
Весь goal ACTIVE.

## Документация

Штатный [renderer](docs-render01.log) пересоздал35 пар семантики,14 implements cases и
оба исходных snapshot; норматива379 не добавляет, содержимое generated RU/EN осталось прежним.
[Docs check](docs-check01.log) прошёл:35/14/27/44/615, ссылки, semantic opening и LF27518
первого индекса. После добавления новых файлов [docs-check02](docs-check02.log) проверил полный
staged index:LF27562,35/14/27/44/615; оба diff --check чисты. Чужие два untracked сохранили
исходные SHA. План/checklist/to_sol/README и текущая передача согласованы.
