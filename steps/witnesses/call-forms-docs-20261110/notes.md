# Документация 343: запись вызова и объявлений (2026-11-10)

Шаг документации по решениям автора 2026-11-09/10 ([журнал](../../../LMX_blog/2026-11-09.md): «Новые формы…»,
«Способы вызова», «Основная форма вызова f(args)», ответы о ресиверах, «Чередование скобок», «Аргументы fn в круглых
скобках», граница `A: {}`). Код языка не менялся; реализация новых форм — [M6](../../../next_core_tasks_v3.md#m6),
OPEN.

## Что изменено

- Книга `provenance/semantics-book.md`: раздел «Запись вызова и сокращение аргументов» (`call-forms`, три способа
  автора с примерами 24 / `Hello, Ann` / 7, `f():` как редкое оформление), `f: 3` не вызов, ресиверы не затронуты и
  допускают круглые скобки (`int(5)` = `int: 5`), объявления `name: fn: return args <var body>`, компактная запись
  `f: fn: int (arg: int) {variable: int} {body: int}`, уровни не закрываются без нужды (`return` как trailer),
  граница `A: {}` = `A{}` только для завершённой короткой формы, `catch` с внешним именем, пример t2 и прочие примеры в
  новой записи, рекомендация чередования скобок. Восстановлен паритет абзацев RU/EN в 8 главах (нарушен WIP-коммитом
  v2 8291f7c9): values, fields, descriptions, construction, callables, arrays, mathematics, composition.
- Рендер docs/LMX_semantics.{ru,en}.md; `provenance/semantics-inventory.json` без выдержки l1 11263–11270 главы
  transport (её вставку убрал ещё WIP v2).
- Пояснения RU/EN (`fn-declaration`, `call-forms`), L1/L2, требования (новый §9), READ.ME, инструкция L2/L3, план
  (M6, §8b), `steps/current.md`.
- Грамматика `last_version` RU/EN (§§2, 10, 12, 14, 16–18, 22, 24–26; метка вызова P0, `call_layout_frame`,
  безымянная голова, анонимная круглая Structure). Остальные документы `last_version` перегенерированы из docs
  обратной заменой ссылок `new_` (проверена обратимость).
- `provenance/grammar.json`: раздел 2 перенесён в редакцию 4 (с подразделом `name-visibility`); остальные разделы
  docs/LMX_grammar ещё рендерят прежнюю редакцию — M6.7.
- `selfbuild/tools/docs_check_opening.lm2`: открытие автора ищется на границе абзаца после шапки редакции 4, паритет
  абзацев RU/EN считается от маркера `<!-- semantics-toc -->`.

## Команды и результаты (P = build2/codex_fix250generationchain01, S = P/cold-graph309-codex01)

```text
(cd P/runs/opus343) S/boot342/lmxtool.exe 0 entry 0 -- manifest|stage-copy|verify  -> source44, 404 входа,
    отличается от source43 только tools/docs_check_opening.lm2 (pins/opus343-stage44.log)
S/boot342/lmxtool.exe 0 entry 0 -- build-self R S B S/boot342/g2/frontend/l2trans.exe S/rt68/driver.o tool43
    -> exit 0, S/tool43/lmxtool-tool.exe ef4a998ce4f56fb02222a2e0f9d17afdc8d8f9a2ef047bdea97f76da2942f439
docs render semantics (boot342, pins/docs71-render*.command): 1..3 FAIL (вставка {{ в A{{}}; паритет абзацев;
    ссылки главы fields), 4 OK — 35 глав, 14 случаев implements
docs render grammar (boot342, pins/docs71-grammar.command): 27 разделов, 47 выдержек
docs check (tool43, pins/docs71-check*.command): 1 FAIL (ссылка на LMX_grammar#name-visibility), 2 OK — 35 глав,
    27 разделов, 44 дословные выдержки, 615 импортов, ссылки, открытие автора, LF во всех 25717 файлах индекса
```

`git diff --check` отмечает только хвостовые пробелы внутри дословных цитат автора в журнале; они сохранены.
