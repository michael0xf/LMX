# D-62 — отказ sendMessage в walked-корне

STARTED grok/d62-send-fail@база main `9f6dbb6`. REVIEW 5de4c45 — OK, не BLOCK.

## Факт

`sendMessage: Ref` на ссылку, которая не адрес Thread/Message, в интерпретируемом корне переводится: статическая проверка ссылки верна. `lmx_service_post` возвращает не OK. Тело `l2_emit_send` отвечает `return: 1` (`dev/l2src_sandbox/l2trans.lm1`, пост с Ref и пост родителю). `lmx_walk_prim` кладёт этот статус в `LMX_WALK_PRIMITIVE`. Процесс печатает `lmx: walk error: PRIMITIVE` и завершается. Это не located-отказ транслятора.

Тот же отказ у вызова из метода уже X1: `l2_emit_msend` при `l2_msend<k> != 0` печатает `lmx: invariant: sendMessage failed` и вызывает `abort`. Ранние `return: 1` того же тела (арена, nargs, ячейка) — тот же класс: любой внутренний отказ `l2_send`, не только Ref.

## Правка

Один отказ у обоих вызовов. Нового статуса примитива нет. `lmx_walk.lm1` и `lmx_walk_dyn_selftest` не менять: прочий `said`, не OK и не два THROW, остаётся `LMX_WALK_PRIMITIVE`.

Каждый выход-отказ сгенерированного тела `l2_emit_send` (и `l2_send`, и `l2_msend`) — тот же X1, что уже написан в `l2_emit_msend`: `fprintf` этой строки и `abort`, не `return: 1`. Один помощник на программу, не копия текста на каждый `return`. Успех по-прежнему `return: 0`. Вызов из метода, который проверяет `!= 0`, остаётся: если тело всё же вернуло не 0, его `abort` — тот же текст.

Третьего графа нет. Тихого каста нет. Q7 и Q9 не входят.

## Свидетель

Строка harness, которой сейчас нет: категория не принимает exit 3 без строки драйвера (`tools/l2_harness.ps1`, ветка `eternal-runs`). Добавить одну категорию: процесс завершился abort (exit 3), в stderr есть `lmx: invariant: sendMessage failed`, нет `lmx: walk error: PRIMITIVE`.

Фикстура — walked-корень, `sendMessage: Ref` на ссылку письма, не на Thread (проба из `steps/send-ref-172.md`, голый `receiveMessage: m`). Наблюдаемый факт — этот текст, не ноль entry.

Мутант: пост снова делает `return: 1`. Строка красная: stderr снова `walk error: PRIMITIVE`. Откат — зелёный. Существующие `unit_send_ref_method` и `unit_send_ref_driver_tap` остаются exit 0.

## RESULT

Посажено на `grok/d62-send-fail`. Тело `l2_send`/`l2_msend` зовёт один `l2_send_fail`: `fprintf` строки `lmx: invariant: sendMessage failed` и `abort`. Успех по-прежнему `return: 0`. `lmx_walk.lm1` не менялся.

Свидетель `unit_send_ref_root_fail`: exit 3, строка инварианта есть, `walk error: PRIMITIVE` нет. Мутант: пост снова `return: 1` — stderr `lmx: walk error: PRIMITIVE`. Откат — зелёный harness. `unit_send_ref_method` и `unit_send_ref_driver_tap` остались exit 0.

Гейт: build 282/282 (`build/l2src/20260925_192806`), harness 402/402 (`build/l2_harness/20260925_192542`), L3 11/11, имена 69/128, check_docs OK.

## Не входит

`lmx_walk_dyn_selftest`, ширина args-part, mixed numeric types, Q7, Q9, раскладка `Lmx`.
