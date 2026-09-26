# Тикет fable 2026-09-26-05 — конвертеры: таблица читается из `convert.lm2`, отказ диапазона вместо нуля (BLOCK REVIEW 65dba4c)

Статус: OPEN. Написан по правилу `steps/tickets/README.md`: последний коммит ведущего на main — `65dba4c` в 17:26 UTC, к 18:20 UTC ни коммита, ни ANSWER, ни TAKEN; открытое замечание ревью — BLOCK REVIEW 65dba4c п.1–п.2 (срез `e2c62d0` «convert.lm2 receivers on a primitive assignment»).

## Норма

- Автор (по плану `steps/implements-s7.md`, дословную цитату дописать в `LMX_blog/2026-09-26.md` — п.3 ревью): таблицу и алгоритм `implements` брать из `lingvamyxa_prev`; файл таблицы — `lm2/convert.lm2`, копия в `dev/l2src_sandbox/convert.lm2` и `l2src/convert.lm2`; это данные.
- `next_core_tasks.md` §7 :443: «Портировать механизм создания и заполнения таблиц, написанный на L2, и адаптировать только реальные несовместимости нового ядра». §0: никаких allowlist/скрытых реестров в трансляторе.
- Книга §12 (`docs/LMX_semantics.en.md` :916 / RU то же место): «`u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero». §2.2.4: отказ конвертера — обычный отказ приёмника.

## Где сегодня нарушение (`dev/l2src_sandbox/l2trans.lm1`, main `65dba4c`)

1. `l2_convert_hit` :5898–:5929 — восемь пар имён `strcmp` → зашитые имена приёмников и биты; `l2_emit_convert_defs` :5964–:5985 — тела восьми конвертеров текстовыми литералами. `convert.lm2` не читается никем (`grep convert.lm2` — только комментарии harness). Второй экземпляр таблицы, расходящийся с первым при любой правке.
2. Тела: `lm_stg_convert_size_t_int` (`n > 2147483647U → return: 0`), `lm_stg_convert_int_size_t` (`n < 0 → 0U`), `lm_stg_convert_int_char`, `lm_stg_convert_unsigned_int` — молчаливый 0 при выходе из диапазона. Корпус: `unit_merged_callable` теперь везёт int → size_t через `lm_stg_convert_int_size_t` (три записи), отрицательное значение стало бы 0 без ошибки.

## Сделать (транслятор; ядро не трогается)

1. Транслятор читает `table:` из `convert.lm2` тем же P0-парсером, что читает любую Structure файла (никакого отдельного разбора и никакого имени-исключения: файл задаётся как вход/импорт трансляции, не литеральным именем `` `primitive.convert` `` в коде). Строки — from, to, forbidden, kind, receiver, impl. На ребре присваивания двух разных именованных примитивов: строка с forbidden = 0 и receiver ≠ None → вызов receiver; receiver = None (identity) — прямая запись; строки нет или forbidden = 1 — отказ. `l2_convert_hit` и его биты уходят; `l2_emit_convert_defs` с текстовыми телами уходит.
2. Тела приёмников — порт из `lingvamyxa_prev/lm2/convert_impl.lm2` (файл рядом с таблицей, копия в обоих `l2src`), только реальные несовместимости ядра. Выход из диапазона — отказ приёмника по каналу неявного throw (`merge`/`implements`, Q17; L3 «unsupported» до своей реализации), не `return: 0`. Если порт тел за один срез не вмещается — сначала п.1 с честным отказом «no converter body ported» на строках без тела, ноль не возвращать.
3. Свидетели (в обоих `tests/`, строки `tools/l2_harness.ps1`): `unit_s7_prim_cross` — без изменений результата (строка есть, значение в диапазоне); `unit_s7_conv_range` — `size_t` 4294967296U → `int`: отказ приёмника (не 0, не Entry с нулём); `unit_s7_conv_norow` — пара без строки (`unsigned ← size_t`): located отказ одной фразой «mixed numeric types (a conversion)» (сейчас две фразы, REVIEW 65dba4c п.4); `unit_merged_callable` — прежний Entry. Мутант: строка `size_t int` убрана из `convert.lm2` → `unit_s7_prim_cross` отказывается (видно, что читается файл, а не код).
4. Учёт: `steps/implements-s7.md` (раздел с гейтом), `grok_next.md` §4 п.9, `next_core_tasks.md` §7 :443 (что закрыто, что остаток), цитата автора дословно в `LMX_blog/2026-09-26.md` (п.3 ревью). Близнецы `l2src/` включая `tests/` и `convert.lm2`/`convert_impl.lm2`.

## Критерий готовности

В `l2trans.lm1` нет зашитого списка пар и текстов тел конвертеров; убранная из `convert.lm2` строка меняет результат трансляции; выход из диапазона — отказ, не 0; `unit_s7_prim_cross`, `unit_merged_callable` — прежние Entry; harness зелёный; мутант RED.

Дальше — продолжать `next_core_tasks.md`.
