# Передача кодинга Opus — 2026-11-08 (подготовлена 2026-11-09 01:04 UTC)

REQUEST_ID: CODEX-OPUS-TAKE-WRITER-20261109T0104Z-01

**Принято Opus 2026-11-09 01:25Z** (ответ Codex с этим REQUEST_ID через lmx_uds): Opus — единственный
writer/build/docs (session b79b4933-abc1-4eae-98f7-6361633964ee, PID3188, CWD C:/Nyasha_Planet/LMX). При принятии
проверены HEAD = origin/main = dda769dc, отсутствие процессов pipeline, состав WIP §4 и хэши codex321-source01 и
tool23; rt31/graph41/docs26 не созданы. Текст ниже — передача в виде, в каком её подготовил Codex.

**Снимок передачи: handoff_pending; принятия роли ещё не было.** Автор поручил передать тебе кодинг, когда остаток
лимита Codex станет строго меньше 20%. Проверено: 81% использовано, 19% осталось.
Codex остановился в безопасной точке после завершения tool23 и не начинает следующую сборку.
После адресной доставки этой передачи и твоего содержательного принятия ты — единственный
writer/build/docs и владелец одного compiler/test/docs pipeline. Codex освобождает эту роль,
ставит существующую coding-goal на паузу и остаётся инструктором, ревьюером и управляющим ресурсов.
Все вопросы сначала Codex. Часовой lmx-goal переключается на контроль Opus; сброс лимита
не возвращает роль Codex автоматически. Fable остановлен. Новая сессия не нужна.

**Автор перезапустил неисправный lmx_uds.** Новая действующая relay-сессия:
dbabb8eb-dce1-436d-a760-095db57c5b46, PID7452, CWD C:/Nyasha_Planet/LMX.
В01:21:50Z почтальон подтвердил готовность доставлять сообщения через ListAgents/SendMessage.
Отказ старой сессии в01:02:01Z — история, не новый разрешительный gate.
Свежие peers/read Opus: PID3188, session b79b4933-abc1-4eae-98f7-6361633964ee,
CWD C:/Nyasha_Planet/LMX, READY-WAITING. Native-адрес перед отправкой определяет
новый relay через fresh ListAgents, старые адреса из памяти не использовать.
С отправкой адресного сообщения Codex освобождает writer/build/docs; активного pipeline нет.
Факт принятия роли подтверждает сам Opus, наличие файла и socket ACK его не заменяют.
Историческая передача2026-11-03 сохранена в Git и не является текущей базой.

## 1. Обязательное чтение и цель

AGENTS.md → READ.ME → начало steps/current.md → этот файл → docs/kernel-implementation.ru.md
и .en.md → актуальные §§8/8a next_core_tasks_v3.md, next_core_tasks_v3_checklist.md,
дизайн и точные записи последних срезов. Нормы языка — provenance/semantics-book.md,
generated docs/LMX_semantics.ru.md/.en.md, грамматика и LMX_blog/2026-11-08.md.
Старые абзацы L2_L3_CODING_INSTRUCTION.md об обязательном дереве парсера,
сохранённых картах и отдельных вхождениях не отменяют новое прямое поручение автора:
их согласование с новой моделью ещё нужно закончить.

Полный результат: чистое ядро и единый native; воспроизводимая самосборка L3+L2 без
рукописного L1 в поддерживаемой closure (генерируемый L1 остаётся); G0 строит/проверяет/
замещает G1, затем G1 — G2, с языковыми build/test/docs; общие post и
sendMessage/receiveMessage через call/implements/mail, вся T01–T26; проверенное в main.
Не заменять это одним quick, документом или PASS старого ядра. До самосборки приоритет
сквозной цепочке и конкретным зависимостям, без разрастания предварительной системы тестов.
Старый остановленный pipeline 308/309/310 не возобновлять; нынешний stage чистого графа —
другое продолжение, несмотря на число309 в имени.

## 2. Последняя действующая модель автора

- Исходник → чистый Lmx-граф → оба потребителя. Всё — Lmx, кроме примитивов.
  Атом — термин парсера. Поля прямо адресуют примитив/Lmx; отдельного скрытого
  AST/occurrence/leaf/wrapper или подготовленного представления программы не хранить.
- Адреса ячеек и канонических строк в типизированных участках арены стабильны.
  Имена, операторы и ресиверы сравниваются адресами строк, без числовых кодов.
  Арена присоединяет типизированные участки. Все проверки следуют адресной модели.
- Namespace и карты обхода принадлежат только текущему обходу, начинаются чистыми
  и удаляются после него. Не путать с постоянными адрес→name и классификацией арены.
  Проверять повторный обход изменённого графа без прошлого служебного состояния.
- Последнее уточнение uninit:T: постоянная цепочка слот → примитив-указатель uninit:T →
  заранее выделенная T. Первая и последующие записи меняют только T; слот, внутренний
  указатель, адрес и физический тип не меняются. Языковой i остаётся int; @i адресует
  ту же T до и после5/7. Форма с начальным/дефолтным значением прямо адресует T.
  Сигнатура различает эти формы, вызов её не переписывает. Нет initialized-флагов,
  обещанного нуля/случайности/обязательной ошибки при чтении ещё не записанных байтов.
  Прежняя схема перепривязки слота при первой записи отменена.
- Автозаполненные поля var видны с первой строки тела; инициализаторы выполняются
  на написанных местах. Автозаполнение — построитель графа. Сбор методов —
  отдельный обход потребителя; карты построителя не передавать следующему обходу.
- Сохранять обычную var, голый атом без вызова, локальный @free и узкую паузу изменения
  правил повторного объявления. Новая архитектура не разрешает менять язык.
- := пишет только известное место; в аргументах callable это явная именованная подача.
  a(5) и a:5 — вызовы ровно один раз, результат позиционный. Проверка имён/формы
  до эффектов; затем фактические выражения в написанном порядке и немедленный допуск
  каждого до следующего. AXBY, merge-пример35 и прямые q/z из s остаются требованиями.
- Явный путь пишет физический граф и не обновляет рабочий снимок/dirty голого имени.
  Голое собственное имя пишет текущий рабочий кадр; публикация перед вызовом/выходом.
- Merge копирует используемый граф единой картой источник→копия, сохраняет sharing/
  циклы, перенаправляет внутренние ссылки и нужные лексические цепочки.

## 3. Опубликованная проверенная база

main и origin/main на момент начала передачи:
dda769dc5aaf6a391236590d74c91d569387106c
[codex] Preserve known-place assignment in the clean graph
Author/Committer codex <mtkra@example.com>.

Точные свидетельства: steps/witnesses/known-assignment-20261108/notes.md и
33 перечисленных там receipts (исходные/LF hashes). Последний завершённый срез:
graph40/tool22/rt30, 30 исполнений (10 случаев × interp/native/forced), mutation11
и method-mutation8 PASS. Docs25: 35 semantic pairs,14 implements,27 grammar,
44 quotes,615 imports; LF22652;81checks/0roots. Это не полный новый kernel/§8/§8a.

Проверены known_assignment, четыре отказа unknown/method/path_missing/selected до
эффектов RHS, sub_calls, finally_scope, code_data, dynamic_inputs, saved_address.
В положительном случае: root20; saved@i5/7; local_result15;calls1;procedure_count5;
Data.x11/y22;model_x1;changed17;nested_value11;clean_snapshot19/clean_published9;
dirty_snapshot209/dirty_published2;n3. Явный путь и рабочий снимок намеренно различны.

Предыдущие опубликованные срезы: sub_calls9d495f25; finally2c3577e6; until34ebb976;
control_flowa2ae4b93; code_data2b4adc14; body-inputsf6a4cdf7.
Их границы и точные receipts связаны из steps/current.md. Не повторять все исторические
проверки без причины; текущие изменения и реальные отказы определяют нужную регрессию.

Пути (это сокращения, подставлять абсолютные значения):

    R = C:/Nyasha_Planet/LMX
    P = R/build2/codex_fix250generationchain01
    S = P/cold-graph309-codex01
    B = P/cold-candidate48/full48/g2/frontend
    F = P/cold-graph309/fe309a/l2trans.exe
    T22 = S/tool22/lmxtool-tool.exe
    RT30 = S/rt30
    G40 = S/graph40/graph_trans-prod.exe

База: P/pins/codex320-source06.sha256,328inputs,
SHA256 7f43b023068dfef4c9ddcdcac40c2709090d147933a6b4347ac30fe504b046d6.
T22 0f2130c10ab3aac79ccaaba40ba85f3effdfbe2170b954a74ee2d3efab4942d4.
G40 c1b53d2b40044e4a0bd922eb3f73b33804600dc844f5ae23ce8564d6a7f1c7d6.
RT30/driver.o 4e9eda249c2957118801d4667b3dce08786a00f740e9a2d962997b06ad538c44.
RT30/driver-observe.o 8ef01daaa12646f8458bce5f3a24ea09a0e0cea4c3c00db4131d6a408c4ce76a.
F b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.
Последний docs receipt P/pins/codex320-docs25.log; детали S/docs25.

## 4. Передаваемый WIP Codex — именованные аргументы, НЕ ПРОВЕРЕН

Некоммиченные изменения Codex, принимать как незавершённую работу:
- selfbuild/src/l2src/lmx_graph_run.lm2
- selfbuild/src/l2src/l2_graph_tool.lm2
- selfbuild/tools/build.lm2
- selfbuild/inputs.list
- новые selfbuild/tests/graph/named_arguments.lm2, named_unknown.lm2,
  named_duplicate.lm2, named_mixed_duplicate.lm2, named_positional_after.lm2,
  named_required.lm2, named_admission_order.lm2.

named_arguments.expected ещё не создан. Новых результатов исполнения этих тестов НЕТ.
Меняется общий временный binder lmx_graph_bind_call: сопоставление письменных
позиционных/именованных actual с формальными физическими слотами по адресам имён,
проверка неизвестных/повторов/порядка/обязательных до RHS. Карта size_t[] живёт
только в текущем вызове. Затем RHS в написанном порядке, немедленный admit и
lmx_graph_invoke_bound. Native и walker используют общий binder; native генерирует RHS.
work_scan в фактическом := обходит только RHS и не делает имя формала динамическим входом.
В invoke_data добавлен параметр bindings; обычный call_data передаёт0.
Экспорты graph_run_names увеличены18→20: [18]bind_call,[19]invoke_bound.
ABI graphstate не менялся. Выбор callable — один раз перед фактическими выражениями.
Это частичный int/Structure допуск, не полная реализация AXBY/вычисляемых умолчаний.

P/pins/codex321-source01.sha256:335inputs (328+7),
SHA256 18e84223a71a8f13986bde365efad26b35764e486391803faccd6d0a19f1df92.
Manifest и stage-copy завершены PASS. В S находятся staged335inputs.
**Только tool23 собран успешно**, на T22 и RT30/driver.o:
S/tool23/lmxtool-tool.exe
SHA256 23f0d5d8cc2e63f1c1dbbade904f592dda6ab182273283189e6a259bbae59e05.
Точные receipt S/tool23/record.txt и P/pins/codex321-tool23.log; финальный exit0.
Это проверило orchestration/экспорты, НЕ компиляцию/исполнение нового kernel binder.
rt31 и graph41 НЕ запускались. Текущих compiler/test/docs процессов при передаче не найдено.
Не смешивать старый runtime с новыми exports и не запускать build-graph раньше build-runtime.

Ближайшая работа после принятия: прочитать diff этих файлов, проверить норму именованных
аргументов в книге, затем продолжить один pipeline. Проверить L2-совместимость новой
аллокации size_t (sizeof(size_t)); пока измеренного отказа нет, не считать её доказанно корректной.
Команды по одной, с проверкой exit/точного record перед следующей:

    T23 0 entry 0 -- build-runtime R S B F rt31
    T23 0 entry 0 -- build-graph R S B F S/rt31 graph41
    S/graph41/graph_trans-prod.exe 0 entry 0 -- run S/tests/graph/named_arguments.lm2 1

T23 = S/tool23/lmxtool-tool.exe. Рабочий CWD — R; каждый запуск пишет отдельный named log.
При изменении maintained источников новый manifest и stage-copy, не поверх активного процесса.
При изменении tool/export сначала следующий build-self, затем runtime/header и graph.
Не добавлять новый внешний скрипт сборки.

Независимо рассчитанные ожидаемые значения named_arguments:
named_literal35;named_call36;paren_call62;colon_call62;calls3;defaulted32;
reordered21;mixed61;no_dynamic_label38;written_order21;trace12;
structural47;structural_default42;procedure19;later_default32.
a вызывается три раза суммарно (named_call и две позиционные формы), tick.trace12.
Исходные defaults сигнатуры не меняются.
Пять shape-отказов named_unknown/duplicate/mixed_duplicate/positional_after/required:
ожидаемый interp5; native/forced обычно1, но подтвердить реально; touch.calls0.
named_admission_order: interp4, first.calls1, second.calls0, take.calls0 —
первое значение не соответствует Point, следующий actual/body не исполняются.
Это проверка базового немедленного допуска, а не полного user-conversion AXBY.

После исправлений/реальных запусков создать expected по норме, проверить interp/native/forced,
отказы и их GRAPH-AFTER, профильную регрессию/изменение графа; затем docs и точные receipts,
коммит/публикация. Нельзя просто зафиксировать эти WIP-файлы как готовый срез.
У negative graph-check проверяется статус; состояние/эффекты дополнительно сверять
в точных interp.log, native/run.log и forced/run.log. В native важны начало и GRAPH-AFTER,
хвост может содержать длинный dump арены.

## 5. Остаток и существующие команды

Следом — общий допуск/call и полная структура аргументов (q/z из s), merge(mytest\args;
(a: int: 5))=35, fm/методные ссылки, остальные примитивы/операторы, throws/catch/
именованные переходы/stop/yield и всё необходимое для clean-graph compiler/selfbuild.
Не считать baseline известного присваивания завершением всех типов :=.
Не считать названный WIP завершением общего binding/implements.
Полный collector/3pass, копирование/attach/GC/codec/две арены и повторный обход без
прошлых таблиц проверять на новой модели; затем вся §8/§8a очередь.

Существующий языковой tool (подставлять текущий совместимый T/RT/G):
    T 0 entry 0 -- manifest R/selfbuild/inputs.list R/selfbuild MANIFEST
    T 0 entry 0 -- stage-copy MANIFEST R/selfbuild S
    T 0 entry 0 -- build-self R S B F RT/driver.o toolNN
    T 0 entry 0 -- graph-check R S B F RT G OUT SOURCE EXPECTED EXIT COUNT INTERPANSWER
    G 0 entry 0 -- mutation
    G 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

Следующий свободный docs-каталог на момент передачи — S/docs26. Команда:
    T 0 entry 0 -- docs check R C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt C:/Git/cmd/git.exe S/docs26
Проверить, не появился ли этот каталог после снимка; receipt не перезаписывать.
CWD docs — его собственный новый PRIVATE_OUT. Не параллельно compiler.
После изменения первичного источника регенерировать соответствующую RU/EN пару.
Архив receipts — точный список через языковые manifest/stage-copy, не обход build2 целиком.

## 6. Ограничения, публикация, вопросы и принятие

Корневой C:/Nyasha_Planet/LMX/build не читать, не перечислять и не трогать.
Basename l2_driver_launch.err нигде не читать/перечислять/хешировать/копировать/стейджить.
reference-producer117.patch сохранять непрочитанным/неизменённым.
Frozen inputs/чужой WIP сохранять. В частности to_codex.md и посторонние старые receipts/
stats с EOL-изменениями не включать. Без reset/clean/mass add, новых веток/worktrees/PR.
Поддерживаемые исходники, тесты, build/test/docs orchestration — L2/L3.
Не создавать альтернативные Python/PowerShell/C runners, не писать вручную generated L1/C.
Read-only диагностика/существующий транспорт не являются новой системой сборки.
Процессы проверять PID+creation+CPU/CWD/terminal; полезный процесс не убивать.
При OOM точная операция, receipt, память/владельцы; без слепого повторения/обхода budgets.

Коммиты исполнителя: [opus], Git Author и Committer opus, существующий email
mtkra@example.com; имя задавать только для конкретного коммита, global/shared config не менять.
Историю не переписывать, чужой WIP не подхватывать. Если дорабатываешь WIP Codex,
честно отметить совместное происхождение в теле, фактический завершивший исполнитель opus.
Законченный проверенный main-срез публиковать без разрешительного ACK.
Документы этой передачи и steps/current пока локально изменены Codex; кодовый HEAD выше
не содержит ни этих организационных правок, ни нового binder.

После фактического адресного SendMessage с REQUEST_ID выше прочитай файл и ответь
с тем же ID: принял роль, текущие session/CWD/HEAD, что понимаешь разницу между
проверенной базой и WIP, ближайший шаг. Зафиксируй принятие в начале steps/current.md
и этой передачи как новый единственный writer; периодических отчётов не нужно.
Codex после принятия больше не редактирует проект и не запускает compiler/tests/docs.

Вопросы по нормам/архитектуре/ресурсам — Codex полным текстом с примером и первичными
ссылками через существующий lmx_uds. Не ждать обычного разрешения на следующий шаг.
Fresh native ListAgents/SendMessage, уникальный ID; socket ACK не proof read.
Если relay не может выполнить последний hop, сохрани полный ответ в своей текущей
сессии для read-only chat_status.py, явно сообщи сбой и не запускай новую сессию.
Не менять bridge sources/DB/permissions и не подменять транспорт техническим решением.
