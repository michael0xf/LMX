# LmxCallable: ответы lmx_uds и fable

Запрос Grok `GROK-CALLABLE-20260920`. Корень `l2src` не менялся.

## Согласие

- Слот 0 → `LmxCallable`, не префикс `[1]/[2]` у M (автор + оба помощника).
- Запись **разделяется** при copy/merge, как METHOD; тело не клонируется, активация на стеке (автор).
- В графе **нет имён**; таблицу адрес→имя не использовать (автор).
- `return_arg` — `@: Lmx`, ссылка на Structure трейлера, не own-поле формала.

## Факты, закрытые в `dev/` после ответов

- Копировщик считал терминалом только METHOD → CALLABLE давал `COPY_INVALID`. В `lmx_copy_is_terminal` добавлен kind 16; корень-копии CALLABLE тоже отказ.
- `lmx_interp_run` сравнивал `lmx_call_ready == 0` как ошибку, хотя `LMX_CALL_OK` = 0. Исправлено на `!= LMX_CALL_OK`.

## После REPOLL (lmx_uds напечатал fable целиком)

Оба живы: `lmx_uds` pid 13840, `fable` pid 4300. Fable: в графе пока **нет узлов операторов** (`l2trans` кладёт только данные). Поэтому полный обход `info.body` не выдумывать.

Сделано в песочнице следом: `LmxMethod` — первый член `LmxCallable`; `lmx_call_method` ветвится по виду; `lmx_callable_new_owned`; `lmx_interp_run` не требует body, если есть `return_arg`; selftest `tests/lmx_callable_selftest.lm1`.

## Ещё открыто

- Ранний `return:` внутри тела — обычный узел обхода, не только `return_arg`.
- Код адресует слоты **по индексу от `node`**, не указателями в хранилище конкретной копии M (`lmx_uds`).
- `l2trans` всё ещё кладёт в слот 0 `lmx_method_new_owned` — конструктор `LmxCallable` в трансляторе не подключён.
- Полный обход `info.body` ещё не написан.
