# grok_next.md — записка для Grok CLI на машине автора

Написано fable 2026-09-27 по указанию автора. Адресат — **Grok CLI** (терминальный чат `C:\grok\grok.bat`, cwd `C:\Nyasha_Planet\LMX`; см. `grok_read_me.md`), не Grok Bot (он остановлен окончательно) и не ACP-беседа `grok.py`.

С этого момента Claude-сессии `fable` (диспетчер), `opus` (транслятор `l2trans.lm1`) и `sonnet` (ядро `dev/l2src_sandbox`, walker, L3) работают **в облаке**. У них нет доступа к машине: ни к named pipe `lmx_uds`, ни к консоли, ни к локальному рабочему дереву. Общий носитель — только git (`origin`, `https://github.com/michael0xf/LMX.git`). Ты — руки на машине: гейты, сборки, локальные замеры, при необходимости push.

## 1. Что читать перед первым действием

`READ.ME` → `steps/current.md` → `next_core_tasks.md` §0 (доктрина) и §3 «Пара исполнения code/data» → `fable_next.md` (состояние и очередь) → `opus_next.md`, `sonnet_next.md`. Не импортировать старые записки как норму: `grok_read_me.md` описывает каналы, которых у облачных сессий больше нет.

## 2. Состояние на момент передачи

- `origin/main` = `7ba030b` (или новее): модель code/data, слово `Lmx.native`, merge по карте пар, op-деревья тел методов, массивы в корне (ядро) — всё влито. Гейт на main: `tools/build_l2src.ps1 -Run` 275/275, `tools/l2_harness.ps1` 384/384, `python tools/run_l3_selftest.py` 11/11, `python tools/check_docs.py` OK.
- Могли остаться не влитыми: `origin/opus/l2src-twin-198` (D-74, twin `l2src` = копия песочницы, `opus_next.md`) и `origin/sonnet/merge-194` (K2 merge в корне, `sonnet_next.md`). Их вливает fable из облака после зелёного гейта.

## 3. Протокол с облачными сессиями (через git) — действующая форма с 2026-09-25

Общий носитель — только `origin` (`main`). Облачные сессии сами не просыпаются на новые коммиты: их будит автор одной строкой в чат; fable обходит `main` каждые 15 минут (в :14, :29, :44 и :59 UTC).

1. **Запрос гейта.** fable пишет на `main` файл `steps/gate-request.md` с одной строкой `GATE? main <sha>` (или `GATE? <ветка> <sha>`). Ты проверяешь его командой `git fetch origin main && git show origin/main:steps/gate-request.md`. Автор может дать ту же строку в чат — это равнозначно.
2. **Прогон** (один за раз, никогда два параллельно — машина падает по памяти):
   ```powershell
   Set-Location C:\Nyasha_Planet\LMX
   git fetch --all
   git checkout main; git reset --hard <sha>
   .\tools\build_l2src.ps1 -Run
   .\tools\l2_harness.ps1
   python tools\run_l3_selftest.py
   python tools\check_docs.py
   git diff --check
   ```
3. **Ответ.** В `steps/gate-results.md` дописать сверху запись: дата и время UTC, `<sha>`, четыре числа (build N/N, harness N/N, L3 N/N, check_docs OK/FAIL), при красном — точный текст каждой строки FAIL и путь к логу под `build/`. Коммит в ветке `grok/machine` с первой строкой `GATE DONE main <sha>: build N/N, harness N/N, L3 N/N, check_docs OK` (при красном — `GATE RED main <sha>: …`), затем по правилу автора:
   ```powershell
   git checkout -b grok/machine origin/main   # или git checkout grok/machine; git merge origin/main
   git add steps/gate-results.md; git commit -m "GATE DONE main <sha>: build N/N, harness N/N, L3 N/N, check_docs OK"
   git push -u origin grok/machine
   git checkout main; git merge --no-ff grok/machine -m "integrate: gate result for <sha>"; git push origin main
   ```
   fable прочитает `main` на ближайшем обходе; отдельно сообщать не нужно, но строка `GATE DONE …` в чат автору ускорит.
4. **Ничего не чинить** в чужих файлах. Красный гейт — только факты; владелец чинит: Opus — `l2trans.lm1` и строки harness; Sonnet — ядро, walker, L3, селфтесты; fable — документы и `steps/`.
5. **Не коммитить** `build/`, `dev/l3_interp/build/`, `%TEMP%`, `*.stackdump`, `lmx_root_*_selftest.err/.out`; `claude_chat/profiles/` не читать и не коммитить.
6. **Тикеты от fable** — в `steps/tickets-<дата>.md`, раздел «Тикеты Grok CLI» (сейчас `steps/tickets-20260925.md` §8): -202 K2b, D-60, затем D-62/D-12/миграция `Lmx`. Разделение файлов с Sonnet — там же; effort сессии — xhigh (автор).
7. **Содержательная задача от автора** — из `next_core_tasks.md` §3/§4 по `steps/*.md`, теми же правилами: к.1 read-only план → код по коммитам → RESULT с ID в `steps/` и в первой строке коммита; своя ветка `grok/<тема>`, влитие в `main` по правилу автора после зелёных проверок.

## 4. Правила проекта, которые нельзя нарушать (кратко)

- Доктрина `next_core_tasks.md` §0: никаких спец-веток по именам, allowlist'ов, скрытых реестров, fallback'ов, «переходных двойных режимов», дополнительных полей в базовых типах. Пробел контракта — вопрос автору, не заплатка.
- Имена — только в трансляторе; ядро и walker работают по позициям и классификации адресов по арене. Нет маркеров «callable» — исполнение выбирается по слову `native` (пусто = walker).
- Спеки (`docs/`) описывают язык, без планов и бесед; RU/EN синхронно; `docs/LMX_semantics.*` только через `provenance/semantics-book.md` + `python tools/build_semantics.py`; реплики автора о языке — дословно в `LMX_blog/<дата>.md`.
- Факты harness (Says/Entry/пины) меняются только по правилу автора и с обоснованием в отчёте; каждая правка ядра — селфтест + мутант.
- Один писатель на файл: `l2trans.lm1` — Opus; ядро — Sonnet. Ты не правишь их без явного поручения автора.

## 5. Что дальше по плану (очередь fable, §3 `fable_next.md`)

T3 посажен 2026-09-25 (main `e4fdb62`); дальше: D-76 и -170 трансляторная половина (Opus); D-67 (A), -202 K2b, -201 CATCH к.2, -200 POSIX-двойник (Sonnet); текущее — `steps/tickets-20260925.md`. Прежний порядок: -170 трансляторная половина (ELEM/ELEMPUT/LENGTH в корне, 10 строк) → T4b/T5–T7 (callable merge, PAP, makeAdder, конвертер) → CATCH-роль (ядро + транслятор, 7 строк) → D-67/D-60/D-62/D-12/D-69 → §7 порт implements/admission → GATE «чистое ядро перед самосборкой L2». Открытых вопросов автору нет.
