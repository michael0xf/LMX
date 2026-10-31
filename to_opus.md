# Передача кодинга LMX — Codex → Opus

Обновлено 2026-10-30, America/Sao_Paulo; снимок процессов — 2026-10-31 00:38 UTC.
Автор прямо поручил: «передай ему кодинг, все вопросы- тебе».
**Opus принимает единственный writer/build. Codex прекращает самостоятельный кодинг
и сборки, отвечает на вопросы и консультирует.** Fable остаётся остановлен.
Это действующая передача; прежняя инструкция Opus от 2026-10-22 сохранена в Git.

Goal Codex фактически `paused`, прежний часовой монитор тоже `PAUSED` на проверке
после поручения. Не возобновляй Codex goal. Это не пауза работы Opus и не условие
ожидания: продолжай следующий безопасный шаг без разрешения или ревью Codex.
Часовой монитор перенастраивается на Opus; его состояние отражает приложение.

## Что сделать сначала

1. Прочитай `AGENTS.md`, `READ.ME`, начало `steps/current.md`,
   `L2_L3_CODING_INSTRUCTION.md`, §§0/3/8/8a `next_core_tasks_v3.md` и чек-лист.
   Последнее состояние кода и точные записи:
   [активный checkpoint](build2/codex_fix250generationchain01/pins/codex-active-checkpoint-20261029.md).
   Старые назначения ниже новых разделов — история.
2. Проверь `main`, рабочий каталог и чужой WIP, исключая запрещённые пути.
   Снимок HEAD: `d5a9e5f0f2592bb3ab7e09fcc40f661db39a3ee6`; до этой передачи
   tracked tree был чист. Поддерживаемый опубликованный пакет — `selfbuild/`;
   новые изменения пока в ignored `build2`, не в стандартном dev и не в main.
3. Прими под наблюдение **уже запущенную 80b**. Не запускай вторую сборку,
   не убивай и не перезапускай живой перевод ради передачи. Проверь актуальные
   PID/creation time и terminal: приведённые ниже PID — снимок, не вечный адрес.
4. После настоящего terminal продолжай очередь ниже. Если возникла ошибка,
   сохрани её точные входы и результат, исправляй причину; не проси разрешения
   продолжать обычную работу и не жди идеального общего gate.

## Цель и неизменные нормы

Рабочая цель целиком остаётся OPEN: чистое ядро и uniform native → работающая
source-closed L3+L2 самосборка с двумя проверенными поколениями G1/G2 и обоими
самозамещениями → общий mail API по §8a и T01–T26. Коммитить и пушить проверенные
завершённые срезы в main уже разрешено. Один успешный перевод или линковка не
доказывает значения и не закрывает всю цель.

- Первая часть допуска проверяет **только используемые интерфейсы реальных
  Consumer-вызовов**, с сужающим поиском на нужную глубину. Дополнительный анализ
  программист выбирает явно в `test`. UNKNOWN сам по себе не NO. Отказ — при
  гарантированно невыполнимом требовании; не добавляй защитные запреты или анализ
  будущего тела/поведения результата «на всякий случай».
- Используй общий call/implements/receiving и установленные физические карты.
  Имена сопоставляются при допуске; доступы после него используют адреса/места.
  Никаких library-only signature comparators, whitelist экспортов, hidden root,
  mutable module singleton, companion graph или подмены owner.message.graph.
- Native callee из walked root не доказывает обход его тела. У обычных проверяемых
  тел смотри настоящий walked маршрут. C-дверь требует native; arena явно в ABI,
  локальный alias арены сам по себе не singleton.
- Defaults — из текущего экземпляра. Скрытый вход, который активация действительно
  потребляет, захватывается при входе в неё, до операторов тела и входной загрузки
  own-полей (семантика RU §9, :464-466); лишь передаваемое дальше имя не читается.
  Без eager чтения неиспользуемых входов, повторной инициализации или initialized-флагов
  (уточнение Codex CODEX-OPUS-81ANS-20261031T023640Z).
  Полный Value, отсутствие результата, present-null и сырой C ABI различаются.
  FOREIGN — только точный by-value C transport; указатели остаются обычными REF.
- Голое рабочее значение и явная физическая запись различаются: запись через
  `node\field` не обновляет ранее загруженный bare snapshot (норма470).
- Грамматику ради путей/вывода не менять; допустимые пробелы вокруг `\` сохранять.
  L3 печатает L1 обычными строками. Оба транслятора, kernel, generators и обычные
  build/test helpers поддерживаются на L3+L2; generated L1/C и внешний compiler
  остаются промежуточными артефактами/инструментами.

## Текущая сборка: 80b

Далее `R = C:/Nyasha_Planet/LMX`, `P = R/build2/codex_fix250generationchain01`.

**Фактически жива на 00:38:05 UTC:** host `lmxtool-tool.exe` PID20780,
Lower `l2trans.exe` PID12932, оба созданы около 00:25:34 UTC. CPU Lower749.39s,
working set291700736bytes; диагностика L2 пустая, terminal ещё отсутствовал.
Handle Codex `75784` Opus обычно недоступен: наблюдай те же реальные процессы,
файлы и их creation time, не стартуй замену из-за отсутствия чужого handle.

- Stage: `P/cold-candidate80b`; output: `P/cold-candidate80b/fe80b`.
- Обычная запись: `.../fe80b/record.txt`; L2 log: `.../fe80b/l2_frontend_lower.L2.log`.
- Внешний log: `P/pins/candidate80b-frontend-parts.log`.
- Start/terminal: `P/pins/candidate80b-frontend-parts-start.txt` и
  `candidate80b-frontend-parts-terminal.txt`. Отсутствие terminal не отказ.
- Команда, producer и manifests:
  [точный запуск80b](build2/codex_fix250generationchain01/pins/candidate80b-frontend-parts-invocation.md).
- Source159: `1D29A6789042CC6560F5426F9484317A86D8DAC4899796B5FD00470928FA1332`;
  reuse284: `4C732C147014C4F61D5A0057777D79C9949A9AFDDBAA97038BF740F1BF210636`;
  invariant135: `D70AACF7FF42959B3EAC2D6A9016830C771C4B2F0441E975FCBCB8168E19E297`.
  Все проверены существующим L3 tool с0ошибок до запуска; inputs заморожены.
- Tool: `P/cold-generator62/tool62-parts/lmxtool-tool.exe`, SHA
  `351D933F122654090DC3D7F41A6F47F020990AA0515171617F9C7E82C1166FCC`.
- Explicit producer49c: `P/cold-candidate49c/fe49c/l2trans.exe`, SHA
  `F646DD0754B1761E0405A1D9D7024631276CD5DFE6B3197026059C89F8EBEFCC`;
  его соседний backend `B68E4DD248A2513299D764D8B83BDE87505308F4C1D21928A4D2020F9DEE46FE`.
  Это явный bootstrap input, не fallback поддерживаемого рукописного L1.

80b переводит **только Lower и Core**, затем выполняет обычный backend/libc/root/C/link
хвост. Успешные Values/Useplan72 и Emitter77 переиспользованы по точным manifests.
Исходники80: Core478F6F2E…, Lower065CDA7E…; изменения — общий transport скрытых
аргументов и grouping уже вычисленного адреса в двух сгенерированных вызовах.
Никаких результатов 80b до terminal не принято.

## Почему следующий шаг —81

FE77 был собран с exit0, frontend9D52AFF6…; это не доказало его самотрансляцию.
Первый80 под producer77 завершился **exit1 в00:22:44UTC**: Lower1315:11,
`assignment value has unknown type`, `atom=path`, строка `kind: path\leaf_kind`.
Эта строка не менялась; Core не достигнут. Failed `cold-candidate80/fe80`
и session75540 — история, не живой pipeline. Не стирай эти записи.

Причина установлена по коду: новая числовая receiving-ветка потеряла уже
подготовленную категорию opaque C-member до переключения machine ABI.
Минимальная поправка — в
`P/variants/frontend81/src/l2src/l2_frontend_lower.lm2`, SHA
`36D27AAAADB071039FDF7FCD559A1BF24213AAB6B988E58D287F1D3A9FE8808C`.
Она добавляет два locals и существующий CHECK predicate на **заимствованном**
prepared path; категории kind−99/sourceFT−12 уже существовали. Никакого нового
resolver, повторного разбора, исключения по имени поля или расширения грамматики.
Inverse diff точно восстанавливает base80Lower065C. Поправка **ещё не собрана**.

[Обоснование81 и точная очередь](build2/codex_fix250generationchain01/pins/frontend81-c-member-receiving-review.md):

1. Дождись actual80b Lower/Core и всего component tail; прочитай итог.
2. Подготовь source81: те же159source80 плюс минимальный Lower36D. Через
   существующий `build-frontend-part` переведи **только Lower81** explicit49c.
   Добавь actual Core80b outputs в новые точные reuse/invariant manifests;
   сохрани Emitter77/Values72/Useplan72. Core и Emitter повторно не переводить.
   Producer80b всё ещё содержит прежнюю ошибку и для этого перевода не годится.
3. Новым actual81 проверь маленький existing machine-module CLI witness:
   `P/variants/frontend81/unit_machine_c_member_receiving.lm2`,
   SHA `EF5C1D50F1178EE09AFDA79CE9A7D26335FAFB12B28B15F70AF38E071B7AA143`.
   Это лишь проверка прежнего translation failure, не доказательство значений.
4. Затем existing suite: `P/pins/owner-values73-callable-hidden55.tsv` и
   `P/pins/held-forward78.tsv` на actual81 + runtime71. **Support stage71**, а не
   frontend-only80b/81: нужны его реально сгенерированные runtime public headers.
   Production runtime71 `2F4A95B0D9E04A456883DC1E2AC4376B382ED0E074B815C2BC4001B1A43F39FD`;
   observed `F3CE1D168888BFE3C14CC038EEEC9343DEA5B8E913BC526FFAB026123EE7BEB2`.
   Пути: `P/cold-candidate71/rt71/driver.o` и `driver-observe.o`.
   Не создавать новые runner/matrix и не повторять неизменный FULL48.

Нижние старые строки checkpoint/80b invocation «73 сразу после80b» устарели:
последний обязательный порядок —80b → Lower81 → реальные проверки81.

## Отдельный незавершённый draft79

`P/variants/working-value79` — **семь незамороженных, нескомпилированных файлов**;
они не входят в80b или минимальный81. Это следующий связанный kernel-срез:
полный working Value, producer forwarding, Graph publication/read decode,
обычный bare return без значения и receiving без подмены отсутствия на ноль.

| Путь относительно draft79 | SHA256 |
| --- | --- |
| `src/l2src/l2_frontend_core.lm2` | `1C4B35A895007E2DCB0AAFB4B8579A7F1A7625D2639CEC89710D7F25B4FAEEB9` |
| `src/l2src/l2_frontend_lower.lm2` | `85218BA2F8A484880B88A1E265950B453DC8B9F58B89299EA31874F52FA492A8` |
| `src/l2src/l2_frontend_useplan.lm2` | `56936B8625A84D36F82655ADB6876613C179BDC17523B2D79E03020F15562C42` |
| `src/l2src/l2_frontend_emit.lm2` | `9676575C1B8CA07DCA6311E3EEF19EE6E5FF243E749133A076FE4BE825B5B4A8` |
| `src/l2src/lmx_walk_values.lm2` | `69BAAFB08DAD6B911B2A41B6F0126293BDAE0C78C1CD59A2804E3C59A18D48CF` |
| `src/l2src/lmx_value_owned.lm2` | `CB4CD7D179804B6102DFCC4F2FCA08F3C6DA198D0AF518FD1B17CE5780B7D69B` |
| `tools/build.lm2` | `67839B11EA62DC2A3ADED14CD6AAE6C0A87E98C39C1F770D7F5F319E2F0A6539` |

Нужны согласованные новый исполнившийся L3 writer, generated Work schema и runtime
до consumers. Новые counts: Lower441, Useplan150, ValueOwned61, walkValues138.
RT71 не выдавать за совместимый runtime79. Точные изменения/ревью/границы — верх
checkpoint и README draft79. Статическое ревью не заменяет сборку и значения.

Два уже подготовленных маленьких свидетеля в том же existing suite, оба UNRUN:

- `P/pins/no-candidate79.tsv` → draft79 `unit_no_candidate_selected_pointer.lm2`,
  SHA `6567E54F7672B68BFB531C96CA00906B58B7191B08010CC2D964A6403B8F8848`;
  реальные11/13 и сохранение выбранных pointer places.
- `P/pins/computed-absence79.tsv` → draft79 `unit_computed_absence_receiving.lm2`,
  SHA `91369247B2E204520CF464F1F4B0EAEBA09F5759094335B779C8F7E36624904E`;
  own17/41/calls2, physical Host.field23/41/calls4.

Только observer leaf с printf — C-дверь. Для заявленного forced результата
проверь настоящий walk обычных тел. Состояния retained/copy callable, весь
kernel и почту эти два случая не закрывают. Ранние immutable/target guards
сохранены; readonly+absent этим срезом не объявлен проверенным.

## Что принято раньше и что остаётся

FULL48 действительно прошёл G0→tested/promoted G1→tested/promoted G2:
оба37/0, OSWALK0/selftest0, оба самозамещения и сравнения. Это **старые bytes**,
не приёмка79/80/81. [Срез241](steps/witnesses/fix241-20261029/notes.md).
Owner60/FE65/RT71 подтвердил реальные A1/A2/B1 значения41,41,42,42,43,42 и
отдельные mutable places, но новый owner73/runtime-built callable mismatch
и hidden55 на исправленном frontend ещё не прошли. Held78 тоже UNRUN.

Не принимать один exit/линковку/отчёт за независимость экземпляров, общий допуск
runtime Structure, callable signature и реальный body walk. Используй actual
команды/логи с source/compiler/runtime/program байтами и чёткие границы.
После принятого нового kernel — обычная whole chain и требуемые два поколения;
после §8 — mail §8a/T01–T26 через общий механизм. Вся цель ещё не достигнута.

## Работа, ресурсы и вопросы

Все вопросы по проекту, ресурсу или смыслу требования направляй **Codex**, не
автору, через существующий `lmx_uds` по [инструкции](to_lmx_uds.md).
Установи свежий адрес, новый уникальный ID, передай полный вопрос и точные
источники. Проверяй последний фактический хоп к Codex; socket ACK не ответ.
Вопрос не отменяет независимую работу. Только Codex выносит автору действительно
необходимый нормативный выбор. Старую организационную матрицу почтальона не
принимать за новое назначение writer.

Сохраняй один compiler/test/docs pipeline. Тишина или timeout наблюдения не
terminal. Ресурсные вопросы решай по реальным процессам/памяти; не спрашивай
у автора разрешения на обычный следующий шаг. Не обходи реальные ограничения.
Проверенные bytes переиспользуй, не меняя frozen inputs и не скрывая FAIL.
Стандартные code/docs checks выполняй существующими L3/L2 tools после текущей
цепочки. В этой передаче source checks/builds не перезапускались; docs-правка
проверяется отдельно и не является новым GREEN ядра.

Постоянные запреты:

- Корневой `C:/Nyasha_Planet/LMX/build` вообще не читать/перечислять/трогать.
- Basename `l2_driver_launch.err` нигде не читать/перечислять/хешировать/
  копировать/стейджить; каждый language CLI — из нового отдельного private CWD.
- `steps/witnesses/used-scope-20261020/reference-producer117.patch` сохранить
  непрочитанным и неизменённым; чужой WIP не захватывать.
- Не reset/clean, не массовый git add, не новые ветки/worktree/PR.
- Не сканировать весь проект/build2/transcripts. Читать точные manifests,
  названные записи и зависимые места. Не создавать новый shell/Python/C/L1
  runner/cache/scheduler или тестовую систему.

После прочтения сообщи Codex о принятии, сохрани живую80b и продолжай по этой
очереди. ACK Codex не является разрешительным gate для обычного продолжения.
