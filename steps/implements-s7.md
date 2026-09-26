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

Вызов жирного `l2_descriptor_implements(cand, req, req)` на пустом `uses`, когда индексы разные, сравнил бы все поля required. Спека 2.1: пустой `uses` истинен. Такой вызов отказал бы случай, который сегодня проходит. Его не делаем.

## Срез 1 (этот план, код следующим коммитом)

Только identity, индексы совпали и `uses` уже непустой (иначе `l2_admit_implements` не вызывается).

В `l2_admit_implements` вызвать `l2_descriptor_implements` и при `cand = req` вернуть успех после вызова. Для равных индексов обход видит те же поля: `compatible` становится 1, отказ не появляется. Пустой `uses` остаётся ранним успехом в `l2_admit_consumer_uses`.

Свидетель — новое `unit_s7_identity.lm2`, успех Entry 7: два поля одного типа Structure, тело метода читает поле цели, затем присваивает одно другому. Сегодня этот путь возвращает успех на `cand = req` до вызова. После среза успех тот же.

Мутант: в начале `l2_descriptor_implements` при `cand = req` вернуть 1 (malformed). Свидетель становится «malformed implements descriptor». Откат — снова Entry 7. Так видно, что вызов стоит на пути.

Ядро не меняется. Близнецы: `dev/l2src_sandbox/l2trans.lm1` и `l2src/l2trans.lm1`, фикстура в обоих `tests/`.

## Срез 2, после среза 1

Таблица преобразований. Книга §6: контекст Message, явные данные, без процессного реестра и без наследования ребёнком. `lingvamyxa_prev/lm2/convert.lm2` — `table:` с именем `` `primitive.convert` ``, колонки from, to, forbidden, kind, receiver, impl. Это данные, не спрятанный список в трансляторе.

Вопрос автору (рекомендация в чате, очередь не ждёт): первый кодовый срез таблицы читает такую же `table:` из Structure файла — это данные корневого Message — и вставляет конвертер только при наличии строки. Нет строки — остаётся сегодняшний отказ «mixed numeric types (a conversion)». Тихого каста нет. `implements` конвертер не вызывает.

Пока форма таблицы не подтверждена, строки harness с «mixed numeric types» не переворачивать.
