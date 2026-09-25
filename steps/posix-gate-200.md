# FABLE-SONNET-POSIX-GATE-20260925-200, к.1 — read-only замер

База: ветка `claude/continue-sonnet-next-doc-aaz95e`@`7aa8103`, main `1892fa2`
(merge main→ветка уже сделан этим же коммитом). Никакого кода — только
факты по (a)/(b)/(c) тикета (`steps/tickets-20260925.md` §3).

## 0. Что замерено и как

Прочитаны целиком `tools/build_l2src.ps1` (579 строк), `tools/build_l2src.py`
(300 строк), `tools/run_l3_selftest.py` (173 строки); дополнительно
`tools/l3_type_budget.py` (его `run_l3_selftest.py` импортирует) и
`tools/l2_harness.ps1` (2492 строки, машинный eternal-runs драйвер) —
у обоих оказалась та же стадийная копия, что и у пары build_l2src, см. §3.
Прочитаны сами `lmx_clock.h.lm1`/`.lm1`, `lmx_process_deadline.h.lm1`/`.lm1`,
`lmx_manager_running.h.lm1`/`.lm1` целиком. Счётчики вызовов Win32 API
пересчитаны независимо от текста тикета (см. §1) — совпали с числами fable
дословно.

## 1. (a) Точный контракт `.h.lm1` трёх модулей

**Метод:** для каждого модуля — (i) что предefefают ДРУГИЕ файлы (кроме
самого модуля и его селфтеста) из `l2src/<name>.h.lm1`; (ii) какие функции
из прототипа реально вызываются вне модуля; (iii) какие Win32-типы видны в
самом прототипе или в полях структур.

### `lmx_clock`

`lmx_clock.h.lm1:20` объявляет `foreign: ULONGLONG` и предefефает только
`l2src/lmx.h.lm1` (`lmx_clock.h.lm1:2`). Прототип (`lmx_clock.h.lm1:23-53`):

```
fn: lmx_clock_now () ULONGLONG        # :23 -- ТИП ПРОТЕЧКИ: ULONGLONG в сигнатуре
fn: lmx_clock_ticks () ulong          # :25 -- портативно
fn: lmx_clock_word () size_t          # :33
fn: lmx_clock_half () size_t          # :36
fn: lmx_deadline_passed (...) int     # portable, wrap-safe modular compare
fn: lmx_deadline_wait (...) size_t
fn: lmx_clock_since (ULONGLONG: start) ULONGLONG   # :51 -- ULONGLONG и в аргументе, и в возврате
```

Потребители (`predef: "l2src/lmx_clock.h.lm1"` или `"l2src/lmx_clock.lm1"`,
не сам модуль/его селфтест) — 8 файлов вне `tests/`
(`lmx_domain_selftest.lm1`, `lmx_manager_running.lm1`,
`lmx_process_deadline.lm1`, `lmx_root.lm1`, `lmx_settle.lm1`,
`lmx_thread.lm1`, `lmx_turn.lm1`) плюс 21 файл под `tests/`. Реально
вызываемые оттуда функции — только `lmx_clock_ticks()` (в `lmx_root.lm1` —
строки 234, 333, 1052, 1128, 1134; в `lmx_settle.lm1` — 44, 65, 70) и
`lmx_clock_half()`/`lmx_clock_word()` (`lmx_root.lm1:447,510`) — всё
портативные типы (`ulong`, `size_t`). `lmx_clock_now`/`lmx_clock_since`
(тип-протечка ULONGLONG) вызываются ТОЛЬКО из `lmx_domain_selftest.lm1:329,331`,
и только через сравнение с `0U` (`check(lmx_clock_now() != 0U, ...)`) —
точное битовое значение и ширина типа наружу не идут. Вывод: контракт,
который реально нужен вызывающим, — только `ulong`/`size_t`-функции;
`ULONGLONG` в прототипе — не необходимость API, а следствие того, что
реализация Win32 использует `GetTickCount64()` напрямую в двух местах и не
завела для них портативной обёртки.

### `lmx_process_deadline`

`lmx_process_deadline.h.lm1:1` — `include: "<windows.h>"`; НЕТ собственного
`foreign: DWORD`, хотя прототип возвращает `DWORD` (`:45,
fn: lmx_process_deadline_body (@: void arg) DWORD`) — открытый вопрос к
l1trans (см. §4, "открытый вопрос"). Структура `LmxProcessDeadline`
(`:30-35`):

```
struct: LmxProcessDeadline
    @: void event        # :31 -- HANDLE спрятан за void*, наружу не течёт
    @: void thread        # :32 -- то же
    unsigned: wait_ms     # :33 -- портативно
    int: armed             # :34 -- портативно
end: LmxProcessDeadline
```

Прототип (`:41-45`) — три функции: `lmx_process_deadline_arm(@: LmxProcessDeadline
d; size_t: deadline) int`, `_disarm(@: LmxProcessDeadline d) int`,
`_body(@: void arg) DWORD`. Единственный внешний потребитель — `lmx_root.lm1`
(9 мест: 517, 524, 535, 544, 548, 553, 557, 562, 567, 580 — все через
`lmx_process_deadline_arm`/`_disarm`, `int`/`size_t`, ни одного прямого
обращения к полям структуры и ни одного `DWORD`/`HANDLE` наружу).
`lmx_process_deadline_body` нигде не вызывается снаружи модуля — это
чисто внутренняя точка входа потока, названная в прототипе только потому,
что `lmx_process_deadline_arm`'s `CreateThread` в теле (`:37`) её кастует.
Вывод: контракт для потребителя — `arm`/`disarm` с `size_t`/`int`, поля
структуры уже `void*`/портативные; протечка — только сигнатура `_body`
в самом прототипе (её мог бы не видеть никто, кроме тела).

### `lmx_manager_running`

`lmx_manager_running.h.lm1:1` — `include: "<windows.h>"`; `:17-18` —
`foreign: DWORD` и `foreign: LPTHREAD_START_ROUTINE`, с явным комментарием
файла (`:4-16`): "It is separate from lmx_manager.h.lm1 on purpose: the
manager's INTERFACE is portable and lives there, while the thread entry a
platform hands to the OS has a platform type this file names once." —
т.е. уже СЕЙЧАС порт и платформенная часть разнесены по ДВУМ РАЗНЫМ
модулям (`lmx_manager.h.lm1` — портативный интерфейс, `lmx_manager_running.h.lm1`
— платформенное продолжение той же реализации), а не общий файл с двумя
телами. Прототип (`:20-43`) — шесть функций одной семантики
init/add/remove/take/count/step/round/close, все аргументы —
`@: LmxManager`, `@: LmxSchedule`, `size_t`, `ulong`, `unsigned`; НИ ОДНА
из них не возвращает и не принимает `DWORD`/`LPTHREAD_START_ROUTINE`.
Оба `foreign:` в файле нужны не прототипу, а телу
(`lmx_manager_running.lm1:33` — `fn: lmx_manager_running_body (@: void arg) DWORD`
и `:116` — `(cast: (LPTHREAD_START_ROUTINE) lmx_manager_running_body)`).
Внешние потребители — `lmx_manager.h.lm1:2` (см. ниже — она сама
предefефает `lmx_manager_running.h.lm1`, односторонняя связь для типов
API-слота, не наоборот), `lmx_schedule.h.lm1`, `lmx_thread.lm1`, плюс
6 селфтестов; ни один не упоминает `DWORD`/`HANDLE`/`LPTHREAD_START_ROUTINE`.

### Общий вывод по (a)

Ключевая находка уже в тексте самого модуля
(`lmx_manager_running.lm1:11-13`, дословно): *"The platform is reached
ONLY through the c. door (CreateThread, WaitForSingleObject, CloseHandle,
Sleep), so another platform implements the same interface with its own
four calls and nothing above this file changes."* — автор уже
СФОРМУЛИРОВАЛ ровно то разделение, которое просит Q10, до этого тикета.
Все три контракта видны потребителям ТОЛЬКО как функции с портативными
типами (`size_t`, `ulong`, `unsigned`, `int`, свои структуры/хендлы под
`@: void`); единственные протечки платформенного типа в САМ ПРОТОТИП —
`lmx_clock_now`/`lmx_clock_since` (`ULONGLONG`) и `lmx_process_deadline_body`
(`DWORD`, но не вызывается извне) — обе устранимы без изменения ни одного
внешнего вызывающего файла (см. §2 (c)).

## 2. (b) Минимальный POSIX-эквивалент

Счётчики Win32-вызовов, пересчитаны по коду (не по комментариям) —
совпадают с текстом тикета:

| модуль | вызов | счёт | POSIX-эквивалент |
| --- | --- | --- | --- |
| `lmx_clock` | `GetTickCount64` | 5 (`lmx_clock.lm1:7,13,16,23,26`) | `clock_gettime(CLOCK_MONOTONIC, &ts)`, мс = `ts.tv_sec*1000 + ts.tv_nsec/1000000` |
| `lmx_process_deadline` | `CreateEventW` | 1 (`:30`) | `pthread_cond_t` + `pthread_mutex_t` (ручной "event" через condvar+флаг) или `pipe(2)` (self-pipe) |
| | `CreateThread` | 1 (`:37`) | `pthread_create` |
| | `SetEvent` | 1 (`:51`) | `pthread_cond_signal` под мьютексом / `write` в self-pipe |
| | `WaitForSingleObject` | 2 (`:54,70`) | `pthread_cond_timedwait` (таймаут = абсолютное время, `CLOCK_MONOTONIC` — нужен `pthread_condattr_setclock`) / `poll` на self-pipe с таймаутом |
| | `CloseHandle` | 3 (`:39,55,56`) | `pthread_mutex_destroy`+`pthread_cond_destroy` / `close` обоих концов pipe |
| `lmx_manager_running` | `CreateThread` | 2 (`:16` комментарий не считается, реально `:116` и упоминание входа `:33`) | `pthread_create` |
| | `WaitForSingleObject` | 3 (`:16` коммент, реально `:126,186`) | `pthread_join` (для `INFINITE`, `:186`) / `pthread_tryjoin_np` (не POSIX, GNU-расширение) или flag+`pthread_join` с ненулевым таймаутом через доп. примитив для `:126` (zero-timeout reap) |
| | `Sleep` | 1 (реально, `:52`) | `nanosleep` |
| | `CloseHandle` | 2 (`:128,187`) | ничего не нужно — `pthread_join` уже освобождает; `pthread_t` не хендл, закрывать нечего |

Компиляторные флаги: `-pthread` (линковка и `-D_REENTRANT`), и для
`pthread_condattr_setclock(..., CLOCK_MONOTONIC)` требуется
`-D_POSIX_C_SOURCE=200112L` (или `_GNU_SOURCE`, если понадобится
`pthread_tryjoin_np` для неблокирующего reap в `lmx_manager_running_lane_reap`
— единственное место, где Win32 API формы асимметричны: `WaitForSingleObject(h, 0)`
имеет прямой POSIX-аналог только через нестандартное расширение или через
дополнительный флаг "done", выставляемый потоком перед выходом под мьютексом).
Это единственная реальная трудность формы (b) — не количество вызовов, а
то, что POSIX `pthread_join` не умеет "подождать 0 мс и уйти, если поток
жив" без ГНУ-расширения или ручного протокола (mutex+flag). Решение —
предмет к.2+ кода, не этого замера.

## 3. (c) Форма без переходных двойных режимов

### 3.1 Как сейчас build-скрипты находят, какой `.lm1` реализует модуль

Ни один из скриптов не хранит список/манифест юнитов — модуль есть то,
что находит `glob('*.lm1')` в стейджинг-директории, а базовое имя равно
имени файла без расширения. Ровно это и предстоит изменить.

**`tools/build_l2src.py`** — стейджинг копирует каждый `*.lm1` под его
собственным именем (`build_l2src.py:76-77`):

```python
for f in flat.glob('*.lm1'):
    shutil.copy(f, staged / f.name); n += 1
```

Заголовки (`:171-174`):

```python
for h in sorted(staged.glob('*.h.lm1')):
    base = h.name[:-len('.h.lm1')]
    if convert(f'header:{base}', f'l2src/{h.name}', headers / 'l2src' / f'{base}.lm1.h'):
        row('OK', f'header:{base}')
```

Юниты, то есть тела модулей — своё же имя файла минус `.lm1` и есть
`base` (`:181-192`):

```python
units = [u for u in sorted(staged.glob('*.lm1')) if not u.name.endswith('_selftest.lm1') and not u.name.endswith('.h.lm1')]
...
for u in units:
    in_tests = u.parent.name == 'tests'
    base = ('tests_' if in_tests else '') + u.name[:-4]
    rel = f'l2src/tests/{u.name}' if in_tests else f'l2src/{u.name}'
    c = obj / f'{base}.c'
    o = obj / f'{base}.o'
    if not convert(f'unit:{base}', rel, c):
        continue
    if compile_c(f'unit:{base}', c, o):
        objects.append(o); row('OK', f'unit:{base}')
```

**`tools/build_l2src.ps1`** — тот же приём, PowerShell. Стейджинг
(`:131-133`):

```powershell
foreach ($f in @(Get-ChildItem -LiteralPath $flatSource -File -Filter '*.lm1')) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $staged $f.Name) -Force; $stagedCount++
}
```

Заголовки (`:447-451`), юниты (`:455-480`, база — `:473-475`):

```powershell
$base = $u.Name.Substring(0, $u.Name.Length - '.lm1'.Length)
if ($inTests) { $base = 'tests_' + $base }
$rel = if ($inTests) { "l2src/tests/$($u.Name)" } else { "l2src/$($u.Name)" }
```

Ни манифеста, ни списка модулей нигде нет — «модуль X» ДЛЯ ОБОИХ
скриптов буквально означает «файл `X.lm1`, найденный `glob`».

### 3.2 Что менять

Единственная точка изменения в каждом из четырёх драйверов — САМ ШАГ
КОПИРОВАНИЯ (стейджинг), а не циклы discovery/convert/compile, которые
работают по имени в стейджинг-каталоге и трогать их не нужно:

- `build_l2src.py:76-77`,
- `build_l2src.ps1:131-133`,
- `run_l3_selftest.py:67-68` (`for source in sorted(SANDBOX.glob('lmx*.lm1')): take(source, unit_root / 'l2src' / source.name)`),
- `tools/l3_type_budget.py:81-82` (тот же приём, тот же комментарий "The
  same staging tools/run_l3_selftest.py does" — `:78`),
- `tools/l2_harness.ps1:288-290` (машинный, только Windows, но структурно
  та же копия).

Форма правки — везде одна: при копировании `*.lm1` из `dev/l2src_sandbox`
для ИМЕНИ `lmx_clock.lm1` (аналогично для `lmx_process_deadline.lm1`,
`lmx_manager_running.lm1`) выбирать физический исходник по хосту —
`lmx_clock_win32.lm1` на Windows, `lmx_clock_posix.lm1` на POSIX — и класть
его В СТЕЙДЖИНГ ПОД СТАРЫМ, НЕЙТРАЛЬНЫМ ИМЕНЕМ `lmx_clock.lm1`. Например
для `build_l2src.py` вместо голого `shutil.copy(f, staged / f.name)` —
таблица `{'lmx_clock.lm1': 'lmx_clock_win32.lm1' if windows else
'lmx_clock_posix.lm1', ...}`, применяемая только к этим трём логическим
именам, остальные файлы копируются как раньше.

**Почему так, а не переименование ссылок.** `predef:` резолвится
транслятором по буквальному пути от текущего каталога (сам `.ps1`
формулирует это явно, `build_l2src.ps1:159` и далее: *"THE TRANSLATOR
RESOLVES `predef:` ITSELF, FROM THE WORKING DIRECTORY"*). Все 8
непосредственных потребителей (`lmx_process_deadline.lm1:2`,
`lmx_manager_running.lm1:6`, `lmx_settle.lm1:5`, `lmx_root.lm1`,
`lmx_thread.lm1`, `lmx_turn.lm1`, плюс их `predef:`-цепочки) пишут
`predef: "l2src/lmx_clock.lm1"` буквально. Если физический файл
переименовать в `lmx_clock_win32.lm1`/`lmx_clock_posix.lm1` и оставить
как есть, все эти строки перестанут резолвиться — а править их означало
бы либо трогать чужие/общие файлы без необходимости (`lmx_root.lm1`,
`lmx_thread.lm1`, `lmx_turn.lm1` и 21 файл под `tests/` — хотя формально
все под управлением Sonnet, это 20+ файлов ради одной развилки), либо
писать в самой строке `predef:` условие по ОС — а это `#ifdef`-подобная
логика прямо в теле, то есть именно «переходный двойной режим», который
доктрина §0 запрещает. Выбор физического файла на этапе стейджинга —
единственная форма, которая не трогает НИ ОДНОГО чужого/общего файла и
не вносит условности в `.lm1`-текст: снаружи стейджинга (и снаружи
`dev/l2src_sandbox`, где физически будут лежать `lmx_clock_win32.lm1` +
`lmx_clock_posix.lm1` вместо `lmx_clock.lm1`) никто не видит, что модуль
вообще расщеплён.

Симметрично для `lmx_clock.h.lm1` заголовок остаётся ОДИН файл под
старым именем; его нужно только избавить от протечки Win32-типа в
прототипе — `ULONGLONG` в `lmx_clock_now`/`lmx_clock_since`
(`lmx_clock.h.lm1:23,51`) заменить на портативный `foreign:`-псевдоним,
который на Windows разворачивается в тот же `ULONGLONG` через
`windows.h`, а на POSIX — в `uint64_t`/`unsigned long long` через
собственный небольшой POSIX-заголовок; единственный внешний потребитель
этих двух функций (`lmx_domain_selftest.lm1:329,331`) сравнивает
результат с `0U`, так что смена ширины типа его не касается. Для
`lmx_process_deadline.h.lm1` прототип `_body(...) DWORD` (`:45`) можно
не трогать вовсе, раз наружу он не вызывается — либо (аккуратнее)
вынести его из `.h.lm1` в тело, раз он не часть внешнего контракта.

Ничего из этого не требует НОВОГО механизма на уровне `predef:`/L1:
`predef:` уже поддерживает то, что несколько `.lm1` предefефают один и
тот же `.h.lm1` — это ОБЫЧНАЯ форма потребления заголовка (см. таблицу
в §3.3: `lmx_arena.h.lm1` предefефают 33 файла, `lmx.h.lm1` — 25).
Специального «двух тел под одним заголовком» тут и не нужно: как только
стейджинг кладёт под логическим именем ОДИН выбранный по ОС файл,
транслятор просто ни разу не видит два тела сразу — он видит ровно один
`lmx_clock.lm1` за раз, как и сейчас.

### 3.3 Есть ли уже такой прецедент в кодовой базе

Прямого прецедента «один общий заголовок, несколько тел, выбираемых
сборкой по ОС» в `dev/l2src_sandbox` (ядро LMX) — **НЕТ**. Проверено
двумя способами:

1. Обратный индекс «какие НЕ-селфтестовые `.lm1` предefефают данный
   `.h.lm1` КАК СВОЙ ОДНОИМЁННЫЙ КОНТРАКТ» (т.е. `X.lm1` предefефает
   `X.h.lm1` первой строкой) — для всех 109 `.lm1` в `dev/l2src_sandbox`
   ровно один файл на каждый заголовок совпадает по имени; альтернативных
   тел с другим именем, предefефающих тот же заголовок как реализацию
   (а не как обычную зависимость потребителя), нет ни для одного модуля.
2. `grep -r` по всему репозиторию на `_win32.lm1`/`_posix.lm1`-подобные
   имена: единственные совпадения — в `dev/mixa_sandbox/` (не LMX, а
   отдельный проект `mixa_manager`, C→L1-миграция файлового менеджера,
   `dev/mixa_sandbox/README.md:1,3`: *"active C→L1 migration workspace for
   mixa_manager"*, чужой проект, вне тикета). И там это НЕ прецедент
   «общий заголовок / разные тела»: `mixa_process_win32.lm1` предefефает
   СВОЙ ЖЕ одноимённый `mixa_process_win32.h.lm1`
   (`dev/mixa_sandbox/mixa_manager/mixa_process_win32.lm1:1`), а не общий
   `mixa_process.h.lm1` (тот принадлежит другому, непортированному
   модулю — `mixa_process_marker`). То есть в mixa и заголовок, и тело
   несут суффикс `_win32` — это просто отдельная платформенная пара
   файлов, а не общий контракт с альтернативными реализациями.

Ближайший СМЫСЛОВОЙ аналог в самом LMX — не файловый, а модульный:
`lmx_manager.h.lm1` (портативный интерфейс, шаговая реализация в
`lmx_manager.lm1`) и `lmx_manager_running.h.lm1`/`.lm1` (тот же
шеститочечный API — `init/add/remove/take/count/step/round/close` — но
на лейнах ОС-потоков) — ДВЕ РЕАЛИЗАЦИИ ОДНОГО ИНТЕРФЕЙСА, но как ДВА
РАЗНЫХ МОДУЛЯ с разными именами функций (`lmx_manager_init` vs
`lmx_manager_running_init`), выбираемых ВЫЗЫВАЮЩИМ КОДОМ явно, а не
одним общим заголовком и подстановкой тела сборкой. Это разделение
описано в самом файле (`lmx_manager_running.lm1:8-10`, дословно):
*"lmx_manager_running.lm1 - the SECOND implementation of the manager
interface: it gives every record a lane of its own... Same six
operations, same signatures, same LmxManager; only the binding differs"*
— то есть проект уже практиковал «одна логическая контракт-форма, две
реализации», но КАК ДВА ИМЕНОВАННЫХ МОДУЛЯ, выбор между которыми делает
код (сейчас — всегда `_running`, `lmx_manager.lm1`/`lmx_manager_init`
не используется в текущей сборке, не проверялось отдельно в рамках
этого замера), а не как «один header.lm1, тело выбирает сборка по ОС».

**Вывод по (c)-доктрине:** предложенная форма (общий `.h.lm1`,
platform-body, выбор которым занимается скрипт сборки на этапе
стейджинга, без `predef:`-разветвления и без `#ifdef` в `.lm1`) — ПЕРВЫЙ
СЛУЧАЙ ЭТОГО МЕХАНИЗМА в LMX. Технически это не новый примитив уровня
L1/`predef:` (см. §3.2 — `predef:` уже поддерживает много-к-одному без
всяких изменений), а новая ДОГОВОРЁННОСТЬ УРОВНЯ СБОРОЧНЫХ СКРИПТОВ
(один шаг копирования выбирает физический файл по ОС под нейтральным
именем). Раз это первый экземпляр, а не переиспользование существующего
приёма — по правилу «спрашивать перед новым механизмом» это стоит
явно подтвердить у автора вместе с RESULT/GATE?, а не считать
самоочевидным продолжением уже принятого Q10 (Q10 сказал «да» самому
POSIX-двойнику, но не этой конкретной форме реализации выбора файла).

## 4. Что предполагают про имена файлов `run_l3_selftest.py` и драйверы гейта

- **`tools/run_l3_selftest.py:67-68`** — копирует ВСЕ файлы, подходящие
  под `lmx*.lm1`, единым блоком, под их собственными именами:
  ```python
  for source in sorted(SANDBOX.glob('lmx*.lm1')):
      take(source, unit_root / 'l2src' / source.name)
  ```
  В отличие от build_l2src.py/.ps1 этот скрипт НЕ компилирует каждый
  юнит в отдельный `.o` — он переводит через `l1trans` только
  `.h.lm1`-заголовки (`:94-100`) и один выбранный тестовый файл плюс
  `l2_libc.lm1` (`:101-106`) в ОДИН `.c`, который потом просто
  компилируется `gcc` (`:107-115`) без пообъектной линковки. Значит,
  какое ИМЕННО тело физически лежит в стейджинге под именем
  `lmx_clock.lm1` в момент, когда транслятор идёт по `predef:`-цепочке
  теста, — и определяет, чья реализация попадёт в сгенерированный `.c`.
  Это тот же самый, но даже более чувствительный случай: копия ДОЛЖНА
  положить ровно один выбранный по ОС файл под нейтральным именем,
  иначе (если положить оба физических файла под их НАСТОЯЩИМИ разными
  именами `lmx_clock_win32.lm1`/`lmx_clock_posix.lm1`) все `predef:
  "l2src/lmx_clock.lm1"` в 22 потребителях перестанут резолвиться —
  файла с таким именем в стейджинге не будет вовсе.
- **`tools/l3_type_budget.py:77-82`** — дословно та же стадия, с
  комментарием, что так и задумано (`:78`, *"The same staging
  tools/run_l3_selftest.py does, so the closure is the one the suites
  translate"*): `for source in sorted(SANDBOX.glob('lmx*.lm1')):
  shutil.copyfile(source, unit_root / 'l2src' / source.name)`. Тот же
  фикс нужен здесь же, иначе бюджет типов будет мерять не ту сборку,
  какую видит `run_l3_selftest.py`.
- **`tools/l2_harness.ps1:288-290`** (машинный harness eternal-runs
  драйвер, PowerShell, только Windows) — структурно идентичная стадия:
  ```powershell
  foreach ($f in @(Get-ChildItem -LiteralPath $sandbox -File -Filter '*.lm1')) {
      Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $src ('l2src\' + $f.Name)) -Force; $staged++
  }
  ```
  На машине автора ОС всегда Windows, так что при наивном
  переименовании исходников (`lmx_clock.lm1` → `lmx_clock_win32.lm1`)
  этот драйвер тоже перестанет находить `lmx_clock.lm1` по имени и
  сломает все 22 потребителя, если не получит тот же однострочный
  выбор «на Windows бери `_win32`». Это тот факт, который стоит явно
  сообщить fable/автору: правка не ограничивается двумя облачными
  скриптами — третий (и главный, машинный) гейт-драйвер требует того
  же изменения, хоть сам он никогда не выберет `_posix`.
- Прямых hardcoded ссылок на `lmx_clock.lm1`/`lmx_process_deadline.lm1`/
  `lmx_manager_running.lm1` по имени ни в одном `tools/*.py`, ни в
  `tools/*.ps1` нет (проверено `grep` по всем `.py`/`.ps1` в `tools/`) —
  единственные упоминания — внутри самих `.lm1`-файлов (`predef:`
  строки, см. §3.2). Манифеста или отдельного списка юнитов нигде не
  существует; «модуль» в обоих build-скриптах и во всех трёх
  harness/бюджет-скриптах — исключительно то, что находит `glob` по
  имени файла в стейджинг-каталоге в момент запуска.

## 5. Открытый вопрос (не блокирует RESULT, для fable)

`lmx_process_deadline.h.lm1` использует `DWORD` как тип возврата
прототипа (`:45`) без собственного `foreign: DWORD` — ни в этом файле,
ни в его предef-цепочке (`l2src/lmx.h.lm1`, проверено `grep`). У
`lmx_manager_running.h.lm1` тот же `DWORD` объявлен явно (`foreign:
DWORD`, `:17`). Не выяснено в рамках read-only замера, разрешает ли
`l1trans` использовать имя из `include: "<windows.h>"` этого же файла
без явного `foreign:`, или это скрытый пробел, который сегодня
компилируется только потому, что POSIX-сборка эту красную голову не
доходит до проверки типа. Стоит подтвердить кодом транслятора перед
кодом к.2+, не самим этим замером.
