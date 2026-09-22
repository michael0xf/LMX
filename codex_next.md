# Handoff Codex: аварийная коррекция ядра после «АХИНЕЯ»

Дата среза: 2026-09-22. Репозиторий: `C:\Nyasha_Planet\LMX`, ветка `main`.

## С чего начать следующий сеанс

1. Прочитать `AGENTS.md`, `READ.ME`, `steps/current.md`, `steps/implementation-plan.md`, `steps/l3-receiver.md`, `steps/core-self-build.md` и технические реплики автора в `LMX_blog/2026-09-21.md`, начиная с раздела «Отсутствие числовой раскладки и фиксированного числа детей R0» (это часть разговора от слова «АХИНЕЯ»).
2. Выполнить `python claude_chat/codex_inbound.py bind`, затем `python claude_chat/codex_inbound.py status`.
3. Проверить `git status --short`, `git branch --show-current`, `git rev-parse HEAD`, `git rev-parse '@{upstream}'`. На момент handoff `HEAD == origin/main == b6fb343df050e7441813df492e3d2aab08b16713`, но поверх него лежит большая намеренная незакоммиченная аварийная миграция.
4. Не применять `checkout`, `restore`, `reset`, `rebase`, `clean`, `stash`, `revert`, `force-push`, переключение веток или `git add -A`. Не перезаписывать чужой WIP, `LOCKED` и `OWNED_BY`.
5. Сначала завершить точный промежуточный коммит этого проверенного среза, затем раздать следующие непересекающиеся задачи внешним агентам.

## Принятая модель ядра

### Thread и Message

Принята композиция по значению:

```yaml
struct: LmxThread
    LmxMsg: message
    @: LmxPost mail
    @: LmxSchedule slot
    ...
end: LmxThread
```

`LmxMsg message` — первый by-value член `LmxThread`, поэтому `@thread == @thread\message`. Это общий физический префикс, а не наследование. Самостоятельный `LmxMsg` остаётся минимальной записью и не открывает хвост Thread. Доступ к хвосту требует точного address-range type `THREAD`; общий допуск Message использует общий kind `MSG_RECORD` и принимает точные types `MSG_RECORD` и `THREAD`.

### Граф детей, R0 и планирование

- Никаких фиксированных чисел детей, `LMX_ROOT_CHILDREN`, числовых root slots, `LMX_ROOT_INDEX`, специальных позиций `8/9/10` или параллельных реестров членства.
- Единственный авторитетный состав непосредственных детей — динамический графовый `Array<@LmxThread>` у родителя. Планировщик, GC, settle и orphan-обход используют именно его.
- `LmxLink` не должен быть вторым списком живых детей. Отдельная очередь членства manager также запрещена.
- R0 — обычный `LmxThread` под структурным Thread-родителем/верхним каркасом WorldWideMix. Верхний каркас не имеет собственного родителя и добавляет только внешний timeout/fail-closed границу; лишних возможностей в него не добавлять.
- Каждый родитель просит остановиться только своих непосредственных детей и ждёт их безопасной границы; каждый ребёнок рекурсивно делает то же для своих детей.
- Постоянные типизированные массивы начальной программы находятся в арене R0 и передаются физическими ссылками. Классификация — только по address ranges, не по числовым индексам.
- Поздно подключённый DLL-подобный модуль может владеть своими `independent: const: immutable` ветвями. Их нельзя копировать: `merge` в этом единственном случае кладёт исходную физическую ссылку.

### Почта и закрытие

- Единственный monitor/lock находится внутри коллекции почты L3 Thread. Унаследованные от Message атомарные флаги и address service этим monitor не защищаются.
- Почтовое кольцо динамическое: начальная ёмкость около 2, рост примерно `1.5x`; фиксированного кольца на 256 элементов нет. Lock-free MPSC — отдельная будущая реализация.
- Входящая запись хранит физическую пару `[target, source_arena]`. Producer не изменяет арену получателя. Owner-поток получателя присоединяет donor-арену при `take`; при отказе пара остаётся в очереди.
- `close` обязан неразрушающе проверить pending donor; при невозможности переноса остаётся fail-closed. В `settle` почта закрывается до unregister/remove/release/attach. Никаких service gate/refcount/tombstone/дополнительного lock.
- Один Message в такте исполняется одним OS thread и ровно одним выбранным режимом L3 Thread: native либо interpreter, без hybrid/fallback. Неуспешный такт отменяет requested mode.

### `node`, dynamic visibility и двоеточие

- Зарезервированное исходное имя `node` фиксировано на всю активацию и обозначает лексическое пространство над методом, а не непосредственную объемлющую Structure и не «сам объект».
- Обычное поле рабочего графа `Lmx.parent` — непосредственная объемлющая Structure. `parent` не является зарезервированным словом языка.
- Динамическая видимость доминирует над лексической. Явный `node\env` нужен, когда требуется именно объект из лексического над-метода, а не динамически найденное одноимённое значение.
- Роль ресивера `:` определяется контекстом и существованием имён/типов.
- Если target ещё не существует, форма вроде `env: field` объявляет типизированное поле `field` и создаёт значение единственным механизмом создания структуры — полным `merge(env, empty)` с обходом используемых ветвей. Для `independent: const: immutable` результатом является исходная физическая ссылка без копии.
- Если target уже существует, source обязан существовать, иметь заранее известный тип и не быть запрещённым `const`; выполняется полный `implements`, затем присваивается ссылка, не `merge`.
- Голое присваивание аргументу (явному или скрытому) создаёт own-поле текущего тела на этапе трансляции только если тип аргумента уже известен и source был в namespace. Иначе это ошибка трансляции; нет нетипизированных полей и неизвестных значений.
- Такое own-поле остаётся локальным активации: оно не меняет источник в вызывающем или родительском графе. `dirty/load` должны совпадать с native-моделью.
- Специальное липкое `dirty` от взятия адреса применяется только при взятии адреса до строки присваивания-объявления и сохраняется до конца активации. Оно не распространяется на обычное `@argument`, если аргумент вообще не присваивается, и не распространяется на `node\x`.
- L1 — свободная промежуточная семантика понижения L2 в C; граф, `dirty/load` и нормативная языковая семантика принадлежат L2/L3, а не выводятся из L1.

## Что уже реализовано в незакоммиченном срезе

- By-value Thread/Message prefix и точная range-классификация.
- Единственный динамический `Array<@LmxThread>`; удалены fixed root slots, живой `LmxLink` и manager membership duplicate.
- R0 под structural parent Thread; единый каскад закрытия, watchdog/fail-closed/poison.
- Динамическая почтовая коллекция с одним monitor и owner-side attach donor-арены.
- `lmx_arena_attach` preflight; отказ close сохраняет pending-пару; правильный порядок settle.
- Полная проверка привязки schedule к Thread, включая отрицательный partial-schedule тест.
- Неуспешный такт отменяет mode request; L3 bind требует точный Thread; роли исполняются по физическим ссылкам.
- В срез включены правки colon/node/merge/qualified ranges, документации и generated L2 unit/harness.

Последние подтверждённые проверки после кода:

- L2 full gate: `240/240`, evidence `build/l2src/20260921_235149`.
- L3 runner: `10/10`, counts `6,20,6,6,20,31,6,47,44,85`; type budget во всех четырёх проверках `62/64` имён и `818/4096` байт.
- Generated-program harness: `30/30`, evidence `build/l2_harness_emergency_20260921_234712`.
- `python tools/check_docs.py` и `git diff --check` проходили; их нужно повторить непосредственно перед коммитом после последних редакций документации.

## Точный промежуточный коммит

Перед коммитом желательно заменить устаревшую ссылку evidence `20260921_234437` на `20260921_235149` в:

- `steps/current.md`
- `steps/implementation-plan.md`
- `steps/l3-receiver.md`
- `docs/implementation-notes.ru.md`
- `docs/implementation-notes.en.md`

Затем:

1. Запустить `python tools/check_docs.py` и `git diff --check`.
2. Стадировать каждый tracked path из `git diff --name-only` точным `git add -- <path>`, не `add -A`.
3. Дополнительно стадировать только эти пять новых исходных тестов, уже входивших в полный gate:
   - `dev/l2src_sandbox/tests/lmx_multi_profile_merge_selftest.lm1`
   - `dev/l2src_sandbox/tests/lmx_qualified_range_selftest.lm1`
   - `dev/l2src_sandbox/tests/lmx_range_cell_selftest.lm1`
   - `dev/l2src_sandbox/tests/lmx_settle_mail_close_refusal_selftest.lm1`
   - `dev/l2src_sandbox/tests/lmx_thread_prefix_selftest.lm1`
4. Проверить `git diff --cached --name-status` и `git status --short`.
5. Коммит: `dev: restore dynamic Thread graph and exact Message prefix`.
6. `git push origin main`.

Не включать в этот коммит:

- `bin/`
- `*.LOCKED`, `*OWNED_BY_GROK`, `.bak_*`
- `dev/l3_interp/OWNED_BY_CODEX_L3_PROFILE`
- `tmp_cwd_audit_105.py`, `tmp_cwd_ladder_109.py`, `tmp_image_ladder_109.py`, `tmp_unitroot_test/`
- 17 пока не подключённых к runner файлов `dev/l2src_sandbox/tests/unit_colon_*.lm2` и `unit_eternal_*.lm2`.

## Внешний круг агентов после коммита

Речь только о внешних каналах: `grok`, `grok_bot`, `deepseek`, `openrouter`, `fable`, `lmx_uds`. Не считать delivery/ACK началом работы; требовать `STARTED`, затем commit/files/commands/counts/exits/evidence или конкретный blocker. Ответ должен прийти Codex через `lmx_uds`/`codex_inbound`, а не остаться в терминале агента.

- **Fable:** read-only полный аудит требований от «АХИНЕЯ» до текущего ABI. Таблица `требование → код → тест → evidence → пробел`; сначала без правок.
- **OpenRouter:** read-only инвентарь полной миграции поддерживаемого L1 → L2 и преимущественно L2 → L3 с первым bounded slice и точными командами. После перезапуска напомнить маршрут ответа Codex.
- **DeepSeek:** продолжить локальную self-build/manager-цепочку от нового commit. Сначала воспроизвести manager gate и вернуть первый конкретный failing target/command/exit/evidence; ядро `dev` без отдельного ownership не менять.
- **Grok:** подключить 17 `unit_colon_*.lm2`/`unit_eternal_*.lm2` к реальному runner/manifest и затем взять первый непересекающийся implementation slice миграции L1 → L2 → L3. Маршрут запроса должен явно содержать `lmx_uds → grok`; ответ — через `uds.py` обратно Codex.
- **Grok Bot:** независимый read-only review нового commit и manager launch plan; если manager уже занят — следующий bounded migration/VM audit только как запасная работа. Использовать только настоящий webhook, не файловый watcher.
- **lmx_uds:** relay и сведение ответов; проверить, что каждому тикету соответствует содержательный обратный ответ Codex, а не только доставка.

После независимого аудита исправить реальные пробелы, повторить focused tests + full L2/L3/harness gates, затем отдельной проверяемой партией продвигать `dev` в стабильный `l2src`. После этого приоритеты: полная L1 → L2, преимущественная L2 → L3, полная самосборка на L3 с точечными вставками L2, запуск `myxa_manager`.

## 30-минутный диспетчер

Automation находится в `C:\Users\mtkra\.codex\automations\lmx-git\automation.toml`:

- id: `lmx-git`
- name: `LMX: круговой диспетчер агентов`
- status: `ACTIVE`
- schedule: `FREQ=MINUTELY;INTERVAL=30`
- target thread: `01a0bd99-cdd5-7d00-bbc8-788879689d28`

Его prompt уже требует после каждого пробуждения делать `codex_inbound.py bind/status`, проверять все шесть внешних каналов, выдавать свободным bounded tickets и продолжать core model → L1/L2/L3 → self-build → manager. Если новый сеанс создаст другую задачу, automation нужно обновить на новый target thread либо продолжить работу в текущей задаче.
