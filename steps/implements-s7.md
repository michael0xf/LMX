# S7: первый срез `implements` — точка вызова на identity

STARTED grok/implements-s7, база main `fd074ca`. Тикета без `DONE` нет (20260925-01 закрыт). T5–T7 посажены, REVIEW c713873 OK. D-36 не восстанавливать. D-81 не этот срез. Q31 и Q32 закрыты. Третьего графа нет.

## Что уже измерено в прежнем трансляторе

`lingvamyxa_prev/lm2/trans_l1_namespace.lm2`:

- `lm_trans_admit_implements` :2679–:2680. `candidate_descriptor = required_descriptor` → успех (`return: 0`) до вызова `lm_trans_descriptor_implements`. Обхода полей нет. Runtime-теста нет.
- `lm_trans_descriptor_implements` :572–:577. Пустые structural fields у required или у consumer → успех внутри самой функции, после того как её вызвали.
- `lm_trans_admit_consumer_uses` :801–:807. Обход `uses` уже выполнен. `path_count = 0` → успех до `lm_trans_admit_implements`, если у обоих дескрипторов нет `indexed-members`.

Текущий LMX повторяет те же два ранних успеха:

- `dev/l2src_sandbox/l2trans.lm1` `l2_admit_implements` :10190–:10191, `cand = req` до `l2_descriptor_implements`.
- `l2_admit_consumer_uses` :10223–:10224, `path_count = 0` до `l2_admit_implements`.

Вызов `l2_descriptor_implements(cand, req, req)` на пустом `uses`, когда индексы разные, сравнил бы все поля required и отказал бы случай, который спека 2.1 считает истинным. Отказ даёт третий аргумент `req`, не точка вызова (REVIEW ae4fcc4 п.1): `l2_descriptor_implements` при `cons_n = 0` возвращает успех внутри функции. Пустой `uses` идёт в тот же вызов с Consumer без полей: третий аргумент `l2_ns_n`, у этого индекса нет строк, `cons_n = 0`, успех внутри функции. Непустой `uses` по-прежнему передаёт `req`.

## Срез 1 — посажен

`l2_admit_implements` вызывает `l2_descriptor_implements` и при `cand = req` возвращает успех после вызова. Пустой `uses` остаётся ранним успехом в `l2_admit_consumer_uses`. Обход с третьим аргументом `req` туда не ставится: он отказал бы истинный пустой `uses`.

Свидетель `unit_s7_identity.lm2`, Entry 7. `keep(User)`: атом аргумента — имя Structure, поэтому `cand = req`. `slot\equals` делает `uses` непустым, и вызов admission происходит. Гейт: build 282/282 (`build/l2src/20260926_083021`), harness 421/421 (`build/l2_harness/s7id2`), L3 11/11, имена 69/128, check_docs OK.

Мутант: в начале `l2_descriptor_implements` при `cand = req` вернуть 1. `unit_s7_identity.lm2:15` — «malformed implements descriptor», frame=keep, exit 1. Откат: тот же файл переводится, exit 0. Живой исходник мутантом не оставался: правка была в копии evidence.

Ядро не менялось. Близнецы: `dev/l2src_sandbox/l2trans.lm1` и `l2src/l2trans.lm1`, фикстура в обоих `tests/`.

## Пустой uses — через тот же вызов

`l2_admit_implements` принимает Consumer. Непустой `uses` и отсутствие кадра передают `req`. Пустой `uses` передаёт `l2_ns_n`: у этого индекса нет полей, `l2_descriptor_implements` видит `cons_n = 0` и возвращает успех внутри вызова. `Plain` без `equals` допускается в `Equatable`, пока тело `take` не читает поле.

Свидетель `unit_s7_empty.lm2`, Entry 7: `take(Plain)` → 4. `unit_s7_identity` остаётся Entry 7. `unit_invalid_implements_used_field` по-прежнему «implements is false in function argument». Гейт: build 282/282 (`build/l2src/20260926_085629`), harness 422/422 (`build/l2_harness/s7empty`), L3 11/11, имена 69/128, check_docs OK.

Мутант: в `l2_descriptor_implements` при `cons >= l2_ns_n` вернуть 1. `unit_s7_empty.lm2:18` — «malformed implements descriptor», frame=take, exit 1. `unit_s7_identity` при этом мутанте переводится. Откат: `unit_s7_empty` переводится, exit 0. Живой исходник мутантом не оставался.

## Непустой uses — пути, которые прочитаны

`l2_descriptor_used` берёт первый сегмент каждого пути. Имя, которое есть у required и нет у кандидата, — отказ. Поле required, которое тело не читало, в проверку не входит. В таблицу структур этот список не пишется. `slot\a\b` проверяет наличие `a`; вложенное `b` и тип поля не сравниваются. Это грубость S3 (§7: внутренний `T` не проверяется). Её закрывает порт receiving-expression admission (ANSWER dfee18c-2).

65-й различный путь не отбрасывается: `l2_uses_full` и located «a uses list is full» (ANSWER dfee18c-1). Повтор уже записанного пути лимит не занимает. `unit_s7_uses64` — Entry 7. `unit_s7_uses65.lm2:140` — отказ, frame=take. Мутант: не ставить `l2_uses_full` — `unit_s7_uses65` переводится, exit 0. Откат — снова отказ. Гейт этой посадки: build 282/282 (`build/l2src/20260926_092533`), harness 425/425 (`build/l2_harness/s7full`), L3 11/11, имена 69/128, check_docs OK.

Свидетель `unit_s7_used.lm2`, Entry 7: `Plain` имеет `equals` и не имеет `extra`, `take` пишет `slot\equals`, `take(Plain)` → 4. До среза тот же текст отказывал «implements is false in function argument» (Consumer был всем `Equatable`). `unit_invalid_implements_used_field` по-прежнему отказывает: `Plain` не имеет прочитанного `equals`. `unit_s7_empty` и `unit_s7_identity` остаются Entry 7. Гейт: build 282/282 (`build/l2src/20260926_090918`), harness 423/423 (`build/l2_harness/s7used`), L3 11/11, имена 69/128, check_docs OK.

Мутант: `l2_descriptor_used` сразу возвращает 1. `unit_s7_used.lm2:19` и `unit_s7_identity.lm2:15` — «malformed implements descriptor» (frame=take и frame=keep), exit 1. `unit_s7_empty` переводится. Откат: `unit_s7_used` переводится, exit 0. Живой исходник мутантом не оставался.

## Список путей — одна функция (ANSWER c35e3da-1)

Допуск после `l2_uses_walk_frame` идёт в `l2_admit_paths`: Consumer — сам буфер путей, `req` третьим аргументом не передаётся, `l2_ns_n` не передаётся. Ноль путей — успех в `l2_descriptor_used`. Непустой список сверяет прочитанные имена. Кадра нет — списка путей нет, остаётся `l2_descriptor_implements` по дескриптору. Явный `implements(candidate, required, consumer)` тоже на дескрипторе.

Мутант: `l2_admit_paths` снова зовёт `l2_descriptor_implements(cand, req, req)`. `unit_s7_empty.lm2:18` и `unit_s7_used.lm2:19` — «implements is false in function argument», frame=take. `unit_s7_identity` переводится. Откат: `unit_s7_used` переводится. Гейт: build 282/282 (`build/l2src/20260926_093437`), harness 425/425 (`build/l2_harness/s7paths2`), L3 11/11, имена 69/128, check_docs OK.

## Вложенный путь и вид листа (тикет 20260926-03)

До среза `slot\in\x` при отсутствии `x` у кандидата переводился, и лист `size_t` против `int` тоже переводился (прогон `build/l2_harness/s7paths2/bin/l2trans.exe`). Теперь каждый сегмент, который required объявляет, обязателен у кандидата. Поле kind 3 спускает пару в `l2_nsf_ref`. Последний сегмент сравнивает `l2_nsf_kind`. Имени нет у required на этом уровне — сегмент не входит в Consumer.

`unit_s7_nested_ok` — Entry 7 (identity). `unit_s7_nested_shape` — Entry 7, кандидат `Other` не `Outer`: то же `Inner\x` и непрочитанный `extra` (ANSWER d7bc07f-1). `unit_s7_nested_missing.lm2:25` и `unit_s7_leaf_kind.lm2:17` — «implements is false in function argument», frame=take. Непрочитанное поле по-прежнему не требуется (`unit_s7_used`). Мутант без спуска: `unit_s7_nested_missing` переводится. Мутант без сравнения вида: `unit_s7_leaf_kind` переводится. Откат — оба отказа. Ядерный обход внутрь `ARRAY_OF_DESC` не этот срез. Гейт: build 282/282 (`build/l2src/20260926_102400`), harness 428/428 (`build/l2_harness/s7nest`), L3 11/11, имена 69/128, check_docs OK.

Мутант в начале `l2_descriptor_used` (до ветки нуля путей): `unit_s7_empty.lm2:18` frame=take, `unit_s7_used.lm2:19` frame=take, `unit_s7_identity.lm2:15` frame=keep — все «malformed implements descriptor», exit 1. Откат: `unit_s7_empty` переводится. Гейт: build 282/282 (`build/l2src/20260926_091745`), harness 423/423 (`build/l2_harness/s7paths`), L3 11/11, имена 69/128, check_docs OK.

## Срез 2, после среза 1

Таблица преобразований. Книга §6: контекст Message, явные данные, без процессного реестра и без наследования ребёнком. `lingvamyxa_prev/lm2/convert.lm2` — `table:` с именем `` `primitive.convert` ``, колонки from, to, forbidden, kind, receiver, impl. Это данные, не спрятанный список в трансляторе.

Автор (2026-09-26): таблицу и алгоритм `implements` брать из `lingvamyxa_prev`. Файл таблицы — `lm2/convert.lm2`, копия в `dev/l2src_sandbox/convert.lm2` и `l2src/convert.lm2`. Колонки from, to, forbidden, kind, receiver, impl. Это данные, не второй предикат `implements`.

Аналитический `implements` — тот, что в prev: `lm_trans_primitive_leaf_implements`, затем `lm_trans_descriptor_implements` (имя поля Consumer, которое есть у required, обязано быть у кандидата; пустой required или пустой Consumer — успех). В трансляторе это `l2_primitive_leaf_implements` и `l2_descriptor_implements`. Допуск по списку путей из `l2_uses_walk_frame` остаётся: Consumer — сами прочитанные пути. `implements` приёмник не вызывает.

Ребро присваивания двух разных именованных примитивов вставляет receiver строки, если forbidden = 0 и receiver не None. `size_t` → `int` — `lm_stg_convert_size_t_int` (kind sign). Значение 2 входит, `unit_s7_prim_cross` остаётся Entry 7. Одинаковое имя — прямая запись, вызова нет (`unit_s7_prim_same`). Нет строки — отказ, тихой записи нет. Строки harness «mixed numeric types» на корне не переворачивались: индекс и корень по-прежнему требуют уже подходящий тип.

## Результат вызова и путь поля (тикет 20260926-04)

Актуал, который не является голым именем Structure, больше не минует допуск. `l2_actual_ns` берёт тип результата вызова (`l2_nsty_get` callee, ключ -1) и тип поля пути (`l2_nsf_ref`, kind 3). Оба идут в `l2_admit_consumer_ix`: Consumer — буфер путей после `l2_uses_walk_frame`, не `req` и не `l2_ns_n`. Кадра у callee нет — `l2_admit_implements` по дескриптору required.

`unit_s7_arg_call_refused` — `take(mk())`, `mk` возвращает `Plain`, `take` читает `equals`: «implements is false in function argument», frame=take. `unit_s7_arg_call_ok` — `mk` возвращает `Rich` (`equals` и непрочитанный `extra`), Entry 7. `unit_s7_arg_path` — `take(h\p)`, тип поля `Plain`: та же фраза, frame=take. Trailer `return: h\p` эмиттер не диагностирует; `l2_check_ret_tr` отказывает «a Structure return must be a name» (`unit_s7_ret_path`). `return: Plain` и `return: h` переводятся.

Мутант: ветка кадра в `l2_actual_ns` возвращает 2. `unit_s7_arg_call_refused` переводится, exit 0. Откат — отказ `:20`, frame=take. Живой исходник мутантом не оставался.

Primitive fast path `l2_colon_types_compatible` против `l2_primitive_leaf_implements` этой строкой не закрыт. Ядро внутрь `ARRAY_OF_DESC` не этот срез. Таблица преобразований не начата. Гейт: build 282/282 (`build/l2src/20260926_114055`), harness 433/433 (`build/l2_harness/s7fast`), L3 11/11, имена 69/128, check_docs OK.

## Примитивный код — лист implements

Именованный код значения (`int` 0, `char` 1, `size_t` 2, `unsigned` 34, `ulong` 36, `void` 8) в `l2_colon_types_compatible` больше не решается числовым списком. Пара имён идёт в `l2_primitive_leaf_implements`. Указательный код туда не отображается: иначе `@: int` и `@: char` стали бы одной парой листьев. Литерал `-10`, quoted `-11` и код, у которого нет такого имени, остаются прежним списком. Это не второй предикат примитивов и не таблица `primitive.convert`.

Одинаковое имя — успех листа (`unit_s7_prim_same` Entry 7). Два keyed-листа — тоже успех листа, как `implements(int, u32)` (`unit_s7_prim_cross` Entry 7: `int` из `size_t`). Конвертер не вставляется. Ядро не менялось.

Мутант: одинаковое имя в `l2_primitive_leaf_implements` пишет 0. `unit_s7_prim_same.lm2:9` — «assignment value has incompatible type», frame=a. `unit_s7_prim_cross` на этом мутанте отказывает позже, на `k: go()` (тоже пара `int`), не на `a: b`. Мутант: успех разных keyed-листьев пишет 0. `unit_s7_prim_cross.lm2:10` — та же фраза, frame=a. `unit_s7_prim_same` при этом переводится. Откат — оба переводятся. Живой исходник мутантом не оставался. Ядро внутрь `ARRAY_OF_DESC` не этот срез. Таблица преобразований не начата. Гейт: build 282/282 (`build/l2src/20260926_120249`), harness 435/435 (`build/l2_harness/s7leaf`), L3 11/11, имена 69/128, check_docs OK.

REVIEW 61c2597-1 закрыт автором: форма строки — строка `convert.lm2`. `unit_s7_prim_cross` остаётся Entry 7 и зовёт `lm_stg_convert_size_t_int`. Мутант: успех разных keyed-листьев пишет 0. `unit_s7_prim_cross.lm2:10` — «assignment value has incompatible type», frame=a. Гейт: build 282/282 (`build/l2src/s7conv`), harness 444/444 (`build/l2_harness/s7conv`), L3 11/11, имена 69/128, check_docs OK.

## Return — полный дескриптор

Вызывающих на точке return нет, поэтому Consumer — сам required: `l2_admit_implements(cand, req, req)`. Одно правило для trailer и для тела. cand — тип имени, тип связанной переменной, тип результата вызова или тип одного поля Structure (`l2_nsf_ref`).

`unit_s7_ret_name` — `return: Plain` в `Equatable`: «implements is false in return value». `unit_s7_ret_call` — `return: mk()` при `mk () Plain`: та же фраза. `unit_s7_ret_body` — тот же отказ у indented `return:`. `unit_s7_ret_path` — `return: h\p` при поле `Plain`: та же фраза. `unit_s7_ret_rich` — `return: Rich` (`equals` и непрочитанный `extra`), `take` читает `equals`, Entry 7. `unit_s7_ret_field` — `return: h\p` при поле `Rich`, Entry 7. D-82 закрыт: поле Structure возвращается, фразы «a Structure return must be a name» нет.

Мутант: `l2_admit_return` сразу возвращает 0. `unit_s7_ret_name` переводится, exit 0. Откат — отказ `:12`, frame=fn. Живой исходник мутантом не оставался. Глубокий путь `take(h\a\p)` не этот срез. Таблица преобразований не начата. Гейт: build 282/282 (`build/l2src/20260926_122104`), harness 440/440 (`build/l2_harness/s7ret`), L3 11/11, имена 69/128, check_docs OK.

## Путь глубже одного поля (REVIEW 4812c2a-2)

`l2_actual_path` читает `name\seg\seg` любой нечётной длины от 3. Корень — связанное имя Structure. Каждый сегмент — поле kind 3; лист — `out_ni`. Нет имени — «unresolved name». Сегмент не Structure — «a field path must end at a Structure». Иначе 2, и прежняя проверка выражения остаётся. Допуск тот же `l2_admit_consumer_ix` / `l2_admit_implements(cand, req, req)`.

Значение — вложенный `lmx_arena_ref_struct` (`l2_emit_actual_path`). Один сегмент по-прежнему `lmx_arena_ref_struct(l2_p0_0, 0U)` (`unit_s7_ret_field`). Два сегмента — то же, вложенное.

`unit_s7_arg_deep` — `take(h\a\p)`, лист `Rich`, Entry 7. `unit_s7_arg_deep_refused` — лист `Plain`, «implements is false in function argument», frame=take. `unit_s7_ret_deep` — `return: h\a\p`, лист `Rich`, Entry 7. Мутант: `l2_actual_path` при span > 3 возвращает 2. `unit_s7_arg_deep_refused` переводится (ложный допуск). `unit_s7_ret_deep` — «implements is false in return value». `unit_s7_arg_path` остаётся прежним отказом. Откат — прежние исходы. Живой исходник мутантом не оставался. Ядро не менялось. Таблица преобразований не начата. `unit_s7_prim_cross` не переворачивался. Гейт: build 282/282 (`build/l2src/s7span`), harness 443/443 (`build/l2_harness/s7span2`), L3 11/11, имена 69/128, check_docs OK.
