# Имя строкой и одно требование результата — 2026-11-09

Исполнитель: opus. Основание — ответы Codex на вопросы RESULT 334 в сообщении CODEX-OPUS-QA-ONLY-20261109T110815Z-01
([копия](records/pins/codex-qa-only-answers.txt)), которое также передаёт организационное поручение автора: Codex
только отвечает на вопросы, срезы на ревью не отправляются ([steps/current.md](../../current.md)). Авторские формы —
[журнал 2026-11-09](../../../LMX_blog/2026-11-09.md): `fn: name: "test"; args: (); return: (); body: ()` и
`fn: name := "test"; args := (); return := (); body := ()`. Предыдущий срез: [334](../fn-binder-20261109/notes.md).

## Изменение

1. **Контракт имени.** `lmx_graph_name_value` (lmx_graph_run.lm2) — одно правило для части `name` любого ресивера:
   слово-идентификатор отвечает своим написанием, обычный строковый литерал — своим значением, иначе 0 (слово с
   кавычкой — широкий, символьный или испорченный литерал, int, Structure). `lmx_graph_string_value` декодирует значение
   по правилам C (грамматика §6): простые escape, до трёх восьмеричных цифр, `\x` с шестнадцатеричными цифрами, `\u` и
   `\U` — UTF-8 символа, обратная косая черта перед переносом склеивает строки; значение с нулевым байтом отклоняется
   (каноническое написание — C-строка); результат интернируется (§4). Им пользуются действие ресивера
   (`lmx_graph_receiver_make`) и записанное имя объявления (`lmx_graph_fn_decl_name` — resolve и транслятор). Прежде имя
   было словом с кавычками (`"test"`), и `test()` отвечал 3.
2. **Значение части для формала «как написано».** В `lmx_graph_receiver_bind` для `name` и `return` значение части по
   голове — её единственное записанное поле, значение `:=` — операнд (тело, которое построитель держит Structure, потому
   что оно не одно значение, читается своим полем). Прежде по голове и через `:=` приходил блок, державший форму
   (`return:` с `@: c.FILE` внутри), позиционно — сама форма; теперь все три дают одну часть `return` — ссылку на
   записанную форму типа. Формалы-Structure читаются по-прежнему одной моделью Frame (`lmx_graph_frame_value`).
3. **Пустое требование.** `return: ()` остаётся пустой Structure требования; исполнители исполняют результаты `int`
   (`lmx_graph_call_shape`), вызов такой функции отказывает 5 — граница реализации, не правило.

## Фикстуры

| Фикстура | Что | graph73 (SHA журналов interp / native / forced) |
|---|---|---|
| fn_named_supply (дополнена) | + `name := "t1"`, `name: "t2"`, `name := "t\x33"` | прежние 5, 12, 4, 42, 31, 2, 7, 9, 10, 6; t1(1) 101, t2(2) 202, t3(3) 303 (f6baf35c46b8 ×3) |
| fn_return_forms (новая) | p1 позиционно, p2 через `:=`, p3 по голове — требование `@: c.FILE`; копии R1–R3 merge | у R1, R2, R3 одна часть `@: return @` (b193e3942572 ×3) |
| fn_author_forms (новая, отр.) | обе авторские формы с `"test"`, `"test2"`, `return: ()` | `test()` — 5 (неизвестное имя дало бы 3), `before 1`, `after` не вычислен; native/forced — отрицательный R0 |

Пробы до правки (pins/opus335-rundir-probe-*): на graph72 R2 держал блок `return:` с `@: c.FILE`, R3 — ссылку на Frame
`return` (probe-return2-72.log); на graph73 — одинаковые части (probe-return2-73.log).

## Проверки

graph73/tool34/rt62 (`opus335-source29`, 396 входов; между source28 и source29 — только фикстуры и inputs.list):
`checks opus335-graph-check73.tsv` — `CHECKS 81 lines, 0 failed`, 243 PASS (11:18:14→11:19:41Z); `mutation` 12/12;
`method-mutation` 8/8; `sub_void_value` — `run answered 5`, `emit answered 5`, частичный L1 = graph58; девять
производственных модулей (`after73-*`) — журналы совпадают с graph64 после строки CWD.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus335.

- P/pins/opus335-source29.sha256, 396 входов: fc62d9ad008dbaa6cbe5a7dbcb89e6bb7fc9a79f9354943f2905bb2efd06051a
  (source28 f140dab231060ceb80fbffd7ea30218edaba80e37419552b77c4e9787c1b2623 — сборки).
- T34 = S/tool34/lmxtool-tool.exe: d6bc050516f6145d62647bce2a0d415602dd14a3848697144a038d78f0824950 (как в 334).
- S/rt62/driver.o: 7ac7f399b5b6b01cedca7213f61b05c2de8186a06cbf3a6e976faf99b5afccdb;
  driver-observe.o 07314bcc14ec364872559c41281869a2ce766c042b652ec7200c7cd3b42d0104.
- G73 = S/graph73/graph_trans-prod.exe: b8bde91c97f09bce41a4ac30a5c1f36008ae107011c39ca4cd9988fcfcf79ce6.

```text
T34 0 entry 0 -- build-runtime R S B F rt62
T34 0 entry 0 -- build-graph R S B F S/rt62 graph73
T34 0 entry 0 -- checks P/pins/opus335-graph-check73.tsv
G73 0 entry 0 -- mutation
G73 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
G73 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G73 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph73/sub-void-refused.lm1 native 1
G73 0 entry 0 -- run S/<production input> 1
```

OUT строк проверки — `S/check73-CASE`. Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA
LF-копий](records-lf.sha256); docs check и архивные журналы — [список](records2.list), [SHA](records2.sha256),
[SHA LF](records2-lf.sha256).

## Граница и следующее

1. Значения строк в графе — только контракт имени; общего примитива строки нет (слово хранит литерал как написан).
2. Широкие и символьные литералы именем не служат (5).
3. Ответ Codex 2: именованный оператор тела в `merge` нормы не меняет; общий merge не трогается.
4. Следующее — маршрут 331: F на runtime и машинный вход из чистого графа, первым модулем lmx_schedule.
