# Локальные сервисы разработки LMX

Ежедневный порядок для агентов: [инструкция использования](USAGE.md).

Один Python/FastMCP сервер предоставляет поиск действующих правил и адаптеры команд
проекта. Те же операции доступны из CLI. Ядро, исходники, существующий транспорт
`lmx_uds` и настройки клиентов сервер не меняет. `stdio` запускается клиентом по
требованию; отдельная постоянно работающая служба Windows не нужна.

## Установка и подключение

Из корня проекта, Python 3.11+ (проверено на Windows, Python 3.14.7):

```powershell
powershell -NoProfile -File tools/lmx_dev/install.ps1
build2/lmx_dev/venv/Scripts/python.exe tools/lmx_dev/entry.py status
```

Для клиента MCP (например, Claude Code) добавьте запись в его конфигурацию:

```json
{
  "mcpServers": {
    "lmx-dev": {
      "command": "C:/Nyasha_Planet/LMX/build2/lmx_dev/venv/Scripts/python.exe",
      "args": ["C:/Nyasha_Planet/LMX/tools/lmx_dev/entry.py", "serve"]
    }
  }
}
```

Эквивалентная запись Codex:

```toml
[mcp_servers.lmx-dev]
command = "C:/Nyasha_Planet/LMX/build2/lmx_dev/venv/Scripts/python.exe"
args = ["C:/Nyasha_Planet/LMX/tools/lmx_dev/entry.py", "serve"]
startup_timeout_sec = 30
tool_timeout_sec = 90000
```

**Подключено на этой машине 2026-11-24:** Codex зарегистрировал `lmx-dev` в
`C:/Users/mtkra/.codex/config.toml`; остальные настройки сохранены. Все 12
`C:/claude/new/*.bat`, кроме `lmx_uds.bat`, получили ссылку на USAGE и подключение:
семь CLI-launcher'ов передают `--mcp-config` и `--append-system-prompt`, пять
SDK-launcher'ов — адресные `LMX_DEV_MCP_CONFIG`/`LMX_DEV_INSTRUCTIONS` общему
`fable_chat.py`. Общий JSON — [mcp.json](mcp.json). Состав моделей, сессии и
делегирование не менялись; `lmx_uds.bat` побайтно прежний. Project/user MCP
настройка Claude не добавлялась, чтобы не подключить исключённого почтальона.
У работающей сессии может остаться прежний каталог tools; до её обычного
перезапуска доступен тот же CLI. Сессии ради подключения не перезапускаются.

Готовый Windows launcher: `tools/lmx_dev/start.bat`. Вручную запускать его перед
подключением клиента не требуется. В stdout идут только сообщения MCP;
служебные сообщения — в stderr, вывод компилятора — в файлы запусков.

## Инструменты и CLI

| MCP | CLI после `python tools/lmx_dev/entry.py` | Что выполняется |
| --- | --- | --- |
| `get_spec_rule(topic, max_chars=2600, include_history=false)` | `spec "R0"` | Дословный раздел текущих Markdown |
| `check_file(file, phase="syntax", closure="")` | `check file.lm2 --phase syntax [--closure NAME]` | Graph `p0`, только синтаксический разбор |
| `check_file(file, phase="static")` | `check file.lm2 --phase static` | Пока `unavailable`: отдельного нормативного CLI нет |
| `check_file(file, phase="translate", closure="")` | `check file.lm2 --phase translate [--closure NAME]` | Принятый FE, перевод L2 в L1, включая его CHECK |
| `bootstrap(profile="smoke")` | `bootstrap smoke` | Компонентный suite10, исполняет программы |
| `bootstrap(profile="selfHost")` | `bootstrap selfHost` | Явная полная G1/G2, full-suite и штатные сравнения |
| `service_status()` | `status` | Покрытие команд, окно и блокировка |

Проверка файла не вызывает `run`, `emit-check`, тесты или тело программы.
`translate` не называется нормативным `sys\translate`, Graph `check` не выдаётся
за `sys\check`. Ошибка компилятора возвращается как отказ, а недоступная фаза —
как `notRun`. `bootstrap quick` не используется под именем smoke.

## Текущие producers и единственный конвейер

`configure-w3` создаёт **локальный, игнорируемый Git** файл
`build2/lmx_dev/config.json` из принятого комплекта W3 (`cb7a8798a…`). Команда
сверяет наличие файлов, записывает SHA-256 producer binaries и списка smoke;
имеющуюся конфигурацию не перезаписывает. На этой машине она уже выполнена.
Исполняемые команды описаны массивами argv, `shell=False`; произвольной команды
или параметра shell у MCP-клиента нет.

Конфигурация использует отдельный `baseline-w3-immutable-stage`, а не основной
STAGE с новыми W4 headers. Smoke/selfHost получают новую частную копию этой
стадии в каталоге запуска. **Эти профили проверяют принятые исходники W3 из этой
копии**, а не будущие правки ядра. Для нового среза ведущий должен обновить
согласованную стадию, producer pins, списки и описание профиля. Это не механизм
приёмки произвольного изменённого ядра с прежними generated headers.

Compiler permit по умолчанию **закрыт**. Ведущий проверил три реальные операции
в отдельном окне и снова закрыл permit; результаты ниже. Python/MCP проверки
не занимают конвейер LMX. После освобождения окна ведущий выполняет:

```powershell
build2/lmx_dev/venv/Scripts/python.exe tools/lmx_dev/entry.py permit --seconds 300 --reason "Свободное окно; producers используют общий lock"
# После адресной работы:
build2/lmx_dev/venv/Scripts/python.exe tools/lmx_dev/entry.py close-window
```

Permit связан с хешем конфигурации и сроком начала запуска. Он не доступен как
MCP tool. Уже начатая команда удерживает блокировку до завершения/отмены;
закрытие окна не обрывает её. Все клиенты делят существующий atomic-mkdir
`machine.lock.d`, уважают `docs-check.running`/`quiet.running`. Чужие и старые
маркеры автоматически не удаляются. Сам по себе lock сервиса не останавливает
внешний producer, который не берёт этот lock: координация ведущего обязательна.
Memory watchdog дополнительно требует 900 MiB свободных RAM/commit перед
проверкой файла, 3500 MiB перед сборочным профилем и прекращает дерево при
остатке менее 600 MiB; это не замена mutex.

## Зарегистрированные связки producers

Плоская конфигурация остаётся принятым комплектом и связкой по умолчанию с именем
`accepted`; прежняя конфигурация версии 1 работает без изменений. Необязательный
ключ `closures` регистрирует другие комплекты по имени, например кандидата среза:

```json
"closures": {
  "return-at-graph05": {
    "role": "candidate",
    "description": "RT04 runtime, Graph05 graph tool, FEH04 frontend",
    "acceptedRevision": "0c79ce0e…",
    "variables": {"graph": "C:/…/codex-k3-return-at-graph05/graph_trans-prod.exe",
                  "fe": "C:/…/codex-k3-return-at-feh04/l2trans.exe"},
    "stage": "C:/…/service-candidate-return-at",
    "stageManifest": "C:/…/service-candidate-return-at/stage.sha256",
    "pinsManifest": "C:/…/service-candidate-return-at/artifacts.sha256",
    "pins": {"C:/…/stage.sha256": "0d5df282…", "C:/…/artifacts.sha256": "06fc63e6…"}
  }
}
```

- Связка **явно** задаёт `stage`, `graph` и `fe`; у принятого комплекта ничего не наследует.
- Шаблоны `check:syntax`/`check:translate`, адаптер `p0-v1`, lock, permit и каталоги
  запусков общие: в шаблон подставляются проверенные `{graph}`, `{fe}` и `{stage}`
  выбранной связки. Собственных argv у связки нет.
- `pins` — путь → SHA-256; `pinsManifest` добавляет строки sha256sum (абсолютные
  пути или относительно самого файла). Один файл с разными хешами — отказ.
- `stageManifest` — sha256sum **всего** `stage/src` (пути относительно `stage`):
  стадия — это точное множество файлов, а не путь. Оба манифеста сами закреплены
  в `pins`.
- `bootstrap:smoke` и `bootstrap:selfHost` выполняются только на `accepted`;
  `check:static` остаётся `unavailable`.

Permit открывает ведущий. С `--closure` он допускает **ровно** перечисленные имена;
принятый комплект допускается только если назван явно:

```powershell
# только кандидат: проверка без closure (accepted) в этом окне закрыта
build2/lmx_dev/venv/Scripts/python.exe tools/lmx_dev/entry.py permit --seconds 300 --reason "…" --closure return-at-graph05
# приняты оба, каждый назван явно
build2/lmx_dev/venv/Scripts/python.exe tools/lmx_dev/entry.py permit --seconds 300 --reason "…" --closure accepted --closure return-at-graph05
```

Такой permit содержит `scopedConfigHash`, `closures` и `effectiveHashes` и **не
содержит** `configHash`: процесс со старым runner (до связок) не находит в нём
привязки и держит окно закрытым. Permit без `--closure` имеет прежний вид и
допускает только `accepted`; новый runner читает его тоже только для `accepted`.
Любая правка `config.json`, как и прежде, делает имеющийся permit недействительным.

Отказы — все до запуска процесса: неизвестное имя; имя не допущено permit; другая
эффективная конфигурация связки; закрытый или чужой permit. Затем под общим lock
повторно проверяются permit, pins, `graph`/`fe` и точное множество `stage/src`
(добавленный, пропавший или изменённый файл, строка манифеста вне `stage/src`,
ссылка или junction в дереве — отказ). Команда фазы обязана начинаться с
объявленного producer (`argv[0]`). `pinsManifest` читается до lock; под lock
сверяются pin, текущий файл и хеш прочитанных байтов.

Чеки: `closure` в результате, в `receipt.json` и в ответе MCP/CLI — `name`, `role`
(`accepted`/`candidate`), `selection`, `effectiveHash`, `acceptedRevision`,
`pinsVerified`, `producers` (путь и SHA-256 `graph` и `fe`), `stage` (`manifest`,
`manifestSha256`, число файлов). Снимок входов содержит pins и файлы манифеста
стадии. `status`/`service_status` перечисляет связки с ролью и тем, допускает ли их
текущий permit (`admitted` говорит об имени и содержимом; само окно —
`compilerWindow`).

Границы. Читаемое producer вне стадии (системные заголовки, внешние include) не
отслеживается. Собственные операции, smoke и сборочные producers для кандидата не
регистрируются. Реальный standalone static отсутствует; когда он появится, его
подключают новым ключом `check:*` в общей конфигурации со своим адаптером, а не argv
в связке. Уже запущенные старые MCP-процессы работают с `accepted` на прежнем
permit; ради границы permit их перезапускать не нужно.

## Правила и границы индекса

`catalogue.json` содержит только пути, идентификаторы, роли и поисковые синонимы,
без копий нормы. Индексируются перечисленные основные EN спецификации, актуальные
формы объявлений/операций и руководство; русский запрос может вести к английскому
первоисточнику. Это явно заданный корпус, а не обещание поиска во всех файлах проекта.
PDF, XLS, статистика, task-пакеты и архивы не читаются.

Якоря и заголовки читаются вне code fences. Ответ содержит точный текст, файл,
якорь, строки, роль, hash раздела и hash **содержимого рабочего дерева** всего
индексируемого корпуса. Новые незакоммиченные изменения видны при следующем запросе.
Отсутствующий якорь каталога — `indexError`, не подбор похожего текста.
Явно исторические разделы и открытые вопросы скрыты по умолчанию; историческая
фраза внутри действующей нормы сохраняется вместе с её отменой/исключениями.

`then` возвращает выбор между `bind` и Pattern-`then`. `int@:`, `int[]`, `::`,
обратные кавычки не теряются при поиске. Ответ не режется посередине правила:
слишком большой раздел возвращает `sectionTooLarge`; прочитать его целиком можно
повторным запросом по `ruleId` с большим `max_chars` (до 80000). Это лимит символов,
а не обещание точного числа токенов. Неоднозначный поиск возвращает до шести
кандидатов и общее количество, без молчаливой подмены значения слова.

## Логи, отмена и достоверность результата

Каждый запуск получает новый `build2/lmx_dev/runs/<id>/`: `receipt.json`, полный
`output.log`, снимки хешей входов до/после и артефакты. В receipt — argv, cwd,
producer pins через снимок входов, параметры окружения и его общий hash (остальные
значения окружения, включая секреты, не выводятся). Изменение наблюдаемых входов
даёт `stale=true`, `result=indeterminate` даже после exit 0. Кэша компиляции нет.
Наблюдаются явный файл, `watch` roots и `pins` (для выбранной связки — ещё файлы её
манифеста стадии); внешние include вне этой области нужно добавить в `watch`. Без этого сервис не удостоверяет их неизменность.

Различаются `completed/passed`, `completed/rejected`, `unavailable/notRun`,
`timeout`, `cancelled`, `resourceLimit`, `crash`, `protocolError`. Последние пять
имеют `result=indeterminate`. Exit 0 без обещанного артефакта или итоговой строки
сборщика — `protocolError`. Для чистого P0-разбора exit 0 достаточен, пустой AST
не является ошибкой. Только известные форматы P0/l2trans разбираются в поля
диагностики. Неизвестные сообщения остаются в полном логе; код, файл, expected
tokens и единицы координат не додумываются. Положение в C не переносится в LMX.

У принятого hosted Graph синтаксический отказ P0 имеет логический exit 2,
но процесс драйвера возвращает 1. Адаптер `p0-v1` признаёт его `rejected` только
при согласованной диагностике P0, единственной ошибке проверки `[exit]` и
отчёте драйвера `exit 2, expected 0` / `1 failed`. `exitCode=1` и
`logicalExitCode=2` сохраняются отдельно. Произвольный exit 1, другая ошибка
драйвера или неполная диагностика не превращаются в отказ синтаксиса.

На Windows child создаётся suspended, помещается в Job Object и только затем
запускается. Timeout/отмена закрывают **всё дерево**, включая потомков и процессы,
оставленные уже завершившимся родителем. POSIX использует отдельную process group;
эта ветвь пока не проверялась на данной Windows машине. Stdout/stderr процесса
пишутся в один полный лог; MCP возвращает первые шесть распознанных ошибок.

## Проверка самого сервиса

```powershell
build2/lmx_dev/venv/Scripts/python.exe -m unittest tools.lmx_dev.tests.test_services tools.lmx_dev.tests.test_closures -v
```

Тесты не запускают LMX: используют управляемый Python subprocess для timeout,
отмены, потомков, блокировок, отказов, отсутствующих артефактов и изменения входов.
Отдельно проходит настоящий MCP stdio handshake/list-tools/call-tool и проверка
характерных запросов по текущей спецификации. `test_closures` на тех же fixture-процессах
проверяет: прежнюю конфигурацию и выбор по умолчанию без изменений; явного кандидата с
чеком; отказы до процесса (неизвестное имя, permit только для `accepted`, изменённый и
неприкреплённый producer, изменённая/добавленная/удалённая стадия, подменённый манифест,
двойной хеш, манифест вне `src`, ссылка в дереве, закрытое окно); команду не с
объявленного producer; невход в занятый lock вторым процессом; scoped permit, который
не принимает прежний gate. Hosted P0 закреплён реальным логом
отказа и отрицательными контрпримерами без запуска LMX.

**Реальные пробы 2026-11-24, выполнены ведущим в единственном конвейере:**

- [Valid P0](../../build2/lmx_dev/runs/20261124-090149-0c65872aa302/receipt.json): passed, exit 0.
- [Syntax rejection](../../build2/lmx_dev/runs/20261124-090638-7a1785003fac/receipt.json): rejected,
  process exit 1 / logical exit 2, diagnostic 19 at 1:33, stale=false.
- [L1 translation](../../build2/lmx_dev/runs/20261124-090208-158187b6589e/receipt.json): passed,
  exit 0, свежий output.lm1, SHA-256
  `e776740f0938177aaa93e3bb8b2172b6b0086e694f15fee21bc0435aceff38b5`.

Целевая программа не исполнялась. Первая историческая расписка отрицательного
P0 (`20261124-090157-7b60ab552553`) сохранена как обнаружение ошибки адаптера,
не переписана задним числом. Smoke/selfHost через новый сервис ещё не запускались;
успех Python-тестов и этих трёх проб не означает успех W3 suite.

FastMCP: [tools](https://gofastmcp.com/docs/servers/tools),
[stdio transport](https://gofastmcp.com/docs/deployment/running-server).
