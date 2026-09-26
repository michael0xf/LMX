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

`l2_descriptor_used` берёт первый сегмент каждого пути. Имя, которое есть у required и нет у кандидата, — отказ. Поле required, которое тело не читало, в проверку не входит. В таблицу структур этот список не пишется.

Свидетель `unit_s7_used.lm2`, Entry 7: `Plain` имеет `equals` и не имеет `extra`, `take` пишет `slot\equals`, `take(Plain)` → 4. До среза тот же текст отказывал «implements is false in function argument» (Consumer был всем `Equatable`). `unit_invalid_implements_used_field` по-прежнему отказывает: `Plain` не имеет прочитанного `equals`. `unit_s7_empty` и `unit_s7_identity` остаются Entry 7. Гейт: build 282/282 (`build/l2src/20260926_090918`), harness 423/423 (`build/l2_harness/s7used`), L3 11/11, имена 69/128, check_docs OK.

Мутант: `l2_descriptor_used` сразу возвращает 1. `unit_s7_used.lm2:19` и `unit_s7_identity.lm2:15` — «malformed implements descriptor» (frame=take и frame=keep), exit 1. `unit_s7_empty` переводится. Откат: `unit_s7_used` переводится, exit 0. Живой исходник мутантом не оставался.

## Срез 2, после среза 1

Таблица преобразований. Книга §6: контекст Message, явные данные, без процессного реестра и без наследования ребёнком. `lingvamyxa_prev/lm2/convert.lm2` — `table:` с именем `` `primitive.convert` ``, колонки from, to, forbidden, kind, receiver, impl. Это данные, не спрятанный список в трансляторе.

Вопрос автору (рекомендация в чате, очередь не ждёт): первый кодовый срез таблицы читает такую же `table:` из Structure файла — это данные корневого Message — и вставляет конвертер только при наличии строки. Нет строки — остаётся сегодняшний отказ «mixed numeric types (a conversion)». Тихого каста нет. `implements` конвертер не вызывает. Отбор не по литеральному имени `` `primitive.convert` ``: это name-special (§0). Приёмник — по объявлению (тип таблицы или merge-ключ, §2.2.4), не по имени. Форму таблицы вопрос не предрешает. Глобальный реестр не заводится. Код таблицы не начат.

Пока форма таблицы не подтверждена, строки harness с «mixed numeric types» не переворачивать.
