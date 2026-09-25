# grok_next.md — записка для Grok CLI на машине автора

Написано fable 2026-09-27 по указанию автора. Адресат — **Grok CLI** (терминальный чат `C:\grok\grok.bat`, cwd `C:\Nyasha_Planet\LMX`; см. `grok_read_me.md`), не Grok Bot (он остановлен окончательно) и не ACP-беседа `grok.py`.

С этого момента Claude-сессии `fable` (диспетчер), `opus` (транслятор `l2trans.lm1`) и `sonnet` (ядро `dev/l2src_sandbox`, walker, L3) работают **в облаке**. У них нет доступа к машине: ни к named pipe `lmx_uds`, ни к консоли, ни к локальному рабочему дереву. Общий носитель — только git (`origin`, `https://github.com/michael0xf/LMX.git`). Ты — руки на машине: гейты, сборки, локальные замеры, при необходимости push.

## 1. Что читать перед первым действием

`READ.ME` → `steps/current.md` → `next_core_tasks.md` §0 (доктрина) и §3 «Пара исполнения code/data» → `fable_next.md` (состояние и очередь) → `opus_next.md`, `sonnet_next.md`. Не импортировать старые записки как норму: `grok_read_me.md` описывает каналы, которых у облачных сессий больше нет.

## 2. Состояние на момент передачи

- `origin/main` = `daccbb0` (или новее; `daccbb0` — только записки поверх `b7cce8c`): модель code/data, слово `Lmx.native`, merge по карте пар, op-деревья тел методов (T4a `7ba030b`), массивы в корне (ядро), K2 — merge в корне (-194 к.6) — всё влито. Гейт на main (записан в сообщении `b7cce8c` и в `fable_next.md` §2): `tools/build_l2src.ps1 -Run` 276/276, `tools/l2_harness.ps1` 390/390, `python tools/run_l3_selftest.py` 11/11, `python tools/check_docs.py` OK.
- Уже влиты, на этих tip'ах гейт и merge не нужны: `origin/opus/l2src-twin-198` (D-74, twin `l2src` = копия песочницы, `opus_next.md`) — merge `da91903` (tip `bb4a3f7`) и `origin/sonnet/merge-194` (K2 merge в корне, `sonnet_next.md`) — merge `b7cce8c` (tip `43046fc`). Новые ветки вливает fable из облака после зелёного гейта.
- Не влит и устарел: черновик grok_bot -185 (D-60) `08e0a4f` на `origin/fable/grokbot-185-c1`. Он читает слот 0 письма как сырой Message, а с `a771048` (Sonnet -172 к.4) там pointer-ячейка — на main этот блок молча ничего не сделает; его правка `steps/defects.md` берёт уже занятый F-54 и добавляет второй D-60 со статусом FIXED. Не cherry-pick'ать и не гейтить; D-60 на main — OPEN.

## 3. Протокол с облачными сессиями (через git)

Предлагаемая форма (ещё не согласована с автором — `fable_next.md` §5; веток `fable/requests` и `grok/results` на `origin` пока нет, файлов `steps/gate-request.md`/`steps/gate-results.md` на main тоже; до согласования запросы может пересылать автор вручную):

1. **Запрос гейта** от fable/opus/sonnet: файл `steps/gate-request.md` в ветке `fable/requests` (или коммит с текстом `GATE? <ветка> <sha>`). Один запрос — одна ветка/sha.
2. **Ты** (по одному запросу за раз, никогда два гейта параллельно — машина падает по памяти):
   ```powershell
   Set-Location C:\Nyasha_Planet\LMX
   git fetch --all
   git status --short          # должно быть пусто; иначе стоп и вопрос автору
   git switch --detach <sha>   # точный sha без ветки — см. ниже
   .\tools\build_l2src.ps1 -Run
   .\tools\l2_harness.ps1
   python tools\run_l3_selftest.py
   python tools\check_docs.py
   git diff --check
   ```
   Почему не `git checkout <ветка>; git reset --hard <sha>`: многие ветки помощников заняты другими worktree на машине (`git worktree list`; в `git branch` помечены `+`), в том числе `sonnet/merge-194` (worktree `C:\Nyasha_Planet\LMX_sonnet_noderoot`). git 2.37 отказывает в `checkout` такой ветки (`already checked out at …`), а `;` в PowerShell не останавливает следующую команду — `reset --hard <sha>` сдвинул бы локальный `main` на чужой sha. Отсоединённая HEAD на точном sha гейтит ровно запрошенное и не двигает ни одну ветку; `switch`, в отличие от `reset --hard`, незакоммиченное не выбрасывает — поэтому сначала `git status`. После гейта — `git switch main`.
   Результат — в `steps/gate-results.md` (дата, ветка, sha, четыре числа, список красных строк с точным текстом FAIL, пути evidence под `build/`) коммитом `GATE DONE <ветка> <sha>: …` в ветку `grok/results`, push.
3. **Ничего не чинить** в чужих ветках. Красный гейт — только отчёт с фактами; починка — у владельца (Opus — l2trans и фикстуры harness; Sonnet — ядро/walker/L3/селфтесты).
4. **Артефакты** (`build/`, `dev/l3_interp/build/`, `%TEMP%`) не коммитить. `claude_chat/profiles/` не коммитить и не читать `.key`.
5. Если автор попросит тебя сделать содержательную задачу — она берётся из `next_core_tasks.md` §3/§4 по плану в `steps/*.md`, с теми же правилами: к.1 read-only план → код по коммитам с гейтом → RESULT; STARTED/RESULT с ID тикета в сообщении коммита и в `steps/`.

## 4. Правила проекта, которые нельзя нарушать (кратко)

- Доктрина `next_core_tasks.md` §0: никаких спец-веток по именам, allowlist'ов, скрытых реестров, fallback'ов, «переходных двойных режимов», дополнительных полей в базовых типах. Пробел контракта — вопрос автору, не заплатка.
- Имена — только в трансляторе; ядро и walker работают по позициям и классификации адресов по арене. Нет маркеров «callable» — исполнение выбирается по слову `native` (пусто = walker).
- Спеки (`docs/`) описывают язык, без планов и бесед; RU/EN синхронно; `docs/LMX_semantics.*` только через `provenance/semantics-book.md` + `python tools/build_semantics.py`; реплики автора о языке — дословно в `LMX_blog/<дата>.md`.
- Факты harness (Says/Entry/пины) меняются только по правилу автора и с обоснованием в отчёте; каждая правка ядра — селфтест + мутант.
- Один писатель на файл: `l2trans.lm1` — Opus; ядро — Sonnet. Ты не правишь их без явного поручения автора.

## 5. Что дальше по плану (очередь fable, §3 `fable_next.md`)

T3 (merge в корне, транслятор) → -170 трансляторная половина (ELEM/ELEMPUT/LENGTH в корне, 10 строк) → T4b/T5–T7 (callable merge, PAP, makeAdder, конвертер) → CATCH-роль (ядро + транслятор, 7 строк) → D-67/D-60/D-62/D-12/D-69 → §7 порт implements/admission → GATE «чистое ядро перед самосборкой L2». Открытый вопрос автору: -195 Q7 (`steps/next-phase-195.md`, «Questions for fable»; не путать с закрытым Q7 в `q.md` о полях C-структур) — класс корневых адресов (`@:`-фактические, результаты-указатели, строки в корне): входит в walkable-подмножество или отказывается по правилу, раз сырые указатели нативны; ответа в `LMX_blog/` и `steps/` нет, на нём стоят 4 root-pending строки (`fable_next.md` §3 п.6).
