# LMX передача кодинга fable_pc

## Действующая передача 2026 10 27

По прямому поручению автора Codex передаёт **единственный writer/build агенту `fable_pc`**.
Задание — самостоятельно продолжать [next_core_tasks_v3.md](next_core_tasks_v3.md), прежде всего
работающую самосборку L3+L2 через короткий bootstrap всей цепочки. Это не прежнее read-only ревью.
Codex после передачи прекращает самостоятельный кодинг и новые сборки, отвечает на вопросы и
раз в час проверяет, не остановился ли `fable_pc` по формальной причине. Opus остановлен; не будить.

**Все вопросы — Codex через `lmx_uds`, не автору.** Не ждать авторского ответа вместо ответа Codex,
ревью промежуточного среза или нового разрешения продолжать обычную работу. Реальный вопрос
передавать с точными местами, наблюдением, новым ID `FABLE-QUESTION-<UTC>` и требуемым решением.
При необходимости ответа удерживать только зависимый шаг, продолжая безопасные независимые.
Неразрешённый нормативный выбор или действительно необходимое личное разрешение автора выносит Codex.
Это не разрешение обходить отказ среды, ресурсное ограничение или safety policy.

Получатель — именно **`fable_pc`**, не `fable_chat`, не Opus. Почтальон сохраняет полный текст,
отправителя и ID, доставляет вопрос в эту задачу Codex и ответ обратно исходной сессии.
См. [to_lmx_uds.md](to_lmx_uds.md) и [CODEX_INBOUND.md](claude_chat/CODEX_INBOUND.md).
Перед отправкой проверять живой адрес; ACK почтальона не доказывает последний `SendMessage`.
Не повторять неопределённую отправку вслепую и не запускать другую сессию ради обхода транспорта.

После чтения действующей передачи и получения команды Codex **принять кодинг и продолжать**,
не останавливаться после одного отчёта, коммита или компонентного перевода.
Обычные dependency-closed проверенные срезы коммить и пушить в `main` без разрешительного ревью Codex.
Самостоятельность прекращается по явной остановке автора, завершению плана либо реальному блокеру,
переданному Codex после исчерпания безопасных независимых шагов.

### Приоритет и обязательные границы

Прочитать AGENTS.md, READ.ME, актуальное начало steps/current.md, инструкцию L2/L3 и план v3.
Эта передача новее прежних назначений Codex/Opus и read-only задания ниже.
Подробные старые записи — история, не команда возобновить старый gate или чужой процесс.

- Цель — чистое ядро, source-closed L3+L2 самосборка, два полных проверенных самозамещения,
  затем общая почта `post/sendMessage/receiveMessage` и T01–T26. Это ещё не завершено.
- Сейчас двигаться небольшими шагами через **короткий вариант всей bootstrap-цепочки**.
  Не подменять его одной компонентой, quick9 или новой широкой тестовой кампанией.
  FULL-режим и две FULL-проверенные последовательные самосборки остаются итоговыми требованиями.
- Поддерживаемые ядро, трансляторы, генераторы, build/test scripts — L3+L2.
  L1/C — генерируемые артефакты. Не писать новый PS/Python/C/L1 runner, cache, parser или verifier;
  не прятать прежние алгоритмы в строках. Одноразовые прямые внешние CLI-команды и сохранённые
  `.command` здесь — свидетельства начального моста, не параллельная поддерживаемая система сборки.
- Объявления арены/пулов печатает обычный L3-код строками L1. Не вводить ради этого механизм
  C-layout, новую грамматику L2 или второй разбор. Нормальный cold recipe должен исполнять
  поддерживаемый L3-генератор до потребителей, без рукописного L1 fallback.
- Первая часть допуска проверяет **используемые поля и интерфейсы реальных Consumer-вызовов**,
  не полное равенство сигнатур и не будущие значения/поведение. Глубокое сужение разрешено;
  отказ — только при гарантированно невыполнимом требовании, одна UNKNOWN не основание отказа.
  Дополнительный анализ — только явно выбранный программистом `test`.
  Не добавлять protective gates, result-proof паспорта, Consumer activation-state, library comparator,
  whitelist или blanket разрешение всех callable. Уже установленную совместимость не доказывать повторно.
- Один writer/build и **один compiler pipeline**. До запуска сверять pins/CWD, отсутствие другого
  l1/l2/gcc/cc1/collect2/ld/as и свободную virtual memory не меньше 838861 KiB.
  Тишина и timeout наблюдения не terminal; тихую живую сборку не перезапускать.
- **Корневой `C:/Nyasha_Planet/LMX/build` вообще не читать, не перечислять и не трогать.**
  Basename **`l2_driver_launch.err` нигде не читать, не перечислять, не хешировать, не копировать,
  не stage и не удалять**. Сохранить несвязанный
  `steps/witnesses/used-scope-20261020/reference-producer117.patch` непрочитанным и неизменённым.
  Не сканировать весь проект/build2/transcripts; идти по точным manifests и зависимым путям.
- Никаких reset/clean, массового git add, kill тихих процессов, новых веток/worktree/PR.
  Чужой WIP сохранять. Frozen inputs не править: новый фикс — новый явно названный кандидат.

### Снимок Git и расположение незавершённой работы

Рабочий корень `R = C:/Nyasha_Planet/LMX`, ветка `main`.
На чтении при передаче HEAD — `89caa75ccca07594261ef4ae30e8be25bb7ebb14` (Verified237).
До самой передачи tracked tree был чистым; теперь организационные изменения — этот файл и
начало `steps/current.md`. Источники ядра в tracked tree в этом запуске не менялись.
Обновлён также внешний launcher `C:/claude/new/fable.bat`; это не файл репозитория.

Основной незавершённый WIP и реальные receipts лежат в ignored каталоге
`P = R/build2/codex_fix250generationchain01`. Он **не опубликован и не принят целиком**.
Полный подробный checkpoint: `P/pins/active-goal-checkpoint-1530.json` (15:27 UTC 2026-10-27).
Читать нужные поля JSON, не весь build2. Имена старых каталогов не выбирают версию:
опираться на source/command/output pins и terminal receipts.

Старые выбранные manifests не менялись:
`P/pins/source90-generationchain20.raw.sha256` —
`052FB499287CA047E8EC1A742DC66311071C5B7AF7992A7F89AEA6C6231EFE34`;
`P/pins/source133-full10.raw.sha256` —
`C77CA5341A012D3FDA18E804C8A08E8331C25047F69D565034D971CC84D0DB1C`.
Они не описывают новый candidate39 и не должны подменять его.

### Трансляция emitter завершилась отказом перед отправкой передачи

**Уже TERMINAL exit 1, не перезапускать те же байты.** Это L2-перевод emitter,
не C/link/run или bootstrap. Ниже сохранены идентификаторы закончившегося процесса.

- Codex exec session **43833**, OS **PID 12208**, старт **2026-10-27T14:53:39.5585111Z**.
- Источник `P/variants/call-hidden-choice04/l2_frontend_emit.lm2`, 1020197 bytes,
  SHA256 **EA539A006812DEC81C03ABB836D7221DCB0FA5BB2885DA95EEDF4FE61165CF7D**.
- CWD **`P/component-parts37-emit01/context`** — имя историческое, это правильный контекст.
- Команда `P/pins/parts38-emit02-choice04-L2.command`, SHA256
  **23533CF719335C696D3080E83F42798FDA657B9B76DE5270FB815C06A1999C36**.
- Ready `P/pins/parts38-emit02-choice04-ready.json`: 24 зависимости, 30 guards,
  310 machine exports, 628 argv включая executable, timeout 7200 seconds.
- Выходы `P/component-parts38-emit02-choice04/l2_frontend_emit.lm1`,
  `l2_frontend_emit.h.lm1`, `L2.log`.
- На **2026-10-27T15:38:03.5701726Z** PID жив, CPU 2659.390625 s,
  все 30 guards совпали, оба ожидаемых source/output признака command line совпали,
  log 0 bytes, FreeVirtualMemory 2121300 KiB. Последний poll того же handle дал running, не exit.

**Фактический terminal получен Codex в 15:46 UTC:** конец
**2026-10-27T15:43:52.3894723Z**, elapsed **3012.8121219 s**, compiler exit **1**:

```text
l2trans error: .../variants/call-hidden-choice04/l2_frontend_emit.lm2:7035:254: field path goes through a slot with no Structure
l2trans detail: atom=out
```

Сохранён `P/pins/parts38-emit02-choice04-L2.terminal.json` с исходным tool result chunk402a00.
После terminal на **15:46:51.4393967Z** все30 guards совпали, compiler processes отсутствуют;
log210 bytes, SHA256 `CDE774F5B00828FC9A4D6B25B7280A2B526F5BBA265CDFE4A4A972DEBF8478DD`.
Выходы этого emitter **не приняты**. `43833` больше не running; Codex новую сборку не запускал.
В указанной строке — `c.fprintf(..., \out, \out, uslot)` внутри `rw_dyn_arg_emit`;
исправление ещё не исследовано и не применено. Первый шаг Fable — узко исправить этот реальный
портировочный отказ в следующем immutable варианте, не расширять язык и не менять frozen04/39.
Наличие частичного header не даёт права продолжать с ним.

### Что действительно уже переведено

Ниже только **actual L2 exit 0**, не готовая новая frontend/selfbuild-сборка.
Точные source/output hashes, guards и времена — в перечисленных receipts под `P/pins`.
Не повторять перевод тех же байтов без новой причины.

| Компонент и public exports | Каталог выходов относительно P | Receipt в pins |
| --- | --- | --- |
| helpers 257 | component-parts37-helpers02 | parts37-helpers02-L2.terminal.json |
| values 149 | component-parts36-values01 | parts37-values01-L2.terminal.json |
| resolve 121 | component-parts36-resolve01 | parts37-resolve01-L2.terminal.json |
| core 492 | component-parts38-core02 | parts38-core02-L2.terminal.json |
| types 51 | component-parts38-types01 | parts38-types01-L2.terminal.json |
| coords 112 | component-parts38-coords01 | parts38-coords01-L2.terminal.json |
| receiving 1 | component-receiving01 | receiving01-o1-L2.terminal.json |
| consumer 5 | component-consumer01 | consumer01-o1-L2.terminal.json |

Основной frozen frontend — `P/variants/frontend-existing-parts38/`, кроме emitter:
он выбран из `call-hidden-choice04`, не baseline emit38. Core source SHA256
`36EACA02CC5783ACC05354F3E2B53AAFE0ACF0983859638B41683EBD73FDF816`;
core body `3515BBBCC3E7B88ADC779B1C4EE82F09DDD282E24A2D2F618C0AC3D990B98EA1`;
header `2C2BA622C8F809938DAD2FCF2FEE283934A4AFBD00939560FEDD28EEC45C09EB`.
Старые core490 и lower07 отличаются — не подставлять их вместо новых компонентов.
Новые coords112 отличаются от прежнего header только индексами C-параметров, не ABI.

### Ближайшая последовательность

1. Исправить конкретный emitter отказ7035 в новом варианте, получить actual exit0 и проверить
   source/command/output guards и310 exports; только затем положить actual body/header в warm namespace.
2. Выполнить уже подготовленный **decl41/43 bridge02**, затем lower439. Ничего из этого ещё не запускалось.
3. Завершить warm frontend39, один существующий минимальный witness на реальные значения,
   затем новый language tool из **32 частей**, а не ещё одну пересборку старого восьмичастного G0.
4. После исправления emitter подготовить **следующий** source-only candidate на базе frozen39,
   новым инструментом выполнить короткий **целый** bootstrap, реальные G1 → G2,
   без старых seed objects/headers в cold stage. Candidate39 с отказавшим emitter не выдавать за готовый.
5. Закрывать оставшиеся общие kernel/admission/native зависимости по плану; после рубежа — FULL,
   два требуемых полных самозамещения и почта. Не объявлять этап завершённым по компонентным успехам.

**Decl41/43.** `P/bootstrap-decls4143-source02.lm2`, SHA256
`C946CDD4E0D45258569809537F8D3EDBDC41302D20F7848A2A8B80C84A1BBE5C`, 1229 bytes.
Это точная проекция существующих L3 writers `decl_p0_own_forward` и `decl_p0_parser_forward`
из build38 с маленьким ordinary L3 main; строки L1 печатает исполняемый L3, не host script.
Ready `pins/decl4143-bridge02-ready.json`; команда `pins/decl4143-bridge02-L2.command`;
context `bootstrap-decls4143-bridge02/context`, 6 guards. Сначала L2, затем pinned L1 backend
для **body и отдельно header**, затем C compiler и run с **двумя** аргументами:
`P/bootstrap-decls4143-bridge02/l1src/own.h.lm1` и `.../l1src/parser.lm1`.
Оба actual результата идут в `P/warm-frontend39/src/l1src/`.
Capsule — только начальный warm-мост; normal cold recipe генерирует их своим полным L3-кодом.

**Lower439.** Source `P/variants/frontend-existing-parts38/l2_frontend_lower.lm2`, SHA256
`9FF231B4D5F4FEF441E71D42A2E6B23A0481FD04B01376AEF8FCF9A0C7BD0D0E`, 862004 bytes.
Ready `pins/parts38-lower01-ready.json`; команда `pins/parts38-lower01-L2.command`;
context `component-parts38-lower01/context`, 20 guards, 14 headers, timeout7200, 439 exports.
Выходы `component-parts38-lower01/l2_frontend_lower.lm1` и `.h.lm1` ещё не готовы.
Не строить экспортный список по всем определениям: часть функций private.

**Warm frontend39.** Каталог `P/warm-frontend39`; план
`pins/warm-frontend39-composition.json`, copied receipt `pins/warm-frontend39-inputs51.json`.
Сейчас **51 из 57 raw inputs** физически на месте: 21 module pair +14 declarations +thin root
будут полными после emitter/lower/decl41/43. `headers/` создан, но пуст; C/FE exe ещё нет.
Для 11 неизменных module pairs lineage — `generation-quick01/generation01/frontend/record.txt`;
не принимать всю generation-quick01 за успех: она отказала до завершения frontend.

Thin root уже реально напечатан L3 capsule56 и скопирован в
`P/warm-frontend39/frontend-source.lm1`, SHA256
**CBF343676F3E45B7D30015946039A1472E9CB65D6BC154EC8255934C4C295B53**, 1563 bytes.
Полная цепочка capsule L2/L1-body/L1-header/CC/RUN exit0 сохранена в
`pins/root56-bridge01.terminal.json`. Не брать старый монолитный frontend-source.lm1 B2419A32.
`--machine` выбирает exports, **не удаляет остальные тела**: перевод всего build ради одного writer
не устраняет его зависимости. Не создавать постоянную вторую генераторную систему вместо cold recipe.

Сгенерировать **31 C header** свежим backend из `.h.lm1`, затем thin root → C → FE-O1.
У non-header `.lm1` обычные predef/import раскрывают body; дополнительных body C headers нет.
Import dedup сравнивает строку пути, не filesystem identity: сохранить namespace и CWD `warm/src`,
не смешивать абсолютные/относительные aliases одного body. Никаких repo/BASE/вторых include-dir fallback.
Проверенные места: candidate39 `l1_backend_emit.lm2:2962–2974,3069–3128,3229–3230,3270–3390`;
точные состав и флаги есть в composition и основном checkpoint.
Нормальные gcc flags: C99, O1, no-strict-aliasing, LMX_OBSERVE_WALK=0, Wall/Wextra,
errors implicit-function-declaration/implicit-int/incompatible-pointer-types/discarded-qualifiers,
единственный project include `warm/headers`, ggc-min-heapsize16384/ggc-min-expand20.
Сохранить backend и соответствующий `l2_libc.o` рядом с новым FE.

Существующий минимальный witness `P/witnesses/ordinary-source-parts36/` ещё **не запускался**;
ожидание `parts 43 45 1` и entry7; root statement99 не должен сам исполняться.
Receipt `pins/ordinary-source-parts36.source-only.json`. Это короткая проверка перед дорогим tool,
не повод создавать новую матрицу.

### Source-only candidate39 и новый инструмент

`P/source-candidate39` — frozen снимок **159 файлов: 65 src +34 tools +60 существующих tests**.
Ни L1/C/object/header туда не копировались. Все 159 language manifest hashes сверены с guarded copy,
GNU check exit0. Это **целостность исходников, не build/test успех**.
План `pins/source-candidate39-copy-plan.json`, список `pins/source-candidate39.list`,
manifest `pins/source-candidate39.raw.sha256`, SHA256
**4B09D4F6C9B3579D8954E77FB8530D4D137EC02C75642405193C44770496C427**;
receipt `pins/source-candidate39.prepared.json`.
Любая новая правка требует следующего кандидата, не изменения frozen39 задним числом.

В candidate выбран frontend38 + emitter04, runtime ordinal03 и tools/build SHA256
**434F612A06AB6BAA00BAA2DF91B599C877F82541DE779E018EE3E262CA8AD578** (54 implements exports).
34 tools = 32 machine parts +root `lmxtool.lm2` +child `lmxtool_child.lm2`.
Весь алгоритм backend уже в ordinary L2-частях; L3 печатает state/scratch/тонкие roots,
не алгоритм трансляции в L1-строках. Это исходниковый аудит, cold execution ещё не выполнен.

`P/initial-tool32-39` физически подготовлен: **30 raw kernel declarations** в `src/`,
пустые `headers/`, `seed-driver.o` SHA256
`120A09810A60415003EB2376B2C44171137CBF32A9A018D196A2CEC1B06FFE7A`.
План `pins/initial-tool32-kernel-capsule39.json`, receipt
`pins/initial-tool32-kernel-capsule39.prepared.json`. Это явно объявленный **initial warm G0 seed**,
не normal/cold fallback. Старые C headers не копировать: получить свежие29 из raw headers;
libc_abi.lm1 раскрывается body. Ещё один C header — actual generated methods.

Новый tool собирать **новым warm frontend39** по `source-candidate39/tools/build.lm2:bld_self`
(около2701–2794). Его 41 argv: FE; --library; --machine; tool_main; --header; header;
32 части на позициях6–37; common convert38, primitive39, output40.
Полный порядок — в `pins/language-tools-source-closure32-reviewed.json` и actual candidate plan;
старый build из этого review superseded выбранным 434F612A, не подменять его.
Рабочий namespace `initial-tool32-39/src`, outputs methods body/header в `src/l2src/`,
header C в `headers/l2src/lmxtool_methods.lm1.h`.
Root predef `l2src/lmxtool_methods.lm1` — body, не пропущенный C header.
Далее normal program root→L1→C→obj, link с seed-driver и warmFE libc, shell32/bcrypt.
Флаги/links брать из того же bld_self/bld_cflags, не составлять альтернативный recipe по памяти.
В cold stage G1/G2 уже строить runtime03/54 exports из source39, без копии этого seed-driver.

Для однократных мостов pinned seed FE лежит в `P/seed-f1-o1-from-c01/`:
`l2trans.exe` SHA256 `6FA278313E805DA96674F794DDA0FB1DB2A2A765A62732A14E982780F77558C1`;
`l1trans.exe` `3C8976D7001871A919103A9A89E9AAE27A99018FC657F3F582485911F6F20BA5`;
`l2_libc.o` `AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37`.
Gcc — `C:/Qt/Tools/mingw1310_64/bin/gcc.exe`, timeout — `C:/Git/usr/bin/timeout.exe`;
их hashes и toolchain guards в ready/command receipts. Не угадывать пути к компаньонам.
Старый `P/warm-control03/lmxtool-tool.exe` F17AD0A6 использован для manifest159,
но не является новым 32-part tool и не доказывает новую самосборку.

### Открытый общий допуск и чего эти правки не реализуют

Common parts38 работает с выбранными OS/default source units и borrowed cursor/resume,
без flatten/copy/side context. Helpers/values/resolve/types/coords/core/lower/emit согласованы
в frozen source, но emitter/lower и новая вся цепочка ещё требуют actual результатов.
Emitter choice04 выделяет **choose once → emit once** только внутри `rw_dyn_arg`;
310 public ABI прежние. Подготовка до COUNT, sparse binder и transport этим **не исправлены**.
Choice не чистый: lexical/source/cache scratch mutation требует учёта, не повторного вычисления.

Runtime candidate `P/variants/call-source-ordinal03/` (также в source39):
implements SHA256 `1CA8F356D75EB7F272745E56074A94D1C3EC1173E9AC12478A179EAC79098EFF`,
walk values `3434EACFC30A4B088880BCD84F5B344C131AB6D1A271A0EAC8F28569A5E68482`.
Чистые checked SOURCE count/entry readers и границы have/want SOURCE подготовлены;
ещё **нет их runtime/whole build проверки**. Generic ORDINAL/LAST и primitive receiver0 не менять
ради частного callable. Dense width equality и UNKNOWN refusal остаются открытыми.

Неприменённые точные разборы:
`pins/common-used-call-discovery10.unapplied.json` и
`pins/retained-call-source-closure11.unapplied.json`.
Первый: читать существующие CALL/NAMED interface rows, включая все реальные A/B operands,
различать Consumer R entry count, receiving SOURCE count и provider SOURCE count.
`written != 0` отличает явный Empty от отсутствующего hidden input; NULL payload этого не заменяет.
Один binding должен обслуживать допуск, обычный CALL, native и настоящий walk тела.
Нельзя просто убрать сравнение ширин: нынешние массивы/positions индексируются dense R;
provider Values/ref должны идти в действительном SOURCE-порядке после evaluation/publication.
UNKNOWN не должна обрывать проверку остальных используемых требований и становиться отказом
лишь из-за неизвестности; resource/map failure — отдельная причина.
Null result/exits slots не превращать в новое требование анализа будущего результата.

Второй: `rw_call_contract` пока строит ABI-only pair, но безусловно переиспользовать
`rw_declared_source` нельзя: declaring/home/selected code cursors различны, NODE depth станет чужим.
Нужна обычная declaring closure и её owner/address/copy зависимости, не hidden root/context companion,
угадывание глубины или whitelist. Draft private228/02 с ConsumerHome не принят.
Это техническая незавершённость, не новый вопрос автору о норме.

Runtime-created graph witness `P/witnesses/runtime-named-map03.lm2` — **source-only**:
кандидат [padding,value] vs[value], обычный typed_admit, реальное непозиционное соответствие,
ожидания41→42/pad11 и51→52/pad17; не template/identity/manual map registration.
Он ещё не исполнен; не засчитывать его как callable/admission или instance independence proof.
Прежние S8.1 реальные результаты не закрывают новый общий used-call/runtime вопрос.

### Результаты субагентов перед передачей

Все три действующих помощника завершены, работающих субагентов нет. Их проверки read-only:

- `actual_argument_binding`: recipe closure159 согласована; 32 tool parts точно занимают6–37,
  root/child и generated methods body учтены, omitted maintained source в этом scope не найден.
- `used_call_binding`: 31 warm C header достаточно; non-header L1 bodies раскрываются обычным
  import/predef, без дополнительных body C headers. Сохранить path namespace из-за string dedup.
- `helpers_pointer_audit`: в пяти новых OS helper-файлах не найдено конкретной ошибки
  earlier-foreign-field/later-actual typing; поля Win32/POSIX уже вводятся через casts/typed locals.

Это не runtime/C/build proof и не основание пропускать ближайшую реальную цепочку.
Новых помощников Codex после передачи не запускает. При вопросах обращаться к Codex по существу,
не к остановленному Opus и не напрямую к автору. Исторические разделы ниже не выполнять.

## Архив read-only задания 2026 10 26

**Задание ниже заменено передачей 2026-10-27. Ограничение Fable только read-only больше не действует.**

Codex — единственный writer/build; Fable помогает read-only, Opus остановлен.
Обмен — через файл отчёта, без lmx_uds. Ниже сохранён архив прежних назначений,
не действующая передача writer/build.

Прямые [уточнения автора](LMX_blog/2026-10-26.md): первая часть допуска проверяет используемые поля
и их интерфейсы, не полное соответствие. Сужающий поиск разрешён на любую нужную глубину;
ошибку выдавать только при гарантированно невыполнимом требовании, не из-за одной неизвестности.
Весь дополнительный анализ программист выбирает явно в `test`. Не вводить анализ будущего поведения или значений,
Consumer activation-state, result-proof паспорта, новые protective gates или повторную проверку уже
проверенного скомпилированного вызова. Рекомендации прежнего отчёта, выходящие за эту границу, сняты.
Null result/exits slots сами по себе не требуют отказа или нового носителя: обычный CHECK уже проверяет
объявленную совместимость реального употребления, не будущее значение результата.

Нужны точные рекомендации к существующему callable-interface узлу общего `implements`, а не новый анализатор.
Он должен пользоваться действительным descriptor и тем же обычным контрактом вызова.
Не подменять это равенством всех сигнатур или разрешением всех fn, не добавлять запреты «на всякий случай»
и не подменять глубокое сужение по используемым требованиям анализом поведения callable.
Чистые readers CALL/NAMED из private228/01 можно использовать как
чтение формы интерфейса; непроверенный ConsumerHome/resolver draft private228/02 не принят.

Единственная разрешённая запись Fable — `steps/fable_consumer_suitability_review_20261026.md`.
Не менять ядро, нормы, инструкции или чужой WIP; не запускать сборки, тесты или bootstrap.
Вопросы — Codex в конце отчёта, не автору. Отчёт не объявлять runtime-проверкой;
новая широкая тестовая кампания не нужна. Корневой build и защищённые/несвязанные файлы не трогать.

## Архив назначения — 2026-10-19

Автор остановил `fable_pc` и прямо передал единственный writer/build
Codex с продолжением оставленного WIP по [to_codex.md](to_codex.md).
Ниже сохранена прежняя инструкция; она больше не назначает `fable_pc`
исполнителем и не запрещает Codex кодинг/сборку. Текущее назначение —
в [steps/current.md](steps/current.md).

## Прежняя инструкция — 2026-10-18, America/Sao_Paulo

По прямому поручению автора **`fable_pc` самостоятельно продолжает работу
по [next_core_tasks_v3.md](next_core_tasks_v3.md)**. С подтверждённой передачи
2026-10-17, 15:00 он остаётся единственным writer/build ядра. Codex —
консультант и независимый reviewer, его цель кодинга остаётся на паузе.
Обновление этой организационной инструкции Codex не передаёт ему кодинг
или сборки. `fable_chat` — отдельный помощник, не `fable_pc`.

1. **Не ждать новой команды «продолжай».** Завершение gate, коммита,
   push, промежуточного среза или отчёта не завершает работу по плану.
   После проверки и записи результата самостоятельно брать следующую
   выполнимую зависимость. Ожидание фоновой проверки заканчивается её
   фактическим результатом: затем продолжать цепочку, а не только сообщать
   итог и переходить в ожидание автора.
2. **Все вопросы сначала Codex через `lmx_uds`.** Это касается семантики,
   архитектуры, порядка работы, проверок, коммитов, ошибок инструментов,
   нехватки ресурсов и необходимости разрешения. Не задавать эти вопросы
   автору напрямую. Если нужен действительно неразрешённый нормативный
   выбор или личное разрешение автора, его запрашивает Codex; почтальон
   сам решений не принимает.
3. Вопрос отправлять полным текстом с новым уникальным ID
   `FABLE-QUESTION-<UTC-date-time>`, точными местами, наблюдением и требуемым
   решением. Использовать существующую сессию `lmx_uds` и действующий
   маршрут из [to_lmx_uds.md](to_lmx_uds.md). Почтальон пересылает в эту
   привязанную задачу Codex через `codex_inbound.py send` с `sender`
   `fable_pc` и тем же ID, ответ Codex возвращает исходной сессии Fable.
   Socket ACK не является ответом; timeout не разрешает слепой повтор.
4. Пока ответ действительно необходим, удерживать **только зависимую
   операцию**, сохраняя её состояние; продолжать безопасную независимую
   работу плана. Не превращать один вопрос в паузу всего проекта, не
   повторять отчёт вместо работы и не изображать прогресс, если
   независимых действий не осталось. Тогда явно сообщить Codex точную
   блокирующую причину и требуемое действие.
5. Обычные проверки, завершённые dependency-closed коммиты и push в
   `main` выполнять самостоятельно, без предварительной отмашки Codex.
   Один writer/build, один сборочный конвейер; чужой WIP не подхватывать,
   пути коммита выбирать точно. Новую регрессию исправлять или честно
   оставлять срез незавершённым, не менять ожидания ради зелёного цвета.
   Ревью Codex идёт постфактум и не запрещает следующий независимый шаг.
6. Самостоятельность **не отменяет явный запрет среды, требования личной
   авторизации или проверки доступных ресурсов**. Не обходить такой
   запрет новым процессом, оболочкой или ослаблением защиты. Запросить
   решение через Codex; общее указание продолжать не выдавать за
   отдельное разрешение уже запрещённой операции.
7. Текущий общий аудит путей не закрывается одним исправлением захвата.
   После завершения всего объёма прислать Codex итоговые SHA, общий
   механизм и его потребителей, удалённые/оставшиеся ветки и доказательства
   native/walker на точных байтах. Промежуточный срез так и называть.
   Codex сам проверяет реализацию, а Fable продолжает дальнейшие
   зависимости плана, если они не требуют ответа на findings.

Самостоятельная работа заканчивается завершением согласованного плана,
явной остановкой автора либо реальным блокером, при котором исчерпаны
безопасные независимые шаги и Codex уже получил вопрос. Из одних лишь
публикации отчёта, смены даты, упоминания будущей передачи или старой паузы
остановку не выводить.

Ниже сохранён **исторический снимок передачи** 2026-10-17, а не нынешний
состав WIP и не команда снова выполнять уже завершённые проверки.
Текущие факты брать из Git и [steps/current.md](steps/current.md).

## Снимок передаваемого состояния — 2026-10-17, 15:00

Ветка `main`. Принятый frontend P1#1 — `e71f5dc2`; независимый слой
переноса доказанных адресных карт опубликован в **`ff5738e6`** (header,
`lmx_implements.lm1` и table-selftest). Эти три файла побайтно совпадают
с kernel `_62`, **305/305 GREEN**, и не требуют frontend WIP для сборки.
В **`c07c7285`** отдельно опубликованы проверка полной kernel-копии метода
и уточнение комментария primitive cell copy; эти два пути также побайтно
совпадают с kernel `_62`. Это не приёмка всей P1#2.
Остальной frontend/copy/test-срез не закоммичен;
базовый полный L2 gate для сравнения —
`build/l2_harness/codex_p1_full_30/summary.txt`: **3546 целей, 1067 FAIL**.
У общего kernel-плана, §§8/8a, самосборки и T01–T26 статуса завершения нет.
Подробный журнал фактов — [steps/current.md](steps/current.md).

**P1#2 остаётся незакоммиченным WIP: полный gate выявил новые отказы.**
`build/l2_harness/codex_p1_capture_full_65` завершён в 14:41:46,
shell session `6393` терминальна, exit 1. Результат: **3554 цели, 1069 FAIL**.
Против `_30`: **6 новых FAIL-ID, 4 исправленных, 0 изменённых диагностик**.
Это не принятый срез. Сам полный gate не перезапущен. Последующие фокусы
`_70`/`_71`/`_72` завершены RED 2/19; окончательная общая поправка `_73`
завершена **19/19 GREEN**. Фокус счётчиков `_74` тоже завершён:
**18 целей, 2 FAIL** — только `unit_held_call_failed_application_walk`
и `unit_held_call_method_local_walk`, с ровно теми же FAIL-ID/диагностиками,
что `_30` и `_65` (INVALID, exit 3). Все три новых oracle-отказа `_65`
прошли с физическими проверками копий. Shell sessions `6393`, `2713`,
`46001`, `28853`, `81756`, `10989` терминальны; новых сборок сейчас нет.
Не перезапускать завершённые jobs.

**Первое действие нового writer/build — полный gate новых байтов и его
сравнение с `_30`; этого доказательства ещё нет.** Текущий frontend SHA-256:
`DF1A4A4BF55F59242E61E459CF6DCDFCE23516D8817EF558D7CFE566CED45712`.
Игнорируемый `build/p1_pre_handoff_20261017.json` фиксирует **14 WIP-путей**,
их SHA-256/Git blob и совпадение 13 исходников с `_73`/`_74`. Для harness
нет staged-файла: записаны нынешние байты, поведенческий фокус — `_74`.
Резервная копия этих 14 исходных изменений — игнорируемый
`build/p1_pre_handoff_20261017.patch`, SHA-256
`1682CA9BB48CA1C3935951E2C20AA8058F721E5CF02091D1A01F28B9C718755D`.
`git apply --numstat` подтвердил его состав; к уже грязному дереву этот
patch **не применять повторно**. Посторонний `l2_driver_launch.err` в него не входит.

Исходный `l2trans.lm1` полного `_65` имеет SHA-256
`3F5A253D757FDF06E152751427F4106C6B6804568067EC38069A1B3396011531`.
Игнорируемый `build/p1_source_freeze_20261017.json` хранит SHA-256/Git blob
16 предполагаемых путей среза и места проверенных staged-копий; в 14:31
все рабочие байты совпадали с freeze. Наличие записи не заменяет проверку
staged-байтов и покрытия: ещё не дошедшая до fixture часть живого gate
не обязана иметь staged-файл.

В 14:38 исправлены только устаревшие комментарии harness о голом вызове
и прежней плоской компоновке. PowerShell parser не сообщил ошибок;
SHA-256 последовательности всех токенов, кроме Comment/NewLine/LineContinuation,
до и после одинаков:
`792B8C07369D010E59459ADC3E584F0D59411B728DE27A28B0E9E8B348222673`.
Исключение записано в freeze отдельно, без переписывания исходного снимка;
остальные 15 файлов к 14:38 не менялись. Исполняемый сценарий gate не изменён.
После терминального `_65` изменены `l2trans.lm1`, три дополнительные
held-call fixture и общий helper проверки trace в harness — см. ниже.
Старый freeze описывает прежний снимок, не нынешние входы `_73`/`_74`.

### Разбор полного `_65` и текущая поправка

Новые FAIL-ID: `unit_d105n_capture`, `unit_held_capture_host_field` и
`unit_held_capture_host_field_walk`, `unit_held_call_failed_application`,
`unit_held_call_method_local`, `unit_held_call_to_callable_formal`.
У трёх последних программа дошла до старого oracle `seen()` исходного
root (exit 83/84/82). Их WIP теперь проверяет 0 в источнике вместе с
реальным эффектом в копии: 12 после отказавшего первого application,
2 при передаче callable-формалу, 479 у последнего held-значения локального
`a`. Последний post-check проверяет именно финальную копию `a`, не каждый
промежуточный объект. Исходные числовые проверки результатов всех вызовов
сохранены. `$factoryTracePost` обобщён на физический путь к ссылке, чтобы
`a/body/h` не требовал отдельного алгоритма. Проверка — фокус `_74`;
само значение 0 без этих наблюдений не доказывает корректность.

Первые три — реальные регрессии, не oracle. Native `unit_d105n_capture`
получает 20 вместо 10: возвращённый метод читает `m` прямым слотом 0,
как будто capture по-прежнему нормализован в раскладку Model. У host-field
нет читаемого адресного соответствия выбранному Model; walker даёт INVALID.
В post-`_65` WIP:

- native `l2_emit_path_receiving` использует `l2_input_schema` и общую
  `l2_d105_emit_slot` также для captured reference — та же принимающая
  карта, которую уже выбирает walker; специальной нормализации копии нет;
- общий `l2_rw_ns_value` регистрирует чтение нелокального описания типа
  через `l2_use_model` как обычную лексическую зависимость, включая
  qualified адрес; то же делают непосредственные model-операнды ns/path.
  При усечении предков используемый Model нельзя терять только потому,
  что он читается как модель допуска, а не явно написанный операнд;
- оба конструктора до копии формируют retained captured input обычным
  допуском (`l2_hidden_emit_admit` / `l2_rw_admit_source`), сохраняя карту
  к Model. Диагностика `_71/gen/capture_map.gdb` показала, что до этого
  box-копия имела лишь собственный layout и не была допущена к Model;
- общий `l2_rw_admit_project_at` резервирует известную пару source/req
  уже в COUNT. `_72` выявил позднее добавление pair после объявления
  таблиц; это устранено в общем builder, не заплаткой одного capture.

Финальный `codex_p1_capture_admit_focus_73` — **19/19 GREEN**:
переставленные поля native/`--walk-methods`, оба host-field и положительные
copy/alias/eternal/sibling/chain-контроли. Он не заменяет новый полный gate
после завершения миграции оставшихся oracle. Общие kernel-файлы ради
этой поправки не менялись; новые изменения находятся в frontend.

### Что изменено в WIP

- `dev/l2src_sandbox/l2trans.lm1`: native и walked конструкторы возвращённого
  метода используют общий `l2_mad_copy_emit`; выбранная модель и контекст C
  копируются двумя корнями **одной карты** `lmx_graph_copy_many_used_staged`.
  До копии C содержит реальные захваченные ссылки, а не отдельные копии на имя.
  Сохраняются алиасы, циклы, четыре части, разрешённые eternal-профили,
  исходные головы, роли пулов и неизменившийся native. Родитель C — уже
  скопированный host, не исходный. Общий сборщик с T7 замыкает физически
  вложенные и достижимые соседние методы; walker якорится в выбранной копии unit.
- Уже опубликованные `lmx_implements.h.lm1` / `lmx_implements.lm1`: общий
  `lmx_implements_resolve_map` переносит уже доказанные адресные соответствия
  на скопированное описание. Режим координат сохраняет `reception_proof = 1`,
  не объявляет новый поведенческий допуск и не угадывает позицию без доказательства.
- Опубликованный `lmx_walk.lm1`: только исправление комментария о границе primitive cell copy.
  Старый `lmx_walk_capture` больше не вызывается транслятором, но остаётся
  API двух kernel-тестов; его удаление не входит в этот срез.
- Опубликованные `tests/lmx_implements_table_selftest.lm1` и
  `tests/lmx_walk_call_data_selftest.lm1`: поздний допуск к скопированному
  описанию, обе половины карты, отказ без допуска, независимые четыре части
  метода, перенаправление ссылки в body на собственный var двух копий.
- `tools/l2_harness.ps1`, пять старых held/catch-фикстур и четыре новых
  `tests/unit_factory_{capture_alias,copied_host,eternal_copy,sibling_closure}.lm2`:
  поведение копий, реальные эффекты в скопированном root и физические проверки.
  Изменённый исходный счётчик 0 сам по себе не достаточен: post-check проверяет
  эффект в копии, чтобы пропущенный вызов не стал ложным GREEN.

Все пути выше относятся к `dev/l2src_sandbox`, кроме явно названного harness.
Точный нынешний WIP брать из `git status`, не старого freeze: пять kernel-путей
уже опубликованы, дополнительно изменены три held-call fixture; новые четыре
factory fixture пока untracked. **`l2_driver_launch.err` не относится к срезу: не трогать,
не stage и не удалять.** Не делать `git add .`, reset/checkout WIP или
смешивание с прежним checkpoint OpenRouter.

### Проверки, которые уже завершены

| Материал под `build/` | Наблюдаемый результат и граница |
| --- | --- |
| `l2src/codex_p1_copy_final_kernel_62/summary.txt` | kernel **305/305 GREEN**; общие kernel-файлы после этого не менялись |
| `l3/codex_p1_copy_55` | 11 suites и четыре type budgets GREEN; не доказательство новой самосборки L3 |
| `l2_harness/codex_p1_copy_closure_focus_59` | 27/27 GREEN: 24 fixture, рекурсия, T7, две физические проверки по 242 |
| `l2_harness/codex_p1_capture_map_focus_64` | 25/26 fixture GREEN; один FAIL — старый текстовый oracle одного корня, затем исправлен |
| `l2_harness/codex_p1_capture_oracle_focus_66` | окончательный фокус **10/10 GREEN**, включая alias/Wide, физические проверки и исправленный oracle |
| `l2_harness/codex_p1_capture_admit_focus_73` | post-`_65` поправка, **19/19 GREEN**; не новый полный gate |
| `l2_harness/codex_p1_trace_oracle_focus_74` | 18 целей, 2 прежних walked FAIL; новые trace-проверки GREEN |
| `l2_harness/codex_p1_capture_distinct_probe_68/run.ps1` | четыре запуска GREEN: разные одинаково наполненные объекты не склеиваются, источники не меняются |
| `l2_harness/codex_p1_copy_anchor_mutant_56` | возврат глобального unit вместо выбранной копии отвергнут, exit 3 |
| `l2_harness/codex_p1_capture_alias_probe_63` | старое раздельное копирование двух ссылок на одну Model давало неправильный exit 81; текущая общая карта проходит _64/_66 |

Промежуточные полные `_51`, `_54`, `_60` **намеренно отменены**, итогового
verdict у них нет; не засчитывать их ни GREEN, ни новым падением программы.
`_60` отменён после принятого фокуса `_66`, чтобы не конкурировать с `_65`.
После терминального `_65` сравнить с `_30` **FAIL-ID и диагностики**, а не
только число отказов. Коммитить dependency-closed проверенный срез можно
при сохранённом честном общем RED; не ждать Codex-разрешения на каждый
обычный коммит и не выдавать локальный успех за чистое ядро. Если появились
новые регрессии, сначала классифицировать их, не менять goldens для маскировки.

### Следующая зависимость, а не ещё один частный constructor fix

1. Повторить полный gate нынешних байтов и сравнение с `_30`; фокусы
   закрывают шесть новых FAIL `_65`, но не доказывают отсутствие иных.
   Проверить точные исходные байты,
   `python tools/check_docs.py`, `git diff --check`; commit/push точных путей.
2. M2/N4: распространить общий учёт фактического тела и размещения own-полей
   на результаты `fn`, не только обычные именованные Structure.
   `l2_m2_constructed`, `l2_m2_call_site`, `l2_struct_call_plan`,
   `l2_split_data_row`, `l2_split_close`, `l2_rw_split_data`,
   `l2_emit_struct_call`, fn-ветка `l2_own_from_expr` имеют NS-only/старые
   допущения. Одного расширения сертификата тела недостаточно: чтение, `@`
   и публикация должны адресовать **переданную data** по общей карте.
   Scratch-пробы: `build/l2_harness/codex_m2_method_probes_61`.
3. Одновременно устранить старую коллизию координат контекста: формал `n`
   и третий local сейчас оба пишутся в C-слот 4. Минимальная программа,
   current/baseline измерения —
   [дефект](steps/defects.md#capture-context-coordinate-collision) и
   `build/l2_harness/codex_capture_slot_probe_69/run.ps1`.
   Обе версии, все четыре режима, дают неправильный exit 81 вместо 7
   (вычисленное значение должно быть 73). Нужна одна карта source-place →
   context-place для constructor/fallback/node/backend, не сдвиг offset.
   Две копии ошибочной формулы — `l2_madc_slot` и projected-ветка
   `l2_node_seg_resolve`. Уже существующий `l2_hid_source` связывает
   последний с native-fallback и `l2_rw_arg_fb`; переиспользовать общий
   путь после исправления физической проекции, не вводить ещё resolver.
4. Старый `node\n` у соседнего вложенного метода также отказан и текущей,
   и базовой версиями: [дефект](steps/defects.md#nested-node-formal-context),
   scratch `_57/probe_node.lm2`. Не объявлять его новой регрессией копии.
5. Далее зависимая миграция 47 свидетелей и семейства `unit_walk_body_path_*`,
   затем оставшиеся v3 M/N/K-зависимости. Фокус `_67` оставил те же восемь
   FAIL-ID и диагностики `_30`. Проверить смысл старого inline-owned состояния
   по текущему code/data, не закрепить его, просто скопировав старый native.

`call: step step` не подменяется на `step\var` по равенству адресов:
у метода как data есть явные `args/return/var/body`, но отсутствующий direct
`x` общий допуск не должен придумывать. Положительный пример с отдельной
Data пишет `Data\x`, оставляя `step\var\x` неизменным. Никакой скрытой data.
Чистое ядро §3 остаётся условием переноса §8; актуальная
[инвентаризация closure](steps/closure-map.md) не является принятой G0/G1/G2.

## При получении передачи

Сначала сверить `git status`, последний коммит и [текущий статус](steps/current.md),
затем прочитать [AGENTS.md](AGENTS.md), [READ.ME](READ.ME),
[план v3](next_core_tasks_v3.md), [инструкцию кодинга](L2_L3_CODING_INSTRUCTION.md),
[семантику L3](docs/LMX_semantics.ru.md), [физическую спецификацию L2](docs/L2_spec_ru.md)
и [словарь](next_core_tasks_dictionary_v2.md). Снимок передачи Opus→Codex —
[to_codex.md](to_codex.md); его данные о незакоммиченном дереве относятся только
к моменту передачи. Старые планы и прежняя версия этой памятки доступны в Git.

Цель остаётся прежней: чистое ядро, две действительные самосборки L3 со
вставками L2 (L1 — только генерируемый промежуточный язык), затем почтовая
матрица T01–T26. Порядок зависимостей и условия приёмки задаёт план v3.
Решения должны проходить один общий алгоритм выражений и ресиверов, без
исключений по имени, месту, синтаксической форме или backend. Готовый native
работает по адресам/картам, без таблицы имён для связывания переменных и без
второго графа. Обходчик вправе брать имя написанной головы из существующей
таблицы «адрес → имя», чтобы определить роль ресивера; последующие обращения
к полям используют адреса и доказанные карты, не повторный поиск переменных
по имени. При настоящем противоречии утверждённых
норм остановить только зависимый срез и передать Codex минимальную программу,
две точные цитаты и измеренное поведение; независимую работу продолжать.

**Все вопросы, которые `fable_pc` хотел бы задать автору, сначала адресовать
Codex через `lmx_uds`.** Codex отвечает по утверждённым нормам; лишь
неразрешённый нормативный выбор или действительно необходимое личное
разрешение передаёт автору. Почтальон сохраняет полный
текст, действительного отправителя и request ID; его обязанности —
[to_lmx_uds.md](to_lmx_uds.md). Не считать локальный ACK содержательным ответом.

Не запускать отдельную Grok CLI-сессию: она выведена из работы. `grok_bot` —
другой адресат. `opus`/`fable_pc` почтальон ищет в действующем списке Claude,
`fable_chat` использует отдельный клиент.


## Состояние `fable_pc` на паузе — 2026-10-18, 20:45 (время машины)

**Снято с паузы 2026-10-18, 21:40 по слову автора («снимайся с паузы, продолжай по плану, сейчас с открытого отказа
a[0]\f»).** Открытый отказ закрыт в скане захватов (не в проверке), срез D2 закоммичен — его состояние теперь в
`steps/current.md` («Потребители путей — срез D2»); раздел ниже — запись на момент паузы, оставлен как есть.

Автор сказал «поставься на паузу» — всё остановлено: ни одна цепочка, сборка (gcc) или монитор не работает;
ничего не запускать до следующего слова автора. Слот writer/build остаётся у `fable_pc` (раздел выше).
Запись сделана самим `fable_pc` для возобновления (в этой или следующей сессии).

### Дерево и git

- `HEAD` = `origin/main` = `916d66ba` (U6-V1, `l2_m_code_rooted`). Последние срезы: `8fcc55bd` (U7 D),
  `a6c29b67` (U7 E), `3f237409`/`557a2056` (U6b), `f89115d3` (U6).
- Рабочее дерево (не коммитить как есть):
  - `dev/l2src_sandbox/l2trans.lm1` — **срез D2, не гейтован, не закоммичен** = `HEAD` + три патча по порядку
    `d3_patch.py` → `d3_trim.py` → `d3_fix.py`; байт-копия `build/fable_tools_20261017/u7_d2_pause_20261018/l2trans_d3_dry.lm1`
    (sha256 `a3d3ea4c452d8a91…`). Чистый транслятор: `git checkout -- dev/l2src_sandbox/l2trans.lm1`.
  - `steps/defects.md` — добавлена запись `L1-END-HEAD-SWALLOWED` (OPEN, `l1trans` молча выбрасывает оператор
    L1 с головой `end`, когда так названа локаль; `python tools/check_docs.py` — OK). Коммитится вместе с D2.
  - `l2_driver_launch.err` — чужой untracked файл, не трогать.
- Весь материал паузы (патчи, скрипты цепочек, тексты, свидетели, два транслятора) скопирован в
  `build/fable_tools_20261017/u7_d2_pause_20261018/` (ignored). Scratch сессии
  (`…\scratchpad\u7\`, обозначение `S7` в скриптах) держит ещё большие каталоги replay (`replay_v1` — база
  сравнения D2, ~1 ГБ; `replay_d2`, `replay_fix30`); при потере сессии их регенерирует `replay.sh` штампом
  `build/l2_harness/fable_u6_full_02` и `u7_d2_pause_20261018/bin/l2trans_v1_916d66ba.exe` (~3 мин).

### Срез D2 (потребители путей, записанных атомами, читают запись адаптера `l2_path_steps_run`)

По блокирующему R2 Codex (CODEX-U7D-READONLY-20261018: `l2_join_path` — вторая грамматика, шесть вызовов) и четырём
поручениям автора (LMX_blog/2026-10-18.md: JOIN-PATH, NO-PATH-FALLBACK, PATH-RESOLUTION, PATH-VALUES).
Что сделано и измерено точечно (полная цепочка `d2_chain.sh` запускалась трижды и трижды остановлена):

1. Первая сборка зациклилась на `unit_uniform_dispatch.lm2`: две новые функции держали локаль `end`, `l1trans`
   выбросил `end: end + 1U` — пустые тела `while`. Найдено сборкой `gen/l2trans.c` с `-g -O0` и `gdb -p` (командный
   файл). Исправлено (`end` → `cut`); проверка после `l1trans` — скан C на пустые тела (0). Зарегистрировано в ledger.
2. Второй replay: 21 строка изменила exit — две семьи, обе о записи: (а) адаптер принимал атом-оператор за корень
   прогона (`\\p2` читался как путь с корнем `\`, `unit_pointer_cell_*`) — корень прогона теперь слово имени
   (`l2_ident_word`, статус 2 иначе); (б) скан захватов передавал `l2_scan_node_use` адрес ЛОКАЛЬНОЙ `LmP0Text` над
   текстом записи, который `l2_mcap_add` хранит указателем, а `l2_path_release` освобождает (17 строк `node\name`) —
   имя записывается узлом шага записи. Оба — `d3_fix.py`. Сняты локали без читателя (`d3_trim.py`: `prefix`,
   `p1`/`p3`/`p4`, `l2_pn`); предупреждений gcc 104 против 105 у V1, новых нет.
3. Третий replay: 3572 SAME + 1 MSG — `unit_steps_field_after_index_refused` (`int: v a[0]\f`): V1 отказывал обходом
   пути в 4:17 «field path goes through a slot with no Structure» (атом `f`, так пинует Needle харнесса), D2 — позже
   и иначе, 7:30 «unbound dynamic input f». Снятие среза имён (`drop_names_only.py`: петли операндов разрешают весь
   прогон, `l2_path_names_only` удалён) отказ **не вернуло** — на 32 строках (21 + контроль) 31 SAME, та же 1 MSG.
   **ОТКРЫТО, следующий шаг:** найти, какой маршрут `l2_check_fields` берёт `a [0] \ f` до блока адаптера (старый
   `l2_path_chain` брал весь прогон через `l2_rw_path_run_mode`; подозрение — маршруты элементов «выше» берут `a[0]`
   и оставляют `\f` префиксу разыменования, либо корень `a` (локальный массив) не проходит условие блока);
   проверить трассой на одной строке (`u7_d2_pause_20261018/bin/l2trans_d2_test.exe`, cwd = `…fable_u6_full_02\src`).
4. После починки: тест-вариант (`vbuild2.sh <штамп> <dir>`), replay 32 строк (`rows_changed21.txt`) против
   `replay_v1` → `nohup bash d2_chain.sh <S7>` (вариант, replay 3573 vs `replay_v1`, мутант `mutate_d3.py`, трасса
   `trace_d3.py` — достижимость запасного маршрута `l2_emit_actual_path`, фокус `fable_u7d2_focus_01`, полный gate
   `fable_u7d2_full_01`, ядро `fable_u7d2_kernel_01`, сравнение с `fable_u7v1_full_01`) → `values_d2.txt` +
   `section_d2.md` (`u6/fill_section.py`; плейсхолдер `{{VALUES}}` переформулировать — свидетели значений не в этом
   срезе; `{{FALLBACK}}` из трассы; в тексте раздела убрать упоминание `l2_path_names_only`) → `check_docs`,
   `git diff --check` → `commit_slice2.sh fable_u7d2_full_01.pregate.txt build/l2_harness/fable_u7d2_full_01
   commit_msg_d2.txt` → push → REPLY 7 Codex (`build/fable_tools_20261017/reply7_review_path_unify_d2.txt`,
   плейсхолдеры `{{SHA}}` и числа; убрать строки про `l2_path_names_only`) под
   `FABLE-REVIEW-PATH-UNIFY-20261018T1635Z` через `lmx_uds` (`codex_inbound.py send --sender fable_pc --request-id …`).

Оставшиеся границы D2 (названы в разделе и в REPLY 7, не закрываются этим срезом): текстовые передачи
`l2_address_path_text` (16 мест: `l2_path_resolve_contract`, `l2_emit_path_to`, `l2_path_chain_check` на
`path_operand`, `l2_indirect_span`, маршрут `pcallee` …) — следующий срез переводит их на запись
(`l2_path_resolve_run`); запасной маршрут `l2_emit_actual_path`; `l2_raw_index_span`; `l2_indirect_span`;
остатки `after`/`fld` для корня-не-атома.

### Подготовлено, не применено (после коммита D2)

- **V1b** (Codex CODEX-U6V1-READONLY-20261018T224613Z п. 4, уточнение ROOT-PARTS): две ветви implicit-AT уровня 1 в
  `l2_rw_path_value` (:43417 `field\holder = stop`, :43456 общая) читают `l2_m_code_rooted(l2_rw_mi)` вместо
  `l2_m_is_split` — `v1b_patch.py` (dry-run чист на D2), мутант `mutate_v1b.py`, `apply_v1b.sh` (копирует свидетели,
  вставляет 9 строк харнесса `witness/rows_v1b.py` перед строкой `unit_null_struct_deref_root`, патчит транслятор),
  `v1b_chain.sh` (база `replay_d2`, фокус = 9 свидетелей + семья V1 + достигнутые мутантом, gate `fable_u7v1b`).
- **Свидетели значений** (поручение PATH-VALUES): `witness/unit_part_path_inside.lm2` (`count\var\x` читается и
  пишется ВНУТРИ count; 515, затем 15), `unit_values_deep_mixed.lm2` (вложенная Structure, ссылка, индекс:
  чтение/запись/соседи/адрес), `unit_values_permuted_deep.lm2` (то же через формал Model с Wide, поля переставлены
  D-105: tag 0→3, mid 1→2, other 2→1; читатель снаружи проверяет ячейки по раскладке Wide). Все три транслируются
  в обоих режимах транслятором D2; **исполнение не проверено** (нужен харнесс). Строки харнесса: native
  (`NativeMethods = @(0,1)`), `_walk` (`WalkMethods`, `WalkedMethods = @(0,1)`), `_walk_root` (`WalkRoot` +
  `WalkMethods`), все `Entry = 7`.

### Открытые нити (исследование, без сборок)

- **V2** (из V1: 5 строк exit 3→1): обойдённая процедура-Structure `Counter` пишет `n` цепочкой
  `SET_OF → OF(3) → OF(2) → OF(2) → NODE(0)` — та же цепочка, что native `l2_gp9..11` (`exec_index(code,3)`, `2`,
  `2`); различие во времени исполнения (корень после прогона читает `Counter\n` = 0; проба `nsxprobe/nsx_pd`: a 0,
  n 0, b 5). Нужна трасса ядра — `v2_probe.sh` (gcc). Там же K03-строки exit 81 и `graph_shape_else_method`.
- **Остаток :41840** (сырой `place\child` в обойдённом `OF(NODE(0), …)` против native `lmx_implements_exec_index`):
  в ядре OF отображает индекс через `lmx_implements_slot` только при операнде-модели (`lmx_walk.lm1` :1886), OWN —
  через `lmx_implements_code_slot` (:901); `exec_map` ставит `lmx_implements_exec_save` для результата merge, чьё тело
  исполняется над завершённым значением. Кандидат свидетеля несовпадающей раскладки кода:
  `graph_shape_t7_local_callable_field_walk` (`merge(y: k; model)` — поле `y` перед частями `model`); зелёный в gate —
  проверить, доходит ли до сырого индекса (трасса ядра в `lmx_implements_exec_save` при map[i] ≠ i).
- Трасса кода, не выпущенного транслятором: `python tools/check_docs.py` OK на текущем ledger.

### Codex и автор

- Доставлены REPLY 4–6 под `FABLE-REVIEW-PATH-UNIFY-20261018T1635Z`; Codex подтвердил свидетельства V1
  (CODEX-U6V1-EVIDENCE-20261018225025Z), глобальный вывод OPEN. REPLY 7 (D2) **не отправлен** — ждёт SHA.
- Поручения автора 4–7 (JOIN-PATH, NO-PATH-FALLBACK, PATH-RESOLUTION, PATH-VALUES) заархивированы дословно в
  `LMX_blog/2026-10-18.md` (коммит `916d66ba`).
- Память сессии: `~/.claude/projects/C--Nyasha-Planet-LMX/memory/` (`read-field-closure-handoff.md`,
  `l1-end-head-swallows-statements.md`, `walker-holder0-is-the-data-not-the-occurrence.md`).
