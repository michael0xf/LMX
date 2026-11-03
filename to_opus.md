# Передача кодинга Opus — 2026-11-03

Автор поручил после актуализации документов передать тебе кодинг.
После отдельного сообщения Codex о передаче ты — **единственный writer/build**
и владелец единственного compiler/test/docs pipeline. Codex освобождает слот,
остаётся консультантом и управляющим ресурсов; его goal намеренно paused.
Fable остановлен. Нового разрешения автора, ACK или design/review gate не нужно.
Старая очередь «ждать окончания всей оптимизации Fable/Codex» отменена:
ты наследуешь её остаток сейчас, затем продолжаешь §§8/8a.

Читать эту передачу как действующую. Исторические назначения и WIP в
to_codex.md/to_fable.md не переопределяют её. Старая версия этого файла
сохранена в Git и в P/pins/to_opus-before-20261103-handoff.md; не возвращай
непроверенный checkpoint80b/81 или full100 как текущую исходную базу.

## 1. Первый шаг и связь

Прочитай AGENTS.md, READ.ME, L2_L3_CODING_INSTRUCTION.md, эту передачу,
текущую сводку steps/current.md, план v3 и чек-лист #status-20261103.
Свежие CWD/HEAD/dirty и named receipt важнее старого номера процесса.
Не возобновляй goal Codex и не создавай новую сессию.

Вопросы проекта, нормы, ресурсов и вопросы, которые иначе задал бы автору,
направляй Codex полным текстом через существующий lmx_uds. Codex сначала
сверяет историю и документацию; только действительное неразрешённое
противоречие выносит автору. Обычный следующий шаг, commit/push или уточнение
ABI не являются поводом ждать разрешения.

Канал проверен полным roundtrip CODEX-LMX-ROUNDTRIP-20261103T120944Z-01.
Последняя live Opus: b79b4933-abc1-4eae-98f7-6361633964ee / native[a8230d].
Это снимок, не вечный адрес: каждое сообщение — fresh ListAgents и фактический
SendMessage TO opus; offline[c60b83] не адресат. lmx_uds:
ff11f4c5-75c5-499f-a9c2-7d5b4fc7efea / [f4bea3].
codex_inbound.py доставляет TO CODEX, не тебе. Транспортный ACK не proof read.

## 2. Опубликованная база и документы

База кода: main45cafc25519123f6b1343d40779342c8efeea686 (пакет270).
Документальный commit этой передачи следует поверх неё и не меняет selfbuild.
Maintained root — selfbuild,184 inputs; input manifest:
b9af771a661c8a2ecff90dcd881c055af974d301460d3493fa5cf9d69533a916.
Frozen tested270: E4D1E376;182 inputs raw-equal, два различия только LF/EOF
(l2_driver и l2_frontend_views); подробности в fix270/notes, старые bytes целы.

P = C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01.
Q132 = P/cold-boot132c/quick132c. Это проверенная coherent быстрая линия:

| Артефакт | Относительный путь от Q132 | SHA-256 |
| --- | --- | --- |
| tool | lmxtool.exe | 2e936543ab9c36c842b03c489052b44a6bcaa3110f8018851f2ee07f7f49ba26 |
| frontend G2 | g2/frontend/l2trans.exe | fa22765b71e99c1e2f5b4eb0f01588eec5859e9d30405945492a73dece09b99d |
| runtime | g2/runtime/driver.o | 5a39a205a07e4e40b185251811ac2897b1ff22660d1224f04637f25deef06ada |
| observe | g2/runtime/driver-observe.o | 60ff05dd4bff4c1567775b10c4ec5348a4f614a2eb697756fca2e38cd1b99adb |

boot132c завершён:879.95s,G1/G2 smoke9/0,G2 focus32/0,OSWALK9 тел.
Не считать его живой сборкой. Карта артефактов и receipts:
selfbuild/README.md, steps/witnesses/fix270-20261103/notes.md.

По твоему запросу OPUS-CODEX-DOCS-HANDOFF-20261103T1208Z обновлены:
- provenance/semantics-book.md и generated RU/EN: actual runtime admission,
  запрет future-body immutable/write прогнозов, actual native reset.
- парные L1/L2 и implementation-notes, CORE.md, словарь и инструкции.
- plan/checklist/design: актуальные262–270, отдельно WIP271 и остаток.
- действующие команды docs render/check на языковом tool вместо Python.

Генерация и docs-check завершены exit0 в12:28:05Z;35пар глав/27пар
разделов грамматики/14implements/615imports, LF15944. Полные receipts —
[документальная сверка](steps/witnesses/docs-opus-20261103/notes.md).

Решения по пунктам2.1–2.3 твоего аудита следуют первичному ответу автора
LMX_blog/2026-11-01.md, нового вопроса нет. Написанные throws/catch и
корректный C проверяются в трансляции; actual values — при достигнутом
приёме. Защита immutable действует на реальной записи/публикации;
квалификация проверяет уже построенные значения, не будущие тела.
Копия сохраняет текущие подготовленные карты/представления/ABI; это не
сертификат будущего тела или alias forecast. Реальная запись кода→native0,
обычная запись данных его сохраняет.

Обычная var уже уточнена и реализована270. Exact Oct15 message и точная
цитата — LMX_blog/2026-11-03.md, source anchor ordinary-var.
Атом никогда не является вызовом; @ может идти первым. var можно обычно
объявлять и присваивать, как зарезервированное имя с явно описанными
особенностями. Присваивание Structure не исполняет её. @free адресует
собственную локальную input cell; внешнее место — явное @(node\x).
U3 не pending и повторять вопрос автору нельзя.

## 3. Передаваемый WIP271 / tp133

В maintained selfbuild ещё не посажен. Кандидат variants/tp133, рабочий
cold-tp133, frozen cold-boot133a.185 inputs, source manifest:
66b15db1b3ba4543c11cf99cd49f27c10677302e45b97f0b756fa38f0c43b5c8.
Frozen inputs не менять; все следующие проверки должны указывать их.

Девять изменений перечислены P/pins/tp133-changed.list:
frontend_resolve/lower/coords/core/emit, lmx_walk_values, tools/build,
tests/full-suite.tsv и новая tests/dyn/free_index_places.lm2.
inputs.list отдельно увеличен до185. Source/fixture/ABI pins сохранены.

Реализация: native и walker используют общий lmx_walk_value_index_place
для actual Array/pointer read/write/@, с receiving/границами/контекстом
и общим store. FREE сохраняется до достигнутой операции, без статического
lexical-only запрета. own_bound отделён от scalar dirty-cache: настоящий
caller Array входит в activation binding полным Value существующего
descriptor; walker использует прежний OWN/work row. Нового графа,
broad field scan, автообновления held bare cell и driver/oracle patch нет.

| Проверка | Действительный результат |
| --- | --- |
| rt133a | runtime exit0; driver b27649dc650501c116e4e1162739f3c6c8cbbec70e7e3390d95d0512dc9dbcd0, observe9dd49f04fb886b14fa8b76b39ffa5f1affdd5a42e94a89a6d3c9ada4edb3c8a8; после неё runtime не менялся |
| tool133b | exit0; 9fc96760288f19a6189de5dfaec39497e6096e3fbb0dad7f6ec22ddcbcf73d50 |
| fe133b | exit0; b609a8fdac53f7e477e2eff0acaccbdd3cde4f99fc85270311e0053f5c509eea |
| tp133-suite-04 | 12:06:55.3026805→12:07:21.9664991Z;1row/0failures, n/f root0/root1=7 |
| tp133t-obs-index01 | OSWALK0; forced m1/read_int12/write_nine3/address_int3/relay_nine1/mixed_read1/mixed_write1 в обоих roots; native0walks этих тел |
| Final fixture | 21f7582aa07c6dd75df9dc723ff4507957002eeb35ab8808e64b6b692a9c19be |
| boot133a | 12:08:22.5906238Z→12:27:02.0057253Z; BootstrapExit0,1119.42s; детальная сверка G1/G2 и G2 focus ещё НЕ выполнены |

Первоначальные suite01/02 красные сохранены; suite03/04 после исправления
Array binding зелёные. Не ослабляй oracle и не повторяй их ради смены writer.

## 4. Точный порядок завершения271

1. Terminal boot133a уже завершён BootstrapExit0 в12:27:02.0057253Z. Проверить
   его actual pins/boot133a-quick.log и именованный g2-build.log из этого запуска. Если иной следующий pipeline ещё
   работает, принять под наблюдение тот же pipeline; не запускать дубль.
   Сверять PID+creation/CPU/команду, не старый PID. При ошибке сохранить
   фактическую фазу/диагностику; не выдавать Start за успешный End.
2. При BootstrapExit0 прочитать реальные producer records G1/G2, все inner
   exits и inventories. Сверить оба185 source inputs, consumed manifests,
   actual248 артефактов каждого поколения. Ожидаемое сравнение245raw+3PE
   не подставлять вместо измерения; маска только настоящих PE timestamp/checksum.
3. Запустить уже подготовленный P/pins/tp133a-suite-g2.command:
   powershell -NoProfile -Command "& ([ScriptBlock]::Create([IO.File]::ReadAllText('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/tp133a-suite-g2.command')))"
   Аргументы внутри явные: новый Q133 G2 tuple и pins/focus133-final.tsv
   (прежние32 + новаястрока =33). Stale комментарий slice270/tp132 и label
   SUITE132CG2 — косметическая история шаблона; actual paths/hashes — tp133.
   Скрипт ещё не исполнялся на момент составления передачи.
4. Не повторять component focus. Достаточный G2 observed witness для нового
   пути использовать через существующий os-walk рецепт, без новой кампании.
5. После coherent G2/focus посадить exact185 исходников языковым stage-copy/
   manifest/verify по pattern land270, обновить selfbuild/README, current,
   design/checklist и fix271 records/evidence. Старые frozen manifests не
   переписывать. Если Git нормализует bytes — отдельно показать точную дельту.
6. docs-check языковым текущим tool, git diff --check, точный allowlist,
   commit/push main. Нового разрешения Codex не нужно.

Готовы только prepare/quick/G2-suite; land271 и финальная документация271
ещё НЕ готовы и НЕ выполнены. Не считать эту передачу кодовой публикацией271.
Оболочки находятся в P/pins; поддерживаемая логика build/test остаётся L3/L2.
Свежий CWD каждого запуска и абсолютные receipts обязательны.

## 5. Остаток после271

Сначала закончить конкретные открытые потребители и C по design rev29:
raw-only consumer при известном C ABI; descriptor/DESC address witnesses;
source-occurrence и одинаковые ссылки не смешивать с несколькими datafields.
Известныйactual graphplace не opaquevoid*, таблица pointer codes не норма.
Далее убрать остающийся вывод throws (body_throws/throws_close ещё существуют),
остатки proof-only/preflight и дубли semantics в emission; сохранить явные
throws/catch и reached selected-call obligation, UNKNOWN не равен NO.
M2 forecast functions уже удалены264; не восстанавливать/не переделывать
этот срез по старому тексту плана. split_close сейчас пакует declared rows,
не доказывает будущие тела.

После зависимостей — один настоящий общий collector/resolver compiler+walker
и ровно три compiler-прохода. Interpreter не обязан предварительно обходить
программу: проверяет достигнутую операцию. Общие kernel APIs не должны скрывать
два отдельных алгоритма. Затем coherent whole quick по необходимости,
FULL только финал. Завершить оставшиеся §8 и §8a (post/send/receive через
общий call/implements/mail, T01–T26). Один numeric/Point witness или готовый
документ не завершает общий план. Проверенный scope P1-RET/P1-NUMERIC-KIND/
local@free/A/B1 не открывать заново без новой дельты.

## 6. Ресурсы и защищённые пути

Один writer/build/pipeline. Codex больше не кодит параллельно и не запускает
compiler/tests/docs после передачи. При OOM направить Codex точную ошибку,
операцию, PID/creation и named receipt. Не повторять вслепую; не обходить
реальные limits. Освобождать можно лишь точно опознанные ненужные процессы
проекта, не полезный compiler и не чужие/неизвестные приложения.

Корневой C:/Nyasha_Planet/LMX/build вообще не читать/перечислять/трогать.
Basename l2_driver_launch.err нигде не читать/перечислять/хешировать/копировать/
стейджить. reference-producer117.patch сохранить непрочитанным/неизменённым.
Чужие dirty: steps/witnesses/fix249-20261101/notes.md, to_codex.md,
to_fable.md — не включать. to_opus.md явно передан автором для этой редакции;
его исходный dirty-текст сохранён отдельно. Без reset/clean/massadd,
новых веток/worktree/PR. Frozen inputs и исторические receipts сохранять.
Обычный законченный main commit/push разрешён без ACK.

Часовой lmx-goal обновлён: ACTIVE, тот же чат и интервал в один час,
контроль твоего продолжения по плану вместо get_goal:
полезный долгий compiler и обычное ожидание не являются остановкой.
Codex разбирает фактический блокер, отвечает по чату/документам и помогает
с ресурсами; явную паузу автора уважает. Монитор сохраняется до настоящего
завершения §§8/8a либо отмены и затем удаляется.
