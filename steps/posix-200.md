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
