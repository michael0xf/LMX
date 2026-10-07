# Голое поле `v: 9` как операнд merge

Статус: ОТКРЫТ, 2026-10-07. Случай нашёл Opus в переписи операндов merge (K03 S7); Codex задаёт вопрос автору
(K03-MERGE-OPERANDS-20261007-26, K03-MERGE-PARENT-20261007-27) и запретил выбирать чтение до ответа. Файл записал Opus.

## Вопрос

Что обозначает операнд `v: 9` в `A: merge(Model; v: 9)` для обычной модели `Model` с полем `int: v 1`?

```text
Model:
    int: v 1
end: Model
fn: m () int
    A: merge(Model; v: 9)
    return: A\v
end: m
sendMessage: exit(exit_code: m(); stdout: ""; stderr: "")
return
```

## Почему это вопрос, а не вывод

Три абзаца `docs/LMX_semantics.en.md`, дословно:

- `:1066` (#composition, «Composition of structural parts»): «`merge(add; y: 5)` puts the field `y` into the `body` of
  the method `add` (specialization: for the formal `y` of `add` that datum is its default value, below), while
  `merge((n: 5); addN)` puts the method `addN` inside the Structure holding `n` as a nested field -- the nested method
  is called as `w\addN(...)`, which differs from calling `w` itself. ... `n` in the body of `addN`, when no ordinary
  dynamic source supplies it, resolves by the lexical fallback to the enclosing Structure's field» — оба примера
  читают `имя: число`, написанное операндом (или внутри него), как поле с данными.
- `:666` (#resolved-head-consumption): «An unknown head retains general construction of a named Structure with its
  written contents without executing the body»; `:688` (#construction): «Unknown A in A: b declares Structure A, not a
  primitive variable whose type is inferred from b: the language has no var.»
- `:1062` (#composition, «Model slots»): «A field of a later operand or of the appended body that matches a model field
  (the match is known at translation: name and type; admission as for assignment) is written into the model's slot».

Чтения, между которыми документы не выбирают:

1. по `:1066`, обобщённому на обычную модель, `v: 9` даёт поле v с числом 9; его тип — тип слота модели (int) по
   `:1062`, `A\v` = 9; но тогда для `merge(Model; u: 9)` без совпадающего слота тип поля u ничем не задан, а выводить
   его из 9 `:688` запрещает;
2. по `:666`/`:688` `v: 9` определяет именованную Structure v с написанным содержимым 9; операнд — эта Structure; её
   имя v совпадает с int-полем модели по имени, но не по типу (`:1062`): добавить рядом? отказать?
3. описательная семантика `:1066` принадлежит только формалам callable-модели (значение по умолчанию y), а для
   обычной модели операнд `имя: значение` читается по 2.

Тот же ответ решает, что такое `(n: 5)` во втором примере `:1066`: поле n с числом 5 или Structure n.

## Что транслятор делает сейчас (измерено 2026-10-07, K03 S7, не норма)

- До S7 чтение операндов ведущими атомами молча отбрасывало `v: 9`: программа выше транслировалась как
  merge(Model) и возвращала 1 (дефект MERGE-LEADING-ATOMS, `steps/defects.md`).
- После S7 `v: 9` — один операнд, отказ у него: «this merge operand form is not lowered yet»
  (`unit_k03_merge_op_bare_field_limit` с двойником); значение не закреплено.
- Однозначная форма с объявленным типом — анонимная Structure `(int: v 9)`: `merge(Model; (int: v 9))` по `:1062`
  даёт `A\v` = 9, `merge((int: v 9); Other)` — модель с v 9. Это обязательный позитив `unit_k03_merge_op_anon_typed`
  с двойником, красный, пока не построен (MERGE-WRITTEN-OPERAND).
