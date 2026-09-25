# -200 POSIX-двойник, срез (а)

База main `a01f354`. Форма — `steps/tickets-20260925.md` §6 и замер `steps/posix-gate-200.md`.

## Что сделано

Один общий заголовок на модуль, без типа Win32 в прототипе.

- `lmx_clock.h.lm1`: `include: "<stdint.h>"`. `lmx_clock_now` и `lmx_clock_since` возвращают `uint64_t`. `foreign: ULONGLONG` и `<windows.h>` из заголовка сняты.
- `lmx_process_deadline.h.lm1`: `<windows.h>` снят. `lmx_process_deadline_body` в заголовке нет; прототип тела — в Win32-файле.
- `lmx_manager_running.h.lm1`: `<windows.h>`, `foreign: DWORD` и `foreign: LPTHREAD_START_ROUTINE` сняты. Прототипы шести операций не менялись.

Тела переименованы в `lmx_clock_win32.lm1`, `lmx_process_deadline_win32.lm1`, `lmx_manager_running_win32.lm1`. Это прежние тела: `<windows.h>` теперь в теле, `GetTickCount64` приводится к `uint64_t`. `predef:` потребителей не менялись: на стейджинге выбранный файл кладётся под нейтральное имя (`lmx_clock.lm1` и два других).

Выбор в `build_l2src.ps1`, `l2_harness.ps1` — всегда Win32. В `build_l2src.py`, `run_l3_selftest.py`, `l3_type_budget.py` и `run_walk_selftest.py` — Win32 на Windows, POSIX на другом хосте. Флаги `.ps1` не менялись. POSIX-тел ещё нет: это срез (б).

## Мутант

Снять со стейджа нейтральный `lmx_clock.lm1` → `l1trans` `lmx_process_deadline.lm1` exit 1, `cannot read import l2src/lmx_clock.lm1`. Файл возвращён.

## Гейт

build 277/277 (`build/l2src/20260925_121038`). Harness 398/398 (`build/l2_harness/20260925_121335`). L3 11/11, бюджет имён 68/128 (пин сдвинут с 69: `foreign: ULONGLONG` ушёл из заголовка). `check_docs` OK. POSIX-тела и облачный `build_l2src.py` 230/230 — срез (б), здесь не заявлены.

# -200 POSIX-двойник, срез (б)

База main `7cd11f3`. Форма — §6 `steps/tickets-20260925.md` (не self-pipe из замера: событие — condvar + мьютекс + флаг, `CLOCK_MONOTONIC`).

## Что сделано

Три тела: `lmx_clock_posix.lm1`, `lmx_process_deadline_posix.lm1`, `lmx_manager_running_posix.lm1`. `#ifdef` и `os:` нет. Общий заголовок не вырос: типы POSIX живут в `lmx_posix_abi.h.lm1`, его predef'ят только POSIX-тела. Windows-тело его не тянет, поэтому бюджет имён L3 на Windows остаётся 68. На POSIX к тем же четырём сюитам прибавляется 8 имён (4 foreign, `type: LmxPosixTimespec struct timespec`, 2 struct, fnptr `LmxPosixStart`).

`struct timespec` — не typedef. Псевдоним `LmxPosixTimespec` опускается в `typedef struct timespec`. Записи ожидания и lane — в куче; в портативные `void*` кладётся указатель на них. `pthread_t` указателем не является.

Часы: `clock_gettime(CLOCK_MONOTONIC)`, миллисекунды `sec*1000 + nsec/1000000`. `lmx_clock_word` приводит это 64-битное чтение к `size_t` напрямую, не через `lmx_clock_ticks`.

Дедлайн: `pthread_condattr_setclock(CLOCK_MONOTONIC)`. Флаг `signaled` пишется под тем же мьютексом, что и ожидание, поэтому сигнал до входа в `pthread_cond_timedwait` не теряется. Абсолютный срок считается один раз. Ожидание конечное: не больше 49 суток (`49*86400000` мс), семафора «никогда» нет. Истечение по-прежнему печатает прежнюю строку и зовёт `abort`.

Lane: последним актом после `lmx_thread_finish` поток ставит `finished`. `lane_reap` читает флаг и зовёт `pthread_join` только если флаг уже виден. `pthread_tryjoin_np` нет. `close` ждёт `pthread_join` без флага — это закрытие, ему можно блокироваться. Пауза витка — `nanosleep` 1 мс.

Флаги `-pthread` и `-D_POSIX_C_SOURCE=200809L` добавлены только в POSIX-ветку `build_l2src.py`, `run_l3_selftest.py`, `run_walk_selftest.py`. `.ps1` флаги не меняет.

Три логических имени — один список, скопированный в шести скриптах (`build_l2src.py`, `build_l2src.ps1`, `run_l3_selftest.py`, `l3_type_budget.py`, `l2_harness.ps1`, `run_walk_selftest.py`). Срез (б) новую копию не заводил.

## DWORD без foreign

Открытый вопрос замера §5. После среза (а) `foreign: DWORD` из заголовка снят, а Win32-тело по-прежнему пишет `fn: … DWORD` и гейт 277/277 его собрал. `l1trans` печатает это имя как написано; определение даёт `<windows.h>`. Отдельный `foreign:` телу не нужен. POSIX-тело `DWORD` не использует: вход потока — `void* (*)(void*)` (`LmxPosixStart`).

## Мутанты

Исходник не мутировался в коммите: правка → прогон → откат на копии порождённого C. На этом MinGW `pthread_condattr_setclock(CLOCK_MONOTONIC)` возвращает EINVAL (22); `CLOCK_REALTIME` принимается. Поэтому прогон дедлайна шёл на копии, где оба `CLOCK_MONOTONIC` заменены на `CLOCK_REALTIME`. Строки флага и reap — те же, что в исходнике. Сам `lmx_clock_posix` на `CLOCK_MONOTONIC` собран и прочитан: `lmx_clock_now` = 395374560, второе чтение не меньше.

- Часы. Верная формула против `clock_gettime(CLOCK_MONOTONIC)`: delta 0 (`got` = `expect` = 395848777). Мутант `nsec / 1000` вместо `/ 1000000`: delta 894012, exit 1.
- Флаг дедлайна снят (`w->signaled = 1` убран): arm на `now+3000` мс, disarm не возвращается сразу; ожидание доходит до срока и процесс гибнет с прежней строкой `the overall close deadline expired`, exit 3. С флагом disarm по стенным часам 0.000 с, exit 0.
- Проверка `finished` в `lane_reap` снята: поток крутится (`lmx_thread_running` = 1, состояние WAITING), `pthread_join` не возвращается; процесс убит на 1.5 с. С проверкой reap 0.000 с и `slot->lane` остаётся ненулевым (поток ещё жив).

Облачный `build_l2src.py` 230/230 этой машиной не измерен: Windows-гейт POSIX-тела не компилирует. Три юнита здесь переведены `l1trans` и собраны `gcc -c` с `-pthread -D_POSIX_C_SOURCE=200809L` (exit 0).

## Гейт среза (б)

build 279/279 (`build/l2src/20260925_124018`; +2 к 277: `header:lmx_posix_abi` и `unit:lmx_posix_abi.h`, как у прочих заголовков). Harness 398/398 (`build/l2_harness/20260925_124305`). L3 11/11, бюджет имён на Windows 68/128. `check_docs` OK. Облачный `build_l2src.py` 230/230 не измерен.

## Остаток REVIEW b5e72d7

`WaitForSingleObject` ушёл из `lmx_thread.lm1`. Вопрос «lane завершилась?» — `lmx_manager_running_lane_ended` в общем заголовке. Тело не в `lmx_manager_running_*.lm1`: тот файл тянет часы и ход, и селфтест, который их уже встроил, не может прилинковать его целиком. Отдельная пара `lmx_manager_running_lane_win32.lm1` / `_posix.lm1` стейджится под нейтральным именем, четвёртым в том же списке шести скриптов. `lmx_thread.lm1` встраивает это тело: драйвер harness линкует только свой объект. Win32 смотрит `WaitForSingleObject(lane, 0)`. POSIX читает `finished` под мьютексом lane и не делает join. Пауза селфтеста — `lmx_manager_running_pause_ms` (Win32 `Sleep`, POSIX `nanosleep`). Комментарии `lmx_clock.h.lm1` и `lmx_process_deadline.h.lm1` больше не называют `GetTickCount64` и `WaitForSingleObject`.

Свидетель — `lmx_domain_selftest`: пауза сдвигает `lmx_clock_word` не меньше чем на 30 мс; живая lane не завершена; после `running: 0` и паузы завершена, reap ещё впереди.

Гейт: build 280/280 (`build/l2src/20260925_133833`; +1 к 279 — `unit:lmx_manager_running_lane`). Harness 399/399 (`build/l2_harness/20260925_134128`). L3 11/11, бюджет имён 68/128. `check_docs` OK. Облако 232/232 измеряет fable.

## Срез селфтестов REVIEW 5bc8ec7 п.1–п.2

`c.Sleep` девяти селфтестов — `lmx_manager_running_pause_ms`. Поток селфтеста — `thread_start` / `thread_running` / `thread_join` / `thread_id` в том же заголовке и той же паре lane, без нового списка имён. `lmx_root_os_mkdir` в том же `os:`-блоке, что `lmx_root_os_cwd`. D-78 не в этом срезе.

Гейт: build 280/280 (`build/l2src/20260925_141743`). Harness 400/400 (`build/l2_harness/20260925_142056`). L3 11/11, бюджет имён 69/128 (`LmxManagerWork`). `check_docs` OK. Облако 233/233 измеряет fable.
